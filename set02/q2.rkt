;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide
 initial-state
 next-state
 is-red?
 is-green?)

(check-location "02" "q2.rkt")

;; DATA DEFINITIONS:

;; Colour:
;; A Colour is represented as one of the following strings:
;; --"red"
;; --"green"
;; --"blank"
;; INTERPRETATION: Self-evident
;; EXAMPLES:
(define RED "red")
(define GREEN "green")
(define BLANK "blank")

;; Max Time:
;; The MaxTime is represented as a PositiveInteger
;; WHERE: MaxTime > 3
;; It is provided as an input to the function initial-state
;; INTERPRETATION: It is the total time that the ChineseTrafficSignal runs for
;;                 in the red state, or in the combined green + blank state

;; Countdown Timer:
;; A TimerState is represented as a PositiveInteger
;; WHERE: 3 < t <= max-time, as provided in function initial-state
;; INTERPRETATION: The number of seconds until the next colour change.
;; If t = 1, the colour should change at the next second.

;; Chinese Traffic Signal:
;; A ChineseTrafficSignal is represented as a struct
;;   (make-light colour time-left max-time)
;; with the fields
;; colour : Colour         represents the current colour of the traffic light
;; time-left : TimerState  represents the current state of the timer
;; max-time : MaxTime      represents the total time the signal stays red

;; IMPLEMENTATION:
(define-struct light (colour time-left max-time))

;; CONSTRUCTOR TEMPLATE
;; (make-light Colour TimerState)

;; OBSERVER TEMPLATE
;; (define (light-fn l)
;;   (...
;;   (light-colour l)
;;   (light-time-left l)
;;   (light-max-time l)))

;; initial-state : PosInt -> ChineseTrafficSignal
;; GIVEN: an integer n greater than 3
;; RETURNS: a representation of a Chinese traffic signal
;;     at the beginning of its red state, which will last
;;     for n seconds
;; DESIGN STRATEGY: Use Constructor Template for ChineseTrafficSignal
;; EXAMPLE:
;;     (is-red? (initial-state 4))  =>  true

(define (initial-state n)
  (make-light RED n n))

;; next-state-timer : ChineseTrafficSignal -> TimerState
;; GIVEN: A representation of a traffic signal in some state
;; RETURNS: The TimerState that traffic signal should have one second later
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLE:
;;      (next-state-timer (initial-state 4)) => 3
;;      (next-state-timer (make-light RED 1 10)) => 10

(define (next-state-timer signal)
  (if (or (red-to-green-check signal) (blank-to-red-check signal))
    (light-max-time signal)
    (- (light-time-left signal) 1)))

;; next-state-colour : ChineseTrafficSignal -> Colour
;; GIVEN: A representation of a traffic signal in some state
;; RETURNS: The Colour that traffic signal should have one second later
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLE:
;;       (next-state-colour (initial-state 4)) => "red"
;;       (next-state-colour (make-light RED 1 10)) => "green"
;;       (next-state-colour (make-light GREEN 4 10)) => "blank"
;;       (next-state-colour (make-light BLANK 3 10)) => "green"
;;       (next-state-colour (make-light BLANK 1 10)) => "red"

(define (next-state-colour signal)
  (cond
    [(red-to-green-check signal) GREEN]
    [(green-to-blank-check signal) BLANK]
    [(blank-to-red-check signal) RED]
    [(blank-to-green-check signal) GREEN]
    [else (light-colour signal)]))

;; red-to-green-check : ChineseTrafficSignal -> Boolean
;; GIVEN: A representation of a traffic signal in some state
;; RETURNS: True iff the signal changes from red to green on the next tick
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLE:
;;   (ready-to-change (initial-state 4)) => #false
;;   (ready-to-change (make-light RED 1 10)) => #true

(define (red-to-green-check signal)
  (and (is-red? signal) (= (light-time-left signal) 1)))

;; green-to-blank-check : ChineseTrafficSignal -> Boolean
;; GIVEN: A representation of a traffic signal in some state
;; RETURNS: True iff the signal changes from green to blank on the next tick
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLE:
;;   (ready-to-change (initial-state 4)) => #false
;;   (ready-to-change (make-light GREEN 4 10)) => #true

