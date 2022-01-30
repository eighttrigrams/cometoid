(ns run-tests
  (:require [cljs-run-test :refer [run-test]] 
            [cljs.test :refer [run-tests]]
            ;; make sure to list all test files here, such that they get watched by shadow-cljs
            lowlevel-test
            machine-test))

(defn init [& _args]
  run-tests ;; list here such that we have no warnings
  run-test
  nil)