;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide
 simulation
 initial-world
 world-ready-to-serve?
 world-after-tick
 world-after-key-event
 world-ball
 world-racket
 ball-x
 ball-y
 racket-x
 racket-y
 ball-vx
 ball-vy
 racket-vx
 racket-vy
 )

(check-location "03" "q1.rkt")

;; CONSTANTS

;; Dimensions of the Squash Court:

(define COURT-WIDTH 425)
(define COURT-HEIGHT 649)

;; Dimensions of the ball:

(define BALL-RADIUS 3)
(define BALL-COLOUR "black")
(define BALL-TRANSPARENCY "solid")
(define BALL-IMAGE (circle BALL-RADIUS BALL-TRANSPARENCY BALL-COLOUR))
(define INITIAL-VX 3)
(define INITIAL-VY -9)

;; Dimensions of the racket:

(define RACKET-HEIGHT 7)
(define RACKET-LENGTH 47)
(define RACKET-COLOUR "green")
(define RACKET-TRANSPARENCY "solid")
(define RACKET-IMAGE (rectangle RACKET-LENGTH RACKET-HEIGHT RACKET-TRANSPARENCY
                                RACKET-COLOUR))

;; Key Events:

(define SPACE-EVENT " ")
(define LEFT-EVENT "left")
(define RIGHT-EVENT "right")
(define UP-EVENT "up")
(define DOWN-EVENT "down")

;; DATA DEFINITIONS:

;; A Ball is represented as a struct with the following fields:
;; x :  Integer  is the x-coordinate of the position of the ball
;; y :  Integer  is the y-coordinate of the position of the ball
;; vx:  Real     is the x-component of the velocity of the ball, in pixels per
;;                tick
;; vy:  Real     is the y-component of the velocity of the ball, in pixels per
;;                tick

;; Implementation:
(define-struct ball (x y vx vy))

;; Constructor Template:
;; (make-ball Integer Integer Real Real)

;; OBSERVER TEMPLATE
;; ball-fn : Ball -> ?
;; (define (ball-fn b)
;;  (...
;;   (ball-x b)
;;   (ball-y b)
;;   (ball-vx b)
;;   (ball-vy b)))

;; ball-x: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The x-coordinate of that ball's position
;; DESIGN STRATEGY: Use Observer Template for Ball
;; EXAMPLE: (ball-x (world-ball (initial-world 1))) => 330

;; ball-y: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The y-coordinate of that ball's position
;; DESIGN STRATEGY: Use Observer Template for Ball
;; EXAMPLE: (ball-y (world-ball (initial-world 1))) => 384

;; ball-vx: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The x-component of that ball's velocity
;; DESIGN STRATEGY: Use Observer Template for Ball
;; EXAMPLE: (ball-vx (world-ball (initial-world 1))) => 0

;; ball-vy: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The y-component of that ball's velocity
;; DESIGN STRATEGY: Use Observer Template for Ball
;; EXAMPLE: (ball-vy (world-ball (initial-world 1))) => 0

;; A Racket is represented as a struct with the following fields:
;; x :  Integer  is the x-coordinate of the position of the racket
;; y :  Integer  is the y-coordinate of the position of the racket
;; vx:  Real     is the x-component of the velocity of the ball, in pixels per
;;                tick
;; vy:  Real     is the y-component of the velocity of the ball, in pixels per
;;                tick

;; Implementation:
(define-struct racket (x y vx vy))

;; CONSTRUCTOR TEMPLATE
;; (make-racket Integer Integer Real Real)

;; OBSERVER TEMPLATE
;; racket-fn : Racket -> ?
;; (define (racket-fn r)
;;  (...
;;   (racket-x r)
;;   (racket-y r)
;;   (racket-vx r)
;;   (racket-vy r)))

;; racket-x: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The x-coordinate of that racket's position
;; DESIGN STRATEGY: Use Observer Template for Racket
;; EXAMPLE: (racket-x (world-racket (initial-world 1))) => 330

;; racket-y: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The y-coordinate of that racket's position
;; DESIGN STRATEGY: Use Observer Template for Racket
;; EXAMPLE: (racket-y (world-racket (initial-world 1))) => 384

;; racket-vx: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The x-component of that racket's velocity
;; DESIGN STRATEGY: Use Observer Template for Racket
;; EXAMPLE: (racket-vx (world-racket (initial-world 1))) => 0

;; racket-vy: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The y-component of that racket's velocity
;; DESIGN STRATEGY: Use Observer Template for Racket
;; EXAMPLE: (racket-vy (world-racket (initial-world 1))) => 0

;; A World is represented as a struct
;;(make-world ball racket state pause-timer speed)
;; with the following fields:
;; ball        : Ball       is the ball in the court
;; racket      : Racket     is the racket in the court
;; state       : State      is the current state of the world
;; pause-timer : NonNegInt  is the amount of time left for the world to be in
;;                          the Paused state
;; speed       : PosReal    is the speed of the world in ticks per second

;; A State can be represented as one of the following strings:
;; --"rally"
;; --"ready to serve"
;; --"paused"
;; Interpretation: Self-evident
;; Examples:

(define READY-TO-SERVE "ready-to-serve")
(define RALLY "rally")
(define PAUSED "paused")

;; Implementation: 
(define-struct world (ball racket state pause-timer speed))

;; CONSTRUCTOR TEMPLATE
;; (make-world Ball Racket State NonNegInt PosReal)

