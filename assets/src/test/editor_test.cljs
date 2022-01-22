(ns editor-test
  (:require [cljs.test :refer (deftest is)]
            editor))

(defn init [& _args])


(deftest base-case
  (is (= (editor/hey "hi") "hihi")))

(deftest base-case2
  (is (= (editor/hey "hi") "hihi")))