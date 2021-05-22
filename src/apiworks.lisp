(in-package :cl-user)
(defpackage :nine.apiworks
  (:use :cl
        :nine.utils)
  (:import-from :stepster
   :prepare-url))

(in-package :nine.apiworks)

(defparameter *apiv* '("v1" "v2" "v3"))
(defparameter *bad-codes* '(404))

(defvar *url* nil)
(defvar *bad-path* nil)
(defvar *bad-argument* nil)
(defvar *endpoints* nil)


(defun merge-urls (one two)
    (concatenate 'string one two))

(defun setup (url)
    (setf *url* url)
    (setf *bad-path* (dex:get (merge-urls url "18u24j38p88Z74"))))

(defun endpoint-exists (endpoint)
    (with-get (merge-urls *url* endpoint)
        (if (member status-code *bad-codes*)
            nil
            t)))

(defun argument-exists (argument &optional (default *url*))
    (let ((url (quri:render-uri (quri:make-uri :defaults default
                                               :query '((argument . 1))))))
        (with-get url
            (or ((member status-code *bad-codes*))
                nil
                t))))

(defun response-change (body)
    (or (= (length body) (length *bad-path*))))

(defun brute-path (wordlist)
    (for-line-in wordlist
        (when (endpoint-exists line)
            (push line *endpoints*))))