;; OBSERVER TEMPLATE
;; world-fn : World -> ?
;; (define (world-fn w)
;;  (...
;;   (world-ball w)
;;   (world-racket w)
;;   (world-state w)
;;   (world-pause-timer w))

;; world-ball: World -> Ball
;; GIVEN: A world
;; RETURNS: The ball that's present in the world
;; DESIGN STRATEGY: Use Observer Template for World
;; EXAMPLE: (world-ball (initial-world 1)) => (make-ball 330 384 0 0)

;; world-racket: World -> Racket
;; GIVEN: A world
;; RETURNS: The racket that's present in the world
;; DESIGN STRATEGY: Use Observer Template for World
;; EXAMPLE: (world-racket (initial-world 1)) => (make-racket 330 384 0 0)

;; FUNCTION DEFINITIONS:

;; simulation: PosReal -> World
;; GIVEN: The speed of the simulation, in seconds per tick
;; EFFECT: Runs the simulation, starting with the initial world.
;; RETURNS: The final state of the world.
;; DESIGN STRATEGY: Combine simpler functions
;; EXAMPLES:
;;     (simulation 1) runs in super slow motion
;;     (simulation 1/24) runs at a more realistic speed

(define (simulation speed)
  (big-bang (initial-world speed)
            (on-tick world-after-tick speed)
            (on-key world-after-key-event)
            (on-draw world-to-scene)))

;; initial-world: PosReal -> World
;; GIVEN: The speed of the simulation, in seconds per tick
;; RETURNS: The ready-to-serve state of the world
;; DESIGN STRATEGY: Use constructor template for World
;; EXAMPLE:
;;   (initial-world 1)

(define (initial-world speed)
  (make-world (make-ball 330 384 0 0) (make-racket 330 384 0 0)
              READY-TO-SERVE 0 speed))

;; world-after-tick: World -> World
;; GIVEN: Any world that's possible for the simulation
;; RETURNS: The world that follows the given world after one tick
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLES: (world-after-tick (initial-world 1)) => (initial-world 1)
;;           (world-after-tick (make-world (make-ball 330 384 0 0)
;;                                        (make-racket 330 384 0 0) PAUSED 9 1))
;;        => (world-after-tick-paused (make-world (make-ball 330 384 0 0)
;;                                                (make-racket 330 384 0 0)
;;                                                PAUSED 8 1))

(define (world-after-tick w)
  (cond
    [(string=? (world-state w) RALLY) (world-after-tick-rally w)]
    [(string=? (world-state w) PAUSED) (world-after-tick-paused w)]
    [else w]))

;; world-after-tick-rally: World -> World
;; GIVEN: A world in rally state
;; RETURNS: The world that follows the given world one tick later
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLE: (world-after-tick-rally (make-world (make-ball 330 384 3 -9)
;;                                              (make-racket 330 384 0 0)
;;                                              RALLY 0 1))
;;       => (world-after-no-collision (make-world (make-ball 330 384 3 -9)
;;                                                (make-racket 330 384 0 0)
;;                                                RALLY 0 1))

(define (world-after-tick-rally w)
  (cond
    [(ball-hits-racket? w) (ball-collide-racket w)]
    [(ball-hits-wall? w) (ball-collide-wall w)]
    [(racket-hits-wall? w) (racket-collide-wall w)]
    [else (world-after-no-collision w)]))

;; ball-hits-racket?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball touches the racket of the box on the next tick
;; DESIGN STRATEGY: Transcribe geometrical formula
;; EXAMPLES: (ball-hits-racket? (make-world (make-ball 260 240 -5 10)
;;                                          (make-racket 250 250 5 -5)
;;                                          RALLY 0 1)) => #true

(define (ball-hits-racket? w)
  (and
   (or
    (and (< (get-ball-x w) (racket-intersect w))
         (<= (racket-intersect w) (+ (get-ball-x w) (get-ball-vx w))))
    (and (> (get-ball-x w) (racket-intersect w))
         (>= (racket-intersect w) (+ (get-ball-x w) (get-ball-vx w)))))
   (<= (+ (- (get-racket-x w) 23) (get-racket-vx w))
       (racket-intersect w)
       (+ (get-racket-x w) 23 (get-racket-vx w)))
   )
  )

;; racket-intersect: World -> Integer
;; GIVEN: A world
;; RETURNS: The x-coordinate of the point where the ball would meet with the
;;          racket's straight horizontal line
;; DESIGN STRATEGY: Transcribe mathematical formula
;; rx = ((bvx/bvy)*(ry+rvy-by)) + bx
;; EXAMPLES: (racket-intersect (initial-world 1)) => 330

(define (racket-intersect w)
  (+ (* (/ (get-ball-vx w)
           (get-ball-vy w))
        (- (+ (get-racket-y w) (get-racket-vy w))
           (get-ball-y w)))
     (get-ball-x w)))

;; ball-collide-racket: World -> World
;; GIVEN: A world in rally state
;; WHERE: The ball has collided with the racket
;; RETURNS: The world following the given world at the next tick
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLE: (ball-collide-racket (make-world (make-ball 250 250 0 200)
;;                                           (make-racket 250 300 0 0)
;;                                           RALLY 0 1))
;;       => (make-world (make-ball 250 150 0 -200)
;;                      (make-racket 250 300 0 0) RALLY 0 1)

(define (ball-collide-racket w)
  (make-world
   (make-ball (+ (get-ball-x w) (get-ball-vx w))
              (- (* 2 (+ (get-racket-y w) (get-racket-vy w)))
                 (get-ball-y w) (get-ball-vy w))
              (get-ball-vx w) (- (get-racket-vy w ) (get-ball-vy w)))
   (make-racket (+ (get-racket-x w) (get-racket-vx w))
                (+ (get-racket-y w) (get-racket-vy w)) (get-racket-vx w)
                (if(< (get-racket-vy w) 0) 0 (get-racket-vy w)))
   RALLY 0 (world-speed w)))

;; ball-collide-wall: World-> World
;; GIVEN: A world where the ball will collide with a wall on the next tick
;; RETURNS: The world following the given world on the next tick
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLE: (ball-collide-wall (make-world (make-ball 5 250 -15 10)
;;                                         (make-racket 300 300 0 0)
;;                                         RALLY 0 1)
;;       => (make-world (make-ball 10 260 15 10) (make-racket 300 300 0 0)
;;                      RALLY 0 1)

(define (ball-collide-wall w)
  (cond
    [(or (ball-hits-back? w) (ball-vy-too-high? w)) (rally-to-paused w)]
    [(ball-vx-too-high? w) (ball-collide-left-right w)]
    [(and (ball-hits-left? w) (ball-hits-front? w))
     (ball-collide-top-left w)]
    [(and (ball-hits-right? w) (ball-hits-front? w))
     (ball-collide-top-right w)]
    [(ball-hits-left? w) (ball-collide-left w)]
    [(ball-hits-right? w) (ball-collide-right w)]
    [(ball-hits-front? w) (ball-collide-front w)]))
      
;; ball-hits-wall?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball has collided with any of the four walls
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLE: (ball-hits-wall? (make-world (make-ball 5 250 -15 10)
;;                                       (make-racket 300 300 0 0)
;;                                       RALLY 0 1) => #true

(define (ball-hits-wall? w)
  (or (ball-hits-back? w) (ball-hits-front? w) (ball-hits-left? w)
      (ball-hits-right? w)))

;; ball-hits-back?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball is touching the bottom of the box
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-back? w)
  (> (+ (get-ball-y w) (get-ball-vy w)) COURT-HEIGHT))

;; ball-hits-left?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball is touching the left of the box
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-left? w)
  (< (+ (get-ball-x w) (get-ball-vx w)) 0))

