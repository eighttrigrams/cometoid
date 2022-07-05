(ns editor.bindings-resolver)

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

(defn build [commands] 
  (fn [transform-state]
    (fn _transform-state_ [[key-code modifiers] {selection-present? :selection-present?
                                                 :as                state}]
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
          (assoc state :dont-prevent-default true))))))