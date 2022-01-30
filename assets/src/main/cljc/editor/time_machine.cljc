(ns editor.time-machine)

(def commands-to-track #{:delete-with-selection-present 
                         :delete-wordwise-forward
                         :delete-wordwise-backward
                         :delete-sentence-wise-backward
                         :delete-sentence-wise-forward
                         :insert})

(defn- clean [state]
  (select-keys state #{:value :selection-start :selection-end}))

(defn build [execute]
  (let [history (atom '())]
    (fn _execute_ [command state]
      (if (= command :restore)

        (if (seq @history)
          (let [first (first @history)]
            (swap! history rest)
            (merge state first))
          state)

        (let [new-state (execute command (assoc state :history @history))]
          (when (and (not= nil command (comment "TODO review"))
                     (command commands-to-track))
            (swap! history conj (clean state)))
          new-state)))))
