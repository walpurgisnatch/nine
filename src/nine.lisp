(defpackage nine
  (:use :cl
        :nine.utils
        :nine.workflow
        :nine.apiworks))

(in-package :nine)

(cl-reexport:reexport-from :nine.apiworks)
(cl-reexport:reexport-from :nine.workflow)

(defun test-api ()
  (maphash
   #'(lambda (key value)
       (let* ((response (api-request key))
             (body-map (map-response-body response)))
         (test-contract response body-map)
         (try-methods response body-map)))
   *queue*))
