#!r6rs
(import (rnrs) (linenoise))

(define (display-line line)
  ; SRFI 48 is better, but I can't assume they have it installed
  (display "echo: '")
  (display line)
  (display "'\n"))

(define (main)
  (history-load! "history.txt")
  (let loop ()
    (let ((line (linenoise "hello> ")))
     (unless (eof-object? line)
       (display-line line)
       (history-add! line)
       (history-save! "history.txt")
       (loop)))))

(main)
