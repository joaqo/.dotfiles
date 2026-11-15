import { View, div } from "gpui-kit";
import { props, run, closeOverlay, agents } from "herdr";

export default class CyclePinned extends View {
  init() {
    const overlay = props()?.overlay;
    if (!overlay) return;
    closeOverlay(overlay);
    const pinned = agents().filter((a) => a.pinned);
    if (!pinned.length) return;
    const next = pinned[(pinned.findIndex((a) => a.focused) + 1) % pinned.length];
    run("agent.focus", { terminal: next.address });
  }

  render() {
    return div();
  }
}
