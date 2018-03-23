;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(check-location "01" "q5.rkt")
      
(provide years-to-test)

;; DATA DEFINITIONS
;; flops is represented as a positive integer
;; flopYear is represented as a positive integer

;; GLOBAL CONSTANTS
(define SECS_MIN 60)
(define MINS_HR 60)
(define HRS_DAY 24)
(define DAYS_YR 365)

;; years-to-test: flopSecond -> flopYear
;; GIVEN: The speed of a microprocessor in flops
;; RETURNS: The number of years the same microprocessor would take
;;          to test double precision addition on all legal inputs

;; flopM: flopSecond -> flopMin
;; GIVEN: The number of floating point operations a microprocessor can perform
;;        in 1 second
;; RETURNS: The nuumber of floating point operations the same microprocessor
;;          can perform in 1 minute

;; flopH: flopMin -> flopHrs
;; GIVEN: The number of floating point operations a microprocessor can perform
;;        in 1 minute
;; RETURNS: The nuumber of floating point operations the same microprocessor
;;          can perform in 1 hour

;; flopD: flopHrs -> flopDay
;; GIVEN: The number of floating point operations a microprocessor can perform
;;        in 1 hour
;; RETURNS: The nuumber of floating point operations the same microprocessor
;;          can perform in 1 day

;; flopY: flopDay -> flopYear
;; GIVEN: The number of floating point operations a microprocessor can perform
;;        in 1 day
;; RETURNS: The nuumber of floating point operations the same microprocessor
;;          can perform in 1 year

;;EXAMPLES:
;; (years to test 300000000000) =
;;                1298074214633706907132624082305024/36090087890625
;; (years-to-test 500000000000) =
;;                12980742146337069071326240823050244/60150146484375

;; (flopM 1) = 60
;; (flopM 450) = 27000

;; (flopH 1) = 31536000
;; (flopH 450) = 27000

;; (flopD 1) = 31536000
;; (flopD 450) = 10800

;; (flopY 1) = 31536000
;; (flopY 450) = 164250

;; DESIGN STRATEGY: Transcribe mathematical formula

(define (flopM flopSecond)
  (* flopSecond SECS_MIN))

(define (flopH flopMin)
  (* flopMin MINS_HR))

(define (flopD flopHrs)
  (* flopHrs HRS_DAY))

(define (flopY flopDays)
  (* flopDays DAYS_YR))

(define (years-to-test flops)
  (/ (expt 2 128) (flopY (flopD (flopH (flopM flops))))))

;; TESTS:

(begin-for-test
  (check-equal? (flopY (flopD (flopH (flopM 1)))) 31536000
                "A microprocessor performing 1 flops should perform
31536000flopy")
  (check-equal? (flopY (flopD (flopH (flopM 450)))) 14191200000
                "A microprocessor performing 450 flops should perform
14191200000 flopy"))

(begin-for-test
  (check-equal? (flopM 1) 60
                "A microprocessor performing 1 flops should perform
60 flopm")
  (check-equal? (flopM 450) 27000
                "A microprocessor performing 450 flops should perform
27000 flopm"))

(begin-for-test
  (check-equal? (flopH 1) 60
                "A microprocessor performing 1 flopm should perform
60 floph")
  (check-equal? (flopH 450) 27000
                "A microprocessor performing 450 flopm should perform
27000 floph"))

(begin-for-test
  (check-equal? (flopD 1) 24
                "A microprocessor performing 1 floph should perform
24 flopd")
  (check-equal? (flopD 450) 10800
                "A microprocessor performing 450 floph should perform
10800 flopd"))

(begin-for-test
  (check-equal? (flopY 1) 365
                "A microprocessor performing 1 flopd should perform
365 flopy")
  (check-equal? (flopY 450) 164250
                "A microprocessor performing 450 flopd should perform
164250 flopy"))