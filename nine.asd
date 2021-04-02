(defsystem "nine"
  :version "0.0.0"
  :author "Walpurgisnatch"
  :license "MIT"
  :depends-on ("dexador"
               "cl-ppcre")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "nine/tests"))))

(defsystem "nine/tests"
  :author ""
  :license ""
  :depends-on ("nine"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for nine"
  :perform (test-op (op c) (symbol-call :rove :run c)))
