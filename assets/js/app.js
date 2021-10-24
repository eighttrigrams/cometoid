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
hooks.TextAreaHook = {
    mounted() {
        // https://stackoverflow.com/a/6637396
        this.el.addEventListener('keydown', function(e) {
            if (e.key == 'Tab') {
              e.preventDefault();
              var start = this.selectionStart;
              var end = this.selectionEnd;
              this.value = this.value.substring(0, start) +
                "    " + this.value.substring(end);
              this.selectionStart =
                this.selectionEnd = start + 4;
            }
          });
    }
}
hooks.ContentsHook = {
    mounted () {
        this.el.addEventListener("mouseleave", e => { 
            this.pushEvent("mouse_leave");
        });
    },  
}
hooks.IssueEventHook = {
  inpStored: '',
  mounted() {
      const inp = document.getElementById("issue-form_title");
      this.inpStored = inp.value;
      inp.addEventListener("input", e => { this.inpStored = inp.value; });
  },
  updated() {
      const inp = document.getElementById("issue-form_title");
      inp.value = this.inpStored;
  }
}
hooks.ContextItemHook = {
    id: '',
    mounted() {
        this.id = this.el.id.replace("context-", "");
        document.addEventListener('mousedown', function (event) {
            if (event.detail > 1) {
            event.preventDefault();
          }
        }, false);
         this.el.addEventListener('dblclick', e => {
             this.pushEvent("edit_context", this.id);
         }, false);  
    }
}
hooks.IssueItemHook = {
    id: '',
    mounted() {
        this.id = this.el.id.replace("issue-", "");
        document.addEventListener('mousedown', function (event) {
            if (event.detail > 1) {
            event.preventDefault();
          }
        }, false);
         this.el.addEventListener('dblclick', e => {
             this.pushEvent("edit_issue", this.id);
         }, false);  
    }
}
hooks.IssueDescriptionHook = {
   mounted() {
      const elements = this.el.getElementsByTagName('a');
      for (const element of elements) {
        element.tabindex = -1;
        element.tabIndex = -1;
      }
      document.addEventListener('mousedown', function (event) {
        if (event.detail > 1) {
          event.preventDefault();
        }
      }, false);
       this.el.addEventListener('dblclick', e => {
           this.pushEvent("edit_issue_description");
       }, false);
   } 
}
hooks.ContextDescriptionHook = {
    mounted() {
      const elements = this.el.getElementsByTagName('a');
      for (const element of elements) {
        element.tabindex = -1; // tabindex works in chromium
        element.tabIndex = -1; // tabIndex works in opera
      }
       // https://stackoverflow.com/a/43321596
       document.addEventListener('mousedown', function (event) {
         if (event.detail > 1) {
           event.preventDefault();
         }
       }, false);
        this.el.addEventListener('dblclick', e => {
            this.pushEvent("edit_context_description");
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

