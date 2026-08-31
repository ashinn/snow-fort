(import (scheme base)
        (scheme read)
        (scheme write)
        (scheme file)
        (scheme process-context)
        (scheme char)
        (scheme time)
        (chibi config)
        (chibi snow package)
        (chibi snow utils)
        (chibi log)
        (chibi filesystem)
        (chibi sxml)
        (chibi time)
        (srfi 1)
        (srfi 95))

(define pkg-data-dir "s/pkg-data")

(when (null? (cdr (command-line)))
  (error "Pass repository files as arguments"))

(define (write-to-string x)
  (let ((out (open-output-string)))
    (write x out)
    (get-output-string out)))

(define packages
  (let ((previous-pkg-name "")
        (previous-pkg-publisher "")
        (repo->packages (lambda (repo-file)
                          (filter package?
                                  (with-input-from-file repo-file (lambda () (cdr (read))))))))
    (filter-map
      (lambda (pkg)
        (if (and (equal? (package-name pkg) previous-pkg-name)
                 (equal? (package-publisher '() pkg) previous-pkg-publisher))
          (begin
            (set! previous-pkg-name (package-name pkg))
            (set! previous-pkg-publisher (package-publisher '() pkg))
            #f)
          (begin
            (set! previous-pkg-name (package-name pkg))
            (set! previous-pkg-publisher (package-publisher '() pkg))
            pkg)))
      (sort
        (apply append (map repo->packages (cdr (command-line))))
        (lambda (a b)
          (let ((compstr-a
                  (string-append (write-to-string (package-name a))
                                 "-"
                                 (package-version a)))
                (compstr-b
                  (string-append (write-to-string (package-name b))
                                 "-"
                                 (package-version b))))
            (string>? compstr-a compstr-b)))))))

(define packages-newest
  (let ((package-updated
          (lambda (pkg)
            (let ((updated (assq 'updated pkg)))
              (if updated
                (cadr updated)
                "")))))
    (sort packages
          (lambda (a b)
            (string>? (package-updated a) (package-updated b))))))

(define (package-row pkg . description?)
  (let* ((desc (or (assoc-get pkg 'description) ""))
         (pkg-page-url (string-append "pkg-page?name="
                                      (write-to-string (package-name pkg))
                                      "&publisher="
                                      (package-publisher '() pkg))))
    `(tr (td (@ (class . "package")) ,(write-to-string (package-name pkg)))
         (td (@ (class . "publisher")) ,(package-publisher '() pkg))
         (td (small (a (@ (href . ,pkg-page-url)) ,(package-version pkg))))
         (td (@ (class . "updated"))
             (small
               ,(cond
                  ((assoc-get (cdr pkg) 'updated)
                   => (lambda (s) (substring s 0 10)))
                  (else ""))))
         ,(if (or (null? description?)
                  (car description?))
            `(td (@ (class . "description")) ,desc)
            '()))))

(define (write-package-data pkg)
  (let ((pkg-dir (string-append pkg-data-dir "/" (package-publisher '() pkg))))
    (when (not (file-exists? pkg-dir))
      (create-directory pkg-data-dir)
      (create-directory pkg-dir)))
  (let* ((path (string-append pkg-data-dir
                              "/"
                              (package-publisher '() pkg)
                              "/"
                              (write-to-string (package-name pkg))
                              ".scm")))
    (with-output-to-file path (lambda () (write pkg)))))

(define (package-dependencies-list pkg)
  (letrec*
    ((lib->list
       (lambda (lib)
         `(li ,(write-to-string (car lib))
              (ul ,(map
                     (lambda (dep)
                       (cond ((and (pair? dep)
                                   (equal? (car dep) 'depends))
                              (lib->list dep))
                             (else
                               `(li ,(write-to-string dep)))))
                     (cdr lib)))))))
    `(ul
       ,@(map
           (lambda (lib)
             `(li ,(write-to-string (car (cdr (assoc 'name (cdr lib)))))
                  (ul ,@(map
                          (lambda (item)
                            (cond ((and (pair? item)
                                        (equal? (car item) 'depends))
                                   (lib->list item))
                                  ((equal? (car item) 'cond-expand)
                                   `(li "cond-expand"
                                        (ul ,(map lib->list (cdr item)))))
                                  (else `(ul))))
                          (cdr lib)))))
           (package-libraries pkg)))))


(define (write-package-dependency-data pkg)
  (let ((pkg-dir (string-append pkg-data-dir "/" (package-publisher '() pkg))))
    (when (not (file-exists? pkg-dir))
      (create-directory pkg-data-dir)
      (create-directory pkg-dir)))
  (let* ((path (string-append pkg-data-dir
                              "/"
                              (package-publisher '() pkg)
                              "/"
                              (write-to-string (package-name pkg))
                              "-dependencies.scm"))
         (dependencies (package-dependencies-list pkg)))
    (with-output-to-file path (lambda () (write dependencies)))))

(define page
  `(div (@ (id . "package-list"))
        (label (@ (for . "package-search")) "Search: ")
        (input (@ (id . "package-search") (class . "fuzzy-search")))
        (table
          (thead
            (tr (th (@ (class . "package"))
                    (span (@ (class . "sort")
                             (data-sort . "package")
                             (data-default-order . "asc"))
                          "Package ⇅"))
                (th (@ (class . "publisher")) "Publisher")
                (th (@ (class . "version")) "Version")
                (th (@ (class . "updated"))
                    (span (@ (class . "sort")
                             (data-sort . "updated")
                             (data-default-order . "asc"))
                          "Updated ⇅"))
                (th (@ (class . "description")) "Description")))
          (tbody
            (@ (class . "list"))
            ,@(filter-map
                (lambda (pkg)
                  (guard
                    (exn
                      (else
                        (log-error "couldn't generate package summary: "
                                   exn)
                        #f))
                    (write-package-data pkg)
                    (write-package-dependency-data pkg)
                    (package-row pkg)))
                (reverse packages))))))

(with-output-to-file
  "s/recent-list.scm"
  (lambda ()
    (write
      `(table
         (thead
           (tr (th (@ (class . "package"))
                   (span (@ (class . "sort")
                            (data-sort . "package")
                            (data-default-order . "asc"))
                         "Package"))
               (th (@ (class . "publisher")) "Publisher")
               (th (@ (class . "version")) "Version")
               (th (@ (class . "updated"))
                   (span (@ (class . "sort")
                            (data-sort . "updated")
                            (data-default-order . "asc"))
                         "Updated"))))
         ,(map (lambda (pkg)
                 (package-row pkg #f))
               (take packages-newest 5))))))


(define (package-feed-item pkg)
  (let* ((desc (or (assoc-get pkg 'description) ""))
         (pkg-page-url (string-append "pkg-page?name="
                                      (write-to-string (package-name pkg))
                                      "&publisher="
                                      (package-publisher '() pkg)))
         (updated (assoc-get (cdr pkg) 'updated)))
    (cond ((not updated) '())
          (else
            `(entry
               (id ,(write-to-string (package-name pkg)))
               (title ,(write-to-string (package-name pkg)))
               (link (@ (href ,(string-append "https://snow-fort.org/" pkg-page-url))) "")
               (updated ,updated)
               (summary ,desc))))))

(with-output-to-file
  "s/recent-feed.xml"
  (lambda ()
    (display
      (sxml->xml
        `(feed (@ (xmlns "http://www.w3.org/2005/Atom"))
               (id "https://snow-fort.org")
               (title "Snow-fort recent activity")
               (link "https://snow-fort.org")
               (updated ,(tai->rfc-3339 (current-second)))
               ,(map (lambda (pkg)
                       (package-feed-item pkg))
                     (take packages-newest 10)))))))

(with-output-to-file "s/package-list.scm" (lambda () (write page)))

