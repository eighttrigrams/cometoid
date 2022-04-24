(ns user
  (:require [reloader.core :as reloader]))

(reloader/start ["src/main/cljc" "src/test/cljc"])