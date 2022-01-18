(ns editor)

(def ctrl-pressed (atom false))
(def shift-pressed (atom false))
(def meta-pressed (atom false))
(def alt-pressed (atom false))

(defn keydown [_el]
  (fn [e]
    (.preventDefault e)
    (when (= (.-code e) "ControlLeft") (reset! ctrl-pressed true))
    (when (= (.-code e) "ShiftLeft") (reset! shift-pressed true))
    (when (= (.-code e) "MetaLeft") (reset! meta-pressed true))
    (when (= (.-code e) "AltLeft") (reset! alt-pressed true))
    (prn (.-code e) @ctrl-pressed @shift-pressed @alt-pressed @meta-pressed)))

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