
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
           (h3 "Packaging")
           (p
            "Snowballs are created with the " (command "package") " command. "
            "Simply give it the path to one or more R7RS library files and "
            "it will package them along with any include files. For example, "
            "if we wanted to package the old "
            (a (@ (href . "http://www.cs.cmu.edu/afs/cs/project/ai-repository/ai/lang/scheme/code/parsing/earley/0.html")) "Earley parser")
            " from the CMU AI Repository, we would first trivially update it "
            "to R7RS, creating a file named, e.g. \"earley.sld\": ")
           (blockquote
            (pre
             (code
              "(define-library (feeley earley)
  (export make-parser parse->parsed?
          parse->trees parse->nb-trees tree-display)
  (import (scheme r5rs))
  (include \"tree.scm\")
  (include \"earley.scm\"))")))
           (p
            "This could then be packaged with: ")
           (blockquote
            (code
             "snow-chibi package earley.sld"))
           (p
            "This will use your local username as the author, but "
            "provide no other information.  We can add this with options: ")
           (blockquote
            (pre
             (code
              "snow-chibi package --version=1.0 --authors=\"Marc Feeley\" \\\n"
              "  --maintainers=\"Me <me@myself.com>\" earley.sld")))
           (p
            "We don't know the license or we'd include that with the "
            (command "--license") " option.  Of course, packages are not "
            "much use without documentation, so we would want to add some: ")
           (blockquote
            (pre
             (code
              "snow-chibi package --version=1.0 --authors=\"Marc Feeley\" \\\n"
              "  --maintainers=\"Me <me@myself.com>\" --doc=earley.ps \\\n"
              "  --description=\"Earley Parser for Context-Free Grammars\" \\\n"
              "  earley.sld")))
           (p
            "Any format (ps, pdf, html) is fine, as we simply include this "
            "file in the snowball and provide a link to it, however for "
            "ease of browsing from the public repo html is preferred.  If "
            "you want to embed the docs in the code in a literate-programming "
            "fashion, you can also use the --doc-from-scribble option, which "
            "treats any line beginning with " (code "\";;>\"") " as docs in "
            "scribble syntax, using backslash instead of @ as the escape "
            "character.  In this case we can infer the description from the "
            "first sentence of documentation.")
           (p
            "Finally, a well maintained library should provide tests. "
            "You can include these with the " (command "--test=<prog.scm>")
            " option, which should be an R7RS program that either exits "
            "with a non-zero status or outputs text including \"ERROR\" or "
            "\"FAIL\" on failure.  If you want to keep your tests in a library "
            "you can alternately use " (command "--test-library=<mylib.scm>")
            ", which should be a library exporting a thunk "
            (command "run-tests") ", which when run has the same behavior as "
            "a test program.  You can also specify "
            (code "(append-to-last -test)") " as the " (command "test-library")
            ", which would look for a library based on the packaged library "
            "with the given suffix, in this case "
            (code "(feeley earley-test)")
            ".  This is especially handy when packaging multiple libraries "
            "together.")
           (p
            "Putting all of this together we have: ")
           (blockquote
            (pre
             (code
              "snow-chibi package --version=1.0 --authors=\"Marc Feeley\" \\\n"
              "  --maintainers=\"Me <me@myself.com>\" --doc=earley.ps \\\n"
              "  --description=\"Earley Parser for Context-Free Grammars\" \\\n"
              "  --test=earley-test.scm earley.sld")))
           (p
            "The " (command "snow-chibi") " command uses "
            (a (@ (href . "http://synthcode.com/scheme/chibi/lib/chibi/app.html"))
               (code "(chibi app)"))
            " to manage options and configuration, "
            "which means you can also specify defaults for any of these "
            "options in your \"~/.snow/config.scm\" file.  If we put this all "
            "together, converting the docs to scribble, adding a VERSION "
            "file, and creating the " (code "(feeley earley-test)") " library, "
            "with the following config.scm:")
           (blockquote
            (pre
             (code
              "((command
  (package
   (authors \"Me <me@myself.com>\")
   (doc-from-scribble #t)
   (version-file \"VERSION\")
   (test-library (append-to-last -test)))))")))
           (p
            "then the command becomes simply:")
           (blockquote
            (pre (code "snow-chibi package --authors=\"Marc Feeley\" earley.sld")))
           (h3 "Publishing")
           (p
            "Once we have a package the next step is to share it.  First "
            "generate a key with: ")
           (blockquote
            (pre (code "snow-chibi gen-key")))
           (p
            "which will ask you for your email address and a password, "
            "then register it with: ")
           (blockquote
            (pre (code "snow-chibi reg-key")))
           (p
            "You should receive an email with a link to complete the "
            "registration, after which you're ready to upload.  In this "
            "case we can upload our package with: ")
           (blockquote
            (pre (code "snow-chibi upload feeley-earley-1.0.tgz")))
           "and we're done!")
          (div
           (@ (id . "col3_2"))   ;; notes
           (p
            )))))))))
