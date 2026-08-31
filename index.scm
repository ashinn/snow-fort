(import (scheme base) (scheme read) (scheme write) (scheme file)
        (srfi 1)
        (chibi config) (chibi io) (chibi log) (chibi memoize)
        (chibi net servlet) (chibi pathname) (chibi string)
        (chibi snow fort) (chibi snow package))

(define memoized-read
  (memoize-file-loader
    (lambda (file)
      (call-with-input-file file read))))

(servlet-run
 (lambda (cfg request next restart)
   (respond
    cfg
    request
    (lambda (content)
     (let* ((recent-list-path (static-local-path cfg "recent-list.scm"))
            (recent-list (if (file-exists? recent-list-path)
                           (memoized-read recent-list-path)
                           '())))
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
           (p
            "Browse the " (a (@ (href . "/pkg/")) "packages") " or try "
            (a (@ (href . "http://chibi-scheme.appspot.com/"))
               "chibi-scheme in the browser")
            "!"))
          (div
           (@ (id . "col2"))
           (h3 "Recent activity "
               (a (@ (href "s/recent-feed.xml"))
                  (img (@ (src "s/img/Feed-icon.svg") (width "16px")))))
           ,recent-list)))))))))
