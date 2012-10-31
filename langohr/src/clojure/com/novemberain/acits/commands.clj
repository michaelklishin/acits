(ns com.novemberain.acits.commands
  (:require [langohr.core     :as lc]
            [langohr.queue    :as lq]
            [langohr.exchange :as le]
            [langohr.basic    :as lb]
            [cheshire.core    :as json])
  (:import [com.rabbitmq.client Channel]))

(def ^{:const true}
  commands-exchange "")

;;
;; API
;;

(defn exchange-declare
  "Instructs the given client to declare an exchange"
  [^Channel ch ^String client ^String name props]
  (lb/publish ch commands-exchange (format "commands.%s" client) (json/encode props)
              :type "exchange.declare"
              :headers {"name" name}))

(defn queue-declare
  "Instructs the given client to declare a queue"
  [^Channel ch ^String client ^String name props]
  (lb/publish ch commands-exchange (format "commands.%s" client) (json/encode props)
              :type "queue.declare"
              :headers {"name" name}))
