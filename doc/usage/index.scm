(import (scheme base)
        (scheme write)
        (chibi log)
        (chibi process)
        (chibi net servlet)
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
                 (p (a (@ (href . "/doc/install")) "Installing") (br)
                   (a (@ (href . "/doc/author")) "Publishing") (br)
                   (a (@ (href . "/doc/usage")) "Command Summary") (br)
                   (a (@ (href . "/doc/spec")) "Specification") (br)
                   (a (@ (href . "/doc/repo")) "Repositories") (br)))
               (div
                 (@ (id . "col2_3"))
                 (p
                   (pre
                     (code
                       ,(process->string "snow-chibi")))))
               (div
                 (@ (id . "col3_2"))))))))))
