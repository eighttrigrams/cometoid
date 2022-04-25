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
        ;; TODO remove next line as soon as dont-adjust-position-in-line is implemented
        (assoc :position-in-line selection-start)
        (assoc :selection-start selection-start)
        (assoc :selection-end selection-end)))) ;; TODO remove line

(defn caret-right [{value :value 
                    selection-start :selection-start 
                    selection-end :selection-end 
                    :as state}]
  (let [selection-end  (if (< selection-end (count value))
                           (+ selection-end 1)
                           selection-end)]
    (-> state
        ;; TODO remove next line as soon as dont-adjust-position-in-line is implemented
        (assoc :position-in-line selection-start)
        (assoc :selection-start selection-start) ;; TODO remove line
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

(defn find-position-in-line-starting-from-end-of-line
  [{value :value
    position-in-line :position-in-line}
   position-of-linebreak]
  (let [[line-length line-position] (h/cursor-position-in-line value position-of-linebreak)]
    (if (<= position-in-line line-length)
      (+ line-position position-in-line)
      position-of-linebreak)))

(defn same-position-previous-line 
  [{value :value
    selection-start :selection-start
    :as state}]
  (-> state
      (assoc :prevent-adjust-position-in-line true)
      (assoc :selection-start 
         (let [[_
                line-position
                previous-line-exists?] (h/cursor-position-in-line value selection-start)]
           (if-not previous-line-exists?
             selection-start
             (find-position-in-line-starting-from-end-of-line
              state
              (dec line-position)))))))