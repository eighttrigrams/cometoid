(ns editor
  (:require lowlevel
            machine))

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

(defn get-command [is-pressed?]
  (cond (is-pressed? "KeyY" #{:ctrl})
        :restore
        (is-pressed? "KeyL" #{:ctrl})
        :caret-left
        (is-pressed? "KeyJ" #{:ctrl})
        :caret-right
        (is-pressed? "KeyL" #{:shift :ctrl})
        :caret-left-with-selection
        (is-pressed? "KeyJ" #{:shift :ctrl})
        :caret-right-with-selection
        (is-pressed? "KeyL" #{:meta})
        :word-part-left
        (is-pressed? "KeyJ" #{:meta})
        :word-part-right
        (is-pressed? "KeyL" #{:shift :meta})
        :word-part-right-with-selection
        (is-pressed? "KeyJ" #{:shift :meta})
        :word-part-left-with-selection
        (is-pressed? "KeyL" #{:alt})
        :sentence-right
        (is-pressed? "KeyJ" #{:alt})
        :sentence-left
        (is-pressed? "KeyL" #{:shift :alt})
        :sentence-right-with-selection
        (is-pressed? "KeyJ" #{:shift :alt})
        :sentence-left-with-selection
        (is-pressed? "Backspace" #{:shift})
        :shift-backspace
        (is-pressed? "Backspace" #{:meta})
        :meta-backspace
        (is-pressed? "Backspace" #{:shift :meta})
        :shift-meta-backspace
        (is-pressed? "Backspace" #{:alt})
        :alt-backspace
        (is-pressed? "Backspace" #{:shift :alt})
        :shift-alt-backspace
        (is-pressed? "Enter" #{:shift})
        :shift-enter
        (is-pressed? "Enter" #{:alt})
        :alt-enter
        (is-pressed? "KeyV" #{:ctrl})
        :keyv-ctrl
        (is-pressed? "KeyX" #{:ctrl})
        :keyx-ctrl
        (is-pressed? "KeyC" #{:ctrl})
        :keyc-ctrl))

(defn clean [{selection-start :selection-start selection-end :selection-end value :value}]
  {:value value :selection-start selection-start :selection-end selection-end})

(defn keydown [el direction history modifiers]
  (fn [e]
    (set-modifiers! e true modifiers)
    (let [is-pressed? (is-pressed? e @modifiers)
          key         (get-command is-pressed?)
          state       (convert el direction history)
          {dir :direction :as new-state}      (machine/handle-key key state)]

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
