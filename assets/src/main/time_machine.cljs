(ns time-machine
  (:require machine))

;; TODO use take keys
(defn- clean [{selection-start :selection-start 
               selection-end :selection-end 
               value :value}]
  {:value value 
   :selection-start selection-start 
   :selection-end selection-end})

;; TODO don't assoc history into state, instead handle restore here
(defn build []
  (let [history (atom '())]
    (fn execute [command state]
      (let [new-state (machine/execute command (assoc state :history @history))]
        (if (:do-pop-history new-state)
          (swap! history rest)
          (when (:do-track new-state)
            (swap! history conj (clean state))))
        new-state))))
