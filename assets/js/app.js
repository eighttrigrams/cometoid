// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import topbar from "topbar"
import {LiveSocket} from "phoenix_live_view"

let hooks = {};
hooks.IssueHook = {
  teStored: '',
  inpStored: '',
  contValue: [],
  mounted (){
      const te = this.el.getElementsByTagName("textarea")[0];
      const inp = document.getElementById("issue-form_title");
      const cont = document.getElementById("issue-form_contexts");
      this.teStored = te.value;
      this.inpStored = inp.value;
      this.contStored = Array.from(cont.selectedOptions).map(o => o.value);
      te.addEventListener("input", e => { this.teStored = te.value; });
      te.addEventListener("input", e => { this.teStored = te.value; });
      cont.addEventListener("input", e => { this.contStored = Array.from(cont.selectedOptions).map(o => o.value); });
  },
  updated() {
      const te = this.el.getElementsByTagName("textarea")[0];
      const inp = document.getElementById("issue-form_title");
      const cont = document.getElementById("issue-form_contexts");
      te.value = this.teStored;
      inp.value = this.inpStored;
      for (const o of cont.options) o.selected = this.contStored.includes(o.value);
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    hooks: hooks,
    params: {
        _csrf_token: csrfToken
    }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

