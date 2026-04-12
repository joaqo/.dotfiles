---
name: cmux-browser
description: End-user browser automation with cmux. Use when you need to open sites, interact with pages, wait for state changes, and extract data from cmux browser surfaces.
---

# Browser Automation with cmux

Use this skill for browser tasks inside cmux webviews.

## Input Strategy

For text entry, default to `click` + `type`.

Assume `fill` is the wrong choice unless there is a specific reason to use it. In this setup, you should almost never use `fill`.

Why:
- `type` is the closest to human behavior.
- `type` produces the key-driven event sequence many apps depend on.
- `fill` jumps straight to the final value and can miss keypress-driven side effects, validation, formatting, autocomplete behavior, focus transitions, anti-bot checks, and other logic that only appears during real typing.
- In real products, you usually do not know which inputs have those side effects ahead of time.

Practical rule:
- Default: `click` the field, then `type`.
- Use `fill` only as an exception:
  - clearing a field with `fill ""`
  - deliberately replacing text in a clearly dumb/plain field when human-like behavior does not matter

If unsure, use `type`. Do not use `fill` just because it is shorter.

## Core Workflow

1. Open or target a browser surface.
2. Verify navigation with `get url` before waiting or snapshotting.
3. Snapshot (`--interactive`) to get fresh element refs — or use `find` if you know the element by role/label/text.
4. Act with refs (`click`, `type`, `press`, `select`; use `fill` only in the rare exception cases above).
5. Wait for state changes.
6. Re-snapshot after DOM/navigation changes.

```bash
cmux --json browser open https://example.com
# use returned surface ref, for example: surface:7

cmux browser surface:7 get url
cmux browser surface:7 wait --load-state complete --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
cmux browser surface:7 click e1
cmux browser surface:7 type e1 "hello"
cmux --json browser surface:7 click e2 --snapshot-after
cmux browser surface:7 snapshot --interactive
```

## Slow Pages And Replacement Policy

Browser surfaces can be slow to load or briefly time out. Do not assume a timeout means the page is stuck.

Rules:
- Stay on the same browser surface by default.
- If a browser command times out, retry on that same surface first.
- Spend about 30 seconds total retrying and waiting on the same surface before calling it stuck.
- Never respond to a slow page by opening extra browser pages or surfaces for the same task.
- If the surface is still stuck after ~30 seconds, close that surface first with `cmux close-surface --surface surface:N`.
- Only after closing the stuck surface may you open one replacement surface.
- Do not fan out multiple replacement browser surfaces for one stuck page.

## Flag Safety

For commands that take free-text positional args, especially `type` and the rarer `fill`, do not append flags after the text value.
If you need a fresh DOM state, run `snapshot` as a separate command after the action.

Wrong:

```bash
cmux browser surface:7 fill e11 "hello" --snapshot-after
cmux browser surface:7 type e11 "hello" --snapshot-after
```

Preferred:

```bash
cmux browser surface:7 type e11 "hello"
cmux browser surface:7 snapshot --interactive

# only when you specifically need to clear/replace:
cmux browser surface:7 fill e11 ""
cmux browser surface:7 snapshot --interactive
```

## Surface Targeting

```bash
# identify current context
cmux identify --json

# open routed to a specific topology target
cmux browser open https://example.com --workspace workspace:2 --window window:1 --json

# open in a new split next to the current surface
cmux browser open-split https://example.com
```

Notes:
- Treat `cmux browser open` as a routing/reuse command, not a topology command.
- If you need a guaranteed new visible browser context, use `cmux new-pane --type browser --url <url>` instead of `cmux browser open`.
- Never use `cmux browser open` to create a second browser for a task in a workspace that already has a browser pane.
- Route browser actions from `caller` context or explicit refs, not `focused`.
- The user often views another workspace while the agent works, so `focused` usually points at unrelated UI state.
- After opening a browser, verify workspace/pane/surface placement before continuing.
- CLI output defaults to short refs (`surface:N`, `pane:N`, `workspace:N`, `window:N`).
- UUIDs are still accepted on input; only request UUID output when needed (`--id-format uuids|both`).
- Keep using one `surface:N` per task unless you intentionally switch.