;; ball-collide-left: World -> World
;; GIVEN: A ball that has collided with the left wall
;; RETURNS: The world that follows the given world on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (ball-collide-left w)
  (make-world
   (make-ball (* -1 (+ (get-ball-x w) (get-ball-vx w)))
              (+ (get-ball-y w) (get-ball-vy w))
              (* -1 (get-ball-vx w)) (get-ball-vy w))
   (make-racket (+ (get-racket-x w) (get-racket-vx w)) (+ (get-racket-y w)
                                                          (get-racket-vy w))
                (get-racket-vx w) (get-racket-vy w)) RALLY 0 (world-speed w)))

;; ball-hits-right?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball is touching the right of the box
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-right? w)
  (> (+ (get-ball-x w) (get-ball-vx w)) COURT-WIDTH))

;; ball-collide-right: World -> World
;; GIVEN: A ball that has collided with the right wall
;; RETURNS: The world that follows the given world on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (ball-collide-right w)
  (make-world
   (make-ball (- (* 2 COURT-WIDTH) (get-ball-x w) (get-ball-vx w))
              (+ (get-ball-y w) (get-ball-vy w))
              (* -1 (get-ball-vx w)) (get-ball-vy w))
   (make-racket (+ (get-racket-x w) (get-racket-vx w)) (+ (get-racket-y w)
                                                          (get-racket-vy w))
                (get-racket-vx w) (get-racket-vy w))
   RALLY 0 (world-speed w)))

;; ball-hits-front?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball is touching the top of the box
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-front? w)
  (< (+ (get-ball-y w) (get-ball-vy w)) 0))

;; ball-collide-front: World -> World
;; GIVEN: A ball that will collide with the front wall on the next tick
;; RETURNS: The world that bounces the ball on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (ball-collide-front w)
  (make-world
   (make-ball (+ (get-ball-x w) (get-ball-vx w))
              (* -1 (+ (get-ball-y w) (get-ball-vy w)))
              (get-ball-vx w) (* -1 (get-ball-vy w)))
   (make-racket (+ (get-racket-x w) (get-racket-vx w)) (+ (get-racket-y w)
                                                          (get-racket-vy w))
                (get-racket-vx w) (get-racket-vy w))
   RALLY 0 (world-speed w)))

;; ball-collide-top-left: World -> World
;; GIVEN: A ball that will collide with the top and left walls on the next tick
;; RETURNS: The world that bounces the ball on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (ball-collide-top-left w)
  (make-world
   (make-ball (* -1 (+ (get-ball-x w) (get-ball-vx w)))
              (* -1 (+ (get-ball-y w) (get-ball-vy w)))
              (* -1 (get-ball-vx w)) (* -1 (get-ball-vy w)))
   (make-racket (+ (get-racket-x w) (get-racket-vx w)) (+ (get-racket-y w)
                                                          (get-racket-vy w))
                (get-racket-vx w) (get-racket-vy w))
   RALLY 0 (world-speed w)))

;; ball-collide-top-right: World -> World
;; GIVEN: A ball that will collide with the top and right walls on the next tick
;; RETURNS: The world that bounces the ball on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (ball-collide-top-right w)
  (make-world
   (make-ball (- (* 2 COURT-WIDTH) (get-ball-x w) (get-ball-vx w))
              (* -1 (+ (get-ball-y w) (get-ball-vy w)))
              (* -1 (get-ball-vx w)) (* -1 (get-ball-vy w)))
   (make-racket (+ (get-racket-x w) (get-racket-vx w)) (+ (get-racket-y w)
                                                          (get-racket-vy w))
                (get-racket-vx w) (get-racket-vy w))
   RALLY 0 (world-speed w)))

;; ball-vy-too-high?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the vy is greater than the height of the court
;; DESIGN STRATEGY: Transcribe mathematical formula

(define (ball-vy-too-high? w)
  (< (* 2 COURT-HEIGHT) (+ (get-ball-vy w) (get-ball-y w))))

;; ball-vx-too-high?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the vx is greater than the width of the court
;; DESIGN STRATEGY: Transcribe mathematical formula

(define (ball-vx-too-high? w)
  (< (* 2 COURT-WIDTH) (+ (if (> 0 (get-ball-vx w))
                              (* -1 (get-ball-vx w))
                              (get-ball-vx w))
                          (get-ball-x w))))

