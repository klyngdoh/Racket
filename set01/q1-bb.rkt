;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1-bb) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))

(require rackunit)
(require rackunit/text-ui)
(require "q1.rkt")

(define tests
  (test-suite
   "q1"

   (test-case
    "Test #1"
    (check-pred procedure? pyramid-volume
                "expected a procedure"))
   ))

(run-tests tests 'verbose)
