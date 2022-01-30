(ns bindings)

(defn get-command [is-pressed?]
  (cond (is-pressed? "KeyY" #{:ctrl})
        :restore
        (is-pressed? "KeyL" #{:ctrl})
        :caret-left
        (is-pressed? "KeyJ" #{:ctrl})
        :caret-right
        (is-pressed? "KeyL" #{:shift :ctrl})
        :caret-left-with-selection
        (is-pressed? "KeyJ" #{:shift :ctrl})
        :caret-right-with-selection
        (is-pressed? "KeyL" #{:meta})
        :word-part-left
        (is-pressed? "KeyJ" #{:meta})
        :word-part-right
        (is-pressed? "KeyL" #{:shift :meta})
        :word-part-right-with-selection
        (is-pressed? "KeyJ" #{:shift :meta})
        :word-part-left-with-selection
        (is-pressed? "KeyL" #{:alt})
        :sentence-right
        (is-pressed? "KeyJ" #{:alt})
        :sentence-left
        (is-pressed? "KeyL" #{:shift :alt})
        :sentence-right-with-selection
        (is-pressed? "KeyJ" #{:shift :alt})
        :sentence-left-with-selection
        (is-pressed? "Backspace" #{:shift})
        :shift-backspace
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