;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q3) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q3.rkt")
      
(provide kelvin-to-farenheit)

;; DATA DEFINITIONS
;; kelTemp is represented as a non-negative real number
;; calTemp is represented as a real number greater than or equal to -273.15
;; farTemp is represented as a real number greater than or equal to -459.67

;; kelvin-to-farenheit: kelTemp -> farTemp
;; GIVEN: A temparature in Kelvin
;; RETURNS: The equivalent length in Farenheit

;; kelvin-to-celsius: kelTemp -> celTemp
;; GIVEN: A temparature in Kelvin
;; RETURNS: The equivalent length in Celsius

;; celsius-to-farenheit: celTemp -> farTemp
;; GIVEN: A temparature in Celsius
;; RETURNS: The equivalent length in Farenheit

;;EXAMPLES:
;; (kelvin-to-farenheit 0) = -459.67
;; (kelvin-to-farenheit 373.15) = 212

;; (kelvin-to-celsius 0) = -273.15
;; (kelvin-to-celsius 373.15) = 100

;; (celsius-to-farenheit 0) = 32
;; (celsius-to-farenheit 100) = 212

;; DESIGN STRATEGY: Transcribe mathematical formula

(define (kelvin-to-celsius kelTemp)
 (- kelTemp 273.15))

(define (celsius-to-farenheit calTemp)
 (+ (* calTemp 1.8) 32))
  
(define (kelvin-to-farenheit kelTemp)
 (celsius-to-farenheit (kelvin-to-celsius kelTemp)))

;; TESTS:

(begin-for-test
  (check-equal? (kelvin-to-farenheit 0) -459.67
                "0 Kelvin should be -459.67 Farenheit")
  (check-equal? (kelvin-to-farenheit 373.15) 212
                "373.15 Kelvin should be 212 Farenheit"))

(begin-for-test
  (check-equal? (kelvin-to-celsius 0) -273.15
                "0 Kelvin should be -273.15 Celsius")
  (check-equal? (kelvin-to-celsius 373.15) 100
                "373.15 Kelvin should be 100 Celsius"))

(begin-for-test
  (check-equal? (celsius-to-farenheit 0) 32
                "0 Celsius should be 32 Farenheit")
  (check-equal? (celsius-to-farenheit 100) 212
                "100 Celsius should be 212 Farenheit"))