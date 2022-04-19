(ns editor.machine-test
  (:require [cljs.test :refer (deftest is)]
            [editor.machine :as machine]))

(def transform-state (machine/build))

(deftest base-case
  (is (= {:selection-start 1
          :selection-end   1
          :value           "abc"}
         (transform-state
          :caret-left
          {:selection-start 2
           :selection-end   2
           :value           "abc"}))))

(deftest delete-selection
  (is (= {:direction 0
          :selection-start 1
          :selection-end   1
          :value           "adef"}
         (transform-state
          :delete-with-selection-present
          {:selection-start 1
           :selection-end 3
           :value "abcdef"}))))

(deftest start-leftwards-oriented-selection
  (is (= {:direction -1
          :selection-start 2
          :selection-end   3
          :value           "abcdef"}
         (transform-state
          :caret-left-with-selection
          {:selection-start 3
           :selection-end 3
           :direction 0
           :value "abcdef"}))))

(deftest revert-leftwards-oriented-selection
  (is (= {:selection-start 2
          :direction       -1
          :selection-end   3
          :value           "abcdef"}
         (->> {:selection-start 3
               :selection-end 3
               :value "abcdef"}
              (transform-state :caret-left-with-selection)
              (transform-state :caret-left-with-selection)
              (transform-state :caret-right-with-selection)))))
