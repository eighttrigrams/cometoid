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

(deftest word-part-right
  (is (= (lowlevel/word-part-right (convert "|abc def"))
         (convert "abc| def"))))

(deftest word-part-right-skip-whitespace
  (is (= (lowlevel/word-part-right (convert "abc| def"))
         (convert "abc |def")))
  (is (= (lowlevel/word-part-right (convert "abc|  def"))
         (convert "abc  |def"))))

(deftest word-part-right-to-end-of-line
  (is (= (lowlevel/word-part-right (convert "|abc"))
         (convert "abc|"))))

(deftest word-part-left
  (is (= (lowlevel/word-part-left (convert "abc def|"))
         (convert "abc |def"))))

(deftest word-part-left-skip-whitespace
  (is (= (lowlevel/word-part-left (convert "abc |def"))
         (convert "abc| def")))
  (is (= (lowlevel/word-part-left (convert "abc  |def"))
         (convert "abc|  def"))))

(deftest word-part-left-to-beginning-of-line
  (is (= (lowlevel/word-part-left (convert "abc|"))
         (convert "|abc"))))

(deftest sentence-part-right
  (is (= (lowlevel/sentence-part-right (convert "|abc def. a"))
         (convert "abc def|. a"))))

(deftest sentence-part-right-skip-period
  (is (= (lowlevel/sentence-part-right (convert "abc def|. a"))
         (convert "abc def.| a")))
  (is (= (lowlevel/sentence-part-right (convert "abc def|, a"))
         (convert "abc def,| a")))
  (is (= (lowlevel/sentence-part-right (convert "abc def|; a"))
         (convert "abc def;| a"))))

(deftest sentence-part-right-double-newline
  (is (= (lowlevel/sentence-part-right (convert "|abc\n\ndef"))
         (convert "abc|\n\ndef")))
  (is (= (lowlevel/sentence-part-right (convert "|abc\ndef"))
         (convert "abc\ndef|"))))

(deftest sentence-part-left
  (is (= (lowlevel/sentence-part-left (convert "abc def. abc abc|"))
         (convert "abc def.| abc abc"))))

(deftest delete-word-part-right
  (is (= (lowlevel/delete-word-part-right (convert "|abc def"))
         (convert "| def"))))

(deftest delete-word-part-left
  (is (= (lowlevel/delete-word-part-left (convert "abc def|"))
         (convert "abc |"))))