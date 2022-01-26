(ns lowlevel)

(def word-stop-pattern "[,;.-_]")

(def word-stop-pattern-incl-whitespace "[,;.-_\\s\\n\\t]")

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
  (+ selection-start (cond (starts-with-pattern? s word-stop-pattern)
                           1
                           (starts-with-pattern? s "[\\s]")
                           (index-of-substr-or-end s "[^\\s]")
                           :else
                           (index-of-substr-or-end s word-stop-pattern-incl-whitespace))))

(defn reverse-state [{value           :value
                selection-start :selection-start}]
  {:value           (apply str (reverse value))
   :selection-start (- (count value) selection-start)})

(defn leftwards [fun state]
  (reverse-state (fun (reverse-state state))))

(defn word-part-right [{value :value selection-start :selection-start}]
  (let [rest (subs value selection-start (count value))
        selection-start (move rest selection-start)]
    {:value value 
     :selection-start selection-start}))

(defn delete-word-part-right [{value :value selection-start :selection-start :as state}]
  (let [{new-selection-start :selection-start} (word-part-right state)]
    {:value (str (subs value 0 selection-start)
                 (subs value new-selection-start (count value)))
     :selection-start selection-start}))

(defn delete-word-part-left [state]
  (leftwards delete-word-part-right state))

(defn word-part-left [state]
  (leftwards word-part-right state))

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

(defn sentence-part-left [state]
  (leftwards sentence-part-right state))