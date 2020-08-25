
(import (scheme base) (scheme read) (scheme write) (srfi 1) (srfi 27)
        (chibi pathname) (chibi filesystem) (chibi regexp)
        (chibi log) (chibi io) (chibi config) (chibi net servlet)
        (chibi time) (chibi net smtp) (chibi crypto sha2)
        (chibi snow fort))

(define (valid-integer? x)
  (or (and (integer? x) (exact? x))
      (and (string? x) (valid-integer? (string->number x 16)))))

;; allow 1 day to confirm
(define (live-request? file)
  (<= (current-seconds)
      (+ (file-modification-time file) (* 60 60 24))))

(define (invalid-public-key-reason key)
  (let ((fail
         (lambda (str)
           (let ((out (open-output-string)))
             (display str out)
             (display ": " out)
             (write key out)
             (get-output-string out)))))
    (cond
     ((not (list? key))
      (fail "key must be a list"))
     ((not (string? (assoc-get key 'email)))
      (fail "key email must be a string"))
     ((not (string? (assoc-get key 'name)))
      (fail "key name must be a string"))
     ((not (string? (assoc-get key 'password)))
      (fail "key requires a password"))
     (else
      (let ((ls (assoc-get key 'public-key eq?))
            (priv (assoc-get key 'private-key eq?)))
        (cond
         ((not (or ls priv))
          ;;(fail "key requires a public-key or private-key")
          #f)
         (priv
          #f)
         ((not (valid-integer? (assoc-get ls 'modulus eq?)))
          (fail "key modulus must be an integer"))
         ((not (valid-integer? (assoc-get ls 'exponent eq?)))
          (fail "key exponent must be an integer"))
         (else #f)))))))

(define (make-confirmation-link cfg key email conf-key)
  (string-append "http://snow-fort.org/pkg/reg/?c=" conf-key "&e=" email))

(define (make-confirmation-mail cfg key email conf-key)
  (string-append
   "Hello " (assoc-get key 'name) ",\n\n"
   "To confirm this email address, " email ", for use with the snow-fort.org "
   "public Scheme repository, click the following link:\n"
   (make-confirmation-link cfg key email conf-key) "\n\n"
   "If you have not requested registration of this address, contact "
   "alexshinn@gmail.com.\n\n"
   "Thanks,\n"
   "The Snow Admins\n"))

(define (handle-registration cfg request up)
  (let* ((key (upload->sexp up))
         (email (assoc-get key 'email eq?)))
    (log-info `(key: ,key))
    (cond
     ((invalid-public-key-reason key)
      => fail)
     ((not (valid-email? email))
      `(span "Invalid email address: " ,email))
     (else
      (let* ((user-dir (static-local-path cfg (email->path email)))
             (reg-file (make-path user-dir "pending"))
             (key-file (make-path user-dir "pub-key"))
             (clean-key
              (remove (lambda (x) (and (pair? x) (eq? 'password (car x))))
                      key))
             ;; one-time key for confirmation
             (conf-key (sha-256 (string-append
                                 (number->string (random-integer 1000000))
                                 email))))
        (cond
         ((and (file-exists? reg-file) (live-request? reg-file))
          "Awaiting email confirmation from this user.")
         ((file-exists? key-file)
          `(span "User already registered: " ,email))
         (else
          ;; store the (hashed) password in the per-user key file, but
          ;; remove it from the public repository
          (create-directory* user-dir)
          (call-with-output-file key-file
            (lambda (out) (write key out)))
          (update-repo-object cfg 'email `(publisher ,@clean-key))
          (cond
           ((conf-get cfg 'skip-email-confirmation?)
            `(span "Thank you for registering " ,email ". "
                   "You can now upload packages with this account."))
           (else
            (send-mail 'From: "alexshinn@gmail.com"
                       'To: email
                       'Subject: "snow-fort.org confirmation"
                       'Body: (make-confirmation-mail cfg key email conf-key)
                       'Host: #f)
            (call-with-output-file reg-file
              (lambda (out) (write conf-key out)))
            `(span "Thank you for registering " ,email ". "
                   "A confirmation mail has been sent to this address. "
                   ))))))))))

(define (handle-confirmation cfg request conf-key)
  (let ((email (request-param request "e")))
    (cond
     ((not (valid-email? email))
      `(span "Invalid email address: " ,email))
     (else
      (let* ((user-dir (static-local-path cfg (email->path email)))
             (key-file (make-path user-dir "pub-key"))
             (reg-file (make-path user-dir "pending")))
        (cond
         ((and (not (file-exists? reg-file))
               (file-exists? key-file))
          `(span "User already registered: " ,email))
         ((not (file-exists? reg-file))
          `(span "Can't confirm unknown user: " ,email))
         (else
          (let ((expected-key (call-with-input-file reg-file read)))
            (cond
             ((not (equal? expected-key conf-key))
              `(span "Invalid confirmation key: " ,email))
             ((not (live-request? reg-file))
              (log-warn `(> ,(current-seconds)
                            (+ ,(file-modification-time reg-file) 1 day)))
              `(span "Request expired, please register again."))
             (else
              (delete-file reg-file)
              `(span "Thank you for confirming " ,email ". "
                     "You can now upload packages with this account. ")
              ))))))))))

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
           "Public Key File: "
           (input (@ (type . "file") (name . "u")))
           (input (@ (type . "submit") (value . "send"))))
         ,@(content
            (cond
             ((request-param request "c")
              => (lambda (c) (list (handle-confirmation cfg request c))))
             ((request-upload request "u")
              => (lambda (up) (list (handle-registration cfg request up))))
             (else
              '())))))))))
