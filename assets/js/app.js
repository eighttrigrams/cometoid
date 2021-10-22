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
hooks.IssueEventHook = {
  inpStored: '',
  mounted () {
      const inp = document.getElementById("issue-form_title");
      this.inpStored = inp.value;
      inp.addEventListener("input", e => { this.inpStored = inp.value; });
  },
  updated() {
      const inp = document.getElementById("issue-form_title");
      inp.value = this.inpStored;
  }
}
hooks.IssueItemHook = {
    id: '',
    mounted () {
        this.id = this.el.id.replace("issue-", "");
        document.addEventListener('mousedown', function (event) {
            if (event.detail > 1) {
            event.preventDefault();
            // of course, you still do not know what you prevent here...
            // You could also check event.ctrlKey/event.shiftKey/event.altKey
            // to not prevent something useful.
          }
        }, false);
         this.el.addEventListener('dblclick', e => {
             this.pushEvent("edit_issue", this.id);
         }, false);  
    }
}
hooks.IssueDescriptionHook = {
   mounted() {
      // https://stackoverflow.com/a/43321596
      document.addEventListener('mousedown', function (event) {
        if (event.detail > 1) {
          event.preventDefault();
          // of course, you still do not know what you prevent here...
          // You could also check event.ctrlKey/event.shiftKey/event.altKey
          // to not prevent something useful.
        }
      }, false);
       this.el.addEventListener('dblclick', e => {
           this.pushEvent("edit_issue_description");
       }, false);
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

