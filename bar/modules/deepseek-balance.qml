import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// DeepSeek account balance pill. Rendering, hover tooltip and click handling
// come from the shared WidgetButton; this file owns only the fetching: a timer
// refreshes on the configured interval, hover refreshes again (debounced), and
// an open tooltip is re-rendered with the figure that refresh returned.
BarWidget {
  id: root
  moduleName: "deepseek-balance"

  readonly property string scriptPath: setting("exec", "~/.config/omarchy/bar/scripts/deepseek-balance")
  readonly property int refreshMs: Math.max(60, Number(setting("interval", 1800))) * 1000
  readonly property int hoverRefreshMs: Number(setting("hoverRefreshMs", 60000))

  property string outputText: ""
  property string outputTooltip: ""
  property double lastFetchMs: 0

  function apply(raw) {
    var data = Util.parseModuleJson(raw)
    var nextText = data.text ? String(data.text) : ""
    var nextTip = data.tooltip ? String(data.tooltip) : "DeepSeek balance"
    var changed = nextText !== outputText || nextTip !== outputTooltip
    if (nextText) outputText = nextText
    outputTooltip = nextTip
    lastFetchMs = Date.now()
    if (changed && button.tooltipHovered) bar.showTooltip(button, outputTooltip)
  }

  function fetch() {
    if (proc.running) return
    if (Date.now() - lastFetchMs < hoverRefreshMs) return
    proc.command = ["bash", "-lc", scriptPath]
    proc.running = true
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: proc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.apply(text)
    }
  }

  Timer {
    interval: root.refreshMs
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.fetch()
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.outputText || String(root.setting("text", "…"))
    tooltipText: root.outputTooltip || "DeepSeek balance"
    fontSize: Number(root.setting("fontSize", 12))

    onPressed: function(mouseButton) {
      var command = String(root.setting("onClick", ""))
      if (command && root.bar) root.bar.run(command)
    }

    onTooltipHoveredChanged: if (tooltipHovered) root.fetch()
  }
}
