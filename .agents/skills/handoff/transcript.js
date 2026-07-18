#!/usr/bin/env node
// Distills a Claude Code session JSONL into a readable markdown transcript.
// Drops tool payload bodies (file dumps, command output) — keeps the narrative:
// user turns verbatim, assistant text, and one line per tool call with its result status.
//
// Usage: node transcript.js [--out <dir>] [--session <jsonl path>] [--thinking]
//   --out       output dir (default: ~/.claude/handoffs/<timestamp>/); created if missing
//   --session   explicit JSONL path (default: newest session for the current cwd)
//   --thinking  keep assistant thinking blocks (dropped by default)
// Prints the output directory path on stdout (last line) so the caller can find it.

const fs = require("fs");
const os = require("os");
const path = require("path");

const args = process.argv.slice(2);
const getFlag = (name) => {
  const i = args.indexOf(name);
  return i !== -1 ? args[i + 1] : null;
};
const keepThinking = args.includes("--thinking");

function collectJsonl(projectsDir) {
  const out = [];
  if (!fs.existsSync(projectsDir)) return out;
  for (const d of fs.readdirSync(projectsDir)) {
    const dir = path.join(projectsDir, d);
    if (!fs.statSync(dir).isDirectory()) continue;
    for (const f of fs.readdirSync(dir))
      if (f.endsWith(".jsonl")) out.push(path.join(dir, f));
  }
  return out;
}

function findSessionFile() {
  const explicit = getFlag("--session");
  if (explicit) return explicit;

  const projectsDir = path.join(os.homedir(), ".claude", "projects");

  // Deterministic: Claude Code exports the running session's id into the env of
  // any subprocess (this script). The JSONL is named `<sessionId>.jsonl`.
  const sid = process.env.CLAUDE_CODE_SESSION_ID;
  if (sid) {
    const hit = collectJsonl(projectsDir).find(
      (f) => path.basename(f, ".jsonl") === sid
    );
    if (hit) return hit;
    console.error(
      `warning: CLAUDE_CODE_SESSION_ID=${sid} set but no matching JSONL found; falling back to newest.`
    );
  } else {
    console.error(
      "warning: CLAUDE_CODE_SESSION_ID not set; falling back to newest session for this cwd (may be wrong if multiple sessions are open)."
    );
  }

  // Fallback: newest JSONL for the current cwd (by mtime = being appended to now).
  const cwd = process.cwd();
  const encoded = cwd.replace(/[^a-zA-Z0-9]/g, "-");
  const encodedDir = path.join(projectsDir, encoded);
  let candidates = fs.existsSync(encodedDir)
    ? fs.readdirSync(encodedDir).filter((f) => f.endsWith(".jsonl")).map((f) => path.join(encodedDir, f))
    : [];
  if (!candidates.length) candidates = collectJsonl(projectsDir);
  if (!candidates.length) throw new Error(`No session JSONL found for cwd ${cwd}`);
  return candidates
    .map((f) => ({ f, m: fs.statSync(f).mtimeMs }))
    .sort((a, b) => b.m - a.m)[0].f;
}

const truncate = (s, n = 140) => {
  s = String(s).replace(/\s+/g, " ").trim();
  return s.length > n ? s.slice(0, n) + "…" : s;
};

// One-line label for a tool call, keyed on tool name.
function formatToolUse(name, input = {}) {
  const p = (k) => input[k];
  switch (name) {
    case "Read":
    case "Edit":
    case "Write":
    case "MultiEdit":
    case "NotebookEdit":
      return `${name} \`${p("file_path") || p("notebook_path") || "?"}\``;
    case "Bash":
      return `Bash: \`${truncate(p("command"), 120)}\``;
    case "Grep":
      return `Grep \`${p("pattern")}\`${p("path") ? ` in ${p("path")}` : ""}`;
    case "Glob":
      return `Glob \`${p("pattern")}\``;
    case "WebFetch":
      return `WebFetch ${p("url")}`;
    case "WebSearch":
      return `WebSearch \`${truncate(p("query"), 100)}\``;
    case "Task":
    case "Agent":
      return `Agent(${p("subagent_type") || "?"}): ${truncate(p("description") || "", 80)}`;
    case "TodoWrite":
      return `TodoWrite`;
    default: {
      const firstStr = Object.values(input).find((v) => typeof v === "string");
      return `${name}${firstStr ? ` ${truncate(firstStr, 100)}` : ""}`;
    }
  }
}

