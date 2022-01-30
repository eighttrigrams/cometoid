(ns time-machine)

(def commands-to-track #{:delete})

(defn- clean [state]
  (select-keys state #{:value :selection-start :selection-end}))

(defn build [execute]
  (let [history (atom '())]
    (fn _execute_ [command state]
      (if (= command :restore)

        (if (seq @history)
          (do 
            (swap! history rest)
            (merge state (first @history)))
          state)

        (let [new-state (execute command (assoc state :history @history))]
          (when (and (not= nil command (comment "review")) 
                     (command commands-to-track))
            (swap! history conj (clean state)))
          new-state)))))
