(import (scheme base)
        (scheme read)
        (scheme write)
        (scheme file)
        (scheme char)
        (srfi 1)
        (srfi 2)
        (srfi 95)
        (chibi log)
        (chibi net servlet)
        (chibi config)
        (chibi memoize)
        (chibi pathname)
        (chibi string)
        (chibi regexp)
        (chibi io)
        (chibi snow fort)
        (chibi snow package)
        (chibi crypto md5))

(define (write-to-string x)
  (let ((out (open-output-string)))
    (write x out)
    (get-output-string out)))

(define (package-hash pkg)
  (md5
    (list->string
      (filter
        (lambda (item) item)
        (map
          (lambda (c)
            (if (or (char-alphabetic? c) (char-numeric? c)) c #f))
          (string->list
            (string-append
              (write-to-string (package-name pkg))
              (write-to-string (or (assq 'authors pkg) ""))
              (write-to-string (or (assq 'maintainers pkg) "")))))))))

;; TODO Make smarter :)
(define (remove-email str)
  (car (string-split str #\<)))
(define memoized-read
  (memoize-file-loader (lambda (file) (call-with-input-file file read))))

(define (pkg-field->string pkg field)
  (let ((item (assq field pkg)))
    (cond ((not item) "")
          ((list? (cadr item))
           (let ((list-str (apply
                             string-append
                             (map (lambda (item)
                                    (string-append (remove-email item) ", "))
                                  (cadr item)))))
             (string-copy list-str (- (string-length list-str) 1))))
          ((string? (cadr item)) (remove-email (cadr item)))
          ((symbol? (cadr item)) (symbol->string (cadr item)))
          ((equal? field 'size)
           (string-append (number->string (cadr item)) " bytes"))
          (else ""))))

(define (pkg-signature->string pkg)
  (if (assq 'signature pkg)
    (let* ((signature (cdr (assq 'signature pkg)))
           (digest-type (cadr (assq 'digest signature)))
           (digest (assq digest-type signature)))
      (if digest
        (cadr digest)
        ""))
    ""))

(define (pkg->left-table cfg pkg name)
  (let* ((url-type (if (assq 'git pkg) 'git 'http))
         (url (if (equal? url-type 'git)
                (cadr (assq 'url (cdr (assq 'git pkg))))
                (cadr (assq 'url pkg))))
         (doc (pkg-field->string pkg 'manual))
         (doc-url
           (cond ((string=? doc "") "")
                 ((or (string-prefix? doc "http:")
                      (string-prefix? doc "https:"))
                  doc)
                 ((equal? url-type 'http)
                  (let* ((email (package-email pkg))
                         (dir (package-dir email pkg)))
                    (make-path (static-url cfg dir) "index.html")))
                 ((equal? url-type 'git) url)
                 (else "")))
         (doc-url-text
           (cond ((equal? url-type 'http)
                  (path-strip-directory doc-url))
                 ((equal? url-type 'git)
                  doc)
                 (else doc-url)))
         (download-url
           (if (assq 'git pkg)
             (assoc-get 'url (assoc-get 'git pkg))
             (assoc-get 'url pkg)))
         (updated (let ((updated-str (pkg-field->string pkg 'updated)))
                    (if (and (>= (string-length updated-str) 10))
                      (substring updated-str 0 10)
                      ""))))
    `(table
       (@ (style . "text-align: left"))
       (tr (th "Authors")
           (th ,(pkg-field->string pkg 'authors)))
       (tr (th "Maintainers")
           (th ,(pkg-field->string pkg 'maintainers)))
       (tr (th "Latest version")
           (th ,(pkg-field->string pkg 'version)))
       (tr (th "Documentation")
           (th
             ,(if (equal? url-type 'http)
                `(a (@ (href . ,doc-url))
                    ,(if (and (string? url)
                              (> (string-length url) 0)
                              (char=? (string-ref url 0) #\/))
                       (path-strip-directory doc-url)
                       doc-url))
                (string-append doc-url-text " in repository"))))
       (tr (th "Repository")
           ,(if (equal? url-type 'git)
              `(th (a (@ (href . ,url))
                      ,(path-strip-directory url)))
              '()))
       (tr (th "Package file")
           ,(if (equal? url-type 'http)
              `(th (a (@ (href . ,url))
                      ,(if (and (string? url)
                                (> (string-length url) 0)
                                (char=? (string-ref url 0) #\/))
                         (path-strip-directory url)
                         url)
                      )
                   ,(string-append " (" (pkg-field->string pkg 'size) ")"))
              '()))
       (tr (th "License")
           (th ,(pkg-field->string pkg 'license)))
       (tr (th "Signature")
           (th (textarea ,(pkg-signature->string pkg)))))))

(servlet-run
  (lambda (cfg request next restart)
    (respond
      cfg
      request
      (lambda (content)
        (page
          (let* ((pkg-hash-arg (or (request-param request "pkg" "nosuchfile")))
                 (pkg-file (string-append
                             (static-local-path cfg "pkg-data")
                             "/"
                             pkg-hash-arg
                             ".scm")))
            (if (not (file-exists? pkg-file))
              `(div
                 (div
                   (div
                     (@ (id . "main"))
                     (div (@ (id . "col1")))
                     (div
                       (@ (id . "col2"))
                       (div
                         (@ (style . "min-height: 30vh;"))
                         "Package not found"))
                     (div
                       (@ (id . "col3"))))))
              (let* ((pkg (memoized-read pkg-file))
                     (name (write-to-string
                             (let ((pkg-name (assq 'name pkg)))
                               (if pkg-name
                                 (cdr pkg-name)
                                 (cadr (assq 'name (cdr (assq 'library pkg))))))))
                     (pkg-hash (package-hash pkg))
                     (dependencies-path
                       (static-local-path cfg
                                          (string-append "pkg-data/"
                                                         pkg-hash
                                                         "-dependencies.scm")))
                     (dependencies (if (file-exists? dependencies-path)
                                     (memoized-read dependencies-path)
                                     '())))
                `(div
                   (div
                     (div
                       (@ (id . "main"))
                       (div (@ (id . "col1"))
                            (h2 ,name)
                            ,(pkg->left-table cfg pkg name))
                       (div
                         (@ (id . "col2"))
                         (div
                           (@ (style . "min-height: 30vh;"))
                           ,(pkg-field->string pkg 'description)))
                       (div
                         (@ (id . "col3"))
                         (h3 "Libraries and dependencies")
                         ,dependencies))))))))))))
