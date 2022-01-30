(ns editor.helpers)

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