;; ball-collide-left-right: World -> World
;; GIVEN: A world where the ball bounces off both the left and right walls
;; RETURNS: The world on following the given one on the next tick
;; DESIGN STRATEGY: Divide into cases

(define (ball-collide-left-right w)
  (make-world (make-ball (if (even? (get-bounce-count w))
                             (get-excess w)
                             (- COURT-WIDTH (get-excess w)))
                         (if (ball-hits-front? w)
                             (* -1 (+ (get-ball-y w) (get-ball-vy w)))
                             (+ (get-ball-y w) (get-ball-vy w)))
                         (if (even? (get-bounce-count w))
                             (get-ball-vx w)
                             (* -1 (get-ball-vx w)))
                         (if (ball-hits-front? w)
                             (* -1 (get-ball-vy w))
                             (get-ball-vy w)))
              (world-racket w) RALLY 0 (world-speed w)))

;; get-bounce-count: World -> Integer
;; GIVEN: A world that bounces the ball off both side walls
;; RETURNS: The number of bounces in a tick
;; DESIGN STRATEGY: Transcribe formula

(define (get-bounce-count w)
  (floor (/ (get-ball-vx w) COURT-WIDTH))) 

;; get-excess: World -> Integer
;; GIVEN: A world that bounces the ball off both side walls
;; RETURNS: The remainder to travel after complete bounce cycles
;; DESIGN STRATEGY: Use mathematical formula

(define (get-excess w)
  (+ (get-ball-x w) (modulo (get-ball-vx w) COURT-WIDTH)))

;; racket-hits-wall?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket has collided with any of the four walls
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-wall? w)
  (or (racket-hits-left? w) (racket-hits-right? w) (racket-hits-front? w)
      (racket-hits-back? w)))

;; racket-collide-wall: World-> World
;; GIVEN: A world where the racket will collide with a wall on the next tick
;; RETURNS: The world following the given world on the next tick
;; DESIGN STRATEGY: Divide into cases

(define (racket-collide-wall w)
  (cond
    [(racket-hits-left? w) (racket-collide-left w)]
    [(racket-hits-right? w) (racket-collide-right w)]
    [(racket-hits-back? w) (racket-collide-back w)]
    [(racket-hits-front? w) (rally-to-paused w)]))

;; racket-hits-left?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket is touching the left of the box
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-left? w)
  (< (+ (get-racket-x w) (get-racket-vx w)) (floor (/ RACKET-LENGTH 2))))

;; racket-hits-right?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket is touching the right of the box
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-right? w)
  (> (+ (get-racket-x w) (get-racket-vx w))
     (- COURT-WIDTH (floor (/ RACKET-LENGTH 2)))))

;; racket-hits-front?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket is touching the top of the box
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-front? w)
  (< (+ (get-racket-y w) (get-racket-vy w)) 0))

;; racket-hits-back?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket is touching the bottom of the box
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-back? w)
  (> (+ (get-racket-y w) (get-racket-vy w)) COURT-HEIGHT))

;; racket-collide-left: World -> World
;; GIVEN: A world where the racket will collide with the left wall on the next
;;        tick
;; RETURNS: The world that follows the given world on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (racket-collide-left w)
  (make-world
   (make-ball (+ (get-ball-x w) (get-ball-vx w))
              (+ (get-ball-y w) (get-ball-vy w))
              (get-ball-vx w) (get-ball-vy w))
   (make-racket (floor (/ RACKET-LENGTH 2)) (get-racket-y w) 0
                (get-racket-vy w))
   RALLY 0 (world-speed w)))

;; racket-collide-left: World -> World
;; GIVEN: A world where the racket will collide with the right wall on the next
;;        tick
;; RETURNS: The world that follows the given world on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (racket-collide-right w)
  (make-world
   (make-ball (+ (get-ball-x w) (get-ball-vx w))
              (+ (get-ball-y w) (get-ball-vy w))
              (get-ball-vx w) (get-ball-vy w))
   (make-racket (- COURT-WIDTH (floor (/ RACKET-LENGTH 2)))
                (get-racket-y w) 0 (get-racket-vy w))
   RALLY 0 (world-speed w)))

;; racket-collide-left: World -> World
;; GIVEN: A world where the racket will collide with the back wall on the next
;;        tick
;; RETURNS: The world that follows the given world on the next tick.
;; DESIGN STRATEGY: Use simpler functions

(define (racket-collide-back w)
  (make-world
   (make-ball (+ (get-ball-x w) (get-ball-vx w))
              (+ (get-ball-y w) (get-ball-vy w))
              (get-ball-vx w) (get-ball-vy w))
   (make-racket (get-racket-x w) COURT-HEIGHT
                (get-racket-vx w) 0)
   RALLY 0 (world-speed w)))

;; world-after-no-collision: World -> World
;; GIVEN: A world in rally state
;; WHERE: The ball does not collide with any surface
;; RETURNS: The world that follows the given world one tick later
;; DESIGN STRATEGY: Use simpler functions

(define (world-after-no-collision w)
  (make-world (make-ball (+ (get-ball-x w) (get-ball-vx w))
                         (+ (get-ball-y w) (get-ball-vy w))
                         (get-ball-vx w) (get-ball-vy w))
              (make-racket (+ (get-racket-x w) (get-racket-vx w))
                           (+ (get-racket-y w) (get-racket-vy w))
                           (get-racket-vx w) (get-racket-vy w))
              RALLY 0 (world-speed w)))

;; world-after-tick-paused: World -> World
;; GIVEN: A world in paused state
;; RETURNS: A world that follows the given world after one tick
;; DESIGN STRATEGY: Use constructor template

(define (world-after-tick-paused w)
  (if(= (world-pause-timer w) 1)
     (initial-world (world-speed w))
     (make-world (world-ball w) (world-racket w) PAUSED
                 (- (world-pause-timer w) 1) (world-speed w))))

