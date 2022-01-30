(ns editor
  (:require lowlevel
            [lowlevel-helpers :as h]))

(defn hey [s] (str s s))

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

(defn convert [el direction history]
  {:value                (.-value el)
   :selection-start      (.-selectionStart el)
   :selection-end        (.-selectionEnd el)
   :history              @history
   :direction            @direction
   :dont-prevent-default false
   :do-track             false
   :do-pop-history       false})

;; TODO reenable
#_(defn paste [el]
    (fn [e]
      (.preventDefault e)
      (let [clipboard-data (.getData (.-clipboardData e) "Text")
            apply-action-and-track (apply-action-and-track el)]
        (apply-action-and-track (lowlevel/insert clipboard-data) (convert el)))))

;; TODO factor out direct access to direction
(defn handle-key [is-pressed? {direction :direction :as state}]
  (cond (is-pressed? "KeyY" #{:ctrl})
        (if (seq (:history state))
          (-> state
              (merge (first (:history state)))
              (assoc :do-pop-history true))
          state)

        (is-pressed? "KeyL" #{:ctrl})
        ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/caret-right) state)
        (is-pressed? "KeyJ" #{:ctrl})
        ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/caret-left) state)

        (is-pressed? "KeyL" #{:shift :ctrl})
        (if (= direction -1)
          ((comp h/flip lowlevel/caret-right h/flip) state)
          (assoc (lowlevel/caret-right state) :direction 1))

        (is-pressed? "KeyJ" #{:shift :ctrl})
        (if (= direction 1)
          ((comp h/flip lowlevel/caret-left h/flip) state)
          (assoc (lowlevel/caret-left state) :direction -1))

        (is-pressed? "KeyL" #{:meta})
        ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/word-part-right) state)
        (is-pressed? "KeyJ" #{:meta})
        ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/word-part-left) state)

        (is-pressed? "KeyL" #{:shift :meta})
        (if (= direction -1)
          ((comp h/flip lowlevel/word-part-right h/flip) state)
          (assoc (lowlevel/word-part-right state) :direction 1))

        (is-pressed? "KeyJ" #{:shift :meta})
        (if (= direction 1)
          ((comp h/flip lowlevel/word-part-left h/flip) state)
          (assoc (lowlevel/word-part-left state) :direction -1))

        (is-pressed? "KeyL" #{:alt})
        ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/sentence-part-right) state)
        (is-pressed? "KeyJ" #{:alt})
        ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/sentence-part-left) state)

        (is-pressed? "KeyL" #{:shift :alt})
        (if (= direction -1)
          ((comp h/flip lowlevel/sentence-part-right h/flip) state)
          (assoc (lowlevel/sentence-part-right state) :direction 1))

        (is-pressed? "KeyJ" #{:shift :alt})
        (if (= direction 1)
          ((comp h/flip lowlevel/sentence-part-left h/flip) state)
          (assoc (lowlevel/sentence-part-left state) :direction -1))

        (is-pressed? "Backspace" #{:shift})
        (lowlevel/delete-character-right state)
        (is-pressed? "Backspace" #{:meta})
        (assoc (lowlevel/delete-word-part-left state) :do-track true)
        (is-pressed? "Backspace" #{:shift :meta})
        (assoc (lowlevel/delete-word-part-right state) :do-track true)
        (is-pressed? "Backspace" #{:alt})
        (assoc (lowlevel/delete-sentence-part-left state) :do-track true)
        (is-pressed? "Backspace" #{:shift :alt})
        (assoc (lowlevel/delete-sentence-part-right state) :do-track true)
        (is-pressed? "Enter" #{:shift})
        (lowlevel/newline-after-current state)
        (is-pressed? "Enter" #{:alt})
        (lowlevel/newline-before-current state)

        (is-pressed? "KeyV" #{:ctrl})
        (-> state
            (assoc :dont-prevent-default true)
            (assoc :direction 0))

        (is-pressed? "KeyX" #{:ctrl})
        (-> state
            (assoc :dont-prevent-default true)
            (assoc :direction 0))

        (is-pressed? "KeyC" #{:ctrl})
        (-> state
            (assoc :dont-prevent-default true)
            (assoc :direction 0))

        :else
        (let [{selection-start :selection-start
               selection-end   :selection-end} state]
          (if (= selection-start selection-end)
            (assoc state :dont-prevent-default true)
            state))))

(defn clean [{selection-start :selection-start selection-end :selection-end value :value}]
  {:value value :selection-start selection-start :selection-end selection-end})

(defn keydown [el direction history modifiers]
  (fn [e]
    (set-modifiers! e true modifiers)
    (let [is-pressed? (is-pressed? e @modifiers)
          state       (convert el direction history)
          {dir :direction :as new-state}      (handle-key is-pressed? state)]

      (set-values! el new-state)
      (reset! direction dir)

      (if (:do-pop-history new-state)
        (swap! history rest)
        (when (:do-track new-state)
          (swap! history conj (clean state))))

      (when (not= (:dont-prevent-default new-state) true) (.preventDefault e))

      (let [{selection-start :selection-start
             selection-end   :selection-end} (convert el direction history)]
        (when (= selection-start selection-end) (reset! direction 0))))))

(defn keyup [_el modifiers]
  (fn [e]
    (set-modifiers! e false modifiers)))

(defn mouseleave [_el modifiers]
  (fn [_e]
    (reset! modifiers #{})))

(defn ^:export new [el]
  (let [direction (atom 0)
        history   (atom '())
        modifiers (atom #{})]
    #_(.addEventListener el "paste" (paste el))
    (.addEventListener el "keydown" (keydown el direction history modifiers))
    (.addEventListener el "keyup" (keyup el modifiers))
    (.addEventListener el "mouseleave" (mouseleave el modifiers))))
