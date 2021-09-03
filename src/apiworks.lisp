(in-package :cl-user)
(defpackage :nine.apiworks
  (:use :cl
        :nine.utils))

(in-package :nine.apiworks)

(defparameter *apiv* '("v1" "v2" "v3"))
(defparameter *bad-codes* '(400 404))

(defvar *url* nil)
(defvar *bad-path* nil)
(defvar *bad-argument* nil)
(defvar *endpoints* nil)

(defvar *responses* (make-hash-table :test #'equalp))

(defun setup (url)
  (setf *url* url)
  (setf *bad-path* (dex:get (merge-urls url "18u24j38p88Z74"))))

(defun endpoint-exists (endpoint)
  (with-get (merge-urls *url* endpoint)
    (unless (member status-code *bad-codes*)
      endpoint)))

(defun argument-exists (argument &optional (default *url*))
  (let ((url (quri:render-uri (quri:make-uri :defaults default
                                             :query ((argument . 1))))))
    (with-get url
      (unless (= status-code 404)
        (setf (gethash url *responses*) response)))))

(defun count-stuff (document)
  (declare (type string document))
  (loop for i across document
        counting (char-equal #\Newline i) into lines
        counting (char-equal #\  i) into spaces
        counting i into length
        finally (return (values length lines (1+ spaces)))))

(defun response-change (body)
  (or (= (length body) (length *bad-path*))))

(defun brute-path (wordlist)
  (for-line-in wordlist
               (when (endpoint-exists line)
                 (push line *endpoints*))))


