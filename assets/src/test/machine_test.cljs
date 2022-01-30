(ns machine-test
  (:require [cljs.test :refer (deftest is)]
            machine))

(deftest base-case
  (is (= {:direction       0
          :selection-start 1
          :selection-end   1
          :value           "abc"}
         (machine/execute
          :caret-left
          {:direction       0
           :selection-start 2
           :selection-end   2
           :value           "abc"}))))

(deftest delete-selection
  (is (= {:selection-start 1
          :selection-end   1
          :value           "adef"
          :direction 0}
         (machine/execute
          :delete
          {:selection-start 1
           :selection-end 3
           :value "abcdef"}))))
