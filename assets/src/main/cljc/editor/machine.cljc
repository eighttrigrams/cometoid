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

    :caret-right-with-selection
    (if (= direction -1)
      ((comp h/flip lowlevel/caret-right h/flip) state)
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

(defn build [] 
  (let [direction-atom (atom 0)]
    (fn transform-state [command state]
      (let [direction @direction-atom
            {selection-start :selection-start
             selection-end   :selection-end
             dir             :direction
             :as             new-state} (_transform-state command state direction)]
        (when dir (reset! direction-atom dir))
        (when (= selection-start selection-end) (reset! direction-atom 0))
        new-state))))
