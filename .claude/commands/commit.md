# Commit Proposal

1. Run all at once: `git status && echo -e "\n\n\n==================== UNSTAGED ====================\n" && git diff && echo -e "\n\n\n==================== STAGED ====================\n" && git diff --cached`

2. Show the diff to the user, actually show it, don't just call these tools, as the user won't be able to see them if you do that.
   - If under 100 lines: show full diff
   - If over 100 lines: show `git diff --stat` summary + key changes

3. Analyze changes and propose a commit message:
   - First line: imperative mood, under 72 chars, describes the "what"
   - If needed: blank line + brief body explaining "why"

4. Present proposal clearly:
   ```
   PROPOSED COMMIT
   ═══════════════
   <message>
   ```

5. Ask user: "Approve? [y] commit / [e] edit message / [n] cancel"
