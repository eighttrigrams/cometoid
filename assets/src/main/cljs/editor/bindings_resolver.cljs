(ns editor.bindings-resolver)

(defn is-pressed? [key-code modifiers]
  (fn [key-code-expected modifiers-expected]
    (and (= key-code key-code-expected)
         (= modifiers modifiers-expected))))

(defn get-command [is-pressed? selection-present?]
  (cond (is-pressed? "KeyY" #{:ctrl})
        :restore
        (is-pressed? "KeyJ" #{:ctrl})
        :caret-left
        (is-pressed? "KeyL" #{:ctrl})
        :caret-right
        (is-pressed? "KeyL" #{:shift :ctrl})
        :caret-left-with-selection
        (is-pressed? "KeyJ" #{:shift :ctrl})
        :caret-right-with-selection
        (is-pressed? "KeyL" #{:meta})
        :word-part-right
        (is-pressed? "KeyJ" #{:meta})
        :word-part-left
        (is-pressed? "KeyL" #{:shift :meta})
        :move-selection-wordwise-right
        (is-pressed? "KeyJ" #{:shift :meta})
        :move-selection-wordwise-left
        (is-pressed? "KeyL" #{:alt})
        :sentence-right
        (is-pressed? "KeyJ" #{:alt})
        :sentence-left
        (is-pressed? "KeyL" #{:shift :alt})
        :sentence-right-with-selection
        (is-pressed? "KeyJ" #{:shift :alt})
        :sentence-left-with-selection

        (and selection-present? (is-pressed? "Backspace" #{}))
        :delete-with-selection-present
        (and selection-present? (is-pressed? "Backspace" #{:shift}))
        :delete-with-selection-present

        (is-pressed? "Backspace" #{})
        :delete
        (is-pressed? "Backspace" #{:shift})
        :delete-forward

        (is-pressed? "Backspace" #{:meta})
        :meta-backspace
        (is-pressed? "Backspace" #{:shift :meta})
        :shift-meta-backspace
        (is-pressed? "Backspace" #{:alt})
        :alt-backspace
        (is-pressed? "Backspace" #{:shift :alt})
        :shift-alt-backspace
        (is-pressed? "Enter" #{:shift})
        :shift-enter
        (is-pressed? "Enter" #{:alt})
        :alt-enter
        (is-pressed? "KeyV" #{:ctrl})
        :keyv-ctrl
        (is-pressed? "KeyX" #{:ctrl})
        :keyx-ctrl
        (is-pressed? "KeyC" #{:ctrl})
        :keyc-ctrl))

(defn build [execute]
  (fn _execute_ [[key-code modifiers] {selection-present? :selection-present? :as state}]
    (let [is-pressed? (is-pressed? key-code modifiers)
          command (get-command is-pressed? selection-present?)]
      (if command
        (execute command state)
        (assoc state :dont-prevent-default true)))))