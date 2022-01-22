(ns editor
  (:require lowlevel))

(def orig-modifiers {:alt? false
                     :shift? false
                     :meta? false
                     :ctrl? false})

(def modifiers (atom orig-modifiers))

(defn hey [s] (str s s))

(defn set-values! [el {selection-start :selection-start
                      value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-start))

(defn set-modifiers! [e b]
  (when (= (.-code e) "ControlLeft") (swap! modifiers assoc :ctrl? b))
  (when (= (.-code e) "ShiftLeft") (swap! modifiers assoc :shift? b))
  (when (= (.-code e) "AltLeft") (swap! modifiers assoc :alt? b))
  (when (= (.-code e) "MetaLeft") (swap! modifiers assoc :meta? b)))

(defn modifiers-matching? [modifiers-expected modifiers]
  (let [modifiers-pressed (->> modifiers
                               (filter (fn [[_k v]] (= v true)))
                               (map first))]
    (= (vec modifiers-expected) modifiers-pressed)))

(defn is-pressed? [e modifiers] 
  (fn [code modifiers-expected]
    (and (= (.-code e) code)
         (modifiers-matching? modifiers-expected modifiers))))

(defn convert [el]
  {:value           (.-value el)
   :selection-start (.-selectionStart el)})

(defn apply-action [el e]
  (fn [a]
    (.preventDefault e)
    (set-values! el (a (convert el)))))

(defn keydown [el]
  (fn [e]
    (set-modifiers! e true)
    (let [is-pressed? (is-pressed? e @modifiers)
          apply-action (apply-action el e)]
      (cond (is-pressed? "KeyJ" [:ctrl?])
            (apply-action lowlevel/caret-left)
            (is-pressed? "KeyL" [:ctrl?])
            (apply-action lowlevel/caret-right)))))

(defn keyup [_el]
  (fn [e]
    (set-modifiers! e false)))

(defn mouseleave [_el]
  (fn [_e]
    (reset! modifiers orig-modifiers)))

(defn ^:export new [el]
  (.addEventListener el "keydown" (keydown el))
  (.addEventListener el "keyup" (keyup el))
  (.addEventListener el "mouseleave" (mouseleave el)))