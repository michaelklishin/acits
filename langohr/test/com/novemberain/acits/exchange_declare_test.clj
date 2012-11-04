(ns com.novemberain.acits.exchange-declare-test
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

(deftest test-durable-exchange-declaration
  (let [ch (lch/open conn)]
    (doseq [c clients]
      (cmd/exchange-declare ch c "acits.direct.durable"  {:durable true :type "direct"})
      (cmd/exchange-declare ch c "acits.fanout.durable"  {:durable true :type "fanout"})
      (cmd/exchange-declare ch c "acits.topic.durable"   {:durable true :type "topic"})
      (cmd/exchange-declare ch c "acits.headers.durable" {:durable true :type "headers"})
      (Thread/sleep 300)
      (le/declare-passive ch "acits.direct.durable")
      (le/declare-passive ch "acits.fanout.durable")
      (le/declare-passive ch "acits.topic.durable")
      (le/declare-passive ch "acits.headers.durable"))))


(deftest test-non-durable-exchange-declaration
  (let [ch (lch/open conn)]
    (doseq [c clients]
      (cmd/exchange-declare ch c "acits.direct.non-durable"  {:durable false :type "direct"})
      (cmd/exchange-declare ch c "acits.fanout.non-durable"  {:durable false :type "fanout"})
      (cmd/exchange-declare ch c "acits.topic.non-durable"   {:durable false :type "topic"})
      (cmd/exchange-declare ch c "acits.headers.non-durable" {:durable false :type "headers"})
      (Thread/sleep 300)
      (le/declare-passive ch "acits.direct.non-durable")
      (le/declare-passive ch "acits.fanout.non-durable")
      (le/declare-passive ch "acits.topic.non-durable")
      (le/declare-passive ch "acits.headers.non-durable"))))


(deftest test-autodelete-exchange-declaration
  (let [ch (lch/open conn)]
    (doseq [c clients]
      (cmd/exchange-declare ch c "acits.direct.autodelete"  {:auto-delete true :type "direct"})
      (cmd/exchange-declare ch c "acits.fanout.autodelete"  {:auto-delete true :type "fanout"})
      (cmd/exchange-declare ch c "acits.topic.autodelete"   {:auto-delete true :type "topic"})
      (cmd/exchange-declare ch c "acits.headers.autodelete" {:auto-delete true :type "headers"})
      (Thread/sleep 300)
      (le/declare-passive ch "acits.direct.autodelete")
      (le/declare-passive ch "acits.fanout.autodelete")
      (le/declare-passive ch "acits.topic.autodelete")
      (le/declare-passive ch "acits.headers.autodelete"))))
