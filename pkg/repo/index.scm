
(import (scheme base) (scheme write)
        (chibi sxml) (chibi log) (chibi net servlet)
        (chibi snow fort))

(servlet-run
 (lambda (cfg request next restart)
   (restart (request-with-uri request "/s/repo.scm"))))
