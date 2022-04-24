(ns test-helpers
  (:require [clojure.string :as str]))

(defn convert [s]
  (let [pipe            (.indexOf s "|")]
    (if (not= pipe -1)
      (let [[l r] (str/split s #"\|")
            value (str l r)]
        {:selection-start pipe
         :selection-end   pipe
         :value           value})
      (let [left  (.indexOf s "[")
            right (.indexOf s "]")
            [l r] (str/split s #"\[")
            value (str l r)
            [l r] (str/split value #"\]")
            value (str l r)]
        {:selection-start left
         :selection-end   (dec right)
         :value           value}))))