;; world-after-key-event: World KeyEvent -> World
;; GIVEN: A World and a KeyEvent
;; RETURNS: The world that should follow the given world after the given
;;          key event
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLES: (world-after-key-event (initial-world 1) " ") => (initial-world 1)

(define (world-after-key-event w kev)
  (cond
    [(is-key-event-space? kev) (world-after-space w)]
    [(is-key-event-left? kev) (world-after-left w)]
    [(is-key-event-right? kev) (world-after-right w)]
    [(is-key-event-up? kev) (world-after-up w)]
    [(is-key-event-down? kev) (world-after-down w)]
    [else w]))

;; is-key-event-space?: KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent is a spacebar press
;; DESIGN STRATEGY: Use simpler functions

(define (is-key-event-space? ke)
  (key=? ke SPACE-EVENT))

;; world-after-space: World -> World
;; GIVEN: A World
;; RETURNS: The world that should follow the given world after a spacebar press
;; DESIGN STRATEGY: Divide into cases

(define (world-after-space w)
  (cond
    [(world-ready-to-serve? w) (ready-to-rally w)]
    [(string=? (world-state w) RALLY) (rally-to-paused w)]
    [else w]))

;; is-key-event-left?: KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent is a left arrow key press
;; DESIGN STRATEGY: Use simpler functions

(define (is-key-event-left? ke)
  (key=? ke LEFT-EVENT))

;; world-after-left: World -> World
;; GIVEN: a world and a left arrow key event
;; RETURNS: The world that should follow the given world after the left arrow
;;          key press
;; DESIGN STRATEGY: Use simpler functions

(define (world-after-left w)
  (if (string=? (world-state w) RALLY)
      (make-world (world-ball w) (make-racket (get-racket-x w) (get-racket-y w)
                                              (sub1 (get-racket-vx w))
                                              (get-racket-vy w))
                  RALLY 0 (world-speed w))
      w))

;; is-key-event-right?: KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent is a right arrow key press
;; DESIGN STRATEGY: Use simpler functions

(define (is-key-event-right? ke)
  (key=? ke RIGHT-EVENT))

;; world-after-right: World -> World
;; GIVEN: a world and a right arrow key event
;; RETURNS: The world that should follow the given world after the right arrow
;;          key press
;; DESIGN STRATEGY: Use simpler functions

(define (world-after-right w)
  (if (string=? (world-state w) RALLY)
      (make-world (world-ball w) (make-racket (get-racket-x w) (get-racket-y w)
                                              (add1 (get-racket-vx w))
                                              (get-racket-vy w))
                  RALLY 0 (world-speed w))
      w))

;; is-key-event-up?: KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent is an up arrow key press
;; DESIGN STRATEGY: Use simpler functions

(define (is-key-event-up? ke)
  (key=? ke UP-EVENT))

;; world-after-up: World -> World
;; GIVEN: a world and an up arrow key event
;; RETURNS: The world that should follow the given world after the up arrow
;;          key press
;; DESIGN STRATEGY: Use simpler functions

(define (world-after-up w)
  (if (string=? (world-state w) RALLY)
      (make-world (world-ball w) (make-racket (get-racket-x w) (get-racket-y w)
                                              (get-racket-vx w)
                                              (sub1 (get-racket-vy w)))
                  RALLY 0 (world-speed w))
      w))

;; is-key-event-down?: KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent is a down arrow key press
;; DESIGN STRATEGY: Use simpler functions

(define (is-key-event-down? ke)
  (key=? ke DOWN-EVENT))

;; world-after-down: World -> World
;; GIVEN: a world and a down arrow key event
;; RETURNS: The world that should follow the given world after the down arrow
;;          key press
;; DESIGN STRATEGY: Use simpler functions

(define (world-after-down w)
  (if (string=? (world-state w) RALLY)
      (make-world (world-ball w) (make-racket (get-racket-x w) (get-racket-y w)
                                              (get-racket-vx w)
                                              (add1 (get-racket-vy w)))
                  RALLY 0 (world-speed w))
      w))

;; ready-to-rally: World -> World
;; GIVEN: A World
;; RETURNS: The world that should follow the given world when its sstate
;;          switches from ready-to-serve to rally
;; DESIGN STRATEGY: Use simpler functions

(define (ready-to-rally w)
  (make-world (make-ball (get-ball-x w) (get-ball-y w) INITIAL-VX INITIAL-VY)
              (world-racket w) RALLY 0 (world-speed w)))

;; rally-to-paused: World -> World
;; GIVEN: A world
;; RETURNS: The world that should follow the given world when its state switches
;;          from rally to paused
;; DESIGN STRATEGY: Use simpler functions

(define (rally-to-paused w)
  (make-world (make-ball (get-ball-x w) (get-ball-y w) 0 0)
              (make-racket (get-racket-x w) (get-racket-y w) 0 0) PAUSED
              (/ 3 (world-speed w)) (world-speed w)))

;; draw-court: World -> Image
;; GIVEN: A world
;; RETURNS: The court of that world
;; DESIGN STRATEGY: Use simpler functions

(define (draw-court w)
  (empty-scene COURT-WIDTH COURT-HEIGHT (if (string=? (world-state w) PAUSED)
                                            "yellow" "white")))

;; world-to-scene: World -> Scene
;; GIVEN: Any world that is possible for the simulation
;; RETURNS: A Scene that prtrays the given world
;; DESIGN STRATEGY: Use simpler functions

(define (world-to-scene w)
  (place-images (list BALL-IMAGE RACKET-IMAGE)
                (list (make-posn (get-ball-x w) (get-ball-y w))
                      (make-posn (get-racket-x w) (get-racket-y w)))
                (draw-court w)))

