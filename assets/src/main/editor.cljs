(ns editor
  (:require lowlevel))

(def ctrl-pressed (atom false))
(def shift-pressed (atom false))
(def meta-pressed (atom false))
(def alt-pressed (atom false))

(defn hey [s] (str s s))

(defn set-values [el {selection-start :selection-start
                      value           :value}]
  (set! (.-value el) value)
  (set! (.-selectionStart el) selection-start)
  (set! (.-selectionEnd el) selection-start))

(defn keydown [el]
  (fn [e]

    (when (= (.-code e) "ControlLeft") (reset! ctrl-pressed true))
    (when (= (.-code e) "ShiftLeft") (reset! shift-pressed true))
    (when (= (.-code e) "MetaLeft") (reset! meta-pressed true))
    (when (= (.-code e) "AltLeft") (reset! alt-pressed true))

    
    (when (and (= (.-code e) "KeyJ") @ctrl-pressed)
      (.preventDefault e)
      (let [values (lowlevel/caret-left {:value (.-value el) :selection-start (.-selectionStart el)})]
        (set-values el values)))
    (when (and (= (.-code e) "KeyL") @ctrl-pressed)
      (.preventDefault e)
      (let [values (lowlevel/caret-right {:value (.-value el) :selection-start (.-selectionStart el)})]
        (set-values el values)))))

(defn keyup [_el]
  (fn [e]
    (when (= (.-code e) "ControlLeft") (reset! ctrl-pressed false))
    (when (= (.-code e) "ShiftLeft") (reset! shift-pressed false))
    (when (= (.-code e) "MetaLeft") (reset! meta-pressed false))
    (when (= (.-code e) "AltLeft") (reset! alt-pressed false))))

(defn mouseleave [_el]
  (fn [_e]
    (reset! shift-pressed false)
    (reset! ctrl-pressed false)
    (reset! meta-pressed false)
    (reset! alt-pressed false)))

(defn ^:export new [el]
  (.addEventListener el "keydown" (keydown el))
  (.addEventListener el "keyup" (keyup el))
  (.addEventListener el "mouseleave" (mouseleave el)))