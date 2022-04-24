(ns editor.helpers)

(defn starts-with-pattern? [s pattern]
  (not (nil? (re-find (re-pattern (str "^" pattern)) s))))

(defn cursor-position-in-line
  "Returns [idx-of-selection-start-cursor-from-start-of-current-line 
            index-of-start-of-current-line-in-context-of-value]
  "
  [{value           :value
    selection-start :selection-start}]
  (loop [i -1
         selection-start selection-start]
    (if (or (= selection-start -1)
            (and (not (= i -1))
                 (= (get value selection-start) \newline)))
      [i (+ selection-start 1)]
      (recur (+ i 1)
             (- selection-start 1)))))

(defn index-of-substr-or-end 
  "Returns 
     the index of `pattern` in `s` - if it has been found
     the length of s               - if `pattern` could not be found in `s`
  "
  [s pattern]
  (loop [rst s
         i 0]
    (if (= i (count s))
      i
      (if-not (starts-with-pattern? rst pattern)
        (recur (apply str (rest rst)) (inc i))
        i))))

(defn reverse-state [{value           :value
                      selection-start :selection-start
                      selection-end   :selection-end
                      :as state}]
  (-> state
      (assoc :value (apply str (reverse value)))
      (assoc :selection-start (- (count value) selection-end))
      (assoc :selection-end (- (count value) selection-start))))

(defn leftwards [fun]
  (fn [state]
    (-> state reverse-state fun reverse-state)))

(defn calc-rest [{value :value selection-end :selection-end}]
  (subs value selection-end (count value)))

(defn pull-r [{selection-end :selection-end :as state}]
  (assoc state :selection-start selection-end))

(defn pull-l [{selection-start :selection-start :as state}]
  (assoc state :selection-end selection-start))

(defn flip [{selection-start :selection-start selection-end :selection-end :as state}]
  (-> state
      (assoc :selection-end selection-start)
      (assoc :selection-start selection-end)))