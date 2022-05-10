(ns test-helpers
  (:require [clojure.string :as str]
            [clojure.set :refer [subset?]]))

(defn matches-model
  "Tests if map1 has al the keys the model has,
   and then tests if those keys have the corresponding values.
   map1 may have additional values not specified in model"
  [map1 model]
  (let [map1 (reduce (fn [map1 [key]]
                          (if (not (contains? model key))
                            (dissoc map1 key)
                            map1))
                        map1 map1)]
    (subset? (set map1) (set model))))

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