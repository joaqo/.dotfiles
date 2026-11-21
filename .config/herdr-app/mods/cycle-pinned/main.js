import { View, div } from "gpui-kit";
import { props, run, closeOverlay, agents, terminals, shared, appHome, readTextFile } from "herdr";

// Mirrors the shipped agents mod's pinned order, which it keeps private: in its
// default "priority" sort, by status (counting live sub-agents), then by when
// that status last changed (its localStorage), then newest first.
const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };

export default class CyclePinned extends View {
  init(_props, cx) {
    const overlay = props()?.overlay;
    if (!overlay) return;
    cx.spawn(async () => {
      try {
        const pinned = await this.pinnedInSidebarOrder();
        if (!pinned.length) return;
        const next = pinned[(pinned.findIndex((a) => a.focused) + 1) % pinned.length];
        run("agent.focus", { terminal: next.address });
      } finally {
        closeOverlay(overlay);
      }
    });
  }

  async pinnedInSidebarOrder() {
    const list = agents();
    const pinned = list.filter((a) => a.pinned);
    if ((shared("agents.sort") ?? "priority") !== "priority") return pinned;

    let changed = {};
    try {
      const store = JSON.parse(await readTextFile(`${appHome()}/data/agents/store.json`) ?? "{}");
      changed = JSON.parse(store.changed ?? "{}") ?? {};
    } catch {}
    const now = Date.now();
    const since = (a) => {
      const c = changed[a.address];
      return c?.s === (a.status === "done" ? "idle" : a.status) ? c.at : now;
    };

    const all = terminals();
    const listed = new Map(list.map((a) => [a.address, a.status]));
    const kidStatus = (k) => {
      const s = listed.get(k.address) ?? k.status;
      return s === "error" ? "blocked" : s === "done" ? "idle" : s;
    };
    const descendants = (addr) => all
      .filter((k) => k.parent === addr && k.state === "live")
      .flatMap((k) => [k, ...descendants(k.address)]);
    const rank = (a) => Math.max(RANK[a.status] ?? 0, ...descendants(a.address).map((k) => RANK[kidStatus(k)] ?? 0));

    return pinned.sort((x, y) => rank(y) - rank(x) || since(y) - since(x) || y.seq - x.seq);
  }

  render() {
    return div();
  }
}
