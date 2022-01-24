(ns lowlevel)

(def sentence-stop-pattern "([\\n][\\n]|[,;.])")

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

(defn move [s selection-start]
  (+ selection-start (index-of-substr-or-end
                      s
                      (str "["
                           (when (starts-with-pattern? s "[\\s]") "^")
                           "\\s]"))))

(defn word-part-right [{value :value selection-start :selection-start}]
  (let [rest (subs value selection-start (count value))
        selection-start (move rest selection-start)]
    {:value value 
     :selection-start selection-start}))

;; TODO extract invert function
(defn word-part-left [{value           :value
                       selection-start :selection-start}]
  (let [inv             #(- (count value) %1)
        selection-start (inv selection-start)
        rest            (subs (apply str (reverse value)) selection-start (count value))]
    {:value           value 
     :selection-start (inv (move rest selection-start))}))

(defn moves [s selection-start]
  (+ selection-start 
     (if (starts-with-pattern? s sentence-stop-pattern)
       1
       (index-of-substr-or-end
        s
        sentence-stop-pattern))))

(defn sentence-part-right [{value :value selection-start :selection-start}]
  (let [rest (subs value selection-start (count value))
        selection-start (moves rest selection-start)]
    {:value value
     :selection-start selection-start}))

(defn sentence-part-left [{value :value selection-start :selection-start}]
  (let [inv             #(- (count value) %1)
        selection-start (inv selection-start)
        rest (subs (apply str (reverse value)) selection-start (count value))]
    {:value value
     :selection-start (inv (moves rest selection-start))}))