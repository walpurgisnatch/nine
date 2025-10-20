(in-package :cl-user)
(defpackage :nine.apiworks
  (:use :cl
        :nine.utils)
  (:export :api-request
           :map-response))

(in-package :nine.apiworks)

(defvar *responses* (make-hash-table :test #'equalp))
(defparameter *bad-codes* '(404 403 401))

(defun api-request (link)
  (jonathan:parse (ss:safe-get link)))

(defun map-response (json &optional result)
  (cond ((null json) result)
        ((consp (car json))
         (map-response (car json) (map-response (cdr json) result)))
        (t (map-response nil
                         (concatenate 'list result (collect-keys json result))))))

(defun collect-keys (json list)
  (loop for (k v) on json by #'cddr
        unless (member k list :key #'car)
        collect (list k
                      (format nil "~a" (ts-type v)))))

(defun endpoint-existsp (endpoint)
  (with-get endpoint
    (unless (member status-code *bad-codes*)
      endpoint)))

(defun argument-exists (argument &optional default)
  (let ((url (quri:render-uri (quri:make-uri :defaults default
                                             :query `((,argument . 1))))))
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



