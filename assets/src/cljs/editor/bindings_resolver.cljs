(ns editor.bindings-resolver)

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
   #{"Tab"  #{}}                               :nop})

;; TODO consider passing in environment via binding
(defn- swap-modifiers-on-mac [modifiers]
  (if (= (.indexOf (.-appVersion js/navigator) "Mac") -1)
    modifiers
    (if (and (modifiers :meta) (modifiers :alt))
      modifiers
      (if (not (or (modifiers :meta) (modifiers :alt)))
        modifiers
        (if (modifiers :meta)
          (conj (disj modifiers :meta) :alt)
          (conj (disj modifiers :alt) :meta))))))

(defn- swap-for-mac [key-code modifiers]
  (if (= (.indexOf (.-appVersion js/navigator) "Mac") -1)
    [key-code modifiers]
    (cond (and (= key-code "KeyY")
               (= modifiers #{:alt}))
          ["KeyY" #{:ctrl}]
          (and (= key-code "KeyV")
               (= modifiers #{:alt}))
          ["KeyV" #{:ctrl}]
          (and (= key-code "INSERT")
               (= modifiers #{:alt}))
          ["INSERT" #{:ctrl}]
          (and (= key-code "KeyC")
               (= modifiers #{:alt}))
          ["KeyC" #{:ctrl}]
          (and (= key-code "KeyX")
               (= modifiers #{:alt}))
          ["KeyX" #{:ctrl}]
          :else [key-code modifiers])))

(defn build [transform-state]
  (fn _transform-state_ [[key-code modifiers] {selection-present? :selection-present? :as state}]
    (let [modifiers            (swap-modifiers-on-mac modifiers)
          [key-code modifiers] (swap-for-mac key-code modifiers)
          key                  #{key-code modifiers}
          key                  (if (and selection-present?
                                        (or (= key #{"Backspace" #{}})
                                            (= key #{"Backspace" #{:shift}})))
                                 (conj key :selection-present)
                                 key)
          command              (commands key)]
      (if command
        (transform-state command state)
        (assoc state :dont-prevent-default true)))))