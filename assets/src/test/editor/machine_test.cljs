(ns editor.machine-test
  (:require [cljs.test :refer (deftest is)]
            [editor.machine :as machine]))

(def execute (machine/build))

(deftest base-case
  (is (= {:selection-start 1
          :selection-end   1
          :value           "abc"}
         (execute
          :caret-left
          {:selection-start 2
           :selection-end   2
           :value           "abc"}))))

(deftest delete-selection
  (is (= {:direction 0
          :selection-start 1
          :selection-end   1
          :value           "adef"}
         (execute
          :delete-with-selection-present
          {:selection-start 1
           :selection-end 3
           :value "abcdef"}))))
