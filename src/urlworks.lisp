(in-package :cl-user)
(defpackage nine.urlworks
  (:use :cl)
  (:import-from	:cl-ppcre
   				:scan-to-strings
                :all-matches-as-strings
   				:split)
  (:export
   :same-domain
   :get-arguments
   :arguments
   :arguments-values))

(in-package :nine.urlworks)

(defun regex-group (group vector)
    (aref vector group))

(defun substp (regex string)
    (if (scan-to-strings regex string)
        t
        nil))

;(defun init-url () )

(defun relative (url)
    (substp "^[/]?[a-zA-Z/]*[.]?[a-zA-Z]*$" url))

(defun split-url (url)
    (let ((items (split "[.]|[/]|[?]" url)))
        (loop for item in items
              collect item)))

(defun get-last (url)
    (nth-value 1 (scan-to-strings "(.+)(\/.+)$" url)))

(defun get-main (url)
    (nth-value 1 (scan-to-strings "(.+[.].+?\/)(.*)" url)))

(defun get-arguments (url)
    (let ((parts (all-matches-as-strings "([a-zA-Z_%0-9-]*?)=.*?(&|$)" url)))
        (mapcar #'(lambda (part) (split "=" (string-trim "&" part))) parts)))

(defun arguments (list)
    (mapcar #'car (get-args list)))

(defun arguments-values (list)
    (mapcar #'car (mapcar #'cdr (get-args list))))

(defun same-domain (url domain)
    (or (substp domain url)
        (relative url)))
