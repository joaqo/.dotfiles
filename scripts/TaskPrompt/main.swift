import AppKit
import SwiftUI

enum TaskMode {
    case large
    case small
}

@main
struct TaskPromptApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 550, height: 340),
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
    @Published var runMobile = false
    @Published var runWeb = true
    @Published var setupBackend = false
    let window: NSWindow

    init(window: NSWindow) {
        self.window = window
    }

    func submit(mode: TaskMode) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Write prompt to temp file
        let tempPath = "/tmp/company-task-prompt.txt"
        try? trimmed.write(toFile: tempPath, atomically: true, encoding: .utf8)

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
        }

        // Launch in iTerm
        openInITerm(command: cmd)

        NSApplication.shared.terminate(nil)
    }

    func cancel() {
        NSApplication.shared.terminate(nil)
    }

    private let paneStateFile = "/tmp/iterm-task-panes.txt"

    private func readPaneState() -> [String] {
        guard let content = try? String(contentsOfFile: paneStateFile, encoding: .utf8) else { return [] }
        return content.split(separator: "\n").map(String.init).filter { !$0.isEmpty }
    }

    private func savePaneState(_ ids: [String]) {
        try? ids.joined(separator: "\n").write(toFile: paneStateFile, atomically: true, encoding: .utf8)
    }

    private func runAppleScript(_ source: String) -> String? {
        guard let script = NSAppleScript(source: source) else { return nil }
        var error: NSDictionary?
        let result = script.executeAndReturnError(&error)
        return result.stringValue
    }

    private func openInITerm(command: String) {
        let esc = command
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")

        var sessionIds = readPaneState()
        if sessionIds.count >= 8 { sessionIds = [] }

        let count = sessionIds.count
        var newId: String? = nil

        if count > 0 {
            let targetIndex: Int
            let direction: String

            if count < 4 {
                // Vertical splits (tree pattern for even widths)
                // count 1,2: split S1 | count 3: split S2
                targetIndex = count == 3 ? 1 : 0
                direction = "vertically"
            } else {
                // Horizontal splits: visual L→R order [S1, S3, S2, S4] = indices [0, 2, 1, 3]
                targetIndex = [0, 2, 1, 3][count - 4]
                direction = "horizontally"
            }

            let targetId = sessionIds[targetIndex]
            newId = runAppleScript("""
            set cmdText to "\(esc)"
            tell application "iTerm"
                tell current window
                    set originalTab to current tab
                    repeat with aTab in tabs
                        repeat with aSession in sessions of aTab
                            if id of aSession is "\(targetId)" then
                                tell aSession
                                    set newSession to (split \(direction) with default profile)
                                end tell
                                tell newSession
                                    write text cmdText
                                    set newId to id
                                end tell
                                select originalTab
                                return newId
                            end if
                        end repeat
                    end repeat
                end tell
            end tell
            """)
        }

        // New tab if no panes yet or split failed (session gone)
        if newId == nil {
            sessionIds = []
            newId = runAppleScript("""
            set cmdText to "\(esc)"
            set itermWasRunning to application "iTerm" is running

            tell application "iTerm"
                if not itermWasRunning then
                    launch
                    delay 0.5
                    tell current session of current window
                        write text cmdText
                        return id
                    end tell
                else
                    tell current window
                        set originalTab to current tab
                        set newTab to (create tab with default profile)
                        tell current session of newTab
                            write text cmdText
                            set newId to id
                        end tell
                        select originalTab
                        return newId
                    end tell
                end if
            end tell
            """)
        }

        if let id = newId {
            sessionIds.append(id)
            savePaneState(sessionIds)
        }
    }
}

struct PromptView: View {
    @ObservedObject var vm: ViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            SubmittableTextEditor(
                text: $vm.text,
                onSubmitLarge: { vm.submit(mode: .large) },
                onSubmitSmall: { vm.submit(mode: .small) },
                onToggle: { index in
                    switch index {
                    case 1: vm.runMobile.toggle()
                    case 2: vm.runWeb.toggle()
                    case 3: vm.setupBackend.toggle()
                    default: break
                    }
                }
            )
                .font(.system(size: 13, design: .monospaced))
                .focused($isFocused)

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

                Text("\u{23CE} large \u{00B7} \u{2318}\u{23CE} small")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            HStack {
                Spacer()
                Button("Cancel") { vm.cancel() }
                    .keyboardShortcut(.cancelAction)
                Button("Small") { vm.submit(mode: .small) }
                Button("Large") { vm.submit(mode: .large) }
                    .keyboardShortcut(.defaultAction)
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
    let onToggle: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmitLarge: onSubmitLarge, onSubmitSmall: onSubmitSmall, onToggle: onToggle)
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
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {}

    class Coordinator: NSObject, NSTextViewDelegate, SubmitHandler {
        @Binding var text: String
        let onSubmitLarge: () -> Void
        let onSubmitSmall: () -> Void
        let onToggle: (Int) -> Void
        weak var textView: NSTextView?

        init(text: Binding<String>, onSubmitLarge: @escaping () -> Void, onSubmitSmall: @escaping () -> Void, onToggle: @escaping (Int) -> Void) {
            _text = text
            self.onSubmitLarge = onSubmitLarge
            self.onSubmitSmall = onSubmitSmall
            self.onToggle = onToggle
        }

        func textDidChange(_ notification: Notification) {
            guard let tv = textView else { return }
            text = tv.string
        }

        func submitLarge() { onSubmitLarge() }
        func submitSmall() { onSubmitSmall() }
        func toggle(_ index: Int) { onToggle(index) }
    }
}

protocol SubmitHandler: AnyObject {
    func submitLarge()
    func submitSmall()
    func toggle(_ index: Int)
}

class SubmittableNSTextView: NSTextView {
    weak var submitHandler: SubmitHandler?

    override func keyDown(with event: NSEvent) {
        let isReturn = event.keyCode == 36
        let isShift = event.modifierFlags.contains(.shift)
        let isCmd = event.modifierFlags.contains(.command)

        if isReturn && isCmd {
            submitHandler?.submitSmall()
            return
        }

        if isReturn && !isShift {
            submitHandler?.submitLarge()
            return
        }

        // Cmd+1/2/3 toggle checkboxes
        if isCmd, let chars = event.charactersIgnoringModifiers {
            switch chars {
            case "1": submitHandler?.toggle(1); return
            case "2": submitHandler?.toggle(2); return
            case "3": submitHandler?.toggle(3); return
            default: break
            }
        }

        super.keyDown(with: event)
    }
}
