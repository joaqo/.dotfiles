import AppKit
import SwiftUI

enum TaskMode {
    case large
    case small
    case notion
}

struct TaskImage: Identifiable {
    let id = UUID()
    let image: NSImage
    let path: String
}

@main
struct TaskPromptApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "New task"
        window.level = .floating
        window.center()
        window.isReleasedWhenClosed = false

        let viewModel = ViewModel(window: window)
        window.contentView = NSHostingView(rootView: PromptView(vm: viewModel))
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(window.contentView)
        // Set up Edit menu so Cmd+A/C/V/X/Z work
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

class ViewModel: ObservableObject {
    var text = ""
    @Published var runMobile = false
    @Published var runWeb = false
    @Published var setupBackend = false
    @Published var images: [TaskImage] = []
    let window: NSWindow
    private var imageCounter = 0
    private let imageDir = "/tmp/task-images"

    init(window: NSWindow) {
        self.window = window
        try? FileManager.default.removeItem(atPath: imageDir)
        try? FileManager.default.createDirectory(atPath: imageDir, withIntermediateDirectories: true)
    }

    func addImage(_ image: NSImage) {
        imageCounter += 1
        let path = "\(imageDir)/\(imageCounter).png"
        if let tiff = image.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff),
           let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: URL(fileURLWithPath: path))
            images.append(TaskImage(image: image, path: path))
        }
    }

    func removeImage(_ item: TaskImage) {
        try? FileManager.default.removeItem(atPath: item.path)
        images.removeAll { $0.id == item.id }
    }

    func submit(mode: TaskMode) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Build prompt with embedded image paths
        var prompt = trimmed
        if !images.isEmpty {
            prompt += "\n\n---\nTask images (use the Read tool to view each one):\n"
            for img in images {
                prompt += "- \(img.path)\n"
            }
        }

        // Write prompt to temp file
        let tempPath = "/tmp/company-task-prompt.txt"
        try? prompt.write(toFile: tempPath, atomically: true, encoding: .utf8)

        // Build command
        var cmd: String
        switch mode {
        case .small:
            cmd = "cd ~/mellow && company task run --small -f \(tempPath); exit"
        case .large:
            var flags: [String] = []
            if runMobile { flags.append("--mobile") }
            if runWeb { flags.append("--web") }
            if setupBackend { flags.append("--backend") }
            let flagStr = flags.joined(separator: " ")
            cmd = "cd ~/mellow && company task run -f \(tempPath)"
            if !flagStr.isEmpty { cmd += " \(flagStr)" }
            cmd += "; exit"
        case .notion:
            let notionPrompt = "Create a Notion task from the following description. Use the 'company notion add' CLI command. Run 'company notion projects' first to pick the right project. Use --project and --body flags as appropriate.\n\nTask description:\n\(prompt)"
            let promptPath = "/tmp/company-notion-prompt.txt"
            try? notionPrompt.write(toFile: promptPath, atomically: true, encoding: .utf8)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = ["-lc", "cd ~/mellow && cat \(promptPath) | claude -p"]
            try? process.run()
            NSApplication.shared.terminate(nil)
            return
        }

        // Launch in iTerm
        openInITerm(command: cmd)

        NSApplication.shared.terminate(nil)
    }

    func cancel() {
        NSApplication.shared.terminate(nil)
    }

    private func runAppleScript(_ source: String) {
        guard let script = NSAppleScript(source: source) else { return }
        var error: NSDictionary?
        script.executeAndReturnError(&error)
    }

    private func openInITerm(command: String) {
        let esc = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        runAppleScript("""
        set cmdText to "\(esc)"
        set itermWasRunning to application "iTerm" is running

        tell application "iTerm"
            if not itermWasRunning then
                launch
                delay 0.5
                tell current session of current window
                    write text cmdText
                end tell
                return
            end if

            if not (exists current window) then
                create window with default profile
                tell current session of current window
                    write text cmdText
                end tell
                return
            end if

            tell current window
                set originalTab to current tab
                set bestTab to missing value
                set bestCount to 0

                -- Find tab with most sessions still under 8
                repeat with aTab in tabs
                    set sessionCount to count of sessions of aTab
                    if sessionCount < 8 and sessionCount > bestCount then
                        set bestCount to sessionCount
                        set bestTab to aTab
                    end if
                end repeat

                if bestTab is not missing value and bestCount > 0 then
                    set allSessions to sessions of bestTab
                    set sessionCount to count of allSessions

                    -- Find max rows (full terminal height)
                    set maxRows to 0
                    repeat with aSession in allSessions
                        if rows of aSession > maxRows then
                            set maxRows to rows of aSession
                        end if
                    end repeat

                    -- Count actual columns: full-height sessions are own column,
                    -- partial-height sessions are stacked (2 per column)
                    set fullHeightCount to 0
                    set partialCount to 0
                    repeat with aSession in allSessions
                        if rows of aSession ≥ (maxRows - 2) then
                            set fullHeightCount to fullHeightCount + 1
                        else
                            set partialCount to partialCount + 1
                        end if
                    end repeat
                    set columnCount to fullHeightCount + (partialCount + 1) div 2

                    if columnCount < 4 then
                        -- Add column: split last full-height session vertically
                        set targetSession to item 1 of allSessions
                        repeat with aSession in allSessions
                            if rows of aSession ≥ (maxRows - 2) then
                                set targetSession to aSession
                            end if
                        end repeat
                        tell targetSession
                            set newSession to (split vertically with default profile)
                        end tell
                    else
                        -- Add row: split first full-height session horizontally
                        set targetSession to missing value
                        repeat with aSession in allSessions
                            if targetSession is missing value and rows of aSession ≥ (maxRows - 2) then
                                set targetSession to aSession
                            end if
                        end repeat
                        if targetSession is missing value then
                            -- All columns split, find tallest session
                            set targetSession to item 1 of allSessions
                            set targetRows to rows of targetSession
                            repeat with aSession in allSessions
                                if rows of aSession ≥ targetRows then
                                    set targetSession to aSession
                                    set targetRows to rows of aSession
                                end if
                            end repeat
                        end if
                        tell targetSession
                            set newSession to (split horizontally with default profile)
                        end tell
                    end if

                    tell newSession
                        write text cmdText
                    end tell
                    select originalTab
                else
                    -- No suitable tab: create new tab
                    set newTab to (create tab with default profile)
                    tell current session of newTab
                        write text cmdText
                    end tell
                    select originalTab
                end if
            end tell
        end tell
        """)
    }
}

