(import (scheme base)
        (scheme write)
        (chibi log)
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
                 (@ (id . "col1"))   ;; nav
                 (p (a (@ (href . "/doc/install")) "Installing") (br)
                    (a (@ (href . "/doc/author")) "Publishing") (br)
                    (a (@ (href . "/doc/usage")) "Command Summary") (br)
                    (a (@ (href . "/doc/spec")) "Specification") (br)
                    (a (@ (href . "/doc/repo")) "Repositories") (br)))
               (div
                 (@ (id . "col2_3"))   ;; main
                 (p "To install package use the " (code "install") " command: ")
                 (blockquote
                   (code "snow-chibi install \"(chibi match)\""))
                 (p "As a convenience, to avoid quoting in the shell you can also "
                    "write the name as a single word, separating components with "
                    "a dot: ")
                 (blockquote
                   (code
                     "snow-chibi install chibi.match"))
                 (p "To install package from file: ")
                 (blockquote
                   (code "snow-chibi install chibi-match-0.9.1.tgz"))
                 (p "By default this will install for chibi-scheme, but you can "
                    "use the " (command "--impls") " option to specify "
                    "one or more alternates, separated by commas:")
                 (blockquote
                   (pre
                     (code
                       "snow-chibi --impls=gauche,larceny install \"(chibi match)\"")))
                 (p "The following implementations are currently supported: "
                    (ul
                      (li (a (@ (href . "https://codeberg.org/playxe/capy")) "capyscheme"))
                      (li (a (@ (href . "http://synthcode.com/wiki/chibi-scheme")) "chibi"))
                      (li (a (@ (href . "http://www.call-cc.org/")) "chicken"))
                      (li (a (@ (href . "https://code.google.com/p/foment/")) "foment"))
                      (li (a (@ (href . "https://gambitscheme.org/")) "gambit"))
                      (li "generic; By default libraries are installed into /usr/local/lib/snow or %LOCALAPPDATA%/lib/snow on windows")
                      (li (a (@ (href . "http://practical-scheme.net/gauche/")) "gauche"))
                      (li (a (@ (href . "https://www.gnu.org/software/guile/")) "guile"))
                      (li (a (@ (href . "http://www.gnu.org/software/kawa/")) "kawa"))
                      (li (a (@ (href . "scheme.fail")) "loko"))
                      (li (a (@ (href . "http://www.larcenists.org/")) "larceny"))
                      (li (a (@ (href . "https://mosh.monaos.org/files/doc/text/About-txt.html")) "mosh"))
                      (li (a (@ (href . "https://racket-lang.org/")) "racket"))
                      (li (a (@ (href . "https://ktakashi.github.io/")) "sagittarius"))
                      (li (a (@ (href . "https://stklos.net/")) "stklos"))
                      (li (a (@ (href . "https://gitlab.com/jobol/tr7")) "tr7"))
                      (li (a (@ (href . "https://github.com/fujita-y/ypsilon")) "ypsilon")))
                    " and the special name " (code "all") " can be used "
                    " to install for all available implementations.  You can "
                    " check the available implementations on your machine "
                    " with the " (code "snow-chibi implementations") " command.")
                 (p "If multiple packages provide the given library name you'll "
                    "be given a choice as to which to install.  In most cases "
                    "people will choose unique prefixes for their libraries, "
                    "but you may find competing SRFI implementations.")
                 (p "This will try to install in the standard system directory "
                    "for the given implementation, invoking " (code "sudo")
                    " if needed.  If you don't have " (code "sudo") " access "
                    "or otherwise want to install in a non-standard location "
                    "you can use the " (code "--install-prefix") " option. "
                    "For example, given " (code "--install-prefix=/usr/local/")
                    " show-chibi will try to install in "
                    "/usr/local/share/snow/<impl>/.  If you don't want to "
                    "assume a given layout, you can specify the exact directory "
                    "with the " (code "--install-library-dir") " option.")
                 (p "To actually find the packages you want you can either browse "
                    "the " (a (@ (href . "/pkg/")) "packages list") ", or you can "
                    "use the " (command "search") " command: ")
                 (blockquote
                   (code
                     "snow-chibi search match"))
                 (p "This will search in the name, description, and other meta-info "
                    "of the packages, ranking higher for direct name matches.")
                 (p "The " (command "upgrade") " command can be used in the same way "
                    "to upgrade already installed packages if a new version is "
                    "available, or more simply run with no argument to upgrade all "
                    "installed packages.  You can also list the current installed "
                    "packages and their versions with the " (command "status")
                    " command.")
                 (p "To remove a package you no longer need use the "
                    (command "remove") " command:")
                 (blockquote
                   (code
                     "snow-chibi remove chibi.match")))
               (div
                 (@ (id . "col3_2"))   ;; notes
                 (p)))))))))
