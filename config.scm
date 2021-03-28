
;; / - welcome, links to pkg list and docs
;;   /pkg - packages, default to browser
;;     /pkg/repo - download the repository
;;     /pkg/put - upload a package
;;     /pkg/reg - register a key
;;   /doc - documentation
;;     /doc/install - how to install packages
;;     /doc/author - how to create and publish packages
;;     /doc/spec - snow specification
;;     /doc/usage - CLI usage
;;   /faq - frequently asked questions
;;   /link - scheme resources
;;   /s - static files, empty index
;;     /s/snow.css
;;     /s/favicon.ico
;;     /s/repo.scm
;;     /s/<domain>/<local>/registration-pending - file with verify key (rand)
;;     /s/<domain>/<local>/pub-key - also in /s/repo
;;     /s/<domain>/<local>/<modname>/<version>/<modname-<version>.tgz>
;;     /s/<domain>/<local>/<modname>/<version>/index.html

((path
  ((or (: "/s/" (* any))
       "/robots.txt")
   (file))
  ((: "/" (* (~ ".")) (? ".scm"))
   (scheme))))