struct PromptView: View {
    @ObservedObject var vm: ViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            SubmittableTextEditor(
                text: .init(get: { vm.text }, set: { vm.text = $0 }),
                onSubmitLarge: { vm.submit(mode: .large) },
                onSubmitSmall: { vm.submit(mode: .small) },
                onSubmitNotion: { vm.submit(mode: .notion) },
                onToggle: { index in
                    switch index {
                    case 1: vm.runMobile.toggle()
                    case 2: vm.runWeb.toggle()
                    case 3: vm.setupBackend.toggle()
                    default: break
                    }
                },
                onAddImage: { image in vm.addImage(image) }
            )
                .font(.system(size: 13, design: .monospaced))
                .focused($isFocused)

            if !vm.images.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(vm.images) { item in
                            ZStack(alignment: .topTrailing) {
                                Image(nsImage: item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipped()
                                    .cornerRadius(4)
                                Button(action: { vm.removeImage(item) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.borderless)
                                .offset(x: 4, y: -4)
                            }
                            .padding(.top, 4)
                            .padding(.trailing, 4)
                        }
                    }
                }
                .frame(height: 44)
            }

            HStack(spacing: 16) {
                HStack(spacing: 12) {
                    Toggle("Mobile", isOn: $vm.runMobile)
                        .toggleStyle(.checkbox)
                    Toggle("Web", isOn: $vm.runWeb)
                        .toggleStyle(.checkbox)
                    Toggle("Backend", isOn: $vm.setupBackend)
                        .toggleStyle(.checkbox)
                }

                Spacer()

                Text("\u{2318}1/2/3 toggles \u{00B7} \u{23CE} large \u{00B7} \u{2318}\u{23CE} small \u{00B7} \u{2325}\u{23CE} notion")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .onAppear { isFocused = true }
    }
}

// Custom TextEditor that submits on Enter (large) and Cmd+Enter (small)
struct SubmittableTextEditor: NSViewRepresentable {
    @Binding var text: String
    let onSubmitLarge: () -> Void
    let onSubmitSmall: () -> Void
    let onSubmitNotion: () -> Void
    let onToggle: (Int) -> Void
    let onAddImage: (NSImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmitLarge: onSubmitLarge, onSubmitSmall: onSubmitSmall, onSubmitNotion: onSubmitNotion, onToggle: onToggle, onAddImage: onAddImage)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = SubmittableNSTextView()
        textView.delegate = context.coordinator
        textView.submitHandler = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        textView.drawsBackground = false
        context.coordinator.textView = textView
        // Register for image drag & drop
        textView.registerForDraggedTypes([.fileURL, .png, .tiff])
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {}

    class Coordinator: NSObject, NSTextViewDelegate, SubmitHandler {
        @Binding var text: String
        let onSubmitLarge: () -> Void
        let onSubmitSmall: () -> Void
        let onSubmitNotion: () -> Void
        let onToggle: (Int) -> Void
        let onAddImage: (NSImage) -> Void
        weak var textView: NSTextView?

