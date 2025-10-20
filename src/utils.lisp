(in-package :cl-user)
(defpackage :nine.utils
  (:use :cl)
  (:export :for-line-in
           :with-get
           :ts-type))

(in-package :nine.utils)

(defmacro with-interned-symbols (symbol-list &body body)
  "Interns a set of symbols in the current package to variables of the same (symbol-name)."
  (let ((symbol-list
          (mapcar (lambda (s)
                    (list s `(intern (symbol-name ',s))))
                  symbol-list)))
    `(let ,symbol-list ,@body)))

(defmacro for-line-in (wordlist &body body)
  (with-interned-symbols (line)
    `(with-open-file (stream ,wordlist)
       (loop for ,line = (read-line stream nil)
             while ,line do (progn ,@body)))))

(defmacro with-get (url &body body)
  (with-interned-symbols (response response-body status-code response-headers response-url)
    `(handler-case
         (multiple-value-bind (,response-body ,status-code ,response-headers quri-uri)
             (handler-bind ((dex:http-request-failed #'dex:ignore-and-continue))
               (dex:get (ss:prepare-url ,url)))
           (declare (ignorable ,response-body ,status-code ,response-headers quri-uri))
           (let ((,response-url (quri:render-uri quri-uri))
                 (,response (list ,response-body ,status-code ,response-headers)))
             (declare (ignorable ,response-url ,response))
             (progn ,@body)))
       (error (e) (print e)))))

(defun substp (regex string)
  (cl-ppcre:scan-to-strings regex string))

(defun string-starts-with (string x)
  (string-equal string x :end1 (length x)))

(defun random-string (len)
  (with-output-to-string (str)
    (dotimes (n len)
      (case (random 3)
        (0 (princ (code-char (+ 65 (random 26))) str))
        (1 (princ (code-char (+ 97 (random 26))) str))
        (2 (princ (random 10) str))))))

(defun ts-type (value)
  (cond
    ((null value) "null")
    ((stringp value) "string")
    ((numberp value) "number")
    ((or (eq value t) (eq value 'nil)) "boolean")
    ((listp value)
     (if (every #'stringp value)
         "string[]"
         (if (every #'numberp value)
             "number[]"
             "any[]")))
    ((hash-table-p value) "Record<string, any>")
    ((and (listp value)
          (every (lambda (x)
                   (and (consp x)
                        (symbolp (car x))))
                 value))
     "Record<string, any>")
    ((symbolp value) "string")
    (t "any")))
