(ns other-test
  (:require [cljs.test :refer (deftest is)]
            editor))

(deftest base-case
  (is (= (editor/hey "hi") "hihi")))

(deftest base-case2
  (is (= (editor/hey "hi") "hihi")))