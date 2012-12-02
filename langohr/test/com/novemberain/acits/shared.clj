(ns com.novemberain.acits.shared
  (:require [clojure.string :as s]))

;; Known options are:
;; "amqp-gem", "pika", "bunny", "erlang-amqp-client"
(def clients (s/split (or (System/getenv "CLIENTS")
                          ""), #","))