(ns editor.bindings-resolver)

(def commands
  {#{"KeyY" #{:ctrl}}                          :restore
   #{"KeyJ" #{:ctrl}}                          :caret-left
   #{"KeyL" #{:ctrl}}                          :caret-right
   #{"KeyL" #{:shift :ctrl}}                   :caret-left-with-selection
   #{"KeyJ" #{:shift :ctrl}}                   :caret-right-with-selection
   #{"KeyL" #{:meta}}                          :word-part-right
   #{"KeyJ" #{:meta}}                          :word-part-left
   #{"KeyL" #{:shift :meta}}                   :move-selection-wordwise-right
   #{"KeyJ" #{:shift :meta}}                   :move-selection-wordwise-left
   #{"KeyL" #{:alt}}                           :sentence-right
   #{"KeyJ" #{:alt}}                           :sentence-left
   #{"KeyL" #{:shift :alt}}                    :sentence-right-with-selection
   #{"KeyJ" #{:shift :alt}}                    :sentence-left-with-selection
   #{"Backspace" #{} :selection-present}       :delete-with-selection-present
   #{"Backspace" #{:shift} :selection-present} :delete-with-selection-present
   #{"Backspace" #{}}                          :delete
   #{"Backspace" #{:shift}}                    :delete-forward
   #{"Backspace" #{:meta}}                     :delete-wordwise-backward
   #{"Backspace" #{:shift :meta}}              :delete-wordwise-forward
   #{"Backspace" #{:alt}}                      :delete-sentence-wise-backward
   #{"Backspace" #{:shift :alt}}               :delete-sentence-wise-forward
   #{"Enter" #{:shift}}                        :shift-enter
   #{"Enter" #{:alt}}                          :alt-enter
   #{"INSERT" #{:ctrl}}                        :insert
   #{"KeyV" #{:ctrl}}                          nil
   #{"KeyX" #{:ctrl}}                          nil
   #{"KeyC" #{:ctrl}}                          nil})

(defn build [execute]
  (fn _execute_ [[key-code modifiers] {selection-present? :selection-present? :as state}]
    (let [key #{key-code modifiers}
          key (if (and selection-present? 
                       (or (= key #{"Backspace" #{}})
                           (= key #{"Backspace" #{:shift}})))
                (conj key :selection-present)
                key)
          command (commands key)]
      (if command
        (execute command state)
        (assoc state :dont-prevent-default true)))))