import { View, div } from "gpui-kit";
import { props, run, closeOverlay, agents } from "herdr";

export default class CycleWorking extends View {
  init() {
    const overlay = props()?.overlay;
    if (!overlay) return;
    closeOverlay(overlay);
    const working = agents().filter((a) => a.status === "working" && !a.pinned).sort((x, y) => y.seq - x.seq);
    if (!working.length) return;
    const next = working[(working.findIndex((a) => a.focused) + 1) % working.length];
    run("agent.focus", { terminal: next.address });
  }

  render() {
    return div();
  }
}
