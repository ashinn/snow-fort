
(import (scheme base) (scheme write) (scheme file) (scheme time) (srfi 1)
        (chibi config) (chibi pathname) (chibi regexp) (chibi zlib)
        (chibi string) (chibi log) (chibi net servlet) (chibi io)
        (chibi filesystem) (chibi tar) (chibi time) (chibi crypto rsa)
        (chibi snow fort) (chibi snow package) (chibi snow utils))

(define (path-top path)
  (substring path 0 (string-find path #\/)))

(define (tar-top tar)
  (path-top (car (tar-files tar))))

;; 2011-08-03T22:44:00+00:00"
(define (tai->rfc-3339 seconds)
  (define (pad2 n)
    (if (< n 10)
        (string-append "0" (number->string n))
        (number->string n)))
  (let ((tm (seconds->time (exact (round seconds)))))
    (string-append
     (number->string (+ 1900 (time-year tm))) "-"
     (pad2 (time-month tm)) "-"
     (pad2 (time-day tm)) "T"
     (pad2 (time-hour tm)) ":"
     (pad2 (time-minute tm)) ":"
     (pad2 (time-second tm)) "+00:00")))

(define (handle-upload cfg request up)
  (guard (exn
          (else
           (log-error "upload error: " exn)
           (fail "unknown error processing snowball: "
                 "the file should be a gzipped tar file "
                 "containing a single directory with a "
                 "packages.scm file, plus a valid signature file")))
    (let* ((raw-data (upload->bytevector up))
           (snowball (maybe-gunzip raw-data))
           (pkg (extract-snowball-package snowball))
           (sig-spec (guard
                         (exn
                          (else
                           (log-error "error parsing sig: " exn)))
                       (upload->sexp (request-upload request "sig"))))
           (email (and (pair? sig-spec) (assoc-get (cdr sig-spec) 'email)))
           (password (request-param request "pw"))
           (password-given? (and password (not (equal? password ""))))
           (user-password (and email (get-user-password cfg email)))
           (signed? (and (pair? sig-spec) (assoc-get (cdr sig-spec) 'rsa))))
      (cond
       ((invalid-package-reason pkg)
        => fail)
       ((not sig-spec)
        (fail "a sig with at least email is required"))
       ((and (not password-given?) (not signed?))
        (fail "neither password nor signature given for upload"))
       ((file-exists? (make-path (static-local-path cfg (email->path email))
                                 "pending"))
        (fail "user email address confirmation is still pending for: " email))
       ((not user-password)
        (fail "unknown user: " email " - did you forget to run reg-key?"))
       ((and password-given? (not (equal? password user-password)))
        (fail "invalid password"))
       ((and signed?
             (invalid-signature-reason cfg sig-spec snowball))
        => fail)
       (else
        (let* ((dir (package-dir email pkg))
               (base (or (upload-filename up) "package.tgz"))
               (path (make-path dir base))
               (local-path (static-local-path cfg path))
               (local-dir (path-directory local-path))
               (url (static-url cfg path))
               (now (tai->rfc-3339 (current-second)))
               (pkg2
                `(,(car pkg)
                  (url ,url)
                  (size ,(bytevector-length snowball))
                  (updated ,now)
                  (created ,now)
                  ,sig-spec
                  ,@(remove
                     (lambda (x)
                       (and (pair? x)
                            (memq (car x) '(url size updated created))))
                     (cdr pkg)))))
          (cond
           ((file-exists? local-dir)
            (fail "the same version of this package already exists: "
                  (package-name pkg) ": " (package-version pkg)))
           (else
            (create-directory* (path-directory local-path))
            (upload-save up local-path)
            (update-repo-package
             cfg pkg2 (lambda (repo drop pkg2)
                        (let ((orig-created
                               (and (pair? drop)
                                    (pair? (car drop))
                                    (assq 'created (cdar drop))))
                              (cell (assq 'created (cdr pkg2))))
                          (if (and orig-created cell)
                              (set-car! (cdr cell) (cadr orig-created))))
                        pkg2))
            (guard (exn (else (log-error "failed to save docs: " exn)))
              (cond
               ;; TODO: support multiple doc files
               ((cond ((assq 'manual (cdr pkg))
                       => (lambda (ls)
                            (and (pair? ls)
                                 (pair? (cdr ls))
                                 (let ((file (make-path (tar-top snowball)
                                                        (cadr ls))))
                                   (tar-extract-file snowball file)))))
                      (else #f))
                => (lambda (bv)
                     (let ((out (open-binary-output-file
                                 (static-local-path
                                  cfg
                                  (make-path dir "index.html")))))
                       (write-bytevector bv out)
                       (close-output-port out))))))
            `(span "Thanks for uploading! "
                   "Users can now install "
                   ,(call-with-output-string
                      (lambda (out) (write (package-name pkg2) out))))))))))))

(servlet-run
 (lambda (cfg request next restart)
   (servlet-parse-body! request)
   (respond
    cfg
    request
    (lambda (content)
      (page
       `(div
         (form (@ (enctype . "multipart/form-data")
                  (method . "POST"))
           "Upload package: "
           (input (@ (type . "file") (name . "u")))
           "Signature: "
           (input (@ (type . "file") (name . "sig")))
           (input (@ (type . "submit") (value . "send"))))
         ,@(content
            (cond
             ((request-upload request "u")
              => (lambda (up) (handle-upload cfg request up)))
             (else
              '())))))))))
