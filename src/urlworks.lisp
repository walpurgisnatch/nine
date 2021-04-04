(in-package :cl-user)
(defpackage nine.urlworks
  (:use :cl)
  (:import-from	:cl-ppcre
   :scan-to-strings)
  (:export
   :same-domain))

(in-package :nine.urlworks)

(defun regex-group (regex string group)
    (aref (nth-value 1 (scan-to-strings regex string)) group))

(defun substp (regex string)
    (if (scan-to-strings regex string)
        t
        nil))

(defun relative (url)
    (substp "^[/]?[a-zA-Z/]*[.]?[a-zA-Z]*$" url))

(defun same-domain (url domain)
    (or (substp domain url)
        (relative url)))
