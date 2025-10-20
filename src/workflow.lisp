(in-package :cl-user)
(defpackage nine.workflow
  (:use :cl
        :nine.utils)
  (:export :add-to-scope
           :in-scopep))

(in-package :nine.workflow)

(defparameter *scope* nil)


(defun add-to-scope (link)
  (setf *scope* (cons link *scope*)))

(defun in-scopep (link)
  t)
