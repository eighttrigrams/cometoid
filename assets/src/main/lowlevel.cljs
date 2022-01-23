(ns lowlevel
  (:require [clojure.string :as str]))

(defn caret-left [{value :value selection-start :selection-start}]
  {:selection-start (if (> selection-start 0)
                     (- selection-start 1)
                     selection-start)
   :value value})

(defn caret-right [{value :value selection-start :selection-start}]
  {:selection-start (if (< selection-start (count value))
                     (+ selection-start 1)
                     selection-start)
   :value value})

(defn index-of-substr-or-end [s what]
  (loop [rst s
         i 0]
    (if (= i (count s))
      i
      (if (not (str/starts-with? rst what))
        (recur (apply str (rest rst)) (inc i))
        i))))

(defn word-part-right [{value :value selection-start :selection-start}]
  (let [rest (subs value selection-start (count value))
        selection-start (+ selection-start (index-of-substr-or-end rest " "))]
    {:value value :selection-start selection-start}))
