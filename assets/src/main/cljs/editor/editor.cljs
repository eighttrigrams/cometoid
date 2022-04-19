(ns editor.editor
  (:require [editor.machine :as machine]
            [editor.time-machine :as time-machine]
            [editor.bindings-resolver :as bindings-resolver]))

(defn set-values! [el {selection-start :selection-start
                       selection-end :selection-end
                       value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-end))

(defn set-modifiers! [e b modifiers]
  (let [code (case (.-code e)
               "ControlLeft" :ctrl
               "ControlRight" :ctrl
               "ShiftLeft" :shift
               "AltLeft" :alt
               "MetaLeft" :meta
               nil)]
    (when code (swap! modifiers (if b conj disj) code))))

(defn construct-state [el]
  (let [selection-start (.-selectionStart el)
        selection-end (.-selectionEnd el)]
    {:value                (.-value el)
     :selection-start      selection-start
     :selection-end        selection-end
     :selection-present?   (not= selection-start selection-end)
     :dont-prevent-default false}))

(defn paste [el modifiers execute]
  (fn [e]
    (.preventDefault e)
    (->> (.getData (.-clipboardData e) "Text")
         (assoc (construct-state el) :clipboard-data)
         (execute ["INSERT" @modifiers])
         (set-values! el))))

(defn keydown [el modifiers execute]
  (fn [e]
    (set-modifiers! e true modifiers)
    (let [new-state   (execute [(.-code e) @modifiers] (construct-state el))]
      (set-values! el new-state)
      (when (not= (:dont-prevent-default new-state) true) (.preventDefault e)))))

(defn keyup [_el modifiers]
  (fn [e]
    (set-modifiers! e false modifiers)))

(defn mouseleave [_el modifiers]
  (fn [_e]
    (reset! modifiers #{})))

(defn ^:export new [el]
  (let [modifiers (atom #{})
        execute (-> (machine/build) time-machine/build bindings-resolver/build)]
    (.addEventListener el "paste" (paste el modifiers execute))
    (.addEventListener el "keydown" (keydown el modifiers execute))
    (.addEventListener el "keyup" (keyup el modifiers))
    (.addEventListener el "mouseleave" (mouseleave el modifiers))))
