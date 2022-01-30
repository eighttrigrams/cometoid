(ns editor
  (:require [editor.lowlevel :as lowlevel]
            [editor.machine :as machine]
            [editor.director :as director]
            [editor.time-machine :as time-machine]
            bindings))

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

(defn is-pressed? [e modifiers]
  (fn [code modifiers-expected]
    (and (= (.-code e) code)
         (= modifiers modifiers-expected))))

(defn convert [el]
  {:value                (.-value el)
   :selection-start      (.-selectionStart el)
   :selection-end        (.-selectionEnd el)
   :dont-prevent-default false})

(defn paste [el]
  (fn [e]
    (.preventDefault e)
    (let [clipboard-data (.getData (.-clipboardData e) "Text")
          new-state      ((lowlevel/insert clipboard-data) (convert el))]
      (set-values! el new-state))))

(defn keydown [el modifiers execute]
  (fn [e]
    (set-modifiers! e true modifiers)
    (let [is-pressed? (is-pressed? e @modifiers)
          command     (bindings/get-command is-pressed?)
          state       (convert el)
          #_(comment "TODO only execute if command not nil")
          new-state   (execute command state)]
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
        execute (-> machine/execute director/build time-machine/build)]
    (.addEventListener el "paste" (paste el))
    (.addEventListener el "keydown" (keydown el modifiers execute))
    (.addEventListener el "keyup" (keyup el modifiers))
    (.addEventListener el "mouseleave" (mouseleave el modifiers))))
