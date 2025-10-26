(in-package :cl-user)
(defpackage :nine.apiworks
  (:use :cl
        :nine.utils
        :nine.workflow)
  (:export :api-request
           :map-response-body
           ))

(in-package :nine.apiworks)

(defvar *cookie-jar* (cl-cookie:make-cookie-jar))

(defparameter *responses* (make-hash-table :test #'equalp))
(defparameter *bad-codes* '(404 403 401))

(defun api-request (request)
  (let ((url (ss:prepare-url (request-url request)))
        (method (request-method request))
        (headers (request-headers request))
        (body (request-body request))
        (time (get-internal-real-time)))
    (multiple-value-bind (response-body response-status response-headers)
        (handler-bind ((dex:http-request-failed #'dex:ignore-and-continue))
               (case method
                 (get (dex:get url :cookie-jar *cookie-jar* :headers headers))
                 (post (dex:post url :cookie-jar *cookie-jar* :headers headers :content body))
                 (put (dex:put url :cookie-jar *cookie-jar* :headers headers :content body))
                 (patch (dex:patch url :cookie-jar *cookie-jar* :headers headers :content body))
                 (delete (dex:delete url :cookie-jar *cookie-jar* :headers headers))))
      (setf time (float (/ (- (get-internal-real-time) time)
                           internal-time-units-per-second)))
      (sethash url (make-response :request request :headers response-headers
                                  :body response-body :status-code response-status :time time)
               *responses*))))

(defun map-response-body (json &optional result)
  (cond ((null json) result)
        ((consp (car json))
         (map-response-body (car json) (map-response-body (cdr json) result)))
        (t (map-response-body
            nil
            (concatenate 'list result (collect-keys json result))))))

(defun json-keys (alist)
  (mapcar #'(lambda (el) (string (car el))) response))

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



