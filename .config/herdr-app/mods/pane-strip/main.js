import { View, div } from "gpui-kit";
import { panes, props, theme } from "herdr";

export default class PaneStrip extends View {
  render() {
    const t = theme();
    const focused = panes().find((p) => p.pane === props()?.pane)?.focused;
    return div().size_full().bg(focused ? t.accent : t.background);
  }
}
