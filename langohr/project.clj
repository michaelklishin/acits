(defproject com.novemberain/acits "1.0.0-SNAPSHOT"
  :min-lein-version "2.0.0"
  :dependencies [[org.clojure/clojure     "1.4.0"]
                 [com.novemberain/langohr "1.0.0-beta11-SNAPSHOT"]
                 [cheshire                "4.0.3"]]
  :source-paths      ["src/clojure"]
  :warn-on-reflection true
  :jvm-opts ["-Xmx512m"])
