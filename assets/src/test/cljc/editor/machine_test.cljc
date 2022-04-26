(ns editor.machine-test
  (:require [clojure.test :refer (deftest is)]
            [test-helpers :as th]
            [editor.machine :as machine]))

(def transform-state (machine/build))

(deftest base-case
  (is (th/matches-model (transform-state
                 :caret-left
                 {:selection-start 2
                  :selection-end   2
                  :value           "abc"})
                {:selection-start 1
                 :selection-end   1
                 :value           "abc"})))

(deftest delete-selection
  (is (th/matches-model (transform-state
                 :delete-with-selection-present
                 {:selection-start 1
                  :selection-end   3
                  :value           "abcdef"})
                {:direction       0
                 :selection-start 1
                 :selection-end   1
                 :value           "adef"})))

(deftest start-leftwards-oriented-selection
  (is (th/matches-model (transform-state
                 :caret-left-with-selection
                 {:selection-start 3
                  :selection-end   3
                  :direction       0
                  :value           "abcdef"})
                {:direction       -1
                 :selection-start 2
                 :selection-end   3
                 :value           "abcdef"})))

(deftest revert-leftwards-oriented-selection
  (is (th/matches-model (->> {:selection-start 3
                      :selection-end   3
                      :value           "abcdef"}
                     (transform-state :caret-left-with-selection)
                     (transform-state :caret-left-with-selection)
                     (transform-state :caret-right-with-selection))
                {:selection-start 2
                 :direction       -1
                 :selection-end   3
                 :value           "abcdef"})))
