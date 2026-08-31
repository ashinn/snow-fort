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
           (p
            "The following implementations are currently supported: "
            (ul
             (li (a (@ (href . "https://codeberg.org/playXE/capy")) "capyscheme"))
             (li (a (@ (href . "http://synthcode.com/wiki/chibi-scheme")) "chibi"))
             (li (a (@ (href . "http://www.call-cc.org/")) "chicken"))
             (li (a (@ (href . "https://justinethier.github.io/cyclone/")) "cyclone"))
             (li (a (@ (href . "https://code.google.com/p/foment/")) "foment"))
             (li (a (@ (href . "https://gambitscheme.org/")) "gambit"))
             (li (a (@ (href . "http://practical-scheme.net/gauche/")) "gauche"))
             (li (a (@ (href . "https://www.gnu.org/software/guile/")) "guile"))
             (li (a (@ (href . "http://www.gnu.org/software/kawa/")) "kawa"))
             (li (a (@ (href . "https://scheme.fail/")) "loko"))
             (li (a (@ (href . "https://github.com/yamacir-kit/meevax")) "meevax"))
             (li (a (@ (href . "https://www.gnu.org/software/mit-scheme/")) "mit-scheme"))
             (li (a (@ (href . "https://mosh.monaos.org/files/doc/text/About-txt.html")) "mosh"))
             (li (a (@ (href . "http://www.larcenists.org/")) "larceny"))
             (li (a (@ (href . "https://racket-lang.org/")) "racket"))
             (li (a (@ (href . "https://ktakashi.github.io/")) "sagittarius"))
             (li (a (@ (href . "https://github.com/false-schemers/skint")) "skint"))
             (li (a (@ (href . "https://stklos.net/")) "stklos"))
             (li (a (@ (href . "https://gitlab.com/jobol/tr7")) "tr7"))
             (li (a (@ (href . "https://github.com/fujita-y/ypsilon")) "ypsilon")))
            " and the special name " (code "all") " can be used "
            " to install for all available implementations.  You can "
            " check the available implementations on your machine "
            " with the " (code "snow-chibi implementations") " command."))
          (div
           (@ (id . "col3_2"))   ;; notes
           (p
            )))))))))
