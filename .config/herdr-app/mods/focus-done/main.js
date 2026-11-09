import { View, div } from "gpui-kit";
import { props, run, closeOverlay, agents, terminals } from "herdr";

// The agents list keeps its order private. It shows Needs you above Done, puts the most
// recently changed agent first in each, and lists pinned agents above every section.
// A sub-agent that is blocked or failed puts its parent in Needs you.
export default class FocusDone extends View {
  init() {
    const overlay = props()?.overlay;
    if (!overlay) return;
    closeOverlay(overlay);
    const all = terminals();
    const kidNeedsYou = (address) => all.some((k) => k.parent === address && k.state === "live"
      && (k.status === "blocked" || k.status === "error" || kidNeedsYou(k.address)));
    const urgency = (a) => (a.status === "blocked" || kidNeedsYou(a.address) ? 1 : 0);
    const top = agents()
      .filter((a) => urgency(a) === 1 || (a.status === "done" && !a.pinned))
      .sort((x, y) => urgency(y) - urgency(x) || y.seq - x.seq)[0];
    if (top) run("agent.focus", { terminal: top.address });
  }

  render() {
    return div();
  }
}
