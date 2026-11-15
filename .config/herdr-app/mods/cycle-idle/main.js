import { View, div } from "gpui-kit";
import { props, run, closeOverlay, agents } from "herdr";

export default class CycleIdle extends View {
  init() {
    const overlay = props()?.overlay;
    if (!overlay) return;
    closeOverlay(overlay);
    const idle = agents().filter((a) => a.status === "idle" && !a.pinned).sort((x, y) => y.seq - x.seq);
    if (!idle.length) return;
    const next = idle[(idle.findIndex((a) => a.focused) + 1) % idle.length];
    run("agent.focus", { terminal: next.address });
  }

  render() {
    return div();
  }
}
