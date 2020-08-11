
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
            (a (@ (href . "/doc/install")) "Installing") (br)
            (a (@ (href . "/doc/author")) "Publishing") (br)
            (a (@ (href . "/doc/usage")) "Command Summary") (br)
            (a (@ (href . "/doc/spec")) "Specification") (br))
           )
          (div
           (@ (id . "col2_3"))   ;; main
           (p
            "Snow2" (sup "[1]")
            " is a simple packaging format for Scheme libraries.\n"
            "You can browse the available libraries online in the "
            (a (@ (href . "/pkg/")) "packages list") ", and download and "
            " install them manually, or you can use existing tools to "
            "automate the install process.  One such tool is Seth Alves "
            (a (@ (href . "https://github.com/sethalves/snow2-client"))
               "snow2-client")
            ", which supports multiple implementations. Another tool "
            "is the " (code "snow-chibi") " command, distributed with "
            (a (@ (href . "http://synthcode.com/wiki/chibi-scheme"))
               "chibi-scheme")
            " as of version 0.7.3, which "
            "also supports multiple implementations. This document "
            "describes " (code "snow-chibi") ".")
           (p
            "From either client you can access multiple repositories. "
            "Library authors can choose to host libraries on their own "
            "servers, but it's better to publish them to a central "
            "repository so other programmers can find them more easily. "
            "A few public repositories are available, but this document "
            "focuses on the default "
            (a (@ (href . "http://snow-fort.org/")) "snow-fort.org")
            ", which allows third party publishing.")
           (p
            "Read on to find out how to "
            (a (@ (href . "/doc/install")) "install") " and "
            (a (@ (href . "/doc/author")) "write and publish") " libraries, "
            "or read the " (a (@ (href . "/doc/spec")) "specification")
            " to create your own tools."
            )
           (p
            "The full " (code "snow-chibi") " "
            (a (@ (href . "http://synthcode.com/scheme/chibi/#h2_SnowPackageManager"))
               "command reference")
            " is included in the chibi-scheme manual."))
          (div
           (@ (id . "col3_2"))   ;; notes
           (p
            (sup "[1]") "The original "
            (a (@ (href . "https://web.archive.org/web/20190404011409/http://snow.iro.umontreal.ca/?tab=Home")) "Snow")
            " was designed around R4RS Scheme, whereas the new version "
            "is based on R7RS Scheme, which has its own library system. "
            "We sometimes just say \"Snow\" when referring to the new "
            "version.")))))))))
