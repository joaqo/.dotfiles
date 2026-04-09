---
name: notion-tool
description: Use when you need to work with notion in any way
---

# Notion

Use this skill for the `notion` CLI tool.

## Rules

- Writes always require `-p <project> -d <database>`
- Database-scoped reads also require `-p <project> -d <database>`
- `notion get` requires `-p <project>`
- Start with `notion context` when the target project/database or filter field is not already known
- If the user says "my" tasks/items, inspect `notion context` for a likely ownership `people` field such as `Assignee`, `Owner`, `Assigned to`, or `Responsible`, then filter by `Joaquín Alori`

## How it works

- Config is split into configured projects, each with configured databases
- Task/page commands operate on one database at a time
- Property flags are inferred from the Notion schema for that database
- Property defaults are scoped to a specific `project/database` pair
- `notion context` shows projects, databases, defaults, users, fields, filter syntax, and possible values in one call

## Common commands

```bash
notion context
notion projects
notion databases -p <project>
notion fields -p <project> -d <database>
notion project add <project> --token "<token>"
notion database add <database> -p <project> --database "<url-or-id>"
notion list -p <project> -d <database> --limit 20
notion add "Title" -p <project> -d <database>
notion update <page-id> -p <project> -d <database> --status "In progress"
notion done <page-id> -p <project> -d <database>
notion get <page-id-or-url> -p <project>
notion defaults -p <project> -d <database>
```

## Typical flows

Inspect what exists:

```bash
notion context
```

Read tasks from a known database:

```bash
notion list -p mellow -d tasks --status "In progress" --limit 20
notion list -p mellow -d tasks --assignee "Joaquín Alori" --status "In progress"
notion list -p Feyn -d Tasks --json
```

Create a task with properties and body:

```bash
notion add "Fix checkout bug" -p mellow -d tasks \
  --status "In progress" \
  --assignee "Joaquín Alori" \
  --due-date 2026-04-10 \
  --body "Investigate regression and ship fix."
```

Inspect one page, then update it:

```bash
notion get 333463c03dcc808687a1e0b8bb3e6e02 -p mellow
notion update 333463c03dcc808687a1e0b8bb3e6e02 -p mellow -d tasks --status Done
```

Set database-scoped defaults:

```bash
notion defaults -p mellow -d tasks
notion defaults -p mellow -d tasks --status "Pending" --assignee "Joaquín Alori"
```

Configure a new project/database:

```bash
notion project add Feyn --token "<token>"
notion database add Tasks -p Feyn --database "<database-url>"
```

## Notes

- Property flags use kebab-case, for example `--due-date`
- Use `notion get` or `notion list --json` when you need exact ids or raw property values
- Removing a page means archiving it via the Notion API
