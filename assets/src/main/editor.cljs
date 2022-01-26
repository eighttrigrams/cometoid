(ns editor
  (:require lowlevel))

(def modifiers (atom #{}))

(defn hey [s] (str s s))

(defn set-values! [el {selection-start :selection-start
                       value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-start))

(defn set-modifiers! [e b]
  (let [code (case (.-code e)
               "ControlLeft" :ctrl
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
  {:value           (.-value el)
   :selection-start (.-selectionStart el)})

(defn apply-action [el e]
  (fn [a]
    (.preventDefault e)
    (set-values! el (a (convert el)))))

(defn keydown [el]
  (fn [e]
    (set-modifiers! e true)
    (let [is-pressed?  (is-pressed? e @modifiers)
          apply-action (apply-action el e)]
      (cond (is-pressed? "KeyJ" #{:ctrl})
            (apply-action lowlevel/caret-left)
            (is-pressed? "KeyL" #{:ctrl})
            (apply-action lowlevel/caret-right)
            (is-pressed? "KeyL" #{:meta})
            (apply-action lowlevel/word-part-right)
            (is-pressed? "KeyJ" #{:meta})
            (apply-action lowlevel/word-part-left)
            (is-pressed? "KeyJ" #{:alt})
            (apply-action lowlevel/sentence-part-left)
            (is-pressed? "KeyL" #{:alt})
            (apply-action lowlevel/sentence-part-right)
            (is-pressed? "Backspace" #{:meta})
            (apply-action lowlevel/delete-word-part-left)
            (is-pressed? "Backspace" #{:shift :meta})
            (apply-action lowlevel/delete-word-part-right)))))

(defn keyup [_el]
  (fn [e]
    (set-modifiers! e false)))

(defn mouseleave [_el]
  (fn [_e]
    (reset! modifiers #{})))

(defn ^:export new [el]
  (.addEventListener el "keydown" (keydown el))
  (.addEventListener el "keyup" (keyup el))
  (.addEventListener el "mouseleave" (mouseleave el)))