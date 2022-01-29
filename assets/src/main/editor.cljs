(ns editor
  (:require lowlevel
            [lowlevel-helpers :as h]))

(def modifiers (atom #{}))

(def history (atom '()))

(def direction (atom 0))

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
    (let [is-pressed?            (is-pressed? e @modifiers)
          apply-action           (apply-action el e)
          apply-action-and-track (apply-action-and-track el e)]
      (cond (is-pressed? "KeyY" #{:ctrl})
            (restore el e)
            (is-pressed? "KeyJ" #{:ctrl})
            (apply-action (comp (if (= @direction -1) h/pull-l h/pull-r) lowlevel/caret-left))
            (is-pressed? "KeyL" #{:ctrl})
            (apply-action (comp (if (= @direction 1) h/pull-r h/pull-l) lowlevel/caret-right))

            (is-pressed? "KeyL" #{:meta})
            (apply-action (comp (if (= @direction -1) h/pull-l h/pull-r) lowlevel/word-part-right))
            (is-pressed? "KeyJ" #{:meta})
            (apply-action (comp (if (= @direction 1) h/pull-r h/pull-l) lowlevel/word-part-left))

            (is-pressed? "KeyL" #{:shift :meta})
            (if (= @direction -1)
              (apply-action (comp h/flip lowlevel/word-part-right h/flip))
              (do (reset! direction 1) (apply-action lowlevel/word-part-right)))

            (is-pressed? "KeyJ" #{:shift :meta})
            (if (= @direction 1)
              (apply-action (comp h/flip lowlevel/word-part-left h/flip))
              (do (reset! direction -1) (apply-action lowlevel/word-part-left)))

            (is-pressed? "KeyJ" #{:alt})
            (apply-action (comp (if (= @direction -1) h/pull-l h/pull-r) lowlevel/sentence-part-left))
            (is-pressed? "KeyL" #{:alt})
            (apply-action (comp (if (= @direction 1) h/pull-r h/pull-l) lowlevel/sentence-part-right))

            (is-pressed? "KeyL" #{:shift :alt})
            (if (= @direction -1)
              (apply-action (comp h/flip lowlevel/sentence-part-right h/flip))
              (do (reset! direction 1) (apply-action lowlevel/sentence-part-right)))

            (is-pressed? "KeyJ" #{:shift :alt})
            (if (= @direction 1)
              (apply-action (comp h/flip lowlevel/sentence-part-left h/flip))
              (do (reset! direction -1) (apply-action lowlevel/sentence-part-left)))

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

            (is-pressed? "KeyV" #{:ctrl})
            (reset! direction 0)

            (is-pressed? "KeyX" #{:ctrl})
            (reset! direction 0)

            (is-pressed? "KeyC" #{:ctrl})
            (reset! direction 0)

            :else
            (let [{selection-start :selection-start
                   selection-end   :selection-end} (convert el)]
              (when (not= selection-start selection-end)
                (.preventDefault e))))
      (let [{selection-start :selection-start
             selection-end   :selection-end} (convert el)]
        (when (= selection-start selection-end) (reset! direction 0))))))

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