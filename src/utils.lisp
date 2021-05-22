(in-package :cl-user)
(defpackage :nine.utils
  (:use :cl)
  (:export :for-line-in
           :with-get))

(in-package :nine.utils)

(defmacro for-line-in (file &optional (buffer-size 16384) &body body)
    `(declare (optimize (speed 3) (safety 2))
              (type fixnum buffer-size))
    `(let ((buffer (make-array ,buffer-size :element-type 'character))
           (end ,buffer-size)
           (temp ,buffer-size))
         (declare (type fixnum end temp))
         (with-open-file (input ,file)            
             (loop
               (when (< end buffer-size)
                   (return))
               (setf (subseq buffer 0) (subseq buffer temp ,buffer-size))
               (setf end (read-sequence buffer input :start (- ,buffer-size temp)))
               (setf temp 0)
               (dotimes (i end)
                   (declare (type fixnum i)
                            (dynamic-extent i))
                   (when (char-equal #\Newline
                                     (aref buffer i))
                       (let ((line (subseq buffer temp i)))
                           (progn ,@body))))))))

(defmacro with-get (url &body body)
    `(handler-case
         (multiple-value-bind (response-body status-code response-headers quri-uri)
             (dex:get (prepare-url ,url) :cookie-jar *cookie-jar*)
             (declare (ignorable status-code response-headers quri-uri))
             (let ((response-url (quri:render-uri quri-uri))
                   (response-length (length response-body)))
                 (declare (ignorable root-node))
                 (progn ,@body)))
       (error (e) (print-error e))))
