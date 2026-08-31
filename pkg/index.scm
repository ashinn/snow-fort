
(import (scheme base) (scheme read) (scheme write) (srfi 1) (srfi 2) (srfi 95)
        (chibi log) (chibi net servlet) (chibi config) (chibi memoize)
        (chibi pathname) (chibi string) (chibi regexp) (chibi io)
        (chibi snow fort) (chibi snow package))

(define memoized-read
  (memoize-file-loader
    (lambda (file)
      (call-with-input-file file read))))

(define read-package-list (lambda (file) (memoized-read file)))

(servlet-run
  (lambda (cfg request next restart)
    (respond
      cfg
      request
      (lambda (content)
        (let ()
          (page
            `(div
               (div
                 (@ (id . "main"))
                 (div
                   (@ (id . "col1"))
                   ,(content
                      (read-package-list
                        (static-local-path cfg "package-list.scm"))))))
            '(script (@ (src . "/s/js/list.min.js")))
            '(script (@ (src . "/s/js/pkg.js")))))))))
