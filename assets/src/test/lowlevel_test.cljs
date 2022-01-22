(ns lowlevel-test
  (:require [cljs.test :refer (deftest is)]
            [clojure.string :as str]
            lowlevel))

(defn convert [s]
  (let [selection-start (.indexOf s "|")
        [l r] (str/split s #"\|")
        value (str l r)]
    {:selection-start selection-start
     :value value}))

(deftest caret-left-base-case
  (is (= (lowlevel/caret-left (convert "abc|")) 
         (convert "ab|c"))))

(deftest caret-left-beginning-of-line
  (is (= (lowlevel/caret-left (convert "|abc"))
         (convert "|abc"))))

(deftest caret-right-base-case
  (is (= (lowlevel/caret-right (convert "|abc"))
         (convert "a|bc"))))

(deftest caret-right-end-of-line
  (is (= (lowlevel/caret-right (convert "abc|"))
         (convert "abc|"))))