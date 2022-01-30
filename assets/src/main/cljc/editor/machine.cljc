(ns editor.machine
  (:require [editor.lowlevel :as lowlevel]
            [editor.lowlevel-helpers :as h]))

(defn execute [key {direction       :direction 
                    selection-start :selection-start
                    selection-end   :selection-end
                    :as             state}]
  (case key
    nil #_(comment "review")
    (assoc state :dont-prevent-default true)

    :caret-right
    ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/caret-right) state)
    :caret-left
    ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/caret-left) state)

    :caret-left-with-selection
    (if (= direction -1)
      ((comp h/flip lowlevel/caret-right h/flip) state)
      (assoc (lowlevel/caret-right state) :direction 1))

    :caret-right-with-selection
    (if (= direction 1)
      ((comp h/flip lowlevel/caret-left h/flip) state)
      (assoc (lowlevel/caret-left state) :direction -1))

    :word-part-right
    ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/word-part-right) state)
    :word-part-left
    ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/word-part-left) state)

    :move-selection-wordwise-right
    (if (= direction -1)
      ((comp h/flip lowlevel/word-part-right h/flip) state)
      (assoc (lowlevel/word-part-right state) :direction 1))

    :move-selection-wordwise-left
    (if (= direction 1)
      ((comp h/flip lowlevel/word-part-left h/flip) state)
      (assoc (lowlevel/word-part-left state) :direction -1))

    :sentence-right
    ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/sentence-part-right) state)
    :sentence-left
    ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/sentence-part-left) state)

    :sentence-right-with-selection
    (if (= direction -1)
      ((comp h/flip lowlevel/sentence-part-right h/flip) state)
      (assoc (lowlevel/sentence-part-right state) :direction 1))

    :sentence-left-with-selection
    (if (= direction 1)
      ((comp h/flip lowlevel/sentence-part-left h/flip) state)
      (assoc (lowlevel/sentence-part-left state) :direction -1))

    :delete
    (if (= selection-start selection-end)
      (lowlevel/delete-character-left state)
      (lowlevel/delete-selection state))

    :delete-forward
    (lowlevel/delete-character-right state)
    
    :meta-backspace
    (lowlevel/delete-word-part-left state)
    :shift-meta-backspace
    (lowlevel/delete-word-part-right state)
    :alt-backspace
    (lowlevel/delete-sentence-part-left state)
    :shift-alt-backspace
    (lowlevel/delete-sentence-part-right state)
    :shift-enter
    (lowlevel/newline-after-current state)
    :alt-enter
    (lowlevel/newline-before-current state)

    :keyv-ctrl
    (-> state
        (assoc :dont-prevent-default true)
        (assoc :direction 0))

    :keyx-ctrl
    (-> state
        (assoc :dont-prevent-default true)
        (assoc :direction 0))

    :keyc-ctrl
    (-> state
        (assoc :dont-prevent-default true)
        (assoc :direction 0))

    (let [{selection-start :selection-start
           selection-end   :selection-end} state]
      (if (= selection-start selection-end)
        (assoc state :dont-prevent-default true)
        state))))
