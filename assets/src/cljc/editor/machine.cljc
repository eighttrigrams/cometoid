(ns editor.machine
  (:require [editor.lowlevel :as lowlevel]
            [editor.helpers :as h]))

(defn- _transform-state [command state direction]
  (case command
    :insert
    (lowlevel/insert state)

    :caret-right
    ((comp (if (= direction -1) h/pull-l h/pull-r) lowlevel/caret-right) state)
    :caret-left
    ((comp (if (= direction 1) h/pull-r h/pull-l) lowlevel/caret-left) state)

    :caret-up
    ((comp h/pull-l lowlevel/same-position-previous-line) state)
    :caret-down
    ((comp h/pull-r lowlevel/same-position-next-line) state)

    :caret-down-with-selection
    (if (= direction -1)
      ((comp h/flip lowlevel/same-position-next-line h/flip) state)
      (assoc (lowlevel/same-position-next-line state) :direction 1))

    :caret-up-with-selection
    (if (= direction 1)
      ((comp h/flip lowlevel/same-position-previous-line h/flip) state)
      (assoc (lowlevel/same-position-previous-line state) :direction -1))

    :caret-right-with-selection
    (if (= direction -1)
      ((comp h/flip lowlevel/caret-right h/flip) state) ;; TODO add wrap-flip function or macro
      (assoc (lowlevel/caret-right state) :direction 1))

    :caret-left-with-selection
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

    :delete (lowlevel/delete-character-left state)
    :delete-forward (lowlevel/delete-character-right state)
    :delete-with-selection-present (lowlevel/delete-selection state)

    :delete-wordwise-backward
    (lowlevel/delete-word-part-left state)
    :delete-wordwise-forward
    (lowlevel/delete-word-part-right state)
    :delete-sentence-wise-backward
    (lowlevel/delete-sentence-part-left state)
    :delete-sentence-wise-forward
    (lowlevel/delete-sentence-part-right state)
    :shift-enter
    (lowlevel/newline-after-current state)
    :alt-enter
    (lowlevel/newline-before-current state)))

(defn adjust-position-in-line 
  [{prevent-adjust-position-in-line :prevent-adjust-position-in-line
    value                           :value
    selection-start                 :selection-start
    :as                             state}]
  (if prevent-adjust-position-in-line
    state
    (let [[pos-in-line] (h/cursor-position-in-line value selection-start)]
      (assoc state :position-in-line pos-in-line))))

(defn build [] 
  (comment "direction-atom: 
            0 if selection-start = selection-end
            1 if selection-end is being moved
            -1 if selection-start is being moved
            ")
  (let [direction:atom (atom 0)]
    (fn transform-state [command state]
      (let [direction @direction:atom
            {selection-start :selection-start
             selection-end   :selection-end
             dir             :direction
             :as             new-state} (_transform-state command state direction)
            new-state (adjust-position-in-line new-state)]
        (when dir (reset! direction:atom dir))
        (when (= selection-start selection-end) (reset! direction:atom 0))
        #_(prn new-state)
        new-state))))
