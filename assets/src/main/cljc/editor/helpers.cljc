(ns editor.helpers)

(defn starts-with-pattern? [s pattern]
  (not (nil? (re-find (re-pattern (str "^" pattern)) s))))

(defn cursor-position-in-line
  "Returns [position-within-current-line
            position-of-current-line
            previous-line-exists?]
  "
  [value position]
  (let [start-i -1]
    (loop [i               start-i
           position position]
      (let [has-reached-beginning-of-file? (= position start-i)
            has-encountered-newline?       (and (not (= i start-i))
                                                (= (get value position) \newline))]
        (if (or has-reached-beginning-of-file?
                has-encountered-newline?)
          [i (inc position) (not has-reached-beginning-of-file?)]
          (recur (inc i)
                 (dec position)))))))

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