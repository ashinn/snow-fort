
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
            (a (@ (href . "/doc/spec")) "Specification") (br)
	    (a (@ (href . "/doc/repo")) "Repositories") (br))
           )
          (div
           (@ (id . "col2_3"))   ;; main
           (p
            "A snowball is simply a tarball containing a single directory, "
            "with any number of programs, libraries or data files therein. "
            "Links to these files come from the external repository meta "
            "data, but for simplicity when you create a snowball with "
            (command "snow-chibi") " it will create a "
            "file called \"package.scm\" in the tarball with much of the "
            "same information.  The current "
            "supported structure of the meta data is as follows:")
           (pre
            (code
             "(package
  ;; The name of a package uses the same namespace as the library names.
  ;; If the package name is not provided, then the package can only be
  ;; referred to by the individual library names in the package.
  (name (wonderland))
  ;; A list of author names, optionally with email addresses.
  (authors \"Charles Dodgson\")
  ;; A list of maintainers if different from the authors.
  (maintainers \"Alice Caroll <alice@wonderland.org>\")
  ;; A URL pointing to the manual for the package.
  (manual \"manual.html\")
  ;; A short description of the package.
  (description \"...\")
  ;; A list of licenses as symbols, e.g.
  ;;  * gpl2
  ;;  * gpl3
  ;;  * lgpl
  ;;  * mit
  ;;  * bsd
  ;;  * artistic
  ;;  * apache
  ;;  * public-domain
  (license bsd)
  ;; Current version string.
  (version \"1.2.3\")
  ;; Program containing tests to run before installing this package.
  ;; The program should exit with a success value (0 on POSIX systems)
  ;; if all tests pass.  On failure it should either exit otherwise,
  ;; or output either \"ERROR\" or \"FAIL\".  Tools should fail or warn
  ;; before installing libraries for which any tests fail.
  (test \"path/to/test-program.scm\")

  ;; The URL points to a tarred, gzipped file containing a single
  ;; directory - any other format is invalid.  Only available from
  ;; repository info.
  ;; All path references below are relative to that directory.
  (url \"http://www.wonderland.org/repo/cheshire-cat.tgz\")
  ;; The size of the package tarball in bytes, for information prior
  ;; to downloading and as an additional checksum (since this is
  ;; a checksum this refers to the size of the unzipped tarball).
  (size 1234)
  ;; A package can contain zero or more signatures.  Each signature
  ;; contains the identity of a publisher as registered with reg-key,
  ;; and an RSA signature of one or more of the checksums as hex strings.
  ;; Due to speed concerns generating and verifying signatures is
  ;; disabled by default.
  (signature (email \"hatter@wonderland.org\")
             (digest sha-256)
             (sha-256 \"0123...\")
             (rsa \"0123...\"))

  ;; Packages may contain any number of libraries.
  (library
   ;; Every library _must_ have a name.
   (name (wonderland cheshire cat))
   ;; Each library must point to a single library description file
   ;; within the tarball.  It is an error if this path is absolute.
   ;; The extension has no specific meaning and can be chosen at will,
   ;; so it is up to install tools to convert as needed for
   ;; host Scheme implementations.
   (path \"cheshire/cat.sch\")
   ;; A list of libraries which are required to install the given
   ;; library - installation tools should determine and install the
   ;; transitive closure of dependencies when any library is
   ;; installed.
   (depends
    (scheme base)
    (srfi 1)
    (rabbit holes))
   ;; List of phases this library is used for, where <phase> can be any
   ;; of final, build or test.  The default is just install.  If used by other
   ;; phases, this library will be installed in a temporary location for use
   ;; during the given phase.
   (use-for final))

  ;; A program has all the same fields as a library, except the name
  ;; is optional, and the path indicates a file containing a single
  ;; top-level program to install in a binary directory.  A package
  ;; can contain a mix of programs and libraries.
  (program
   ...)

  ;; A package can also contain data files, installed relative to
  ;; the library files.
  (data-files
    \"data1.dat\"
    \"data2.dat\"))")))
          (div
           (@ (id . "col3_2"))   ;; notes
           (p
            "The original "
            (a (@ (href . "http://trac.sacrideo.us/wg/wiki/Snow"))
               "Snow2 specification")
            " describes many features not yet implemented by clients. ")))))))))
