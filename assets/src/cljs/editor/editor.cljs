(ns editor.editor
  (:require [net.eighttrigrams.cljs-text-editor.editor :as editor]))

(defn ^:export new [el]
  (editor/create el))
