
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
            (pre
             (code
              "
Usage: snow [options] <command>
Commands:
  search terms ... - search for packages
  show names ... - show package descriptions
  install names ... - install packages
  upgrade names ... - upgrade installed packages
  remove names ... - remove packages
  status names ... - print package status
  package files ... - create a package
  gen-key - create an RSA key pair
  reg-key - register an RSA key pair
  sign file - sign a package
  verify file - verify a signature
  upload files ... - upload a package to a remote repository
  index files ... - add a package to a local repository file
  update - force an update of available package status
  implementations - print currently available scheme implementations
  help args ... - print help
Options:
  -v, --verbose - print additional informative messages
  -y, --always-yes - answer all questions with yes
  -n, --always-no - answer all questions with no
      --require-sig - require signature on installation
      --ignore-sig - don't verify package signatures
      --ignore-digest - don't verify package checksums
      --skip-digest - don't provide digests without rsa
      --skip-version-checks - don't verify implementation versions
      --sign-uploads - sign with the rsa key if present
      --host - base uri of snow repository
      --repo - uris or paths of snow repositories
      --local-root-repository - repository cache dir for root
      --local-user-repository - repository cache dir for non-root users
      --update-strategy - when to refresh repo: always, never, cache or confirm
      --install-prefix - prefix directory for installation
      --install-source-dir - directory to install library source in
      --install-library-dir - directory to install shared libraries in
      --install-binary-dir - directory to install programs in
      --install-data-dir - directory to install data files in
      --library-extension - the extension to use for library files
      --library-separator - the separator to use for library components
      --library-path - the path to search for local libraries
      --installer - name of installer to use
      --builder - name of builder to use
      --program-builder - name of program builder to use
      --impls - impls to install for, or 'all'
      --program-implementation - impl to install programs for
      --chibi-path - path to chibi-scheme executable
      --cc - path to c compiler
      --cflags - flags for c compiler
      --sexp - output information in sexp format
"))))
          (div
           (@ (id . "col3_2"))   ;; notes
           ))))))))