;; world-ready-to-serve?: World -> Boolean
;; GIVEN: A world
;; RETURNS: True iff the world is in its ready-to-serve state
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLE:
;;    (world-ready-to-serve? (initial-world 1/24)) => true
;;    (world-ready-to-serve? (make-world (make-ball 100 100 0 0 )
;;                                  (make-racket 200 200 0 0) RALLY 0 1))
;;                                   => false

(define (world-ready-to-serve? w)
  (string=? (world-state w) READY-TO-SERVE))

;; get-ball-x: World -> Integer
;; GIVEN: A world
;; RETURNS: The x-coordinate of the ball in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-ball-x w)
  (ball-x (world-ball w)))

;; get-ball-y: World -> Integer
;; GIVEN: A world
;; RETURNS: The y-coordinate of the ball in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-ball-y w)
  (ball-y (world-ball w)))

;; get-ball-vx: World -> Integer
;; GIVEN: A world
;; RETURNS: The x-component of the velocity of the ball in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-ball-vx w)
  (ball-vx (world-ball w)))

;; get-ball-vy: World -> Integer
;; GIVEN: A world
;; RETURNS: The y-component of the velocity of the ball in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-ball-vy w)
  (ball-vy (world-ball w)))

;; get-racket-x: World -> Integer
;; GIVEN: A world
;; RETURNS: The x-coordinate of the racket in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-racket-x w)
  (racket-x (world-racket w)))

;; get-racket-y: World -> Integer
;; GIVEN: A world
;; RETURNS: The y-coordinate of the racket in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-racket-y w)
  (racket-y (world-racket w)))

;; get-racket-vx: World -> Integer
;; GIVEN: A world
;; RETURNS: The x-component of the velocity of the racket in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-racket-vx w)
  (racket-vx (world-racket w)))

;; get-racket-vy: World -> Integer
;; GIVEN: A world
;; RETURNS: The y-component of the velocity of the racket in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-racket-vy w)
  (racket-vy (world-racket w)))

