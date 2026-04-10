import AppKit
import Foundation
import SwiftUI

private let agentPath = "\(NSHomeDirectory())/agent/agent"
private let logDir = "\(NSHomeDirectory())/.dotfiles/scripts/oneShot/logs"
private let launchPath = [
    "\(NSHomeDirectory())/.bun/bin",
    "\(NSHomeDirectory())/.local/bin",
    "\(NSHomeDirectory())/.dotfiles/bin",
    "/Applications/cmux.app/Contents/Resources/bin",
    "/opt/homebrew/bin",
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
    "/usr/sbin",
    "/sbin",
].joined(separator: ":")
private let schema = #"""
{
  "type": "object",
  "properties": {
    "skill": {
      "type": "string",
      "enum": ["task", "notion"]
    },
    "status": {
      "type": "string",
      "enum": ["ok", "error"]
    },
    "summary": {
      "type": "string"
    },
    "notes": {
      "type": ["string", "null"]
    },
    "data": {
      "type": "object",
      "properties": {
        "project": {
          "type": ["string", "null"]
        },
        "cwd": {
          "type": ["string", "null"]
        },
        "workspace": {
          "type": ["string", "null"]
        },
        "session": {
          "type": ["string", "null"]
        },
        "branch": {
          "type": ["string", "null"]
        },
        "prompt_source": {
          "type": ["string", "null"]
        },
        "launch_retried": {
          "type": ["boolean", "null"]
        }
      },
      "required": ["project", "cwd", "workspace", "session", "branch", "prompt_source", "launch_retried"],
      "additionalProperties": false
    },
    "error": {
      "type": ["string", "null"]
    }
  },
  "required": ["skill", "status", "summary", "notes", "data", "error"],
  "additionalProperties": false
}
"""#
private let systemPrompt = """
You are a non-interactive execution agent.

Your only job is to receive a single initial prompt from the user, route it correctly, and return a summary of what you did.

So for example if the iput is:
'find out why notifications are not sending correctly on my dotfiles swift agent'

You should NOT find out why the notifications are not sending correctly yourself. You should instead load the /task or $task skill which will instruct you on how to create a task for this request so another agent can work on it.

Default behavior:
- Delegate to a skill for every user request. Never implement the request yourself.
- The only valid routing destinations are /task and /notion.
- Use /notion only for requests that are clearly about saving, organizing, or managing things in Notion.
- Use /task for everything else.
- Do not do coding work yourself.
- Do not do non-coding work yourself either if it can be turned into a skill call.
- If the prompt includes attached image file paths, preserve those exact absolute paths when delegating.

You are basically a router, that receives instructions and then routes them to skills or other agents.

Examples:
- "Save this to notion" -> use /notion.
- "Create a task to debug this" -> use /task.
- "Open a page in the browser" -> use /task.
- "Review these pages and suggest improvements" -> use /task.
- "Whats our top selling user" -> use /task.
- A bare Notion link -> use /task.
- A Notion link plus implementation/review/debug wording -> use /task.

Anything that is not explicitly me asking you to createa or modify a notion -> use /task
Use /notion only when the user explicitly asks you to save, fetch, list, update, or organize data in Notion itself.
A lone Notion URL is not an explicit Notion-management request.
Your final answer must be JSON matching the schema.
It must describe what actually happened after you called the chosen skill.

Schema rules:
- Set `skill` to the skill you actually used: `task` or `notion`.
- Set `status` to `ok` or `error`.
- Set `summary` to a short plain-text summary.
- Set `notes` to short extra details when useful, otherwise null.
- Set `data` to an object. Use null field values when a fact is unavailable.
- Set `error` to the exact blocking error when there is one, otherwise null.

For /task:
- Run `task-run`.
- Inspect the real `task-run` output before filling the schema.
- Never claim task launch success unless the output proves it.
- When task launch succeeds, include verified fields in `data` when available, especially `session`, and also `workspace`, `cwd`, `branch`, `project` when present.
- When task launch fails, set `status` to `error` and propagate the exact error text.

