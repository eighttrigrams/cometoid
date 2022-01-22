(ns editor
  (:require lowlevel))

(def orig-modifiers {:alt? false
                     :shift? false
                     :meta? false
                     :ctrl? false})

(def modifiers (atom orig-modifiers))

(defn hey [s] (str s s))

(defn set-values [el {selection-start :selection-start
                      value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-start))

(defn set-modifiers [e b]
  (when (= (.-code e) "ControlLeft") (swap! modifiers assoc :ctrl? b))
  (when (= (.-code e) "ShiftLeft") (swap! modifiers assoc :shift? b))
  (when (= (.-code e) "AltLeft") (swap! modifiers assoc :alt? b))
  (when (= (.-code e) "MetaLeft") (swap! modifiers assoc :meta? b)))

(defn modifiers-matching? [modifiers-expected modifiers]
  (let [modifiers-pressed (->> modifiers
                               (filter (fn [[_k v]] (= v true)))
                               (map first))]
    (= (vec modifiers-expected) modifiers-pressed)))

(defn is-pressed? [e code modifiers-expected]
  (and (= (.-code e) code) 
       (modifiers-matching? modifiers-expected @modifiers)))

(defn keydown [el]
  (fn [e]
    (set-modifiers e true)

    (cond (is-pressed? e "KeyJ" [:ctrl?])
          (do (.preventDefault e)
              (let [values (lowlevel/caret-left {:value           (.-value el)
                                                 :selection-start (.-selectionStart el)})]
                (set-values el values)))
          (is-pressed? e "KeyL" [:ctrl?])
          (do (.preventDefault e)
              (let [values (lowlevel/caret-right {:value           (.-value el)
                                                  :selection-start (.-selectionStart el)})]
                (set-values el values))))))

(defn keyup [_el]
  (fn [e]
    (set-modifiers e false)))

(defn mouseleave [_el]
  (fn [_e]
    (reset! modifiers orig-modifiers)))

(defn ^:export new [el]
  (.addEventListener el "keydown" (keydown el))
  (.addEventListener el "keyup" (keyup el))
  (.addEventListener el "mouseleave" (mouseleave el)))