// Short status appended to a tool line from its result.
function formatToolResult(block) {
  let text = "";
  if (typeof block.content === "string") text = block.content;
  else if (Array.isArray(block.content))
    text = block.content.map((c) => (typeof c === "string" ? c : c.text || "")).join("\n");
  const isError = block.is_error;
  const clean = text.replace(/\s+$/g, "");
  const lines = clean ? clean.split("\n").length : 0;
  let status;
  if (!clean.trim()) status = "ok";
  else if (lines === 1 && clean.length <= 80) status = truncate(clean, 80);
  else status = `${lines} lines`;
  return `${isError ? "⚠ error: " : ""}${status}`;
}

function main() {
  const file = findSessionFile();
  const lines = fs.readFileSync(file, "utf8").split("\n").filter(Boolean);

  const out = [];
  const pending = new Map(); // tool_use id -> index in `out`
  let sessionId = "",
    cwd = "",
    firstTs = "",
    lastTs = "",
    userTurns = 0,
    toolCalls = 0;

  for (const line of lines) {
    let rec;
    try {
      rec = JSON.parse(line);
    } catch {
      continue;
    }
    if (rec.sessionId) sessionId = rec.sessionId;
    if (rec.cwd) cwd = rec.cwd;
    if (rec.timestamp) {
      firstTs = firstTs || rec.timestamp;
      lastTs = rec.timestamp;
    }
    if (rec.isSidechain) continue; // subagent-internal chatter
    if (rec.type !== "user" && rec.type !== "assistant") continue;

    const content = rec.message && rec.message.content;

    if (rec.type === "user") {
      if (typeof content === "string") {
        if (!content.trim()) continue;
        out.push(`\n## 👤 User\n\n${content.trim()}\n`);
        userTurns++;
      } else if (Array.isArray(content)) {
        for (const b of content) {
          if (b.type === "tool_result") {
            const idx = pending.get(b.tool_use_id);
            if (idx != null) out[idx] += ` → ${formatToolResult(b)}`;
          } else if (b.type === "text" && b.text && b.text.trim()) {
            out.push(`\n## 👤 User\n\n${b.text.trim()}\n`);
            userTurns++;
          }
        }
      }
      continue;
    }

    // assistant
    if (!Array.isArray(content)) continue;
    for (const b of content) {
      if (b.type === "text" && b.text && b.text.trim()) {
        out.push(`\n### 🤖 Assistant\n\n${b.text.trim()}\n`);
      } else if (b.type === "thinking" && keepThinking && b.thinking && b.thinking.trim()) {
        out.push(`\n<details><summary>💭 thinking</summary>\n\n${b.thinking.trim()}\n\n</details>\n`);
      } else if (b.type === "tool_use") {
        out.push(`- ${formatToolUse(b.name, b.input)}`);
        pending.set(b.id, out.length - 1);
        toolCalls++;
      }
    }
  }

  const outDir =
    getFlag("--out") ||
    path.join(
      os.homedir(),
      ".claude",
      "handoffs",
      new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19)
    );
  fs.mkdirSync(outDir, { recursive: true });

  const header = [
    `# Session transcript`,
    ``,
    `- **Session:** \`${sessionId}\``,
    `- **cwd:** \`${cwd}\``,
    `- **Span:** ${firstTs} → ${lastTs}`,
    `- **User turns:** ${userTurns} · **Tool calls:** ${toolCalls}`,
    `- **Source:** \`${file}\``,
    ``,
    `---`,
  ].join("\n");

  const outFile = path.join(outDir, "transcript.md");
  fs.writeFileSync(outFile, header + "\n" + out.join("\n") + "\n");
  console.error(`Wrote ${outFile} (${userTurns} user turns, ${toolCalls} tool calls)`);
  console.log(outDir);
}

main();