        init(text: Binding<String>, onSubmitLarge: @escaping () -> Void, onSubmitSmall: @escaping () -> Void, onSubmitNotion: @escaping () -> Void, onToggle: @escaping (Int) -> Void, onAddImage: @escaping (NSImage) -> Void) {
            _text = text
            self.onSubmitLarge = onSubmitLarge
            self.onSubmitSmall = onSubmitSmall
            self.onSubmitNotion = onSubmitNotion
            self.onToggle = onToggle
            self.onAddImage = onAddImage
        }

        func textDidChange(_ notification: Notification) {
            guard let tv = textView else { return }
            text = tv.string
        }

        func submitLarge() { onSubmitLarge() }
        func submitSmall() { onSubmitSmall() }
        func submitNotion() { onSubmitNotion() }
        func toggle(_ index: Int) { onToggle(index) }
        func addImage(_ image: NSImage) { onAddImage(image) }
    }
}

protocol SubmitHandler: AnyObject {
    func submitLarge()
    func submitSmall()
    func submitNotion()
    func toggle(_ index: Int)
    func addImage(_ image: NSImage)
}

class SubmittableNSTextView: NSTextView {
    weak var submitHandler: SubmitHandler?

    // Include image types so Paste stays enabled when clipboard has images
    override var readablePasteboardTypes: [NSPasteboard.PasteboardType] {
        return super.readablePasteboardTypes + [.png, .tiff]
    }

    override func paste(_ sender: Any?) {
        let pb = NSPasteboard.general
        // Debug: log available pasteboard types
        let types = pb.types?.map { $0.rawValue }.joined(separator: "\n") ?? "none"
        try? types.write(toFile: "/tmp/paste-debug.txt", atomically: true, encoding: .utf8)

        // Check for image file URLs first (Finder copies have both URL + icon TIFF;
        // we want the actual file, not the icon)
        if let urls = pb.readObjects(forClasses: [NSURL.self], options: [
            .urlReadingFileURLsOnly: true,
            .urlReadingContentsConformToTypes: ["public.image"]
        ]) as? [URL], !urls.isEmpty {
            for url in urls {
                if let image = NSImage(contentsOf: url) {
                    submitHandler?.addImage(image)
                }
            }
            return
        }
        // Fall back to raw image data (screenshots, images copied from apps)
        if NSImage.canInit(with: pb), let image = NSImage(pasteboard: pb) {
            submitHandler?.addImage(image)
            return
        }
        super.paste(sender)
    }

    // Drag & drop support for image files
    private func hasImageDrag(_ sender: NSDraggingInfo) -> Bool {
        let pb = sender.draggingPasteboard
        if pb.availableType(from: [.png, .tiff]) != nil { return true }
        guard let urls = pb.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] else { return false }
        let imageExts: Set<String> = ["png", "jpg", "jpeg", "gif", "webp", "tiff", "bmp", "heic"]
        return !urls.isEmpty && urls.allSatisfy { imageExts.contains($0.pathExtension.lowercased()) }
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if hasImageDrag(sender) { return .copy }
        return super.draggingEntered(sender)
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if hasImageDrag(sender) { return .copy }
        return super.draggingUpdated(sender)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pb = sender.draggingPasteboard
        // Handle raw image data drops
        if let data = pb.data(forType: .png) ?? pb.data(forType: .tiff),
           let image = NSImage(data: data) {
            submitHandler?.addImage(image)
            return true
        }
        // Handle image file drops
        if let urls = pb.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] {
            let imageExts: Set<String> = ["png", "jpg", "jpeg", "gif", "webp", "tiff", "bmp", "heic"]
            let imageURLs = urls.filter { imageExts.contains($0.pathExtension.lowercased()) }
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
        // Escape to cancel
        if event.keyCode == 53 {
            NSApplication.shared.terminate(nil)
            return
        }

        let isReturn = event.keyCode == 36
        let isShift = event.modifierFlags.contains(.shift)
        let isCmd = event.modifierFlags.contains(.command)
        let isOption = event.modifierFlags.contains(.option)

        if isReturn && isCmd {
            submitHandler?.submitSmall()
            return
        }

        if isReturn && isOption {
            submitHandler?.submitNotion()
            return
        }

        if isReturn && !isShift {
            submitHandler?.submitLarge()
            return
        }

        // Cmd+W close, Cmd+1/2/3 toggle checkboxes
        if isCmd, let chars = event.charactersIgnoringModifiers {
            switch chars {
            case "w": NSApplication.shared.terminate(nil); return
            case "1": submitHandler?.toggle(1); return
            case "2": submitHandler?.toggle(2); return
            case "3": submitHandler?.toggle(3); return
            default: break
            }
        }

        super.keyDown(with: event)
    }
}
