
(import (scheme base) (scheme write)
        (chibi log) (chibi net servlet)
        (chibi snow fort)
        (chibi process))

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
           (@ (id . "col1"))   ;; nav
           (p
            (a (@ (href . "/doc")) "Getting started") (br)
            (a (@ (href . "/doc/install")) "Installing") (br)
            (a (@ (href . "/doc/author")) "Publishing") (br)
            (a (@ (href . "/doc/usage")) "Command Summary") (br)
            (a (@ (href . "/doc/spec")) "Specification") (br)
            (a (@ (href . "/doc/repo")) "Repositories") (br)
            (a (@ (href . "/doc/implementations")) "Supported implementations") (br)))
          (div
           (@ (id . "col2_3"))   ;; main
           (p (pre (code ,(process->string '(snow-chibi))))))
          (div
           (@ (id . "col3_2"))   ;; notes
           ))))))))
