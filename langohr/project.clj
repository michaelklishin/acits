(defproject com.novemberain/acits "1.0.0-SNAPSHOT"
  :min-lein-version "2.0.0"
  :dependencies [[org.clojure/clojure     "1.5.1"]
                 [com.novemberain/langohr "1.0.0-beta14"]
                 [cheshire                "5.2.0"]]
  :source-paths      ["src/clojure"]
  :warn-on-reflection true
  :jvm-opts ^:replace ["-Xmx512m"])
