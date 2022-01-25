(ns lowlevel)

(defmacro leftwards [body]
  (list 'let ['{value :value selection-start :selection-start} 'state
              'inv             '#(- (count value) %1)
              'selection-start '(inv selection-start)
              'original-value  'value
              'value           '(apply str (reverse value))
              'state           '{:value value :selection-start selection-start}
              '{selection-start :selection-start} body]
        '{:value original-value :selection-start (inv selection-start)}))