(define (green-to-blank-check signal)
  (and (is-green? signal)
       (or (= (light-time-left signal) 2) (= (light-time-left signal) 4))))

;; blank-to-red-check : ChineseTrafficSignal -> Boolean
;; GIVEN: A representation of a traffic signal in some state
;; RETURNS: True iff the signal changes from blank to red on the next tick
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLE:
;;   (ready-to-change (initial-state 4)) => #false
;;   (ready-to-change (make-light BLANK 1 10)) => #true

(define (blank-to-red-check signal)
  (and (is-blank? signal) (= (light-time-left signal) 1)))

;; blank-to-green-check : ChineseTrafficSignal -> Boolean
;; GIVEN: A representation of a traffic signal in some state
;; RETURNS: True iff the signal changes from blank to green on the next tick
;; EXAMPLE:
;;   (ready-to-change (initial-state 4)) => #false
;;   (ready-to-change (make-light BLANK 3 10)) => #true

(define (blank-to-green-check signal)
  (and (is-blank? signal) (= (light-time-left signal) 3)))

;; next-state : ChineseTrafficSignal -> ChineseTrafficSignal
;; GIVEN: a representation of a traffic signal in some state
;; RETURNS: the state that traffic signal should have one
;;     second later
;; DESIGN STRATEGY: Use constructor template
;; EXAMPLE:
;;     (next-state (make-light RED 10 10)) => (make-light "red" 9 10)
;;     (next-state (make-light RED 1 10)) => (make-light "green" 10 10)
;;     (next-state (make-light GREEN 4 10)) => (make-light "blank" 3 10)
;;     (next-state (make-light BLANK 3 10)) => (make-light "green" 2 10)
;;     (next-state (make-light GREEN 2 10)) => (make-light "blank" 1 10)
;;     (next-state (make-light BLANK 1 10)) => (make-light "red" 10 10) 

(define (next-state signal)
  (make-light (next-state-colour signal)
              (next-state-timer signal) 
              (light-max-time signal)))

;; is-red? : ChineseTrafficSignal -> Boolean
;; GIVEN: a representation of a traffic signal in some state
;; RETURNS: true if and only if the signal is red
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;;     (is-red? (next-state (initial-state 4)))  =>  #true
;;     (is-red?
;;      (next-state
;;       (next-state
;;        (next-state (initial-state 4)))))  =>  #true
;;     (is-red?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state (initial-state 4))))))  =>  #false
;;     (is-red?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state
;;          (next-state (initial-state 4)))))))  =>  #false

(define (is-red? signal)
  (string=? (light-colour signal) RED))

;; is-green? : ChineseTrafficSignal -> Boolean
;; GIVEN: a representation of a traffic signal in some state
;; RETURNS: true if and only if the signal is green
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;;     (is-green?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state (initial-state 4))))))  =>  #true
;;     (is-green?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state
;;          (next-state (initial-state 4)))))))  =>  #false

(define (is-green? signal)
  (string=? (light-colour signal) GREEN))

;; is-blank? : ChineseTrafficSignal -> Boolean
;; GIVEN: a representation of a traffic signal in some state
;; RETURNS: true if and only if the signal is blank
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;;    (is-blank?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state
;;          (next-state (initial-state 4)))))))  =>  #true
;;     (is-blank?
;;      (next-state
;;       (next-state
;;        (next-state
;;         (next-state (initial-state 4))))))  =>  #false


(define (is-blank? signal)
  (string=? (light-colour signal) BLANK))

;; TESTING:

