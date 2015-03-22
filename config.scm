
;; / - welcome, links to pkg list, docs, and fun stuff
;;   /pkg - packages, default to browser
;;     /pkg/repo - download the repository
;;     /pkg/get - download a package
;;     /pkg/put - upload a package
;;     /pkg/reg - register a key
;;   /doc - documentation
;;     /doc/snow - snow docs
;;   /fun - fun stuff
;;     /fun/repl - in-browser repl
;;     /fun/sorting-hat - the scheme sorting hat
;;   /s - static files, empty index
;;     /s/snow.css
;;     /s/favicon.ico
;;     /s/repo.scm
;;     /s/<domain>/<local>/registration-pending - file with verify key (rand)
;;     /s/<domain>/<local>/pub-key - also in /s/repo
;;     /s/<domain>/<local>/files/<petname>/<modname>/<version>/<modname-1.0.tgz>
;;     /s/<domain>/<local>/doc/<petname>/<modname>/<version>/<modname.html>
;;     /s/<domain>/<local>/view/<petname>/<modname>/<version>/<modname.sld>
;;     /s/<domain>/<local>/view/<petname>/<modname>/...

((path
  ((or (: "/s/" (* any))
       "/robots.txt")
   (file))
  ((: "/" (* (~ ".")) (? ".scm"))
   (scheme))))
