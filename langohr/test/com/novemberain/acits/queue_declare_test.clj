(ns com.novemberain.acits.queue-declare-test
  (:require [langohr.core     :as lc]
            [langohr.channel  :as lch]
            [langohr.queue    :as lq]
            [langohr.exchange :as le]
            [com.novemberain.acits.commands :as cmd]
            [clojure.test :refer :all]))

(defonce conn (lc/connect))

;;
;; Tests
;;

(deftest test-durable-queue-declaration
  (let [ch (lch/open conn)]
    (cmd/queue-declare ch "amqp-gem" "acits.queue.durable" {:durable true})
    (cmd/queue-declare ch "amqp-gem" "acits.queue.durable" {:durable true})
    (cmd/queue-declare ch "amqp-gem" "acits.queue.durable" {:durable true})
    (cmd/queue-declare ch "amqp-gem" "acits.queue.durable" {:durable true})
    (Thread/sleep 300)
    (lq/declare-passive ch "acits.queue.durable")
    (lq/declare-passive ch "acits.queue.durable")
    (lq/declare-passive ch "acits.queue.durable")
    (lq/declare-passive ch "acits.queue.durable")))
