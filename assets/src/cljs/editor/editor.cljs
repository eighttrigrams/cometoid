(ns editor.editor
  (:require [net.eighttrigrams.cljs-text-editor.editor :as editor]
            [net.eighttrigrams.cljs-text-editor.machine :as machine]
            [net.eighttrigrams.cljs-text-editor.bindings :as bindings]
            [net.eighttrigrams.cljs-text-editor.bindings-resolver :as bindings-resolver]
            [net.eighttrigrams.cljs-text-editor.time-machine :as time-machine]))

(defn ^:export new [el]
  (let [modifiers (atom #{})
        position-in-line (atom nil)
        resolve-bindings (bindings-resolver/build bindings/commands)
        transform-state (-> (machine/build) time-machine/build resolve-bindings)]
    (.addEventListener el "paste" (editor/paste el modifiers transform-state position-in-line))
    (.addEventListener el "keydown" (editor/keydown el modifiers transform-state position-in-line))
    (.addEventListener el "keyup" (editor/keyup el modifiers))
    (.addEventListener el "mouseleave" (editor/mouseleave el modifiers))
    (.addEventListener el "click" (editor/click el position-in-line))))
