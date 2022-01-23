(ns lowlevel)

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

(defn starts-with-pattern? [s pattern]
  (not (nil? (re-find (re-pattern (str "^" pattern)) s))))

(defn index-of-substr-or-end [s pattern]
  (loop [rst s
         i 0]
    (if (= i (count s))
      i
      (if-not (starts-with-pattern? rst pattern)
        (recur (apply str (rest rst)) (inc i))
        i))))

(defn word-part-right [{value :value selection-start :selection-start}]
  (let [rest (subs value selection-start (count value))
        selection-start (+ selection-start (index-of-substr-or-end
                                            rest
                                            (str "["
                                                 (when (starts-with-pattern? rest "[\\s]") "^")
                                                 "\\s]")))]
    {:value value :selection-start selection-start}))
