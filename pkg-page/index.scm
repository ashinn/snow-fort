
(import (scheme base)
        (scheme read)
        (scheme write)
        (scheme file)
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
        (chibi snow package))

(define (any->string any)
  (parameterize
     ((current-output-port (open-output-string)))
     (display any)
     (get-output-string (current-output-port))))

(define (write-to-string x)
  (let ((out (open-output-string)))
    (write x out)
    (get-output-string out)))

(define (extract-email str)
  (and-let* ((re '(: (* any) "<" ($ (* (~ (">")))) ">" (* any)))
             (match (regexp-matches re str)))
    (string-trim (regexp-match-submatch match 1))))

(define (in-snow-fort? repo pkg lib-name)
  (not (null? (filter (lambda (pkg)
                        (and (package? pkg)
                             (equal? (package-name pkg) lib-name)))
                      (cdr repo)))))

(define (to-link-if-exists repo pkg lib-name)
  (if (and (not (equal? (car lib-name) 'scheme))
           (not (equal? (car lib-name) 'srfi))
           (not (equal? (package-name pkg) lib-name))
           (in-snow-fort? repo pkg lib-name))
    `(a (@ (href . ,(string-append "/pkg-page?pkg="
                                   (write-to-string lib-name))))
        ,(write-to-string lib-name))
    (write-to-string lib-name)))

(define (package-libraries-list repo pkg)
  (letrec*
    ((lib->list
       (lambda (lib)
         `(li ,(write-to-string (car lib))
              (ul ,(map
                     (lambda (dep)
                       (cond ((equal? (car dep) 'depends)
                              (lib->list dep))
                             (else
                               `(li ,(to-link-if-exists repo pkg dep)))))
                     (cdr lib)))))))
    `(ul
       ,@(map
           (lambda (lib)
             `(li ,(write-to-string (car (cdr (assoc 'name (cdr lib)))))
                  (ul ,@(map (lambda (item)
                               (cond ((equal? (car item) 'depends)
                                      (lib->list item))
                                     ((equal? (car item) 'cond-expand)
                                      `(li "cond-expand"
                                           (ul ,(map lib->list (cdr item)))))
                                     (else `(ul))))
                             (cdr lib)))))
           (package-libraries pkg)))))

(define repo->pkg-info
  (memoize-file-loader
    (lambda (repo-path cfg pkg-name-string pkg-author pkg-maintainer)
      (let* ((repo (call-with-input-file repo-path read))
             (pkg-name (read (open-input-string pkg-name-string)))
             (pkg (car (filter (lambda (pkg)
                                 (and (package? pkg)
                                      (equal? (package-name pkg) pkg-name)
                                      (or (not (equal? (car pkg-name) 'srfi))
                                          (equal? (package-maintainer repo pkg) pkg-maintainer))))
                               (cdr repo))))
             (email (package-email pkg))
             (description (or (assoc-get pkg 'description) ""))
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
             (download-url (assoc-get pkg 'url))
             (author (package-author repo pkg))
             (maintainer (package-maintainer repo pkg))
             (auth-email (if (and maintainer (not (equal? author maintainer)))
                           (cond
                             ((assoc-get (cdr pkg) 'authors)
                              => (lambda (x)
                                   (if (pair? x)
                                     (extract-email (car x))
                                     (extract-email x))))
                             (else #f))
                           email))
             (version (package-version pkg)))
        `(div
           (div
             (div
               (@ (id . "main"))
               (div (@ (id . "col1"))
                    (h2 ,pkg-name-string)
                    (table
                      (@ (style . "text-align: left"))
                      (tr (th "Author") (th ,(if author author "")))
                      (tr (th "Maintainer") (th ,(if maintainer maintainer "")))
                      (tr (th "Version")
                          (th (a (@ (href . ,download-url)) ,version)))
                      (tr (th "Documentation")
                          ,(if doc-url
                             `(th (a (@ (href . ,doc-url))
                                     ,(path-strip-directory doc-url)))
                             ""))))
               (div
                 (@ (id . "col2"))
                 (div
                   (@ (style . "min-height: 30vh;"))
                   ,description))
               (div
                 (@ (id . "col3"))
                 (h3 "Libraries and their immediate dependencies")
                 ,(package-libraries-list repo pkg)))))))))

(servlet-run
  (lambda (cfg request next restart)
    (respond
      cfg
      request
      (lambda (content)
        (page
          (repo->pkg-info (static-local-path cfg "repo.scm")
                          cfg
                          (request-param request "pkg")
                          (request-param request "author")
                          (request-param request "maintainer")))))))
