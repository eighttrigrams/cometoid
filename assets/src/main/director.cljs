(ns director)

(defn build [execute]
  (let [direction (atom 0)]
    (fn _execute_ [command state]
      (let [{selection-start :selection-start
             selection-end :selection-end
             dir :direction
             :as new-state} (execute command (assoc state :direction @direction))]

        (reset! direction dir)
        (when (= selection-start selection-end) (reset! direction 0))

        new-state))))