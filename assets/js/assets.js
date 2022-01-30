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

const editorHook = {
    mounted() {
        editor.editor.new$(this.el)
    }
}
hooks.TextAreaHook = editorHook;

hooks.ContentsHook = {
    mounted() {
        this.el.addEventListener("mouseleave", e => { 
            this.pushEvent("mouse_leave");
        });
        this.el.addEventListener("contextmenu", e => {
            this.pushEvent("right_click")
            e.preventDefault()
        })
        this.el.addEventListener("mouseup", e => {
            this.pushEvent("mouse_leave")
            e.preventDefault()
        })
    },  
}

hooks.ContextSearchInputHook = {
    mounted() {
      document.getElementById("context_search_q").focus()
    }
  }
  hooks.IssueSearchInputHook = {
    mounted() {
      document.getElementById("issue_search_q").focus()
    }
  }
  
  hooks.DescriptionSaveHook = {
    myTarget: undefined,
    controlPressed: false,
    keyUpListener: undefined,
    keyDownListener: undefined,
    makeKeyUpListener: function(self) { return function(e) {
      if (e.key === "Control") {
        self.controlPressed = false
      }
    }},
    makeKeyDownListener: function(self) { return function(e) {
  
      if (e.key === "Control") {
        self.controlPressed = true
      }
  
      if (e.key === "s") {
        if (self.controlPressed) {
          e.preventDefault()
          self.pushEventTo(self.myTarget, "save", 
            { description: self.el.querySelector("#text-area").value }
          )
        }
      }}
    },
    mounted() {
      const el = this.el.getElementsByTagName("textarea")[0]
      el.focus()
      el.selectionStart = el.selectionEnd = el.value.length
  
      this.myTarget = this.el.getAttribute("phx-my-target")
      
      this.keyUpListener = this.makeKeyUpListener(this)
      this.keyDownListener = this.makeKeyDownListener(this)
  
      document.addEventListener("keyup", this.keyUpListener)
      document.addEventListener("keydown", this.keyDownListener)
    },
    destroyed() {
      document.removeEventListener("keyup", this.keyUpListener)
      document.removeEventListener("keydown", this.keyDownListener)
    }
  }
  hooks.SaveHook = {
    myTarget: undefined,
    controlPressed: false,
    keyUpListener: undefined,
    keyDownListener: undefined,
    makeKeyUpListener: function(self) { return function(e) {
      if (e.key === "Control") {
        self.controlPressed = false
      }
    }},
    makeKeyDownListener: function(self) { return function(e) {
  
      if (e.key === "Enter") e.preventDefault()
      if (e.key === "Control") self.controlPressed = true
      if (e.key === "s") {
        if (self.controlPressed) {
          e.preventDefault()
          self.pushEventTo(self.myTarget, "save")
        }
      }}
    },
    mounted() {
      for (const inputField of this.el.getElementsByTagName("input")) {
        if (inputField.type === "text") {
          inputField.focus()
          inputField.selectionStart = inputField.selectionEnd = inputField.value.length
          break
        }
      }
  
      this.myTarget = this.el.getAttribute("phx-my-target")
      
      this.keyUpListener = this.makeKeyUpListener(this)
      this.keyDownListener = this.makeKeyDownListener(this)
  
      document.addEventListener("keyup", this.keyUpListener)
      document.addEventListener("keydown", this.keyDownListener)
    },
    destroyed() {
      document.removeEventListener("keyup", this.keyUpListener)
      document.removeEventListener("keydown", this.keyDownListener)
    }
  }
  
  
  
  
  hooks.SecondaryContextBadgeHook = {
      context_id: "",
      issue_id: "",
      mounted() {
          const [context_id, issue_id] = this.el.id.split("_")[1].split(":")
          this.context_id = context_id
          this.issue_id = issue_id
          this.el.addEventListener("mouseup", e => { 
              this.pushEvent("jump_to_context", 
                  { target_context_id: context_id, target_issue_id: issue_id })
          })
      }
  }
  hooks.IssueEventHook = {
    inpStored: '',
    mounted() {
        const inp = document.getElementById("issue-form_title")
        this.inpStored = inp.value
        inp.addEventListener("input", e => { this.inpStored = inp.value })
    },
    updated() {
        const inp = document.getElementById("issue-form_title");
        inp.value = this.inpStored
    }
  }
  hooks.ContextItemHook = {
      id: '',
      mounted() {
          this.handleEvent("context_reprioritized", ({ id: id }) => {
            if (this.id == id) this.el.scrollIntoView(false)
          })
          this.id = this.el.id.replace("context-", "")
          document.addEventListener("mousedown", function (event) {
              if (event.detail > 1) {
              event.preventDefault()
            }
          }, false);
           this.el.addEventListener("dblclick", e => {
               this.pushEvent("edit_context", this.id);
           }, false);  
      }
  }
  hooks.IssueItemHook = {
      id: '',
      mounted() {
          this.handleEvent("issue_reprioritized", ({ id: id }) => {
              if (this.id == id) this.el.scrollIntoView(false)
          })
          this.id = this.el.id.replace("issue-", "");
          document.addEventListener('mousedown', function (event) {
              if (event.detail > 1) {
              event.preventDefault()
            }
          }, false)
          this.el.addEventListener('dblclick', e => {
              this.pushEvent("edit_issue", this.id)
          }, false)  
      }
  }
  hooks.EventItemHook = {
    id: '',
    mounted() {
        this.id = this.el.id.replace("event-", "");
        document.addEventListener('mousedown', function (event) {
            if (event.detail > 1) {
            event.preventDefault()
          }
        }, false)
        this.el.addEventListener('dblclick', e => {
            this.pushEvent("edit_event", this.id)
        }, false)  
    }
  }
  hooks.IssueDescriptionHook = {
      mounted() {
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
         // https://stackoverflow.com/a/43321596
        document.addEventListener('mousedown', function (event) {
           if (event.detail > 1) {
             event.preventDefault();
           }
        }, false);
        this.el.addEventListener('dblclick', e => {
            this.pushEvent("edit_context_description");
        }, false);
      }, 
   }
  hooks.DescHook = {
    mounted() {
      const elements = this.el.getElementsByTagName('a');
      for (const element of elements) {
        element.tabIndex = -1;
      }
    },
    updated() {
      const elements = this.el.getElementsByTagName('a');
      for (const element of elements) {
        element.tabIndex = -1;
      }
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