For /notion:
- Fill the same schema after using the notion skill.

Do not ask follow-up questions.
Do not explain your reasoning.
Do not return analysis, chat, or filler.
You are only a router, you do simple routing tasks, you never tackle large tasks yourself.
If you're confused don't get creative, just exit out and return the issue you had.

Return JSON matching the provided schema.
"""

struct TaskImage: Identifiable {
    let id = UUID()
    let image: NSImage
    let path: String
}

@main
struct OneShotApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 380),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "One Shot"
        window.level = .floating
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.center()
        window.isReleasedWhenClosed = false

        let viewModel = ViewModel(window: window)
        window.contentView = NSHostingView(rootView: PromptView(vm: viewModel))
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(window.contentView)

        let mainMenu = NSMenu()
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)
        app.mainMenu = mainMenu

        app.activate(ignoringOtherApps: true)
        app.run()
    }
}

final class ViewModel: ObservableObject {
    @Published var text = ""
    @Published var images: [TaskImage] = []
    @Published var isRunning = false

    let window: NSWindow
    private var imageCounter = 0
    private let imageDir = FileManager.default.temporaryDirectory.appendingPathComponent("oneShot-images-\(UUID().uuidString)")

    init(window: NSWindow) {
        self.window = window
        try? FileManager.default.createDirectory(at: imageDir, withIntermediateDirectories: true)
    }

    func addImage(_ image: NSImage) {
        imageCounter += 1
        let path = imageDir.appendingPathComponent("\(imageCounter).png")
        guard
            let tiff = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:])
        else { return }

        do {
            try png.write(to: path)
            images.append(TaskImage(image: image, path: path.path))
        } catch {}
    }

    func removeImage(_ item: TaskImage) {
        try? FileManager.default.removeItem(atPath: item.path)
        images.removeAll { $0.id == item.id }
    }

    func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || !images.isEmpty || !isRunning else { return }

        isRunning = true
        window.orderOut(nil)
        let imagePaths = images.map(\.path)
        let prompt = buildPrompt(text: trimmed, imagePaths: imagePaths)

        DispatchQueue.global(qos: .userInitiated).async {
            self.runAgent(prompt: prompt, imagePaths: imagePaths)
        }
    }

    func cancel() {
        NSApplication.shared.terminate(nil)
    }

    private func buildPrompt(text: String, imagePaths: [String]) -> String {
        guard !imagePaths.isEmpty else { return text }
        let imageSection = imagePaths.map { "- \($0)" }.joined(separator: "\n")
        if text.isEmpty {
            return "Attached image file paths (inspect them directly):\n\(imageSection)"
        }
        return "\(text)\n\nAttached image file paths (inspect them directly):\n\(imageSection)"
    }

    private func runAgent(prompt: String, imagePaths: [String]) {
        let runId = "\(timestampForFilename())-\(ProcessInfo.processInfo.processIdentifier)"
        let runDir = FileManager.default.temporaryDirectory.appendingPathComponent("oneShot-run-\(UUID().uuidString)")
        let promptPath = runDir.appendingPathComponent("prompt.txt")
        let systemPromptPath = runDir.appendingPathComponent("system-prompt.md")

        try? FileManager.default.createDirectory(at: runDir, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(atPath: logDir, withIntermediateDirectories: true)
        try? prompt.write(to: promptPath, atomically: true, encoding: .utf8)
        try? systemPrompt.write(to: systemPromptPath, atomically: true, encoding: .utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: agentPath)
        process.currentDirectoryURL = URL(fileURLWithPath: NSHomeDirectory())
        process.environment = mergedEnvironment()
        process.arguments = [
            "exec",
            "conversational",
            "--system-prompt-file", systemPromptPath.path,
            "--schema", schema,
            "--ephemeral",
        ]

        let stdinPipe = Pipe()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardInput = stdinPipe
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        var stdoutData = Data()
        var stderrData = Data()
        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
            group.leave()
        }

        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
            group.leave()
        }

        var exitCode: Int32 = 1
        var launchError = ""

        do {
            try process.run()
            if let data = prompt.data(using: .utf8) {
                stdinPipe.fileHandleForWriting.write(data)
            }
            try? stdinPipe.fileHandleForWriting.close()
            process.waitUntilExit()
            exitCode = process.terminationStatus
        } catch {
            launchError = String(describing: error)
            try? stdinPipe.fileHandleForWriting.close()
        }

        group.wait()

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = launchError.isEmpty
            ? (String(data: stderrData, encoding: .utf8) ?? "")
            : launchError + "\n" + (String(data: stderrData, encoding: .utf8) ?? "")
        appendLog(
            runId: runId,
            prompt: prompt,
            imagePaths: imagePaths,
            stdout: stdout,
            stderr: stderr,
            exitCode: exitCode
        )

        if let notification = failureNotification(stdout: stdout, stderr: stderr, exitCode: exitCode) {
            notify(title: notification.title, message: notification.message)
        }

        try? FileManager.default.removeItem(at: runDir)

        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
    }

    private func appendLog(runId: String, prompt: String, imagePaths: [String], stdout: String, stderr: String, exitCode: Int32) {
        let imageSection = imagePaths.isEmpty ? "" : imagePaths.joined(separator: "\n")
        let entry = """
        === \(isoTimestamp()) \(runId) ===
        cwd: \(NSHomeDirectory())
        agent: \(agentPath)
        path: \(launchPath)
        images:
        \(imageSection)
        -- prompt --
        \(prompt)
        -- stdout --
        \(stdout)
        -- stderr --
        \(stderr)
        exit: \(exitCode)

        """

        let path = "\(logDir)/oneShot.log"
        if let data = entry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: path),
               let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: path)) {
                defer { try? handle.close() }
                _ = try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
            } else {
                try? data.write(to: URL(fileURLWithPath: path))
            }
        }
    }

    private func parseResponse(from stdout: String) -> [String: Any]? {
        guard let data = stdout.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    private func parseResult(from stdout: String) -> String? {
        guard let object = parseResponse(from: stdout) else { return nil }
        guard validateResponse(object) == nil else { return nil }
        guard let summary = object["summary"] as? String else { return nil }
        let trimmedSummary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSummary.isEmpty else { return nil }
        let status = (object["status"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        if status == "error", let error = object["error"] as? String {
            let trimmedError = error.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmedError.isEmpty ? trimmedSummary : "\(trimmedSummary): \(trimmedError)"
        }
        return trimmedSummary
    }

    private func validateResponse(_ object: [String: Any]) -> String? {
        guard let skill = object["skill"] as? String, skill == "task" || skill == "notion" else {
            return "Missing or invalid `skill`"
        }

        guard let status = object["status"] as? String, status == "ok" || status == "error" else {
            return "Missing or invalid `status`"
        }

        guard let summary = object["summary"] as? String, !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Missing or empty `summary`"
        }

        let notes = object["notes"]
        if !(notes == nil || notes is NSNull || notes is String) {
            return "Invalid `notes`"
        }

        guard let dataObject = object["data"] as? [String: Any] else {
            return "Invalid `data`"
        }

        let error = object["error"]
        if !(error == nil || error is NSNull || error is String) {
            return "Invalid `error`"
        }

        if status == "error" {
            guard let errorText = object["error"] as? String, !errorText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "Missing `error` for failed response"
            }
        }

        if skill == "task", status == "ok" {
            guard let session = dataObject["session"] as? String,
                  !session.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return "Missing `data.session` for successful task response"
            }
        }

        return nil
    }

    private func failureNotification(stdout: String, stderr: String, exitCode: Int32) -> (title: String, message: String)? {
        if let object = parseResponse(from: stdout) {
            if let validationError = validateResponse(object) {
                return ("Task Failed", clipped("Router returned invalid output: \(validationError)"))
            }
            let status = (object["status"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            if status == "error" {
                let message = parseResult(from: stdout) ?? fallbackResult(stdout: stdout, stderr: stderr, exitCode: exitCode)
                return ("Task Failed", clipped(message))
            }
            return nil
        }

        if exitCode == 0 {
            return ("Task Failed", "Router returned invalid output")
        }

        return ("Task Failed", clipped(fallbackResult(stdout: stdout, stderr: stderr, exitCode: exitCode)))
    }

    private func notify(title: String, message: String) {
        let cleanMessage = clipped(message.replacingOccurrences(of: "\n", with: " "))
        if FileManager.default.isExecutableFile(atPath: "/opt/homebrew/bin/terminal-notifier") {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/terminal-notifier")
            process.arguments = ["-title", title, "-message", cleanMessage, "-sound", "default"]
            try? process.run()
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = [
            "-e",
            "display notification \(appleScriptString(cleanMessage)) with title \(appleScriptString(title))"
        ]
        try? process.run()
    }

    private func appleScriptString(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
    }

    private func fallbackResult(stdout: String, stderr: String, exitCode: Int32) -> String {
        let trimmedStdout = stdout.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedStdout.isEmpty {
            return clipped(trimmedStdout)
        }

        let trimmedStderr = stderr.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedStderr.isEmpty {
            if let summary = summarizeFailure(from: trimmedStderr) {
                return summary
            }
            return clipped(trimmedStderr)
        }

        return exitCode == 0 ? "Done" : "agent exec failed (\(exitCode))"
    }

    private func summarizeFailure(from stderr: String) -> String? {
        let lines = stderr
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let preferredContains = [
            "invalid schema for response_format",
            "invalid_json_schema",
        ]

        for needle in preferredContains {
            if let line = lines.first(where: { $0.lowercased().contains(needle) }) {
                return clipped(line)
            }
        }

        let preferredPrefixes = [
            "codex failed:",
            "error:",
            "fatal:",
        ]

        for prefix in preferredPrefixes {
            if let line = lines.first(where: { $0.lowercased().hasPrefix(prefix) }) {
                return clipped(line)
            }
        }

        if let line = lines.last(where: { isUsefulFailureLine($0) }) {
            return clipped(line)
        }

        return nil
    }

    private func isUsefulFailureLine(_ line: String) -> Bool {
        let lowercased = line.lowercased()
        if lowercased.hasPrefix("openai codex v") { return false }
        if lowercased == "user" || lowercased == "exec" { return false }
        if lowercased.hasPrefix("workdir:") || lowercased.hasPrefix("model:") { return false }
        if lowercased.hasPrefix("provider:") || lowercased.hasPrefix("approval:") { return false }
        if lowercased.hasPrefix("sandbox:") || lowercased.hasPrefix("reasoning ") { return false }
        if lowercased.hasPrefix("session id:") || lowercased.hasPrefix("usage:") { return false }
        if lowercased.hasPrefix("commands:") || lowercased.hasPrefix("environment:") { return false }
        if lowercased.hasPrefix("/") { return false }
        if line.count > 220 { return false }
        return true
    }

    private func clipped(_ text: String, limit: Int = 220) -> String {
        guard text.count > limit else { return text }
        let index = text.index(text.startIndex, offsetBy: limit)
        return String(text[..<index]).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }

    private func isoTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: Date())
    }

    private func timestampForFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: Date())
    }

    private func mergedEnvironment() -> [String: String] {
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = launchPath
        environment["HOME"] = NSHomeDirectory()
        return environment
    }
}

struct PromptView: View {
    @ObservedObject var vm: ViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            SubmittableTextEditor(
                text: .init(get: { vm.text }, set: { vm.text = $0 }),
                isRunning: vm.isRunning,
                onSubmit: { vm.submit() },
                onAddImage: { image in vm.addImage(image) }
            )
            .focused($isFocused)

            if !vm.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(vm.images) { item in
                            ImageThumbnail(item: item, isRunning: vm.isRunning) {
                                vm.removeImage(item)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(height: 78)
            }
        }
        .padding(14)
        .background(.regularMaterial)
        .onAppear { isFocused = true }
    }
}

struct ImageThumbnail: View {
    let item: TaskImage
    let isRunning: Bool
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(nsImage: item.image)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.white, .black.opacity(0.7))
            }
            .buttonStyle(.plain)
            .offset(x: 5, y: -5)
            .disabled(isRunning)
        }
    }
}

struct SubmittableTextEditor: NSViewRepresentable {
    @Binding var text: String
    let isRunning: Bool
    let onSubmit: () -> Void
    let onAddImage: (NSImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit, onAddImage: onAddImage)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = SubmittableNSTextView()
        textView.delegate = context.coordinator
        textView.submitHandler = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .textColor
        textView.insertionPointColor = .textColor
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.registerForDraggedTypes([.fileURL, .png, .tiff])
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.autohidesScrollers = true
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 12, height: 10)
        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        if let textView = scrollView.documentView as? NSTextView {
            textView.isEditable = !isRunning
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate, SubmitHandler {
        @Binding var text: String
        let onSubmit: () -> Void
        let onAddImage: (NSImage) -> Void
        weak var textView: NSTextView?

        init(text: Binding<String>, onSubmit: @escaping () -> Void, onAddImage: @escaping (NSImage) -> Void) {
            _text = text
            self.onSubmit = onSubmit
            self.onAddImage = onAddImage
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            text = textView.string
        }

        func submit() {
            onSubmit()
        }

        func addImage(_ image: NSImage) {
            onAddImage(image)
        }
    }
}

protocol SubmitHandler: AnyObject {
    func submit()
    func addImage(_ image: NSImage)
}

final class SubmittableNSTextView: NSTextView {
    weak var submitHandler: SubmitHandler?

    override var readablePasteboardTypes: [NSPasteboard.PasteboardType] {
        super.readablePasteboardTypes + [.png, .tiff]
    }

    override func paste(_ sender: Any?) {
        let pasteboard = NSPasteboard.general

        if let urls = pasteboard.readObjects(
            forClasses: [NSURL.self],
            options: [
                .urlReadingFileURLsOnly: true,
                .urlReadingContentsConformToTypes: ["public.image"],
            ]
        ) as? [URL], !urls.isEmpty {
            for url in urls {
                if let image = NSImage(contentsOf: url) {
                    submitHandler?.addImage(image)
                }
            }
            return
        }

        if NSImage.canInit(with: pasteboard), let image = NSImage(pasteboard: pasteboard) {
            submitHandler?.addImage(image)
            return
        }

        super.paste(sender)
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        hasImageDrag(sender) ? .copy : super.draggingEntered(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        hasImageDrag(sender) ? .copy : super.draggingUpdated(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard

        if let data = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff),
           let image = NSImage(data: data) {
            submitHandler?.addImage(image)
            return true
        }

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] {
            let imageURLs = urls.filter { supportedImageExtensions.contains($0.pathExtension.lowercased()) }
            if !imageURLs.isEmpty {
                for url in imageURLs {
                    if let image = NSImage(contentsOf: url) {
                        submitHandler?.addImage(image)
                    }
                }
                return true
            }
        }

        return super.performDragOperation(sender)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            NSApplication.shared.terminate(nil)
            return
        }

        if event.keyCode == 36, !event.modifierFlags.contains(.shift), !event.modifierFlags.contains(.command) {
            submitHandler?.submit()
            return
        }

        if event.modifierFlags.contains(.command),
           let chars = event.charactersIgnoringModifiers,
           chars == "w" {
            NSApplication.shared.terminate(nil)
            return
        }

        super.keyDown(with: event)
    }

    private func hasImageDrag(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        if pasteboard.availableType(from: [.png, .tiff]) != nil { return true }
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] else {
            return false
        }
        return !urls.isEmpty && urls.allSatisfy { supportedImageExtensions.contains($0.pathExtension.lowercased()) }
    }

    private var supportedImageExtensions: Set<String> {
        ["png", "jpg", "jpeg", "gif", "webp", "tiff", "bmp", "heic"]
    }
}
