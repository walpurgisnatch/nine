(defsystem "nine"
    :version "0.0.0"
    :author "Walpurgisnatch"
    :license "MIT"
    :depends-on ("stepster"
                 "pero"
                 "cl-ppcre"
                 "dexador"
                 "quri")
    :components ((:module "src"
                  :components
                  ((:file "nine" :depends-on ("apiworks"))
                   (:file "apiworks" :depends-on ("utils"))
                   (:file "utils"))))
    :description "Web-application testing framework")
