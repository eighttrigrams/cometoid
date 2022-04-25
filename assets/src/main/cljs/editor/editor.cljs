(ns editor.editor
  (:require [editor.helpers :as helpers]
            [editor.machine :as machine]
            [editor.time-machine :as time-machine]
            [editor.bindings-resolver :as bindings-resolver]))

(defn set-values! [el {selection-start :selection-start
                       selection-end :selection-end
                       value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-end))

(defn set-modifiers! [e b modifiers]
  (let [code (case (.-code e)
               "ControlLeft" :ctrl
               "ControlRight" :ctrl
               "ShiftLeft" :shift
               "AltLeft" :alt
               "MetaLeft" :meta
               nil)]
    (when code (swap! modifiers (if b conj disj) code))))

(defn construct-state [el position-in-line:atom]
  (let [selection-start (.-selectionStart el)
        selection-end (.-selectionEnd el)
        ;; TODO simplify
        [pos-in-line] (helpers/cursor-position-in-line (.-value el) selection-start)]
    {:value                           (.-value el)
     :selection-start                 selection-start
     :selection-end                   selection-end
     :selection-present?              (not= selection-start selection-end)
     ;; TODO review if this should rather be handled in machine, like direction.
     ;; TODO set automatically in machine, unless it is prevented with a new :dont-adjust-position-in-line property.
     ;; :position-in-line  
     ;;   The position in the line above/below to which caret-up/caret-down
     ;;   will get us to, provided the line above/below is long enough.
     :position-in-line                (if @position-in-line:atom ;; TODO maybe modify somewhere above in the call hierarchy
                                        @position-in-line:atom
                                        (do (reset! position-in-line:atom pos-in-line)
                                            pos-in-line))
     :prevent-adjust-position-in-line false
     :dont-prevent-default            false}))

(defn paste [el modifiers transform-state position-in-line:atom]
  (fn [e]
    (.preventDefault e)
    (->> (.getData (.-clipboardData e) "Text")
         (assoc (construct-state el position-in-line:atom) :clipboard-data)
         (transform-state ["INSERT" @modifiers])
         (set-values! el))))

(defn keydown [el modifiers transform-state position-in-line:atom]
  (fn [e]
    (prn "atm" @position-in-line:atom)
    (set-modifiers! e true modifiers)
    (let [new-state   (transform-state [(.-code e) @modifiers] 
                                       (construct-state el position-in-line:atom))]
      (set-values! el new-state)
      ;; TODO review
      (reset! position-in-line:atom (:position-in-line new-state))
      (when (not= (:dont-prevent-default new-state) true) (.preventDefault e)))))

(defn keyup [_el modifiers]
  (fn [e]
    (set-modifiers! e false modifiers)))

(defn mouseleave [_el modifiers]
  (fn [_e]
    (reset! modifiers #{})))

(defn ^:export new [el]
  (let [modifiers (atom #{})
        position-in-line (atom nil)
        transform-state (-> (machine/build) time-machine/build bindings-resolver/build)]
    (.addEventListener el "paste" (paste el modifiers transform-state position-in-line))
    (.addEventListener el "keydown" (keydown el modifiers transform-state position-in-line))
    (.addEventListener el "keyup" (keyup el modifiers))
    (.addEventListener el "mouseleave" (mouseleave el modifiers))))
