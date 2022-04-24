(ns editor.lowlevel
  (:require [editor.helpers :as h]))

(def word-stop-pattern "[,;.\\-_\\n]")

(def word-stop-pattern-incl-whitespace "[,;.\\-_\\s]")

(def sentence-stop-pattern "([\\n][\\n]|[,;.])")

(defn caret-left [{selection-start :selection-start
                   selection-end :selection-end
                   :as state}]
  (let [selection-start  (if (> selection-start 0)
                           (- selection-start 1)
                           selection-start)]
    (-> state
        (assoc :selection-start selection-start)
        (assoc :selection-end selection-end))))

(defn caret-right [{value :value 
                    selection-start :selection-start 
                    selection-end :selection-end 
                    :as state}]
  (let [selection-end  (if (< selection-end (count value))
                           (+ selection-end 1)
                           selection-end)]
    (-> state
        (assoc :selection-start selection-start)
        (assoc :selection-end selection-end))))

(defn word-part-right [{selection-start :selection-start 
                        selection-end :selection-end 
                        :as state}]
  (let [rest            (h/calc-rest state)
        selection-end (+ selection-end
                         (cond (h/starts-with-pattern? rest word-stop-pattern)
                               1
                               (h/starts-with-pattern? rest "[ ]")
                               (h/index-of-substr-or-end rest "[^ ]")
                               :else
                               (h/index-of-substr-or-end rest word-stop-pattern-incl-whitespace)))]
    (-> state
        (assoc :selection-start selection-start)
        (assoc :selection-end selection-end))))

(defn delete-right [fun]
  (fn [{value           :value
        selection-end :selection-end
        :as             state}]
    (let [{new-selection-end :selection-end} (fun state)]
      (-> state
          (assoc :value (str (subs value 0 selection-end)
                             (subs value new-selection-end (count value))))
          (assoc :selection-start selection-end)
          (assoc :selection-end selection-end)))))

(def delete-character-right (delete-right caret-right))

(def delete-character-left (h/leftwards delete-character-right))

(def delete-word-part-right (delete-right word-part-right))

(def delete-word-part-left (h/leftwards delete-word-part-right))

(defn delete-selection [{value           :value
                         selection-start :selection-start
                         selection-end   :selection-end}]
  {:value           (str (subs value 0 selection-start) (subs value selection-end ))
   :selection-start selection-start
   :selection-end   selection-start
   :direction       0})

(def word-part-left (h/leftwards word-part-right))

(defn sentence-part-right 
  [{selection-start :selection-start
    selection-end   :selection-end
    :as             state}]
  (let [rest          (h/calc-rest state)
        selection-end (+ selection-end
                         (if (h/starts-with-pattern? rest sentence-stop-pattern)
                           1
                           (h/index-of-substr-or-end
                            rest
                            sentence-stop-pattern)))]
    (-> state
        (assoc :selection-start selection-start)
        (assoc :selection-end selection-end))))

(def sentence-part-left (h/leftwards sentence-part-right))

(def delete-sentence-part-right (delete-right sentence-part-right))

(def delete-sentence-part-left (h/leftwards delete-sentence-part-right))

(defn newline-after-current [{value :value 
                              selection-start :selection-start 
                              :as state}]
  (if (= selection-start (count value))
    (let [selection-start (inc selection-start)
          value (str value "\n")]
      (-> state
          (assoc :value value)
          (assoc :selection-start selection-start)
          (assoc :selection-end selection-start)))
    (let [rest (h/calc-rest state)
          i    (+ selection-start (h/index-of-substr-or-end rest "\\n"))
          selection-start (inc i)
          value (str (subs value 0 i) "\n" (subs value i (count value)))]
      (-> state
          ;; TODO remove duplication with the other block above
          (assoc :value value)
          (assoc :selection-start selection-start)
          (assoc :selection-end selection-start)))))

(def newline-before-current (h/leftwards newline-after-current))

(defn insert [{value           :value
               selection-start :selection-start
               selection-end   :selection-end
               clipboard-data  :clipboard-data 
               :as state}]
  (let [value           (str (subs value 0 selection-start)
                             clipboard-data
                             (subs value selection-end (count value)))
        selection-start (+ selection-start (count clipboard-data))]
    (-> state
        (assoc :value value)
        (assoc :selection-start selection-start)
        (assoc :selection-end selection-start))))

(defn same-position-previous-line [{selection-start :selection-start
             :as state}]
  (assoc state :selection-start 
         (let [[position-in-current-line new-selection-start] (h/cursor-position-in-line state)
               has-previous-line?                             (>= (- selection-start position-in-current-line 1) 0)]
           (if has-previous-line?
             (let [[length-of-previous-line i-beginning-of-line] (h/cursor-position-in-line (assoc state :selection-start (- new-selection-start 1)))
                   line-is-long-enough?    (>= length-of-previous-line position-in-current-line)]
               (if line-is-long-enough?
                 (+ i-beginning-of-line position-in-current-line)
                 selection-start))
             selection-start))))