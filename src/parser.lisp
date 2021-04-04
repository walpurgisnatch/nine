(in-package :cl-user)
(defpackage nine.parser
  (:use :cl)
  (:import-from	:nine.urlworks
                :same-domain))

(in-package :nine.parser)

(defvar *xss-payloads* '("<svg =\"on" "< leg'"))

(defun crawl-for-urls (url &optional (urls nil))
    (let* ((request (dex:get url))
           (root-node (plump:parse request))
           (hrefs (extract-urls root-node)))
        (loop for href in hrefs
              do (when (same-domain href url)
                     (adjoin href urls)
                     (crawl-for-urls href urls)))
        hrefs))

(defun extract-urls (root-node)
    (collect-from root-node 'a 'href))

(defun extract-forms (root-node)
    (collect-from root-node 'form))

(defun collect-from (root-node selectors &optional (attr nil))
    (loop for node across (clss:select (nodes-to-string selectors) root-node)
          collect (if attr
                      (plump:attribute node (string attr))
                      node)))

(defun nodes-to-string (list)
    (if (consp list)
        (string-right-trim " "
               (apply #'concatenate 'string
                      (loop for word in list
                            collect (concatenate 'string (string word) " "))))
        (string list)))

(defun concat-node-text (node)
    (let ((text-list nil))
        (plump:traverse node
                        (lambda (node) (push (plump:text node) text-list))
                        :test #'plump:text-node-p)
        (apply #'concatenate 'string (nreverse text-list))))
