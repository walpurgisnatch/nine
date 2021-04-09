(in-package :cl-user)
(defpackage nine.parser
  (:use :cl)
  (:import-from	:nine.urlworks
                :same-domain))

(in-package :nine.parser)

(defvar *xss-payloads* '("<svg =\"on" "< leg'"))
(defparameter *cookie-jar* (cl-cookie:make-cookie-jar))

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

(defun submit-form (url d)
    (let ((data (index-to-string d)))
    (dex:post url
              :cookie-jar *cookie-jar*
              :content data)))

(defun fill-form (form value)
    (let ((fields (collect-input form)))
        (loop for field in fields
              when (string= (assoc 'type field) "text")
                do (setf-assoc field 'value (string value)))
        fields))

(defun index-to-string (list)
    (loop for item in list do
          (setf (car item) (string (car item)))))

(defun setf-assoc (field key value)
    (setf (cdr (assoc key field)) value))

(defun collect-input (node)
    (list (cons 'name (collect-from node 'input 'name))
          (cons 'type (collect-from node 'input 'type))
          (cons 'value (collect-from node 'input 'value))))

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

