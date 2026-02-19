import AppKit
import SwiftUI

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
    @Published var text = ""
    let window: NSWindow

    init(window: NSWindow) {
        self.window = window
    }

    func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        print(trimmed)
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
            SubmittableTextEditor(text: $vm.text, onSubmit: vm.submit)
                .font(.system(size: 13, design: .monospaced))
                .focused($isFocused)

            HStack {
                Spacer()
                Button("Cancel") { vm.cancel() }
                    .keyboardShortcut(.cancelAction)
                Button("Run") { vm.submit() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .onAppear { isFocused = true }
    }
}

// Custom TextEditor that submits on Enter and inserts newline on Shift+Enter
struct SubmittableTextEditor: NSViewRepresentable {
    @Binding var text: String
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = SubmittableNSTextView()
        textView.delegate = context.coordinator
        textView.onSubmit = onSubmit
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
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {}

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        let onSubmit: () -> Void
        weak var textView: NSTextView?

        init(text: Binding<String>, onSubmit: @escaping () -> Void) {
            _text = text
            self.onSubmit = onSubmit
        }

        func textDidChange(_ notification: Notification) {
            guard let tv = textView else { return }
            text = tv.string
        }
    }
}

class SubmittableNSTextView: NSTextView {
    var onSubmit: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        let isReturn = event.keyCode == 36
        let isShift = event.modifierFlags.contains(.shift)

        if isReturn && !isShift {
            onSubmit?()
            return
        }
        super.keyDown(with: event)
    }
}
