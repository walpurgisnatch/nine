(in-package :cl-user)
(defpackage nine.workflow
  (:use :cl
        :nine.utils)
  (:export :*scope*
           :add-to-scope
           :in-scopep
           :push-queue

           :request
           :make-request
           :create-request
           :request-url
           :request-method
           :request-headers
           :request-auth
           :request-role
           :request-expects
           :request-body
           
           :response
           :make-response
           :response-request
           :response-headers
           :response-body
           :response-status-code
           :response-time))

(in-package :nine.workflow)

(defparameter *scope* nil)
(defparameter *queue* (make-hash-table :test #'equalp))
(defparameter *default-headers*
  '(("User-Agent" . "Mozilla/5.0 (X11; Linux x86_64; rv:144.0) Gecko/20100101 Firefox/144.0")))

(defstruct request
  url
  method
  headers
  auth
  role
  expects
  body)

(defstruct response
  request
  headers
  body
  status-code
  time)

(defun create-request (url method &optional (headers *default-headers*) body expects auth role)
  (make-request :url url :method method :headers headers :auth auth
                :role role :expects expects :body body))

(defun add-to-scope (link)
  (push link *scope*))

(defun in-scopep (link)
  t)

(defun push-queue (link request)
  (sethash link request *scope*))



