(ns lowlevel)

(defn caret-left [[value selection-start]]
  [value (if (> selection-start 0) 
           (- selection-start 1) 
           selection-start)])