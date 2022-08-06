(ns editor.editor
  (:require [net.eighttrigrams.cljs-text-editor.editor :as editor]))

(defn ^:export new 
  [el input-field-mode?]
  (editor/create el input-field-mode?))
