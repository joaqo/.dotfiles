import { View, div } from "gpui-kit";
import { props, run, closeOverlay, focused, spaces } from "herdr";

// pane.close on a space's last pane asks for confirmation and takes no `confirmed` flag.
export default class ClosePane extends View {
  init() {
    const overlay = props()?.overlay;
    if (!overlay) return;
    closeOverlay(overlay);
    const f = focused();
    if (!f) return;
    const space = spaces().find((s) => s.id === f.space);
    if (space && space.tabs.length === 1 && space.tabs[0].panes === 1) {
      run("space.close", { id: f.space, confirmed: true });
    } else if (f.pane) {
      run("pane.close", { pane: f.pane });
    }
  }

  render() {
    return div();
  }
}
