(ns time-machine
  (:require machine))

(defn- clean [state]
  (select-keys state #{:value :selection-start :selection-end}))

(defn build []
  (let [history (atom '())]
    (fn execute [command state]
      (if (= command :restore)

        (if (seq @history)
          (do 
            (swap! history rest)
            (merge state (first @history)))
          state)

        (let [new-state (machine/execute command (assoc state :history @history))]
          (when (:do-track new-state)
            (swap! history conj (clean state)))
          new-state)))))
