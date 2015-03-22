
(import (scheme base) (scheme write) (srfi 1) (srfi 95)
        (chibi log) (chibi net servlet) (chibi config) (chibi pathname)
        (chibi string) (chibi snow fort) (chibi snow package))

;; Add a table id, and a sort button to each header to call a sorter
;; function on the table.
(define (sortable-table table)
  table)

(define (package-row cfg repo pkg)
  (let* ((email (package-email pkg))
         (desc (or (assoc-get pkg 'description) ""))
         (dir (package-dir email pkg))
         (doc (assoc-get pkg 'manual))
         (doc-url (if (and doc
                           (or (string-prefix? doc "http:")
                               (string-prefix? doc "https:")))
                      doc
                      (make-path (static-url cfg dir) "index.html"))))
    `(tr
      (td (a (@ (href . ,(assoc-get pkg 'url)))
             ,(let ((out (open-output-string)))
                (write (package-name pkg) out)
                (get-output-string out))))
      (td ,(package-version pkg))
      (td (@ (class . "detail")) ,desc)
      (td (a (@ (href . ,(string-append "mailto:" (or email ""))))
             ,(package-author repo pkg)))
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
                      (th "Author") (th "Docs"))
                  ,@(map
                     (lambda (pkg) (package-row cfg repo pkg))
                     (sort (filter package? (cdr repo))
                           (lambda (a b)
                             (string<? (write-to-string (package-name a))
                                       (write-to-string (package-name b))))
                           ))))))))))))))
