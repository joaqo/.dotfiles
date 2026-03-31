# Sidebar Metadata and Notifications

Two systems for surfacing agent/process state in the cmux sidebar.

## Notifications

```bash
# Send a notification
cmux notify --title "Build complete" --body "Ready to deploy"
cmux notify --title "Error" --subtitle "Step 3" --body "Tests failed"

# List and clear
cmux list-notifications
cmux clear-notifications
```

## Sidebar Metadata

Sidebar metadata appears as pills, progress bars, and log entries in the workspace sidebar. Scoped to a workspace (defaults to current via `CMUX_WORKSPACE_ID`).

### Status Pills

```bash
# Set a status pill (key is an identifier, value is display text)
cmux set-status build "building..."
cmux set-status build "✓ done" --icon checkmark --color green
cmux set-status deploy "deploying" --workspace workspace:2

# Clear
cmux clear-status build

# List all
cmux list-status
cmux list-status --workspace workspace:2
```

### Progress Bar

```bash
# Value is 0.0–1.0
cmux set-progress 0.0 --label "Starting..."
cmux set-progress 0.5 --label "Processing files..."
cmux set-progress 1.0 --label "Done"

cmux clear-progress
```

### Log Entries

```bash
# Levels: info, progress, success, warning, error
cmux log --level info --source build -- "Compiling TypeScript..."
cmux log --level success --source build -- "Build complete in 4.2s"
cmux log --level error --source tests -- "3 tests failed"
cmux log --level warning --source lint -- "12 warnings found"

# View and clear
cmux list-log
cmux list-log --limit 20
cmux clear-log
```

### Sidebar State Snapshot

```bash
# Returns full sidebar state (status, progress, log) as JSON
cmux sidebar-state
cmux sidebar-state --workspace workspace:2
```

## Agent Pattern: Progress Tracking

```bash
cmux set-progress 0.0 --label "Starting task"
cmux log --level info --source agent -- "Analyzing codebase..."

# ...work...

cmux set-progress 0.33 --label "Step 1/3 complete"
cmux log --level success --source agent -- "Analysis done"

# ...more work...

cmux set-progress 1.0 --label "Complete"
cmux log --level success --source agent -- "All steps done"
cmux clear-progress
```
