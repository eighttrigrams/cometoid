(ns app.main)

(def value-a 4)
(defonce value-b 2)


(defn ^:export hello [name]
  (str "Hallo, " name))

(defn main! []
  (println "App loaded!!!!!")
  )

(defn reload! []
  (println "Code updated.")
  (println "Trying values:" value-a value-b))

