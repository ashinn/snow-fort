
(import (scheme base) (scheme write)
        (chibi log) (chibi net servlet)
        (chibi snow fort))

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
           )
          (div
           (@ (id . "col2"))
           (br)
           (p
            "Browse the " (a (@ (href . "/pkg/")) "packages") " or try "
            (a (@ (href . "http://chibi-scheme.appspot.com/"))
               "chibi-scheme in the browser")
            "!"))
          (div
           (@ (id . "col3"))
           ))))))))
