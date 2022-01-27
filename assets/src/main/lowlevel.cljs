(ns lowlevel)

(def word-stop-pattern "[,;.-_\\n]")

(def word-stop-pattern-incl-whitespace "[,;.-_\\s]")

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

;; TODO inline into word-part-right
(defn move [s selection-start]
  (+ selection-start (cond (starts-with-pattern? s word-stop-pattern)
                           1
                           (starts-with-pattern? s "[ ]")
                           (index-of-substr-or-end s "[^ ]")
                           :else
                           (index-of-substr-or-end s word-stop-pattern-incl-whitespace))))

(defn reverse-state [{value           :value
                      selection-start :selection-start}]
  {:value           (apply str (reverse value))
   :selection-start (- (count value) selection-start)})

(defn leftwards [fun] 
  (fn [state]
    (-> state reverse-state fun reverse-state)))

(defn word-part-right [{value :value selection-start :selection-start}]
  (let [rest (subs value selection-start (count value))
        selection-start (move rest selection-start)]
    {:value value 
     :selection-start selection-start}))

(defn delete-right [fun] (fn [{value :value selection-start :selection-start :as state}]
  (let [{new-selection-start :selection-start} (fun state)]
    {:value (str (subs value 0 selection-start)
                 (subs value new-selection-start (count value)))
     :selection-start selection-start})))

(def delete-character-right (delete-right caret-right))

(def delete-word-part-right (delete-right word-part-right))

(def delete-word-part-left (leftwards delete-word-part-right))

(def word-part-left (leftwards word-part-right))

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

(def sentence-part-left (leftwards sentence-part-right))

(def delete-sentence-part-right (delete-right sentence-part-right))

(def delete-sentence-part-left (leftwards delete-sentence-part-right))

(defn newline-after-current [{value :value selection-start :selection-start :as state}]
  (if (= selection-start (count value))
    state
    ;; TODO deduplicate rest calculation
    (let [rest (subs value selection-start (count value))
          i    (+ selection-start (index-of-substr-or-end rest "\\n"))]
      {:selection-start (inc i)
       :value           (str (subs value 0 i) "\n" (subs value i (count value)))})))

(def newline-before-current (leftwards newline-after-current))