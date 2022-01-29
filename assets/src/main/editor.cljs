(ns editor
  (:require lowlevel
            [lowlevel-helpers :as h]))

(def modifiers (atom #{}))

(def history (atom '()))

(defn hey [s] (str s s))

(defn set-values! [el {selection-start :selection-start
                       selection-end :selection-end
                       value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-end))

(defn set-modifiers! [e b]
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
  {:value           (.-value el)
   :selection-start (.-selectionStart el)
   :selection-end (.-selectionEnd el)})

(defn apply-action [el e]
  (fn [a]
    (.preventDefault e)
    (set-values! el (a (convert el)))))

(defn apply-action-and-track [el e]
  (fn [a]
    (.preventDefault e)
    (let [old-value (convert el)
          result (a old-value)]
      (swap! history conj old-value)
      (set-values! el result))))

(defn restore [el e]
  (.preventDefault e)
  (when (seq @history)
    (set-values! el (first @history))
    (swap! history rest)))

(defn paste [el]
  (fn [e]
    (.preventDefault e)
    (let [clipboard-data (.getData (.-clipboardData e) "Text")
          apply-action-and-track (apply-action-and-track el e)]
      (apply-action-and-track (lowlevel/insert clipboard-data)))))

(defn keydown [el]
  (fn [e]
    (set-modifiers! e true)
    (let [is-pressed?  (is-pressed? e @modifiers)
          apply-action (apply-action el e)
          apply-action-and-track (apply-action-and-track el e)]
      (cond (is-pressed? "KeyY" #{:ctrl})
            (restore el e)
            (is-pressed? "KeyJ" #{:ctrl})
            (apply-action lowlevel/caret-left)
            (is-pressed? "KeyL" #{:ctrl})
            (apply-action lowlevel/caret-right)
            (is-pressed? "KeyL" #{:meta})
            (apply-action (comp h/pull-r lowlevel/word-part-right))
            (is-pressed? "KeyJ" #{:meta})
            (apply-action (comp h/pull-l lowlevel/word-part-left))
            (is-pressed? "KeyL" #{:meta :shift})
            (apply-action lowlevel/word-part-right)
            (is-pressed? "KeyJ" #{:meta :shift})
            (apply-action lowlevel/word-part-left)
            (is-pressed? "KeyJ" #{:alt})
            (apply-action lowlevel/sentence-part-left)
            (is-pressed? "KeyL" #{:alt})
            (apply-action lowlevel/sentence-part-right)
            (is-pressed? "Backspace" #{:shift})
            (apply-action lowlevel/delete-character-right)
            (is-pressed? "Backspace" #{:meta})
            (apply-action-and-track lowlevel/delete-word-part-left)
            (is-pressed? "Backspace" #{:shift :meta})
            (apply-action-and-track lowlevel/delete-word-part-right)
            (is-pressed? "Backspace" #{:alt})
            (apply-action-and-track lowlevel/delete-sentence-part-left)
            (is-pressed? "Backspace" #{:shift :alt})
            (apply-action-and-track lowlevel/delete-sentence-part-right)
            (is-pressed? "Enter" #{:shift})
            (apply-action lowlevel/newline-after-current)
            (is-pressed? "Enter" #{:alt})
            (apply-action lowlevel/newline-before-current)
            :else
            (let [{selection-start :selection-start
                   selection-end   :selection-end} (convert el)]
              (when (and (not= selection-start selection-end)
                         (not (is-pressed? "KeyV" #{:ctrl}))
                         (not (is-pressed? "KeyC" #{:ctrl}))
                         (not (is-pressed? "KeyX" #{:ctrl})))
                (.preventDefault e)))))))

(defn keyup [_el]
  (fn [e]
    (set-modifiers! e false)))

(defn mouseleave [_el]
  (fn [_e]
    (reset! modifiers #{})))

(defn ^:export new [el]
  (.addEventListener el "paste" (paste el))
  (.addEventListener el "keydown" (keydown el))
  (.addEventListener el "keyup" (keyup el))
  (.addEventListener el "mouseleave" (mouseleave el)))