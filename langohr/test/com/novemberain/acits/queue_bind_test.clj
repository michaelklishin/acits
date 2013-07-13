(ns com.novemberain.acits.queue-bind-test
  (:require [langohr.core     :as lc]
            [langohr.channel  :as lch]
            [langohr.queue    :as lq]
            [langohr.exchange :as le]
            [langohr.basic    :as lb]
            [com.novemberain.acits.commands :as cmd]
            [clojure.test :refer :all]
            [com.novemberain.acits.shared :refer [clients]]))

(defonce conn (lc/connect))

;;
;; Tests
;;

(deftest test-binding-a-durable-queue-to-predefined-fanout-exchange
  (let [ch (lch/open conn)
        q  "acits.queue.bind.q1"
        x  "amq.fanout"]
    (doseq [c clients]
      (println (format "Running queue binding test for client %s" c))
      (lq/declare ch q)
      (cmd/queue-bind ch c q x {"routing_key" ""})
      (Thread/sleep 300)
      (lb/publish ch x q "verify")
      (is (lb/get ch q))
      (lq/delete ch q))))

(deftest test-binding-a-durable-queue-to-predefined-topic-exchange
  (let [ch (lch/open conn)
        q  "acits.queue.bind.q2"
        x  "amq.topic"]
    (doseq [c clients]
      (println (format "Running queue binding test for client %s" c))
      (lq/declare ch q)
      (cmd/queue-bind ch c q x {"routing_key" "acits.#"})
      (Thread/sleep 300)
      (lb/publish ch x "acits.fanout" "verify")
      (is (lb/get ch q))
      (lq/delete ch q))))
