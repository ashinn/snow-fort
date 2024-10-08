
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
         (br)
         (div
          (@ (id . "main"))
          (div
           (@ (id . "col1"))
           (b "Q: ") (i "Why is it called Snow?") (br)
           (br)
           (b "A: ") "Snow originally stood for \"Scheme Now,\" and is "
           "in part a reference to the analogy that Lisp is a "
           (a (@ (href . "http://en.wikipedia.org/wiki/Big_ball_of_mud#In_programming_languages"))
              "ball of mud") ". "
              "Add anything to Lisp and you still have a ball of mud - "
              "it still looks like Lisp.  The same can be said of Scheme, "
              "except it's cleaner. "
              "You can also use the backronym \"Scheme Networked "
              "Object World.\"" (br))
          (div
           (@ (id . "col2"))
               (b "Q: ") (i "How I can use or install these libraries?") (br)
               (br)
               (b "A: ") "Any " (a (@ (href . "/link"))
                                   "R7RS compliant implementation")
               " should be able to use these libraries. "
               (a (@ (href . "http://synthcode.com/wiki/chibi-scheme"))
                  "Chibi-scheme")
               " as of version 0.7.3 comes with a command " (code "snow-chibi")
               " which can automatically search and install R7RS libraries "
               "for itself and other implementations.")
          (div
           (@ (id . "col3"))))))))))
