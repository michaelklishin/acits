(ns com.novemberain.acits.queue-declare-test
  (:require [langohr.core     :as lc]
            [langohr.channel  :as lch]
            [langohr.queue    :as lq]
            [langohr.exchange :as le]
            [com.novemberain.acits.commands :as cmd]
            [clojure.test :refer :all]
            [com.novemberain.acits.shared :refer [clients]]))

(defonce conn (lc/connect))

;;
;; Tests
;;

(deftest test-durable-queue-declaration
  (let [ch (lch/open conn)]
    (doseq [c clients]
      (cmd/queue-declare ch c "acits.queue.durable" {:durable true})
      (Thread/sleep 300)
      (lq/declare-passive ch "acits.queue.durable"))))


(deftest test-non-durable-queue-declaration
  (let [ch (lch/open conn)]
    (doseq [c clients]
      (cmd/queue-declare ch c "acits.queue.non-durable" {:durable false})
      (Thread/sleep 300)
      (lq/declare-passive ch "acits.queue.non-durable"))))
