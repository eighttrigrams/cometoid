(ns user
  (:require [reloader.core :as reloader]))

(reloader/start ["src/cljc" "test/cljc"])