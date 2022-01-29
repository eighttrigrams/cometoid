(ns lowlevel-test
  (:require [cljs.test :refer (deftest is)]
            [clojure.string :as str]
            lowlevel
            [lowlevel-helpers :as h] ))

(defn convert [s]
  (let [pipe            (.indexOf s "|")
        left            (.indexOf s "[")
        right           (.indexOf s "]")]
    (if (not= pipe -1)
      (let [[l r] (str/split s #"\|")
            value (str l r)]
        {:selection-start pipe
         :selection-end   pipe
         :value           value})
      (let [[l r] (str/split s #"\[")
            value (str l r)
            [l r] (str/split value #"\]")
            value (str l r)]
      {:selection-start left
       :selection-end   (dec right)
       :value           value}))))

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
  (is (= (h/pull-r (lowlevel/word-part-right (convert "|abc def")))
         (convert "abc| def"))))

(deftest word-part-right-with-selection
  (is (= (lowlevel/word-part-right (convert "|abc def"))
         (convert "[abc] def"))))

(deftest word-part-right-skip-whitespace
  (is (= (h/pull-r (lowlevel/word-part-right (convert "abc| def")))
         (convert "abc |def")))
  (is (= (h/pull-r (lowlevel/word-part-right (convert "abc|  def")))
         (convert "abc  |def"))))

(deftest word-part-right-to-end-of-line
  (is (= (h/pull-r (lowlevel/word-part-right (convert "|abc")))
         (convert "abc|"))))

(deftest word-part-left
  (is (= (h/pull-l (lowlevel/word-part-left (convert "abc def|")))
         (convert "abc |def"))))

(deftest word-part-left-with-selection
  (is (= (lowlevel/word-part-left (convert "abc def|"))
         (convert "abc [def]"))))

(deftest word-part-left-skip-whitespace
  (is (= (h/pull-l (lowlevel/word-part-left (convert "abc |def")))
         (convert "abc| def")))
  (is (= (h/pull-l (lowlevel/word-part-left (convert "abc  |def")))
         (convert "abc|  def"))))

(deftest word-part-left-to-beginning-of-line
  (is (= (h/pull-l (lowlevel/word-part-left (convert "abc|")))
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

(deftest newline-after-current
  (is (= (lowlevel/newline-after-current (convert "a|bc\ndef"))
         (convert "abc\n|\ndef"))))

(deftest newline-after-current-end-of-line
  (is (= (lowlevel/newline-after-current (convert "abc|\ndef"))
         (convert "abc\n|\ndef"))))

(deftest newline-after-current-newline-at-end-of-line
  (is (= (lowlevel/newline-after-current (convert "abc\n|"))
         (convert "abc\n\n|"))))

(deftest newline-before-current
  (is (= (lowlevel/newline-before-current (convert "abc\nde|f"))
         (convert "abc\n|\ndef"))))

(deftest newline-before-current-beginning-of-line
  (is (= (lowlevel/newline-before-current (convert "abc\n|def"))
         (convert "abc\n|\ndef"))))

(deftest newline-before-current-beginning-of-file
  (is (= (lowlevel/newline-before-current (convert "|abc"))
         (convert "|\nabc"))))