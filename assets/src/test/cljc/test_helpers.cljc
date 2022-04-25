(ns test-helpers
  (:require [clojure.string :as str]))

(defn equal [map1 map2]
  (let [cmp (fn [map1 map2]
              (reduce (fn [acc [key val]]
                        (and acc 
                             (or 
                              (not (contains? map2 key))
                              (= val (key map2))))) true map1))]
    (and (cmp map1 map2)
         (cmp map2 map1))))

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