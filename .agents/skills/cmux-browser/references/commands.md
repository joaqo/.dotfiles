# Command Reference (cmux Browser)

This maps common `agent-browser` usage to `cmux browser` usage.

## Direct Equivalents

- `agent-browser open <url>` -> `cmux browser open <url>`
- `agent-browser goto|navigate <url>` -> `cmux browser <surface> goto|navigate <url>`
- `agent-browser snapshot -i` -> `cmux browser <surface> snapshot --interactive`
- `agent-browser click <ref>` -> `cmux browser <surface> click <ref>`
- `agent-browser fill <ref> <text>` -> `cmux browser <surface> fill <ref> <text>`
- `agent-browser type <ref> <text>` -> `cmux browser <surface> type <ref> <text>`
- `agent-browser select <ref> <value>` -> `cmux browser <surface> select <ref> <value>`
- `agent-browser get text <ref>` -> `cmux browser <surface> get text <ref-or-selector>`
- `agent-browser get url` -> `cmux browser <surface> get url`
- `agent-browser get title` -> `cmux browser <surface> get title`

## Core Command Groups

Automation rule: do not call `cmux select-workspace` or other cmux focus commands before browser commands. Use caller context or explicit refs and operate on unfocused workspaces directly.

### Navigation

```bash
cmux browser open <url>                        # opens in caller's workspace (uses CMUX_WORKSPACE_ID)
cmux browser open <url> --workspace <id|ref>   # opens in a specific workspace
cmux browser open-split <url>                  # opens in a new split next to current surface
cmux browser <surface> goto <url>
cmux browser <surface> navigate <url> --snapshot-after   # goto alias with snapshot
cmux browser <surface> back|forward|reload
cmux browser <surface> get url|title
```

> **Workspace context:** `browser open` targets the workspace of the terminal where the command is run (via `CMUX_WORKSPACE_ID`), even if a different workspace is currently focused. Use `--workspace` to override.

### Snapshot and Inspection

```bash
cmux browser <surface> snapshot --interactive
cmux browser <surface> snapshot --interactive --compact --max-depth 3
cmux browser <surface> snapshot --selector "form#checkout" --interactive
cmux browser <surface> get text body
cmux browser <surface> get html body
cmux browser <surface> get value "#email"
cmux browser <surface> get attr "#email" --attr placeholder
cmux browser <surface> get count ".row"
cmux browser <surface> get box "#submit"
cmux browser <surface> get styles "#submit" --property color
cmux browser <surface> eval '<js>'

# Element state checks (no snapshot needed)
cmux browser <surface> is visible "#checkout"
cmux browser <surface> is enabled "button[type='submit']"
cmux browser <surface> is checked "#terms"

# Find elements by semantic role/label (alternative to snapshot refs)
cmux browser <surface> find role button --name "Continue"
cmux browser <surface> find text "Order confirmed"
cmux browser <surface> find label "Email"
cmux browser <surface> find placeholder "Search"
cmux browser <surface> find alt "Product image"
cmux browser <surface> find title "Open settings"
cmux browser <surface> find testid "save-btn"
cmux browser <surface> find first ".row"
cmux browser <surface> find last ".row"
cmux browser <surface> find nth 2 ".row"

# Screenshots
cmux browser <surface> screenshot                     # stdout base64
cmux browser <surface> screenshot --out /tmp/page.png # save to file
```

### Interaction

```bash
cmux browser <surface> click|dblclick|hover|focus <selector-or-ref>
cmux browser <surface> fill <selector-or-ref> [text]   # empty text clears
cmux browser <surface> type <selector-or-ref> <text>
cmux browser <surface> press|keydown|keyup <key>
cmux browser <surface> select <selector-or-ref> <value>
cmux browser <surface> check|uncheck <selector-or-ref>
cmux browser <surface> scroll [--selector <css>] [--dx <n>] [--dy <n>]
cmux browser <surface> scroll-into-view <selector>
```

### Wait

```bash
cmux browser <surface> wait --selector "#ready" --timeout-ms 10000
cmux browser <surface> wait --text "Done" --timeout-ms 10000
cmux browser <surface> wait --url-contains "/dashboard" --timeout-ms 10000
cmux browser <surface> wait --load-state complete --timeout-ms 15000
cmux browser <surface> wait --function "document.readyState === 'complete'" --timeout-ms 10000
```

### Session/State

```bash
cmux browser <surface> cookies get|set|clear ...
cmux browser <surface> storage local|session get|set|clear ...
cmux browser <surface> tab list|new|switch|close ...
cmux browser <surface> state save|load <path>
```

### JS/CSS Injection

```bash
cmux browser <surface> addinitscript "<js>"    # run on every new page load
cmux browser <surface> addscript "<js>"        # run once on current page
cmux browser <surface> addstyle "<css>"        # inject CSS into current page
```

### Dialogs and Frames

```bash
# Browser dialogs (alert/confirm/prompt)
cmux browser <surface> dialog accept
cmux browser <surface> dialog accept "Confirmed"
cmux browser <surface> dialog dismiss

# Switch into an iframe context for subsequent commands
cmux browser <surface> frame "iframe[name='checkout']"
cmux browser <surface> frame main   # return to main frame
```

### Downloads

```bash
cmux browser <surface> click "a#download-report"
cmux browser <surface> download --path /tmp/report.csv --timeout-ms 30000
```

### Diagnostics

```bash
cmux browser <surface> console list|clear
cmux browser <surface> errors list|clear
cmux browser <surface> highlight <selector>
```

## Agent Reliability Tips

- Use `--snapshot-after` on mutating actions to return a fresh post-action snapshot.
- Re-snapshot after navigation, modal open/close, or major DOM changes.
- Prefer short handles in outputs by default (`surface:N`, `pane:N`, `workspace:N`, `window:N`).
- Use `--id-format both` only when a UUID must be logged/exported.

## Known WKWebView Gaps (`not_supported`)

- `browser.viewport.set`
- `browser.geolocation.set`
- `browser.offline.set`
- `browser.trace.start|stop`
- `browser.network.route|unroute|requests`
- `browser.screencast.start|stop`
- `browser.input_mouse|input_keyboard|input_touch`

See also:
- [snapshot-refs.md](snapshot-refs.md)
- [authentication.md](authentication.md)
- [session-management.md](session-management.md)
