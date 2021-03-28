
(import (scheme base) (scheme read) (scheme write)
        (srfi 1)
        (chibi config) (chibi io) (chibi log) (chibi memoize)
        (chibi net servlet) (chibi pathname) (chibi string)
        (chibi snow fort) (chibi snow package))

(define (write-to-string x)
  (let ((out (open-output-string)))
    (write x out)
    (get-output-string out)))

(define (package-blurb cfg repo pkg)
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
         )
    `(li
      (a (@ (href . ,doc-url))
         ,(write-to-string (package-name pkg)))
      " "
      (a (@ (href . ,(assoc-get pkg 'url)))
         ,(package-version pkg))
      (br)
      (small
       ,(cond
         ((assoc-get (cdr pkg) 'updated)
          => (lambda (s)
               `(time (@ (class "relative") (datetime ,s))
                      ,(substring s 0 10))))
         (else ""))))))

;; to work with memoization we need to render via javascript
(define repo->recent-summary
  (memoize-file-loader
   (lambda (repo-path cfg)
     (let ((repo (call-with-input-file repo-path read)))
       `(ul
         ,@(filter-map
            (lambda (pkg)
              (guard
                  (exn
                   (else
                    (log-error "couldn't generate package summary: "
                               exn)
                    #f))
                (package-blurb cfg repo pkg)))
            (take (filter package? (cdr repo)) 5)))))))

(servlet-run
 (lambda (cfg request next restart)
   (respond
    cfg
    request
    (lambda (content)
      (page
       `(div
         (div
          (@ (id . "quote"))
          (p (i "Scheme is like a ball of snow. You can add any amount of
snow to it and it still looks like a ball of snow."))
          (p (i "Moreover, snow is cleaner than mud.") " -- Marc Feeley")
          (p))
         (div
          (@ (id . "main"))
          (div
           (@ (id . "col1"))
           (h3 "Welcome to Snow!")
           (p "Snow is a place to share Scheme programs, libraries and data. "
              "Currently we host only R7RS libraries, though we may expand "
              "to more dialects in the future.")
           (p "Snow packages are also mirrored on "
              (a (@ (href . "https://akkuscm.org/")) "Akku") ".")
           )
          (div
           (@ (id . "col2"))
           (p
            "Browse the " (a (@ (href . "/pkg/")) "packages") " or try "
            (a (@ (href . "http://chibi-scheme.appspot.com/"))
               "chibi-scheme in the browser")
            "!"))
          (div
           (@ (id . "col3"))
           (h3 "Recent activity")
           (p
            ,(repo->recent-summary (static-local-path cfg "repo.scm") cfg)))))
       '(script (@ (src . "/s/relativetime.js"))))))))