(begin-for-test
  (check-equal? (initial-state 4) (make-light RED 4 4) "The function should
initialize the Traffic Light at the beginning of the RED phase, with duration
as provided by input.")

  (check-equal? (red-to-green-check (make-light RED 1 10)) #true "The function
should return #true, as the Traffic Light will change from red to green on the
next tick.")

  (check-equal? (red-to-green-check (make-light RED 10 10)) #false "The
function should return #false as the Traffic Light does not change from red to
green on the next tick.")

  (check-equal? (green-to-blank-check (make-light GREEN 4 10)) #true "The
function should return #true as the Traffic Light will change from green to
blank on the next tick.")

  (check-equal? (green-to-blank-check (make-light GREEN 10 10)) #false "The
function should return #false as the Traffic Light will not change from green to
 blank on the next tick.")

  (check-equal? (blank-to-green-check (make-light BLANK 3 10)) #true "The
function should return #true as the Traffic Light will change from blank to
green on the next tick.")

  (check-equal? (blank-to-green-check (make-light BLANK 1 10)) #false "The
function should return #false as the Traffic Light will not change from blank to
 green on the next tick.")

  (check-equal? (blank-to-red-check (make-light BLANK 1 10)) #true "The
function should return #true as the Traffic Light will change from blank to red
on the next tick.")

  (check-equal? (blank-to-red-check (make-light BLANK 3 10)) #false "The
function should return #false as the Traffic Light will not change from blank to
 red on the next tick")

  (check-equal? (is-red? (initial-state 4)) #true "The function
should return #true as when a Traffic Light is initialized, it is in the red
phase.")

  (check-equal? (is-red? (next-state
                         (next-state
                          (next-state
                           (next-state (initial-state 4)))))) #false "This
function should return #false as 4 states later, the next state will be green.")

  (check-equal? (is-green? (next-state
                            (next-state
                             (next-state
                              (next-state (initial-state 4)))))) #true "This
function should return #true as 4 states later, the next state will be green.")

  (check-equal? (is-green? (next-state
                            (next-state
                             (next-state
                              (next-state
                               (next-state (initial-state 4))))))) #false "This
function should return #false as 5 states later, the next state will be blank.")

  (check-equal? (is-blank? (next-state
                            (next-state
                             (next-state
                              (next-state (initial-state 4)))))) #false "This
function should return #false as 4 states later, the next state will be green.")

  (check-equal? (is-blank? (next-state
                            (next-state
                             (next-state
                              (next-state
                               (next-state (initial-state 4))))))) #true "This
function should return #true as 5 states later, the next state will be blank.")

  (check-equal? (next-state-timer (initial-state 4)) 3 "This function should
return 3 as there is no reset in timer.")

  (check-equal? (next-state-timer (make-light RED 1 10)) 10 "This function
should return the max timer of the state as it resets phases.")

  (check-equal? (next-state-colour (initial-state 4)) "red" "This function
should return red as the colour of the Traffic Light at the next tick is red.")

  (check-equal? (next-state-colour (make-light RED 1 10)) "green" "This function
should return green as the colour of the Traffic Light at the next tick is 
green.")

  (check-equal? (next-state-colour (make-light GREEN 4 10)) "blank" "This
function should return blank as the colour of the Traffic Light at the next tick
is blank.")

  (check-equal? (next-state-colour (make-light BLANK 3 10)) "green" "This
function should return green as the colour of the Traffic Light at the next tick
is green.")

  (check-equal? (next-state-colour (make-light BLANK 1 10)) "red" "This function
should return red as the colour of the Traffic Light at the next tick is red.")

  (check-equal? (next-state (make-light RED 10 10)) (make-light "red" 9 10)
"This function should return a Traffic Light that is red, with 9 seconds
remaining and 10 seconds maximum time.")

  (check-equal? (next-state (make-light RED 1 10)) (make-light "green" 10 10)
"This function should return a Traffic Light that is green, with 10 seconds
remaining and 10 seconds maximum time.")

  (check-equal? (next-state (make-light GREEN 4 10)) (make-light "blank" 3 10)
"This function should return a Traffic Light that is blank, with 3 seconds
remaining and 10 seconds maximum time.")

  (check-equal? (next-state (make-light BLANK 3 10)) (make-light "green" 2 10)
"This function should return a Traffic Light that is green, with 2 seconds
remaining and 10 seconds maximum time.")

  (check-equal? (next-state (make-light GREEN 2 10)) (make-light "blank" 1 10)
"This function should return a Traffic Light that is blank, with 1 seconds
remaining and 10 seconds maximum time.")

  (check-equal? (next-state (make-light BLANK 1 10)) (make-light "red" 10 10)
"This function should return a Traffic Light that is red, with 10 seconds
remaining and 10 seconds maximum time.")
)