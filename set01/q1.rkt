;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q1.rkt")
      
(provide pyramid-volume)

;; DATA DEFINITIONS
;; Height is represented as a non-negative real number
;; BaseLength is represented as a non-negative real number
;; Volume is represented as a non-negative real number

;;pyramid-volume: Height, BaseLength -> Volume
;;GIVEN: The height and base length of a square pyramid, in meters
;;RETURNS: The volume of the same square pyramid, in cubic meters

;;EXAMPLES:
;; (pyramid-volume 1 3) = 3
;; (pyramid-volume 3 1) = 1

;; DESIGN STRATEGY: Transcribe mathematical formula
;; Volume of a pyramid = (1/3) * (base length ^ 2) * (height)

(define (pyramid-volume height baseLength)
  (/ (* baseLength baseLength height) 3))

;; TESTS:

(begin-for-test
  (check-equal? (pyramid-volume 1 3) 3
                "A square pyramid with height 1m and base length 3m
should have a volume of 3 m^3")
  (check-equal? (pyramid-volume 3 1) 1
                "A square pyramid with height 3m and base length 1m
should have a volume of 1 m^3"))