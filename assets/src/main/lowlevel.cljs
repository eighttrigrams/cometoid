(ns lowlevel
  (:require [lowlevel-helpers :as h]))

(def word-stop-pattern "[,;.-_\\n]")

(def word-stop-pattern-incl-whitespace "[,;.-_\\s]")

(def sentence-stop-pattern "([\\n][\\n]|[,;.])")

(defn caret-left [{value :value selection-start :selection-start}]
  (let [selection-start  (if (> selection-start 0)
                           (- selection-start 1)
                           selection-start)]
    {:selection-start selection-start
     :selection-end   selection-start
     :value           value}))

(defn caret-right [{value :value selection-start :selection-start}]
  (let [selection-start  (if (< selection-start (count value))
                           (+ selection-start 1)
                           selection-start)]
    {:selection-start selection-start
     :selection-end   selection-start
     :value           value}))

(defn word-part-right [{value :value selection-start :selection-start selection-end :selection-end :as state}]
  (let [rest            (h/calc-rest state)
        selection-end (+ selection-end
                         (cond (h/starts-with-pattern? rest word-stop-pattern)
                               1
                               (h/starts-with-pattern? rest "[ ]")
                               (h/index-of-substr-or-end rest "[^ ]")
                               :else
                               (h/index-of-substr-or-end rest word-stop-pattern-incl-whitespace)))]
    {:value           value
     :selection-start selection-start
     :selection-end   selection-end}))

(defn delete-right [fun]
  (fn [{value           :value
        selection-end :selection-end
        :as             state}]
    (let [{new-selection-end :selection-end} (fun state)]
      {:value           (str (subs value 0 selection-end)
                             (subs value new-selection-end (count value)))
       :selection-start selection-end
       :selection-end   selection-end})))

(def delete-character-right (delete-right caret-right))

(def delete-word-part-right (delete-right word-part-right))

(def delete-word-part-left (h/leftwards delete-word-part-right))

(def word-part-left (h/leftwards word-part-right))

(defn sentence-part-right 
  [{value           :value
    selection-start :selection-start
    selection-end   :selection-end
    :as             state}]
  (let [rest          (h/calc-rest state)
        selection-end (+ selection-end
                         (if (h/starts-with-pattern? rest sentence-stop-pattern)
                           1
                           (h/index-of-substr-or-end
                            rest
                            sentence-stop-pattern)))]
    {:value           value
     :selection-start selection-start
     :selection-end   selection-end}))

(def sentence-part-left (h/leftwards sentence-part-right))

(def delete-sentence-part-right (delete-right sentence-part-right))

(def delete-sentence-part-left (h/leftwards delete-sentence-part-right))

(defn newline-after-current [{value :value selection-start :selection-start :as state}]
  (if (= selection-start (count value))
    (let [selection-start (inc selection-start)]
      {:value           (str value "\n")
       :selection-start selection-start
       :selection-end   selection-start})
    (let [rest (h/calc-rest state)
          i    (+ selection-start (h/index-of-substr-or-end rest "\\n"))
          selection-start (inc i)]
      {:selection-start selection-start
       :selection-end   selection-start
       :value           (str (subs value 0 i) "\n" (subs value i (count value)))})))

(def newline-before-current (h/leftwards newline-after-current))

(defn insert [clipboard-data]
  (fn [{value           :value
        selection-start :selection-start
        selection-end  :selection-end}]
    (let [value           (str (subs value 0 selection-start)
                               clipboard-data
                               (subs value selection-end (count value)))
          selection-start (+ selection-start (count clipboard-data))]
      {:value           value
       :selection-start selection-start
       :selection-end   selection-start})))