## Wait Support

cmux supports wait patterns similar to agent-browser:

```bash
cmux browser <surface> wait --selector "#ready" --timeout-ms 10000
cmux browser <surface> wait --text "Success" --timeout-ms 10000
cmux browser <surface> wait --url-contains "/dashboard" --timeout-ms 10000
cmux browser <surface> wait --load-state complete --timeout-ms 15000
cmux browser <surface> wait --function "document.readyState === 'complete'" --timeout-ms 10000
```

## Common Flows

### Form Submit

```bash
cmux --json browser open https://example.com/signup
cmux browser surface:7 get url
cmux browser surface:7 wait --load-state complete --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
cmux browser surface:7 click e1
cmux browser surface:7 type e1 "Jane Doe"
cmux browser surface:7 click e2
cmux browser surface:7 type e2 "jane@example.com"
cmux --json browser surface:7 click e3 --snapshot-after
cmux browser surface:7 wait --url-contains "/welcome" --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
```

### Clear an Input

```bash
cmux browser surface:7 fill e11 ""
cmux browser surface:7 snapshot --interactive
cmux browser surface:7 get value e11 --json
```

### Stable Agent Loop (Recommended)

```bash
# navigate -> verify -> wait -> snapshot -> action -> snapshot
cmux browser surface:7 get url
cmux browser surface:7 wait --load-state complete --timeout-ms 15000
cmux browser surface:7 snapshot --interactive
cmux --json browser surface:7 click e5 --snapshot-after
cmux browser surface:7 snapshot --interactive
```

If `get url` is empty or `about:blank`, navigate first instead of waiting on load state.

## Deep-Dive References

| Reference | When to Use |
|-----------|-------------|
| [references/commands.md](references/commands.md) | Full browser command mapping and quick syntax |
| [references/snapshot-refs.md](references/snapshot-refs.md) | Ref lifecycle and stale-ref troubleshooting |
| [references/authentication.md](references/authentication.md) | Login/OAuth/2FA patterns, why to prefer `type`, and state save/load |
| [references/authentication.md#saving-authentication-state](references/authentication.md#saving-authentication-state) | Save authenticated state right after login |
| [references/session-management.md](references/session-management.md) | Multi-surface isolation and state persistence patterns |
| [references/video-recording.md](references/video-recording.md) | Current recording status and practical alternatives |
| [references/proxy-support.md](references/proxy-support.md) | Proxy behavior in WKWebView and workarounds |

## Ready-to-Use Templates

| Template | Description |
|----------|-------------|
| [templates/form-automation.sh](templates/form-automation.sh) | Snapshot/ref form typing loop |
| [templates/authenticated-session.sh](templates/authenticated-session.sh) | Login once, save/load state |
| [templates/capture-workflow.sh](templates/capture-workflow.sh) | Navigate + capture snapshots/screenshots |

## Limits (WKWebView)

These commands currently return `not_supported` because they rely on Chrome/CDP-only APIs not exposed by WKWebView:
- viewport emulation
- offline emulation
- trace/screencast recording
- network route interception/mocking
- low-level raw input injection

Use supported high-level commands (`click`, `type`, `fill`, `press`, `scroll`, `wait`, `snapshot`) instead.

## Troubleshooting

### `js_error` on `snapshot --interactive` or `eval`

Some complex pages can reject or break the JavaScript used for rich snapshots and ad-hoc evaluation.

Recovery steps:

```bash
cmux browser surface:7 get url
cmux browser surface:7 get text body
cmux browser surface:7 get html body
```

- Use `get url` first so you know whether the page actually navigated.
- Fall back to `get text body` or `get html body` when `snapshot --interactive` or `eval` returns `js_error`.
- If the page is still failing, navigate to a simpler intermediate page, then retry the task from there.
