
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
            "A Snow repository is a list of zero or more packages and/or "
	    "sibling repositories.  The snow-fort repository lives at "
	    "https://snow-fort.org/s/repo.scm, but clients may maintain "
	    "their own lists of repositories or learn about new repos via "
	    "the sibling links."
	    )
           (pre
            (code
             "
(repository

 ;; A sibling is a pointer to another repository, which the client may
 ;; choose to search as well.  The URL points to a file containing
 ;; another `repository' sexp.  The optional trust level is a real
 ;; number in [0..1] indicating the current repository's trust in the
 ;; sibling - the user's trust level is the product of all trust
 ;; levels along the shortest path to a source.  The default is 0.5.
 ;;
 ;; Siblings may be used to build a distributed network of
 ;; repositories, to split the current repository into several URLs
 ;; for performance (e.g. moving seldom changing packages or publisher
 ;; lists to a repo with a longer refresh), or to provide translated
 ;; versions of the repo.  Clients are free to ignore siblings and/or
 ;; maintain their own lists of repositories.
 (sibling
  (name \"Some Other Repo\")
  (url \"http://some-other-repository.org/packages.scm\")
  (trust 0.5))

 ;; Packages
 (package
  ;; Structure as described in the "
	     (a (@ (href "../spec/")) package specification)
	     ".
  ...))")))
          (div
           (@ (id . "col3_2"))   ;; notes
           (p
            "You can make a pull request at "
	    (a (@ (href "https://github.com/ashinn/snow-fort/"))
	       "https://github.com/ashinn/snow-fort/")
	    " if you want to add your repo as a sibling.")))))))))
