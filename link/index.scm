
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
          (@ (id . "main"))
          (div
           (@ (id . "col1"))
           (h3 "R7RS")
           (ul
            (li (a (@ (href . "https://small.r7rs.org/attachment/r7rs.pdf")) "Final draft"))
            (li (a (@ (href . "http://scheme-reports.org/")) "Scheme Reports")))
           (h3 "Implementations")
           (ul (li (a (@ (href . "https://get.scheme.org/")) "get.scheme.org"))))
          (div
           (@ (id . "col2"))
           (h3 "Community")
           (ul (li (a (@ (href . "http://community.scheme.org")) "community.scheme.org"))))
          (div
           (@ (id . "col3"))
           (h3 "Learn")
           (li (a (@ (href . "https://docs.scheme.org")) "docs.scheme.org"))
           (li (a (@ (href . "http://xuanji.appspot.com/isicp/")) "Interactive SICP"))
           (li (a (@ (href . "http://library.readscheme.org/")) "Read Scheme"))
           (li (a (@ (href . "http://htdp.org/")) "How to Design Programs"))
           (li (a (@ (href . "http://www.scheme.com/tspl3/")) "The Scheme Programming Language"))
           ))))))))
