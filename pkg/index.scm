
(import (scheme base) (scheme write) (srfi 1) (srfi 95)
        (chibi log) (chibi net servlet) (chibi config) (chibi pathname)
        (chibi string) (chibi regexp) (chibi snow fort) (chibi snow package))

;; Add a table id, and a sort button to each header to call a sorter
;; function on the table.
(define (sortable-table table)
  table)

(define (extract-email str)
  (string-trim
   (regexp-replace '(: (* any) "<" ($ (* (~ (">")))) ">" (* any)) str 1)))

(define (package-row cfg repo pkg)
  (let* ((email (package-email pkg))
         (desc (or (assoc-get pkg 'description) ""))
         (dir (package-dir email pkg))
         (docs (assoc-get pkg 'manual))
         (doc (if (pair? docs) (car docs) docs))
         (doc-url (if (and (string? doc)
                           (or (string-prefix? doc "http:")
                               (string-prefix? doc "https:")))
                      doc
                      (make-path (static-url cfg dir) "index.html")))
         (auth (package-author repo pkg))
         (maint (package-maintainer repo pkg))
         (auth-email (if (and maint (not (equal? auth maint)))
                         (cond
                          ((assoc-get (cdr pkg) 'authors)
                           => extract-email)
                          (else #f))
                         email)))
    `(tr
      (td (a (@ (href . ,(assoc-get pkg 'url)))
             ,(let ((out (open-output-string)))
                (write (package-name pkg) out)
                (get-output-string out))))
      (td ,(package-version pkg))
      (td (@ (class . "detail")) ,desc)
      (td (a (@ (href . ,(string-append "mailto:" (or auth-email ""))))
             ,auth)
          ,@(if (and maint (not (equal? auth maint)))
                `((br)
                  "(" (a (@ (href . ,(string-append "mailto:" (or email ""))))
                         ,maint) ")")
                '()))
      (td (a (@ (href . ,doc-url)) "[html]")))))

(define (write-to-string x)
  (let ((out (open-output-string)))
    (write x out)
    (get-output-string out)))

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
             (let ((repo (current-repo cfg)))
               (sortable-table
                `(table
                  (tr (th "Package") (th "Version") (th "Description")
                      (th "Authors") (th "Docs"))
                  ,@(map
                     (lambda (pkg) (package-row cfg repo pkg))
                     (sort (filter package? (cdr repo))
                           (lambda (a b)
                             (string<? (write-to-string (package-name a))
                                       (write-to-string (package-name b))))
                           ))))))))))))))
