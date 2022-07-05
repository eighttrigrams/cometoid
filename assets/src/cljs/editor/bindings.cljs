(ns editor.bindings)

(def commands
  {#{"KeyY" #{:ctrl}}                          :restore
   #{"KeyJ" #{:ctrl}}                          :caret-left
   #{"KeyL" #{:ctrl}}                          :caret-right
   #{"KeyI" #{:ctrl}}                          :caret-up
   #{"KeyK" #{:ctrl}}                          :caret-down
   #{"KeyL" #{:shift :ctrl}}                   :caret-right-with-selection
   #{"KeyJ" #{:shift :ctrl}}                   :caret-left-with-selection
   #{"KeyK" #{:shift :ctrl}}                   :caret-down-with-selection
   #{"KeyI" #{:shift :ctrl}}                   :caret-up-with-selection
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
   #{"KeyC" #{:ctrl}}                          nil
   #{"Tab"  #{}}                               :insert-tab
   #{"Tab"  #{:shift}}                         :nop})