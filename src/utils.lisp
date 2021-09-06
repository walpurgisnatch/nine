(in-package :cl-user)
(defpackage :nine.utils
  (:use :cl)
  (:export :for-line-in
           :with-get
           :prepare-url
   :merge-urls))

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
               (dex:get (prepare-url ,url)))
           (declare (ignorable ,response-body ,status-code ,response-headers quri-uri))
           (let ((,response-url (quri:render-uri quri-uri))
                 (,response (list ,response-body ,status-code ,response-headers)))
             (declare (ignorable ,response-url ,response))
             (progn ,@body)))
       (error (e) (print e)))))

(defun merge-urls (first second)
  (let ((lc (last-char first)))
    (concatenate 'string first (unless (equal lc #\/) "/") second)))

(defun prepare-url (url)
  (cond
    ((substp "http" url) url)
    ((string-starts-with url "//") url)
    (t (http-join url))))

(defun http-join (url)
  (let ((https-url (concatenate 'string "https://" url))
        (http-url (concatenate 'string "http://" url)))
    (handler-case (progn
                    (dex:get https-url)
                    https-url)
      (error () http-url))))

(defun substp (regex string)
  (if (cl-ppcre:scan-to-strings regex string)
      t
      nil))

(defun string-starts-with (string x)
  (if (string-equal string x :end1 (length x))
      t
      nil))

(defun last-char (x)
  (aref x (1- (length x))))
