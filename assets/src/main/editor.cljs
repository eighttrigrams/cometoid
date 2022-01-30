(ns editor
  (:require lowlevel
            time-machine
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

(defn convert [el direction]
  {:value                (.-value el)
   :selection-start      (.-selectionStart el)
   :selection-end        (.-selectionEnd el)
   :direction            @direction
   :dont-prevent-default false
   :do-track             false})

(defn paste [el direction]
  (fn [e]
    (.preventDefault e)
    (let [clipboard-data (.getData (.-clipboardData e) "Text")
          new-state      ((lowlevel/insert clipboard-data) (convert el direction))]
      (set-values! el new-state))))

(defn keydown [el direction modifiers execute]
  (fn [e]
    (set-modifiers! e true modifiers)
    (let [is-pressed? (is-pressed? e @modifiers)
          key         (bindings/get-command is-pressed?)
          state       (convert el direction)
          {dir :direction :as new-state}      (execute key state)]

      (set-values! el new-state)
      (reset! direction dir)

      (when (not= (:dont-prevent-default new-state) true) (.preventDefault e))

      (let [{selection-start :selection-start
             selection-end   :selection-end} (convert el direction)]
        (when (= selection-start selection-end) (reset! direction 0))))))

(defn keyup [_el modifiers]
  (fn [e]
    (set-modifiers! e false modifiers)))

(defn mouseleave [_el modifiers]
  (fn [_e]
    (reset! modifiers #{})))

(defn ^:export new [el]
  (let [direction (atom 0)
        modifiers (atom #{})
        execute (time-machine/build)]
    (.addEventListener el "paste" (paste el direction))
    (.addEventListener el "keydown" (keydown el direction modifiers execute))
    (.addEventListener el "keyup" (keyup el modifiers))
    (.addEventListener el "mouseleave" (mouseleave el modifiers))))