(begin-for-test

  (check-equal? (initial-world 1) (make-world (make-ball 330 384 0 0)
                                              (make-racket 330 384 0 0)
                                              READY-TO-SERVE 0 1) "The function
should return the initial state")

  (check-equal? (world-after-tick (initial-world 1)) (initial-world 1) "The tick
should not do anything in ready-to-serve state")

  (check-equal? (world-after-tick (make-world (make-ball 330 384 3 -9)
                                              (make-racket 330 384 0 0)
                                              RALLY 0 1))
                (world-after-tick-rally (make-world (make-ball 330 384 3 -9)
                                                    (make-racket 330 384 0 0)
                                                    RALLY 0 1)) "The function
should call the rally case")

  (check-equal? (world-after-tick (make-world (make-ball 330 384 3 -9)
                                              (make-racket 330 384 0 0)
                                              PAUSED 0 1))
                (world-after-tick-paused (make-world (make-ball 330 384 3 -9)
                                                     (make-racket 330 384 0 0)
                                                     PAUSED 0 1)) "The function
should call the paused case")

  (check-equal? (world-after-tick-rally (make-world (make-ball 330 384 3 -9)
                                                    (make-racket 330 384 0 0)
                                                    RALLY 0 1))
                (world-after-no-collision (make-world (make-ball 330 384 3 -9)
                                                      (make-racket 330 384 0 0)
                                                      RALLY 0 1))"No collision")

  (check-equal? (world-after-tick-rally (make-world (make-ball 330 384 -3 -10)
                                                    (make-racket 340 370 0 10)
                                                    RALLY 0 1))
                (ball-collide-racket (make-world (make-ball 330 384 -3 -10)
                                                 (make-racket 340 370 0 10)
                                                 RALLY 0 1)) "Collision with
racket")

  (check-equal? (world-after-tick-rally  (make-world (make-ball 2 384 -3 -9)
                                                     (make-racket 330 384 0 0)
                                                     RALLY 0 1))
                (ball-collide-wall (make-world (make-ball 2 384 -3 -9)
                                               (make-racket 330 384 0 0)
                                               RALLY 0 1)) "Collision with
wall")

  (check-equal? (world-after-tick-rally (make-world (make-ball 250 250 5 5)
                                                    (make-racket 30 30 -10 10)
                                                    RALLY 0 1))
                (racket-collide-wall (make-world (make-ball 250 250 5 5)
                                                 (make-racket 30 30 -10 10)
                                                 RALLY 0 1)) "Racket collides
with wall")

  (check-equal? (ball-hits-racket? (make-world (make-ball 260 240 -5 10)
                                               (make-racket 250 250 5 -5)
                                               RALLY 0 1)) #true "Ball collides
with racket")

  (check-equal? (ball-hits-racket? (make-world (make-ball 250 250 -10 10)
                                               (make-racket 240 240 0 0)
                                               RALLY 0 1)) #false "Ball and
racket do not collide")
  
  (check-equal? (ball-collide-racket (make-world (make-ball 260 240 -5 10)
                                                 (make-racket 250 250 5 -5)
                                                 RALLY 0 1))
                (make-world (make-ball 255 240 -5 -15)
                            (make-racket 255 245 5 0)
                            RALLY 0 1) "Racket collides with ball")

  (check-equal? (ball-collide-wall (make-world (make-ball 5 100 -20 10)
                                               (make-racket 250 250 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 15 110 20 10)
                            (make-racket 250 250 0 0) RALLY 0 1) "The ball
bounces off the left wall")

  (check-equal? (ball-hits-left? (make-world (make-ball 5 100 -20 10)
                                             (make-racket 250 250 0 0)
                                             RALLY 0 1)) #true "The ball
bounces off the left wall")

  (check-equal? (ball-hits-left? (make-world (make-ball 5 100 20 10)
                                             (make-racket 250 250 0 0)
                                             RALLY 0 1)) #false "The ball
does not bounce off the left wall")

  (check-equal? (ball-collide-wall (make-world (make-ball 420 100 20 10)
                                               (make-racket 250 250 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 410 110 -20 10)
                            (make-racket 250 250 0 0) RALLY 0 1) "The ball
bounces off the right wall")

  (check-equal? (ball-hits-right? (make-world (make-ball 420 100 20 10)
                                              (make-racket 250 250 0 0)
                                              RALLY 0 1)) #true "The ball
bounces off the right wall")

  (check-equal? (ball-hits-right? (make-world (make-ball 420 100 -20 10)
                                              (make-racket 250 250 0 0)
                                              RALLY 0 1)) #false "The ball
does not bounce off the right wall")

  (check-equal? (ball-collide-wall (make-world (make-ball 250 10 10 -30)
                                               (make-racket 250 250 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 260 20 10 30)
                            (make-racket 250 250 0 0) RALLY 0 1) "The ball
bounces off the front wall")

  (check-equal? (ball-hits-front? (make-world (make-ball 250 10 10 -30)
                                              (make-racket 250 250 0 0)
                                              RALLY 0 1)) #true "The ball
bounces off the front wall")

  (check-equal? (ball-hits-front? (make-world (make-ball 250 10 10 30)
                                              (make-racket 250 250 0 0)
                                              RALLY 0 1)) #false "The ball
does not bounce off the front wall")

  (check-equal? (ball-hits-back? (make-world (make-ball 250 645 10 10)
                                             (make-racket 250 250 10 10)
                                             RALLY 0 1)) #true "The ball
hits the front wall")

  (check-equal? (ball-hits-back? (make-world (make-ball 250 645 10 -10)
                                             (make-racket 250 250 10 10)
                                             RALLY 0 1)) #false "The ball
does not hit the back wall")
  
  (check-equal? (ball-collide-wall (make-world (make-ball 250 645 10 10)
                                               (make-racket 250 250 10 10)
                                               RALLY 0 1))
                (rally-to-paused (make-world (make-ball 250 645 10 10)
                                             (make-racket 250 250 10 10)
                                             RALLY 0 1)) "The ball
hits the back wall")

  (check-equal? (racket-hits-left? (make-world (make-ball 250 250 1 1)
                                               (make-racket 40 300 -20 0)
                                               RALLY 0 1)) #true "The racket
hits the left wall")

  (check-equal? (racket-hits-left? (make-world (make-ball 250 250 1 1)
                                               (make-racket 40 300 20 0)
                                               RALLY 0 1)) #false "The racket
does not hit the left wall")

  (check-equal? (racket-collide-wall (make-world (make-ball 250 250 1 1)
                                                 (make-racket 40 300 -20 0)
                                                 RALLY 0 1))
                (make-world (make-ball 251 251 1 1) (make-racket 23 300 0 0)
                            RALLY 0 1) "The racket hits the left wall")

  (check-equal? (racket-hits-right? (make-world (make-ball 250 250 1 1)
                                                (make-racket 400 300 30 0)
                                                RALLY 0 1)) #true "The racket
hits the right wall")

  (check-equal? (racket-hits-right? (make-world (make-ball 250 250 1 1)
                                                (make-racket 40 300 20 0)
                                                RALLY 0 1)) #false "The racket
does not hit the right wall")

  (check-equal? (racket-collide-wall (make-world (make-ball 250 250 1 1)
                                                 (make-racket 400 300 30 0)
                                                 RALLY 0 1))
                (make-world (make-ball 251 251 1 1) (make-racket 402 300 0 0)
                            RALLY 0 1) "The racket hits the right wall")

  (check-equal? (racket-hits-back? (make-world (make-ball 250 250 1 1)
                                               (make-racket 250 630 0 30)
                                               RALLY 0 1)) #true "The racket
hits the back wall")

  (check-equal? (racket-hits-back? (make-world (make-ball 250 250 1 1)
                                               (make-racket 250 300 0 0)
                                               RALLY 0 1)) #false "The racket
does not hit the back wall")

  (check-equal? (racket-collide-wall (make-world (make-ball 250 250 1 1)
                                                 (make-racket 250 630 0 30)
                                                 RALLY 0 1))
                (make-world (make-ball 251 251 1 1) (make-racket 250 649 0 0)
                            RALLY 0 1) "The racket hits the back wall")

  (check-equal? (racket-hits-front? (make-world (make-ball 250 250 1 1)
                                                (make-racket 250 10 0 -30)
                                                RALLY 0 1)) #true "The racket
hits the front wall")

  (check-equal? (racket-hits-front? (make-world (make-ball 250 250 1 1)
                                                (make-racket 250 10 0 30)
                                                RALLY 0 1)) #false "The racket
hits the front wall")

  (check-equal? (racket-collide-wall (make-world (make-ball 250 250 1 1)
                                                 (make-racket 250 10 0 -30)
                                                 RALLY 0 1))
                (rally-to-paused (make-world (make-ball 250 250 1 1)
                                             (make-racket 250 10 0 -30)
                                             RALLY 0 1)) "The racket hits the
front wall")

  (check-equal? (world-after-tick-paused (make-world (make-ball 250 250 0 0)
                                                     (make-racket 300 300 0 0)
                                                     PAUSED 1 1))
                (initial-world 1) "After the last paused tick it reverts to
ready-to-serve state")

  (check-equal? (world-after-tick-paused (make-world (make-ball 250 250 0 0)
                                                     (make-racket 300 300 0 0)
                                                     PAUSED 20 1))
                (make-world (make-ball 250 250 0 0) (make-racket 300 300 0 0)
                            PAUSED 19 1))

  (check-equal? (is-key-event-space? " ") #true "The key event is a space")

  (check-equal? (is-key-event-space? "q") #false "The key event is not a space")

  (check-equal? (world-after-key-event (initial-world 1) " ")
                (world-after-space (initial-world 1)) "The key event is a
space")

  (check-equal? (world-after-space (initial-world 1))
                (ready-to-rally (initial-world 1)) "The space bar moves the
world from ready-to-serve state to rally state")
  
  (check-equal? (world-after-space (make-world (make-ball 250 250 1 1)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (rally-to-paused (make-world (make-ball 250 250 1 1)
                                             (make-racket 300 300 0 0)
                                             RALLY 0 1)) "The space moves
the state from rally to paused")

  (check-equal? (world-after-space (make-world (make-ball 250 250 0 0)
                                               (make-racket 300 300 0 0)
                                               PAUSED 20 1))
                (make-world (make-ball 250 250 0 0)
                            (make-racket 300 300 0 0)
                            PAUSED 20 1) "Space has no
effect during paused state")

  (check-equal? (is-key-event-left? "left") #true "The key event is a left")

  (check-equal? (is-key-event-left? "q") #false "The key event is not a left")

  (check-equal? (world-after-key-event (initial-world 1) "left")
                (world-after-left (initial-world 1)) "The key event is a left")

  (check-equal? (is-key-event-right? "right") #true "The key event is a right")

  (check-equal? (is-key-event-right? "q") #false "The key event is not a right")

  (check-equal? (world-after-key-event (initial-world 1) "right")
                (world-after-right (initial-world 1)) "The key event is a
right")
  
  (check-equal? (is-key-event-up? "up") #true "The key event is an up")

  (check-equal? (is-key-event-up? "q") #false "The key event is not an up")

  (check-equal? (world-after-key-event (initial-world 1) "up")
                (world-after-up (initial-world 1)) "The key event is an up")
  
  (check-equal? (is-key-event-down? "down") #true "The key event is a down")

  (check-equal? (is-key-event-down? "q") #false "The key event is not a down")

  (check-equal? (world-after-key-event (initial-world 1) "down")
                (world-after-down (initial-world 1)) "The key event is a down")

  (check-equal? (world-after-key-event (initial-world 1) "q")
                (initial-world 1) "The key event is invalid")

  (check-equal? (world-after-left (initial-world 1))
                (initial-world 1) "Arrows do nothing if not in rally state")

  (check-equal? (world-after-left (make-world (make-ball 250 250 10 10)
                                              (make-racket 300 300 0 0)
                                              RALLY 0 1))
                (make-world (make-ball 250 250 10 10)
                            (make-racket 300 300 -1 0)
                            RALLY 0 1) "Left arrow decreases racket's vx")

  (check-equal? (world-after-right (initial-world 1))
                (initial-world 1) "Arrows do nothing if not in rally state")

  (check-equal? (world-after-right (make-world (make-ball 250 250 10 10)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 250 250 10 10)
                            (make-racket 300 300 1 0)
                            RALLY 0 1) "Right arrow increases racket's vx")

  (check-equal? (world-after-up (initial-world 1))
                (initial-world 1) "Arrows do nothing if not in rally state")

  (check-equal? (world-after-up (make-world (make-ball 250 250 10 10)
                                            (make-racket 300 300 0 0)
                                            RALLY 0 1))
                (make-world (make-ball 250 250 10 10)
                            (make-racket 300 300 0 -1)
                            RALLY 0 1) "Up arrow decreases racket's vy")

  (check-equal? (world-after-down (initial-world 1))
                (initial-world 1) "Arrows do nothing if not in rally state")

  (check-equal? (world-after-down (make-world (make-ball 250 250 10 10)
                                              (make-racket 300 300 0 0)
                                              RALLY 0 1))
                (make-world (make-ball 250 250 10 10)
                            (make-racket 300 300 0 1)
                            RALLY 0 1) "Down arrow increases racket's vy")

  (check-equal? (draw-court (initial-world 1)) (empty-scene 425 649 "white")
                "The court is white as the state is not paused")

  (check-equal? (draw-court (make-world (make-ball 250 250 0 0)
                                        (make-racket 300 300 0 0)
                                        PAUSED 20 1))
                (empty-scene 425 649 "yellow") "The court is yellow as the
state is paused")

  (check-equal? (world-ready-to-serve? (initial-world 1)) #true "The initial
world is in ready-to-serve state")

  (check-equal? (world-ready-to-serve? (make-world (make-ball 250 250 0 0)
                                                   (make-racket 300 300 0 0)
                                                   PAUSED 20 1))
                #false "The world is not in ready-to-serve state")

  (check-equal? (world-to-scene (initial-world 1))
                (place-images (list (circle 3 "solid" "black")
                                    (rectangle 47 7 "solid" "green"))
                              (list (make-posn 330 384)
                                    (make-posn 330 384))
                              (empty-scene 425 649 "white")) "The world is in
initial state")

  (check-equal? (ball-collide-wall (make-world (make-ball 0 250 900 0)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 50 250 900 0)
                            (make-racket 300 300 0 0)
                            RALLY 0 1) "The ball should bounce twice")
  
  (check-equal? (ball-collide-wall (make-world (make-ball 0 250 1300 0)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 400 250 -1300 0)
                            (make-racket 300 300 0 0)
                            RALLY 0 1) "The ball should bounce thrice")

  (check-equal? (ball-collide-wall (make-world (make-ball 0 20 900 -50)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 50 30 900 50)
                            (make-racket 300 300 0 0)
                            RALLY 0 1) "The ball should bounce thrice")

  (check-equal? (ball-collide-wall (make-world (make-ball 2 1 -10 -10)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 8 9 10 10)
                            (make-racket 300 300 0 0)
                            RALLY 0 1) "The ball should bounce twice")

  (check-equal? (ball-collide-wall (make-world (make-ball 423 1 10 -10)
                                               (make-racket 300 300 0 0)
                                               RALLY 0 1))
                (make-world (make-ball 417 9 -10 10)
                            (make-racket 300 300 0 0)
                            RALLY 0 1) "The ball should bounce twice")
  )
