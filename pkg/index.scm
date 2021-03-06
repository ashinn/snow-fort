
(import (scheme base) (scheme read) (scheme write) (srfi 1) (srfi 2) (srfi 95)
        (chibi log) (chibi net servlet) (chibi config) (chibi memoize)
        (chibi pathname) (chibi string) (chibi regexp) (chibi io)
        (chibi snow fort) (chibi snow package))

(define (write-to-string x)
  (let ((out (open-output-string)))
    (write x out)
    (get-output-string out)))

;; Add a table id, and a sort button to each header to call a sorter
;; function on the table.
(define (sortable-table table)
  table)

(define (extract-email str)
  (and-let* ((re '(: (* any) "<" ($ (* (~ (">")))) ">" (* any)))
             (match (regexp-matches re str)))
    (string-trim (regexp-match-submatch match 1))))

(define (package-row cfg repo pkg)
  (let* ((email (package-email pkg))
         (desc (or (assoc-get pkg 'description) ""))
         (dir (package-dir email pkg))
         (docs (assoc-get pkg 'manual))
         (doc (if (pair? docs) (car docs) docs))
         (doc-url (cond
                   ((not (string? doc)) #f)
                   ((or (string-prefix? doc "http:")
                        (string-prefix? doc "https:"))
                    doc)
                   (else
                    (make-path (static-url cfg dir) "index.html"))))
         (auth (package-author repo pkg))
         (maint (package-maintainer repo pkg))
         (auth-email (if (and maint (not (equal? auth maint)))
                         (cond
                          ((assoc-get (cdr pkg) 'authors)
                           => (lambda (x)
                                (if (pair? x)
                                    (extract-email (car x))
                                    (extract-email x))))
                          (else #f))
                         email)))
    `(tr
      (td (a (@ (href . ,(assoc-get pkg 'url)))
             ,(write-to-string (package-name pkg))))
      (td (small ,(package-version pkg)))
      (td (small
           ,(cond
             ((assoc-get (cdr pkg) 'updated)
              => (lambda (s) (substring s 0 10)))
             (else ""))))
      (td (@ (class . "detail")) ,desc)
      (td (@ (class . "detail"))
          ,@(append-map
             (lambda (auth email)
               `((a (@ ,@(if email
                             `((href ,(string-append "mailto:" email)))
                             '()))
                    ,auth)
                 " "))
             (if (pair? auth) auth (list auth))
             (append (if (pair? auth-email) auth-email (list auth-email))
                     (map (lambda (i) #f)
                          (iota (if (pair? auth) (length auth) 1)))))
          ,@(if (and maint (not (equal? auth maint)))
                `((br)
                  "(" (a (@ ,@(if email
                                  `((href ,(string-append "mailto:" email)))
                                  '()))
                         ,maint) ")")
                '()))
      (td (a (@ (href . ,(or doc-url ""))) ,(if doc-url "[html]" ""))))))

(define repo->sxml-table
  (memoize-file-loader
   (lambda (repo-path cfg)
     (let ((repo (call-with-input-file repo-path read)))
       (sortable-table
        `(table
          (@ (class . "sortable"))
          (tr (th "Package") (th "Version") (th "Updated")
              (th "Description") (th "Authors") (th "Docs"))
          ,@(filter-map
             (lambda (pkg)
               (guard
                   (exn
                    (else
                     (log-error "couldn't generate package summary: "
                                exn)
                     #f))
                 (package-row cfg repo pkg)))
             (sort (filter package? (cdr repo))
                   (lambda (a b)
                     (string<? (write-to-string (package-name a))
                               (write-to-string (package-name b))))))))))))

(servlet-run
 (lambda (cfg request next restart)
   (respond
    cfg
    request
    (lambda (content)
      (page
       `(div
         (div
          (@ (id . "main"))
          (div
           (@ (id . "col1"))
           ,(content
             (repo->sxml-table (static-local-path cfg "repo.scm")
                               cfg)))))
       '(script (@ (src . "/s/sorttable.js"))))))))
