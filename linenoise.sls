#!r6rs
;;; linenoise.sls -- A line editing library

;; Copyright (C) 2010 Ian Price <ianprice90@googlemail.com>

;; This program is free software, you can redistribute it and/or
;; modify it under the terms of the new-style BSD license.

;; You should have received a copy of the BSD license along with this
;; program. If not, see <http://www.debian.org/misc/bsd.license>.

(library (linenoise)
(export (rename (linenoise* linenoise))
        history-add!
        history-max-length
        history-max-length-set!
        history-save!
        history-load!
        )
(import (rnrs base)
        (ucl ffi)
        (rnrs control)
        (only (rnrs io ports) eof-object)
        )

(define lib-pointer
  (or (load-library "liblinenoise.so")
      (error 'lib-pointer "Can't find library liblinenoise.so")))


(define-syntax define-c-function
  (syntax-rules ()
    ((define-c-function return-type function-name (arg-type ...))
     (define function-name
       (get-function lib-pointer
                     (symbol->string 'function-name)
                     '(arg-type ...)
                     'return-type)))))


(define (string-read/freeing ptr)
  (let ((str (string-read ptr)))
    (free ptr)
    str))


; linenoise* : string -> string
; prompts the user for input with the input string, and then returns
; the string. If it is interrupted, #!eof is returned.
; Exported as `linenoise'
(define-c-function pointer linenoise (string))
(define (linenoise* string)
  (assert (string? string))
  (let ((ptr (linenoise string)))
    (if (null-ptr? ptr)
        (eof-object)
        (string-read/freeing ptr))))


; history-add! string -> void
; Adds the string to the history buffer used by linenoise
(define-c-function uint linenoiseHistoryAdd (string))
(define (history-add! string)
  (assert (string? string))
  (let* ((ret (linenoiseHistoryAdd string)))
    (unless (= 1 ret)
      (error 'history-add! "Could not add line to history" string))))


;; Magic number from linenoise.c
(define *linenoise-max-length* 100)


; history-max-length () -> number
; Gets the maximum number of history items
(define (history-max-length)
  *linenoise-max-length*)


; history-set-max-length! int -> void
; Sets the maximum number of history items kept
(define-c-function uint linenoiseHistorySetMaxLen (uint))
(define (history-max-length-set! len)
  (assert (number? len))
  (if (= 1 (linenoiseHistorySetMaxLen len))
      (set! *linenoise-max-length* len)
      (error 'linenoise-history-set-max-len!
             "Couldn't adjust maximum history length"
             len)))


; history-save! string -> void
; Writes the entire history, in order, to a file
; Creates the file if it doesn't exist, or truncates it first if it doesn't
(define-c-function sint linenoiseHistorySave (string))
(define (history-save! filename)
  (assert (string? filename))
  (let* ((ret (linenoiseHistorySave filename)))
    (unless (zero? ret)
      (error 'history-save! "Couldn't save history to file" filename))))


; history-load! string -> void
; Loads the history buffer from a given file
; If the file doesn't exist, then nothing is added to history, but it
; is not an error (Linenoise design decision)
(define-c-function sint linenoiseHistoryLoad (string))
(define (history-load! filename)
  (assert (string? filename))
  (let* ((ret (linenoiseHistorySave filename)))
    (unless (zero? ret)
      (error 'history-load! "Couldn't load history from file" filename))))

)
