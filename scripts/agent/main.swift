import AppKit
import SwiftUI

struct TaskImage: Identifiable {
    let id = UUID()
    let image: NSImage
    let path: String
}

@main
struct LauncherApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Agent"
        window.level = .floating
        window.center()
        window.isReleasedWhenClosed = false

        let viewModel = ViewModel(window: window)
        window.contentView = NSHostingView(rootView: PromptView(vm: viewModel))
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(window.contentView)

        // Edit menu so Cmd+A/C/V/X/Z work
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
    @Published var images: [TaskImage] = []
    let window: NSWindow
    private var imageCounter = 0
    private let imageDir = "/tmp/agent-images"

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

    func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Build prompt with embedded image paths
        var prompt = trimmed
        if !images.isEmpty {
            prompt += "\n\n---\nImages (use the Read tool to view each one):\n"
            for img in images {
                prompt += "- \(img.path)\n"
            }
        }

        // Shell-escape the prompt
        let escaped = prompt.replacingOccurrences(of: "'", with: "'\\''")

        let systemPromptPath = "$HOME/.dotfiles/scripts/agent/system-prompt.md"

        // Write a small wrapper script to capture claude output and notify
        let logFile = "$HOME/.dotfiles/scripts/agent/logs/agent.log"
        let script = """
        #!/bin/bash -l
        log() { echo "$@" >> \(logFile); }
        log "=== $(date) ==="
        log "PROMPT: \(escaped)"
        log "---"
        output=$(claude -p '\(escaped)' --system-prompt "$(cat \(systemPromptPath))" --no-session-persistence 2>&1)
        log "$output"
        short=$(echo "$output" | tail -1 | head -c 200)
        /opt/homebrew/bin/terminal-notifier -title "Agent" -message "$short" -sound Hero
        """
        let scriptPath = "/tmp/agent-run.sh"
        try? script.write(toFile: scriptPath, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", "nohup /tmp/agent-run.sh >/dev/null 2>&1 &"]
        try? process.run()

        NSApplication.shared.terminate(nil)
    }

    func cancel() {
        NSApplication.shared.terminate(nil)
    }
}

struct PromptView: View {
    @ObservedObject var vm: ViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            SubmittableTextEditor(
                text: .init(get: { vm.text }, set: { vm.text = $0 }),
                onSubmit: { vm.submit() },
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

            HStack {
                Spacer()
                Text("\u{23CE} submit \u{00B7} \u{21E7}\u{23CE} newline \u{00B7} Esc close")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .onAppear { isFocused = true }
    }
}

struct SubmittableTextEditor: NSViewRepresentable {
    @Binding var text: String
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
        textView.registerForDraggedTypes([.fileURL, .png, .tiff])
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {}

    class Coordinator: NSObject, NSTextViewDelegate, SubmitHandler {
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
            guard let tv = textView else { return }
            text = tv.string
        }

        func submit() { onSubmit() }
        func addImage(_ image: NSImage) { onAddImage(image) }
    }
}

protocol SubmitHandler: AnyObject {
    func submit()
    func addImage(_ image: NSImage)
}

class SubmittableNSTextView: NSTextView {
    weak var submitHandler: SubmitHandler?

    override var readablePasteboardTypes: [NSPasteboard.PasteboardType] {
        return super.readablePasteboardTypes + [.png, .tiff]
    }

    override func paste(_ sender: Any?) {
        let pb = NSPasteboard.general

        // Check for image file URLs first
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
        if let data = pb.data(forType: .png) ?? pb.data(forType: .tiff),
           let image = NSImage(data: data) {
            submitHandler?.addImage(image)
            return true
        }
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
        if event.keyCode == 53 {
            NSApplication.shared.terminate(nil)
            return
        }

        let isReturn = event.keyCode == 36
        let isShift = event.modifierFlags.contains(.shift)
        let isCmd = event.modifierFlags.contains(.command)

        if isReturn && !isShift && !isCmd {
            submitHandler?.submit()
            return
        }

        // Cmd+W close
        if isCmd, let chars = event.charactersIgnoringModifiers, chars == "w" {
            NSApplication.shared.terminate(nil)
            return
        }

        super.keyDown(with: event)
    }
}
