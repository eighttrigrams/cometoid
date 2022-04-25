(ns editor.lowlevel-test
  (:require [clojure.test :refer (deftest is)]
            [test-helpers :as th]
            [editor.lowlevel :as lowlevel]
            [editor.helpers :as h] ))

(deftest caret-left-base-case
  (is (th/equal (h/pull-l (lowlevel/caret-left (th/convert "abc|")))
                (th/convert "ab|c"))))

(deftest caret-left-beginning-of-line
  (is (th/equal (h/pull-l (lowlevel/caret-left (th/convert "|abc")))
                (th/convert "|abc"))))

(deftest caret-right-base-case
  (is (th/equal (h/pull-r (lowlevel/caret-right (th/convert "|abc")))
                (th/convert "a|bc"))))

(deftest caret-right-end-of-line
  (is (th/equal (h/pull-r (lowlevel/caret-right (th/convert "abc|")))
                (th/convert "abc|"))))

(deftest word-part-right
  (is (th/equal (h/pull-r (lowlevel/word-part-right (th/convert "|abc def")))
                (th/convert "abc| def"))))

(deftest word-part-right-with-selection
  (is (th/equal (lowlevel/word-part-right (th/convert "|abc def"))
                (th/convert "[abc] def"))))

(deftest word-part-right-skip-whitespace
  (is (th/equal (h/pull-r (lowlevel/word-part-right (th/convert "abc| def")))
                (th/convert "abc |def")))
  (is (th/equal (h/pull-r (lowlevel/word-part-right (th/convert "abc|  def")))
                (th/convert "abc  |def"))))

(deftest word-part-right-to-end-of-line
  (is (th/equal (h/pull-r (lowlevel/word-part-right (th/convert "|abc")))
                (th/convert "abc|"))))

(deftest word-part-left
  (is (th/equal (h/pull-l (lowlevel/word-part-left (th/convert "abc def|")))
                (th/convert "abc |def"))))

(deftest word-part-left-with-selection
  (is (th/equal (lowlevel/word-part-left (th/convert "abc def|"))
                (th/convert "abc [def]"))))

(deftest word-part-left-skip-whitespace
  (is (th/equal (h/pull-l (lowlevel/word-part-left (th/convert "abc |def")))
                (th/convert "abc| def")))
  (is (th/equal (h/pull-l (lowlevel/word-part-left (th/convert "abc  |def")))
                (th/convert "abc|  def"))))

(deftest word-part-left-to-beginning-of-line
  (is (th/equal (h/pull-l (lowlevel/word-part-left (th/convert "abc|")))
                (th/convert "|abc"))))

(deftest sentence-part-right
  (is (th/equal (h/pull-r (lowlevel/sentence-part-right (th/convert "|abc def. a")))
                (th/convert "abc def|. a"))))

(deftest sentence-part-right-with-selection
  (is (th/equal (lowlevel/sentence-part-right (th/convert "|abc def. a"))
                (th/convert "[abc def]. a"))))

(deftest sentence-part-left-with-selection-backwards
  (is (th/equal ((comp h/flip lowlevel/sentence-part-left h/flip) (th/convert "[abc def]. a"))
                (th/convert "|abc def. a"))))

(deftest sentence-part-right-skip-period
  (is (th/equal (h/pull-r (lowlevel/sentence-part-right (th/convert "abc def|. a")))
                (th/convert "abc def.| a")))
  (is (th/equal (h/pull-r (lowlevel/sentence-part-right (th/convert "abc def|, a")))
                (th/convert "abc def,| a")))
  (is (th/equal (h/pull-r (lowlevel/sentence-part-right (th/convert "abc def|; a")))
                (th/convert "abc def;| a"))))

(deftest sentence-part-right-double-newline
  (is (th/equal (h/pull-r (lowlevel/sentence-part-right (th/convert "|abc\n\ndef")))
                (th/convert "abc|\n\ndef")))
  (is (th/equal (h/pull-r (lowlevel/sentence-part-right (th/convert "|abc\ndef")))
                (th/convert "abc\ndef|"))))

(deftest sentence-part-left
  (is (th/equal (h/pull-l (lowlevel/sentence-part-left (th/convert "abc def. abc abc|")))
                (th/convert "abc def.| abc abc"))))

(deftest sentence-part-left-with-selection
  (is (th/equal (lowlevel/sentence-part-left (th/convert "abc def. abc abc|"))
                (th/convert "abc def.[ abc abc]"))))

(deftest delete-word-part-right
  (is (th/equal (lowlevel/delete-word-part-right (th/convert "|abc def"))
                (th/convert "| def"))))

(deftest delete-word-part-left
  (is (th/equal (lowlevel/delete-word-part-left (th/convert "abc def|"))
                (th/convert "abc |"))))

(deftest newline-after-current
  (is (th/equal (lowlevel/newline-after-current (th/convert "a|bc\ndef"))
                (th/convert "abc\n|\ndef"))))

(deftest newline-after-current-end-of-line
  (is (th/equal (lowlevel/newline-after-current (th/convert "abc|\ndef"))
                (th/convert "abc\n|\ndef"))))

(deftest newline-after-current-newline-at-end-of-line
  (is (th/equal (lowlevel/newline-after-current (th/convert "abc\n|"))
                (th/convert "abc\n\n|"))))

(deftest newline-before-current
  (is (th/equal (lowlevel/newline-before-current (th/convert "abc\nde|f"))
                (th/convert "abc\n|\ndef"))))

(deftest newline-before-current-beginning-of-line
  (is (th/equal (lowlevel/newline-before-current (th/convert "abc\n|def"))
                (th/convert "abc\n|\ndef"))))

(deftest newline-before-current-beginning-of-file
  (is (th/equal (lowlevel/newline-before-current (th/convert "|abc"))
                (th/convert "|\nabc"))))