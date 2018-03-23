;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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
 world-balls
 world-racket
 ball-x
 ball-y
 racket-x
 racket-y
 ball-vx
 ball-vy
 racket-vx
 racket-vy
 world-after-mouse-event
 racket-after-mouse-event
 racket-selected?
 )

(check-location "06" "q2.rkt")

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

;; Dimensions of the cursor:

(define CURSOR-RADIUS 4)
(define CURSOR-COLOUR "blue")
(define CURSOR-TRANSPARENCY "solid")
(define CURSOR-IMAGE (circle CURSOR-RADIUS CURSOR-TRANSPARENCY CURSOR-COLOUR))

;; Key Events:

(define SPACE-EVENT " ")
(define LEFT-EVENT "left")
(define RIGHT-EVENT "right")
(define UP-EVENT "up")
(define DOWN-EVENT "down")
(define B-EVENT "b")

;; Mouse Events

(define BUTTON-UP "button-up")
(define BUTTON-DOWN "button-down")
(define DRAG "drag")

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
;; (make-ball Integer Integer Integerr Integer)

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

;; ball-y: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The y-coordinate of that ball's position
;; DESIGN STRATEGY: Use Observer Template for Ball

;; ball-vx: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The x-component of that ball's velocity
;; DESIGN STRATEGY: Use Observer Template for Ball

;; ball-vy: Ball -> Integer
;; GIVEN: A ball
;; RETURNS: The y-component of that ball's velocity
;; DESIGN STRATEGY: Use Observer Template for Ball

;; A Racket is represented as a struct with the following fields:
;; x :        Integer  is the x-coordinate of the position of the racket
;; y :        Integer  is the y-coordinate of the position of the racket
;; vx:        Real     is the x-component of the velocity of the ball, in pixels
;;            per tick
;; vy:        Real     is the y-component of the velocity of the ball, in pixels
;;            per tick
;; dx:        Integer  is the x-coordinate of the distance between the racket 
;;            and the cursor
;; dy:        Integer  is the y-coordinate of the distance between the racket 
;;            and the cursor
;; selected?: Boolean  is true iff the racket is selected

;; Implementation:
(define-struct racket (x y vx vy selected? dx dy))

;; CONSTRUCTOR TEMPLATE
;; (make-racket Integer Integer Real Real Boolean Integer Integer)

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

;; racket-y: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The y-coordinate of that racket's position
;; DESIGN STRATEGY: Use Observer Template for Racket

;; racket-vx: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The x-component of that racket's velocity
;; DESIGN STRATEGY: Use Observer Template for Racket

;; racket-vy: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The y-component of that racket's velocity
;; DESIGN STRATEGY: Use Observer Template for Racket

;; racket-dx: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The x-distance between the racket and the cursor
;; DESIGN STRATEGY: Use Observer Template for Racket

;; racket-dx: Racket -> Integer
;; GIVEN: A racket
;; RETURNS: The y-distance between the racket and the cursor
;; DESIGN STRATEGY: Use Observer Template for Racket

;; racket-selected?: Racket -> Boolean
;; GIVEN: A racket
;; RETURNS: true iff the racket is selected
;; DESIGN STRATEGY: Use Observer Template for Racket

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
(define-struct world (balls racket state pause-timer speed))

;; CONSTRUCTOR TEMPLATE
;; (make-world BallList Racket State NonNegInt PosReal)

;; OBSERVER TEMPLATE
;; world-fn : World -> ?
;; (define (world-fn w)
;;  (...
;;   (world-balls w)
;;   (world-racket w)
;;   (world-state w)
;;   (world-pause-timer w))

;; world-balls: World -> BallList
;; GIVEN: A world
;; RETURNS: The ball that's present in the world
;; DESIGN STRATEGY: Use Observer Template for World

;; world-racket: World -> Racket
;; GIVEN: A world
;; RETURNS: The racket that's present in the world
;; DESIGN STRATEGY: Use Observer Template for World

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
            (on-mouse world-after-mouse-event)
            (on-draw world-to-scene)))

;; initial-world: PosReal -> World
;; GIVEN: The speed of the simulation, in seconds per tick
;; RETURNS: The ready-to-serve state of the world
;; DESIGN STRATEGY: Use constructor template for World
;; EXAMPLE:
;;   (initial-world 1)

(define (initial-world speed)
  (make-world (list (make-ball 330 384 0 0))
              (make-racket 330 384 0 0 #false 0 0)
              READY-TO-SERVE 0 speed))

;; world-after-tick: World -> World
;; GIVEN: Any world that's possible for the simulation
;; RETURNS: The world that follows the given world after one tick
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLES: (world-after-tick (initial-world 1)) => (initial-world 1)
;;           (world-after-tick (make-world (make-ball 330 384 0 0)
;;                                         (make-racket 330 384 0 0 #false 0 0)
;;                                          PAUSED 9 1))
;;        => (world-after-tick-paused (make-world (make-ball 330 384 0 0)
;;                                              (make-racket 330 384 0 0 #false
;;                                               0 0)
;;                                                PAUSED 8 1))

(define (world-after-tick w)
  (cond
    [(string=? (world-state w) RALLY) (world-after-tick-rally w)]
    [(string=? (world-state w) PAUSED) (world-after-tick-paused w)]
    [else w]))

;; world-after-tick-rally: World -> World
;; GIVEN: A world in rally state
;; RETURNS: The world that follows the given world one tick later
;; DESIGN STRATEGY: Use simpler 
;; EXAMPLE: (world-after-tick-rally (make-world (make-ball 330 384 3 -9)
;;                                          (make-racket 330 384 0 0 #false 0 0)
;;                                              RALLY 0 1))
;;       => (world-after-no-collision (make-world (make-ball 330 384 3 -9)
;;                                          (make-racket 330 384 0 0 #false 0 0)
;;                                                RALLY 0 1))

(define (world-after-tick-rally w)
  (cond
    [(racket-hits-front? w) (rally-to-paused w)]
    [(all-balls-gone? (world-balls w))
     (rally-to-paused (make-world (list) (world-racket w) RALLY 0
                                  (world-speed w)))]
    [else (make-world (ball-list-after-tick (world-balls w) (world-racket w))
                      (if (check-ball-racket? (world-balls w) (world-racket w))
                          (make-vy-zero (racket-after-tick w))
                          (racket-after-tick w) ) RALLY 0 (world-speed w))]))

;; ball-list-after-tick: BallList Racket -> BallList
;; GIVEN: A list of balls and a racket
;; RETURNS: The list of balls at the end of the next tick
;; DESIGN STRATEGY: Use Observer Template on BallList

(define (ball-list-after-tick bl r)
  (filter
   ;; Ball -> Boolean
   ;; RETURNS: True iff the ball is not empty
   (lambda (single-ball) (not (empty? single-ball)))
   (map
    ;; Ball Racket -> Ball
    ;; RETURNS: The new ball after one tick
    (lambda (single-ball) (change-ball single-ball r)) bl)))

;; (cond
;;    [(= 1 (length bl)) (list (change-ball (first bl) r))]
;;    [else (remove empty (append (list (change-ball (first bl) r))
;;                                (ball-list-after-tick (rest bl) r)))]))

;; change-ball: Ball Racket
;; GIVEN: A ball and a racket
;; RETURNS: The ball at the end of the next tick
;; DESIGN STRATEGY: Divide into cases

(define (change-ball b r)
  (cond
    [(ball-hits-back? b) empty]
    [(ball-hits-racket? b r) (ball-hits-racket b r)]
    [(and (ball-hits-right? b) (ball-hits-front? b)) (ball-hits-top-right b)]
    [(and (ball-hits-left? b) (ball-hits-front? b)) (ball-hits-top-left b)]
    [(ball-hits-left? b) (ball-hits-left b)]
    [(ball-hits-right? b) (ball-hits-right b)]
    [(ball-hits-front? b) (ball-hits-front b)]
    [else (ball-hits-nothing b)]
    ))

;; all-balls-gone?: BallList -> Boolean
;; GIVEN: A list of balls
;; RETURNS: true iff on the next tick all the balls have disappeared from the
;;          screen
;; DESIGN STRATEGY: Use Observer Template on BallList

(define (all-balls-gone? bl)
  (or (empty? bl)
      (andmap
       ;; Ball -> Boolean
       ;; RETURNS: True iff the ball hits the back of the court
       (lambda (single-ball) (ball-hits-back? single-ball)) bl)))

;;  (cond
;;    [(empty? bl) #true]
;;    [(not (ball-hits-back? (first bl))) #false]
;;    [else (all-balls-gone? (rest bl))]))

;; check-ball-racket?: BallList Racket -> Boolean
;; GIVEN: A list of balls and a racket
;; RETURNS: true iff at least one of the balls in the list hits the racket in
;;          the next tick
;; DESIGN STRATEGY: Use Observer Template on BallList

(define (check-ball-racket? bl r)
  (ormap
   ;; Ball Racket -> Boolean
   ;; RETURNS: True iff a ball has collided with a racket on this tick
   (lambda (single-ball) (ball-hits-racket? single-ball r)) bl))
  
;;  (cond
;;    [(= 0 (length bl)) #false]
;;    [(ball-hits-racket? (first bl) r) #true]
;;    [else (check-ball-racket? (rest bl) r)]))

;; make-vy-zero: Racket -> Racket
;; GIVEN: A racket
;; RETURNS: A racket with the same values, except its vy has been set to zero
;;          if it was negative
;; DESIGN STRATEGY: Use constructor template on Racket

(define (make-vy-zero r)
  (make-racket (racket-x r) (racket-y r) (racket-vx r) (max 0 (racket-vy r))
               (racket-selected? r) (racket-dx r) (racket-dy r)))

;; ball-hits-racket?: Ball Racket -> Boolean
;; GIVEN: A ball and a racket
;; RETURNS: true iff the ball touches the racket of the box on the next tick
;; DESIGN STRATEGY: Transcribe geometrical formula
;; EXAMPLES: (ball-hits-racket? (make-ball 260 240 -5 10)
;;                              (make-racket 250 250 5 -5 #false 0 0) => #true

(define (ball-hits-racket? b r)
  (and (ball-not-on-racket? b r) (>= (ball-vy b) 0)
       (ball-intersects-racket? b r)))

;; ball-not-on-racket?: Ball Racket -> Boolean
;; GIVEN: A ball and a racket
;; RETURNS: True iff the ball is not lying on the racket
;; DESIGN STRATEGY: Use simpler functions

(define (ball-not-on-racket? b r)
  (or (not (= (ball-y b) (racket-y r)))
      (< (ball-x b) (- (racket-x r) (/ COURT-WIDTH 2)))
      (> (ball-x b) (+ (racket-x r) (/ COURT-WIDTH 2)))))

;; ball-intersects-racket?: Ball Racket -> Boolean
;; GIVEN: A ball and a racket
;; RETURNS: True iff the path of the ball for this tick intersects with the new
;;          position of the racket in this tick
;; DESIGN STRATEGY: Use simpler functions

(define (ball-intersects-racket? b r)
  
  (and
   (or
    (<= (ball-x b) (racket-intersect b r) (+ (ball-x b) (ball-vx b)))
    (>= (ball-x b) (racket-intersect b r) (+ (ball-x b) (ball-vx b))))
   (<= (+ (- (racket-x r) 23) (racket-vx r))
       (racket-intersect b r)
       (+ (racket-x r) 23 (racket-vx r)))))

;; racket-intersect: Ball Racket -> Integer
;; GIVEN: A ball and a racket
;; RETURNS: The x-coordinate of the point where the ball would meet with the
;;          racket's straight horizontal line
;; DESIGN STRATEGY: Transcribe mathematical formula
;; rx = ((bvx/bvy)*(ry+rvy-by)) + bx
;; EXAMPLES: (racket-intersect (initial-world 1)) => 330

(define (racket-intersect b r)
  (cond
    [(not (= 0 (ball-vy b)))(+ (* (/ (ball-vx b)
                                     (ball-vy b))
                                  (- (+ (racket-y r) (racket-vy r))
                                     (ball-y b)))
                               (ball-x b))]
    [(< (ball-vx b) 0) (+ (racket-x r) 23 (racket-vx r))]
    [else (+ (racket-x r) 23 (racket-vx r))]))

;; ball-hits-racket: Ball Racket -> Ball
;; GIVEN: A ball and a racket
;; WHERE: The ball will hit the racket this tick
;; RETURNS: The ball at the end of the next tick
;; DESIGN STRATEGY: Use constructor template on Ball

(define (ball-hits-racket b r)
  (make-ball (+ (ball-x b) (ball-vx b))
             (- (* 2 (+ (racket-y r) (racket-vy r)))
                (ball-y b) (ball-vy b))
             (ball-vx b) (- (racket-vy r) (ball-vy b))))

;; ball-hits-back?: Ball -> Boolean
;; GIVEN: A ball
;; RETURNS: true iff the ball will hit the back of the court this tick
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-back? b)
  (> (ball-y b) COURT-HEIGHT))

;; ball-hits-left?: Ball -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the ball will hit the left of the court this tick
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-left? b)
  (< (+ (ball-x b) (ball-vx b)) 0))

;; ball-collide-left: Ball -> Ball
;; GIVEN: A ball that will collide with the left wall
;; RETURNS: The ball at the end of the next tick
;; DESIGN STRATEGY: Use constructor template on Ball

(define (ball-hits-left b)
  (make-ball (* -1 (+ (ball-x b) (ball-vx b)))
             (+ (ball-y b) (ball-vy b))
             (* -1 (ball-vx b)) (ball-vy b)))

;; ball-hits-right?: Ball -> Boolean
;; GIVEN: A ball
;; RETURNS: true iff the ball will hit the right of the court this tick
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-right? b)
  (> (+ (ball-x b) (ball-vx b)) COURT-WIDTH))

;; ball-hits-right: Ball -> Ball
;; GIVEN: A ball that will collide with the right wall
;; RETURNS: The ball at the end of the next tick
;; DESIGN STRATEGY: Use constructor template on Ball

(define (ball-hits-right b)
  (make-ball (- (* 2 COURT-WIDTH) (ball-x b) (ball-vx b))
             (+ (ball-y b) (ball-vy b))
             (* -1 (ball-vx b)) (ball-vy b)))

;; ball-hits-front?: Ball -> Boolean
;; GIVEN: A ball
;; RETURNS: true iff the ball will hit the front of the court this tick
;; DESIGN STRATEGY: Use simpler functions

(define (ball-hits-front? b)
  (< (+ (ball-y b) (ball-vy b)) 0))

;; ball-hits-front: Ball -> Ball
;; GIVEN: A ball that will collide with the front
;; RETURNS: The ball at the end of the next tick.
;; DESIGN STRATEGY: Use constructor Template on Ball

(define (ball-hits-front b)
  (make-ball (+ (ball-x b) (ball-vx b))
             (* -1 (+ (ball-y b) (ball-vy b)))
             (ball-vx b) (* -1 (ball-vy b))))

;; ball-hits-top-left: Ball -> Ball
;; GIVEN: A ball that will collide with the front and left walls
;; RETURNS: The ball at the end of the next tick.
;; DESIGN STRATEGY: Use Constructor Template on Ball

(define (ball-hits-top-left b)
  (make-ball (* -1 (+ (ball-x b) (ball-vx b)))
             (* -1 (+ (ball-y b) (ball-vy b)))
             (* -1 (ball-vx b)) (* -1 (ball-vy b))))

;; ball-hits-top-right: Ball -> Ball
;; GIVEN: A ball that will collide with the top and right walls on the next tick
;; RETURNS: The ball at the end of the next tick.
;; DESIGN STRATEGY: Use constructor template on Ball

(define (ball-hits-top-right b)
  (make-ball (- (* 2 COURT-WIDTH) (ball-x b) (ball-vx b))
             (* -1 (+ (ball-y b) (ball-vy b)))
             (* -1 (ball-vx b)) (* -1 (ball-vy b))))

;; ball-hits-nothing: Ball -> Ball
;; GIVEN: A ball that does not collide with any surface on the next tick
;; RETURNS: The ball at the end of the next tick
;; DESIGN STRATEGY: Use constructor template on Ball

(define (ball-hits-nothing b)
  (make-ball (+ (ball-x b) (ball-vx b))
             (+ (ball-y b) (ball-vy b))
             (ball-vx b) (ball-vy b)))

;; racket-after-tick: World -> Racket
;; GIVEN: A world
;; RETURNS: The racket at the end of the next tick
;; DESIGN STRATEGY: Divide into cases

(define (racket-after-tick w)
  (cond
    [(racket-hits-left? w) (racket-left w)]
    [(racket-hits-right? w) (racket-right w)]
    [(racket-hits-back? w) (racket-back w)]
    [else (racket-normal w)]))

;; racket-hits-left?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket hits the left of the court
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-left? w)
  (< (+ (get-racket-x w) (get-racket-vx w)) (floor (/ RACKET-LENGTH 2))))

;; racket-hits-right?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket hits the right of the court
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-right? w)
  (> (+ (get-racket-x w) (get-racket-vx w))
     (- COURT-WIDTH (floor (/ RACKET-LENGTH 2)))))

;; racket-hits-front?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket hits the front of the court
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-front? w)
  (< (+ (get-racket-y w) (get-racket-vy w)) 0))

;; racket-hits-back?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket hits the back of the court
;; DESIGN STRATEGY: Use simpler functions

(define (racket-hits-back? w)
  (> (+ (get-racket-y w) (get-racket-vy w)) COURT-HEIGHT))

;; racket-left: World -> Racket
;; GIVEN: A world where the racket hits the left wall on the next tick
;; RETURNS: The racket at the end of the next tick.
;; DESIGN STRATEGY: Use constructor template on Racket

(define (racket-left w)
  (make-racket (floor (/ RACKET-LENGTH 2))
               (+ (get-racket-y w) (get-racket-vy w))
               0 (get-racket-vy w) (get-racket-selected? w)
               (get-racket-dx w) (get-racket-dy w)))

;; racket-right: World -> Racket
;; GIVEN: A world where the racket hits the right wall on the next tick
;; RETURNS: The racket at the end of the next tick.
;; DESIGN STRATEGY: Use constructor template on Racket

(define (racket-right w)
  (make-racket (- COURT-WIDTH (floor (/ RACKET-LENGTH 2)))
               (+ (get-racket-y w) (get-racket-vy w)) 0 (get-racket-vy w)
               (get-racket-selected? w)
               (get-racket-dx w) (get-racket-dy w)))

;; racket-back: World -> Racket
;; GIVEN: A world where the racket hits the back wall on the next tick
;; RETURNS: The racket at the end of the next tick.
;; DESIGN STRATEGY: Use constructor template on Racket

(define (racket-back w)
  (make-racket (get-racket-x w) COURT-HEIGHT
               (get-racket-vx w) 0 (get-racket-selected? w)
               (get-racket-dx w) (get-racket-dy w)))

;; racket-normal: World -> Racket
;; GIVEN: A world where the racket does not hit any wall on the next tick
;; RETURNS: The racket at the end of the next tick
;; DESIGN STRATEGY: Divide into cases

(define (racket-normal w)
  (if (get-racket-selected? w)
      (world-racket w)
      (make-racket (+ (get-racket-x w) (get-racket-vx w))
                   (+ (get-racket-y w) (get-racket-vy w))
                   (get-racket-vx w) (get-racket-vy w)
                   (get-racket-selected? w)
                   (get-racket-dx w) (get-racket-dy w))))

;; world-after-tick-paused: World -> World
;; GIVEN: A world in paused state
;; RETURNS: A world that follows the given world after one tick
;; DESIGN STRATEGY: Divide into cases

(define (world-after-tick-paused w)
  (if(= (world-pause-timer w) 1)
     (initial-world (world-speed w))
     (make-world (world-balls w) (world-racket w) PAUSED
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
    [(is-key-event-b? kev) (world-after-b w)]
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
      (make-world (world-balls w) (make-racket (get-racket-x w) (get-racket-y w)
                                               (sub1 (get-racket-vx w))
                                               (get-racket-vy w)
                                               (get-racket-selected? w)
                                               (get-racket-dx w)
                                               (get-racket-dy w))
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
      (make-world (world-balls w) (make-racket (get-racket-x w) (get-racket-y w)
                                               (add1 (get-racket-vx w))
                                               (get-racket-vy w)
                                               (get-racket-selected? w)
                                               (get-racket-dx w)
                                               (get-racket-dy w))
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
      (make-world (world-balls w) (make-racket (get-racket-x w) (get-racket-y w)
                                               (get-racket-vx w)
                                               (sub1 (get-racket-vy w))
                                               (get-racket-selected? w)
                                               (get-racket-dx w)
                                               (get-racket-dy w))
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
      (make-world (world-balls w) (make-racket (get-racket-x w) (get-racket-y w)
                                               (get-racket-vx w)
                                               (add1 (get-racket-vy w))
                                               (get-racket-selected? w)
                                               (get-racket-dx w)
                                               (get-racket-dy w))
                  RALLY 0 (world-speed w))
      w))

;; is-key-event-b?: KeyEvent -> Boolean
;; GIVEN: a KeyEvent
;; RETURNS: true iff the KeyEvent is a b press
;; DESIGN STRATEGY: Use simpler functions

(define (is-key-event-b? ke)
  (key=? ke B-EVENT))

;; world-after-b: World -> World
;; GIVEN: a world
;; RETURNS: the world that should follow the given world on a b key press
;; DESIGN STRATEGY: Divide into cases

(define (world-after-b w)
  (if (string=? (world-state w) RALLY)
      (make-world (add-ball-to-list w)
                  (world-racket w) RALLY 0 (world-speed w))
      w))

;; add-ball-to-list: World -> BallList
;; GIVEN: A world
;; RETURNS: The BallList of that world, with a new ball added
;; DESIGN STRATEGY: Use simpler functions

(define (add-ball-to-list w)
  (append (world-balls w) (list (make-ball 330 384 3 -9))))

;; world-after-mouse-event: World Int Int MouseEvent -> World
;; GIVEN: A world, the x and y coordinates of a mouse event and the mouse event
;; RETURNS: The world that should follow the given world after the mouse event
;; DESIGN STRATEGY: Divide into cases

(define (world-after-mouse-event w x y mev)
  (if(string=? (world-state w) RALLY)
     (make-world (world-balls w)
                 (racket-after-mouse-event (world-racket w) x y mev)
                 RALLY 0 (world-speed w))
     w)
  )

;; racket-after-mouse-event: Racket Int Int MouseEvent -> Racket
;; GIVEN: A racket, the x and y coordinates of a mouse event and the mouse event
;; RETURNS: The racket as it should be after the mouse event
;; DESIGN STRATEGY: Divide into cases:

(define (racket-after-mouse-event r x y mev)
  (cond
    [(mouse=? mev BUTTON-DOWN) (racket-after-button-down r x y)]
    [(mouse=? mev DRAG) (racket-after-drag r x y)]
    [(mouse=? mev BUTTON-UP) (racket-after-button-up r x y)]
    [else r]))

;; racket-after-button-down: Racket Int Int -> Racket
;; GIVEN: A racket, and the coordinates of a button down event
;; RETURNS: The racket as it should be after the event
;; DESIGN STRATEGY: Divide into cases

(define (racket-after-button-down r x y)
  (if (in-racket? r x y)
      (make-racket (racket-x r) (racket-y r) (racket-vx r) (racket-vy r) #true
                   (- x (racket-x r)) (- y (racket-y r)))
      r))

;; racket-after-drag: Racket Int Int -> Racket
;; GIVEN: A racket and the coordinates of a drag event
;; RETURNS: The racket as it should be after the event
;; DESIGN STRATEGY: Divide into cases

(define (racket-after-drag r x y)
  (if (racket-selected? r)
      (make-racket (- x (racket-dx r)) (- y (racket-dy r))
                   (racket-vx r) (racket-vy r)
                   #true
                   (racket-dx r)
                   (racket-dy r))
      r))

;; racket-after-button-up: Racket Int Int -> Racket
;; GIVEN: A racket and the coordinates of a button up event
;; RETURNS: The racket as it should be after the event
;; DESIGN STRATEGY: Divide into cases

(define (racket-after-button-up r x y)
  (if (racket-selected? r)
      (make-racket (racket-x r) (racket-y r) (racket-vx r) (racket-vy r)
                   #false 0 0)
      r))

;; in-racket? Racket Int Int
;; GIVEN: A racket and a co-ordinate
;; RETURNS: true iff the co-ordinate is within 25 pixels of the center of the
;;          racket
;; DESIGN STRATEGY: Transcribe mathematical formula
;; (x2-x1)^2 + (y2-y1)^2 <= 25^2

(define (in-racket? r x y)
  (<= (+ (expt (- x (racket-x r)) 2) (expt (- y (racket-y r)) 2)) 625))

;; ready-to-rally: World -> World
;; GIVEN: A World
;; RETURNS: The world that should follow the given world when its sstate
;;          switches from ready-to-serve to rally
;; DESIGN STRATEGY: Use simpler functions

(define (ready-to-rally w)
  (make-world (list (make-ball (ball-x (first (world-balls w)))
                               (ball-y (first (world-balls w)))
                               INITIAL-VX INITIAL-VY))
              (world-racket w) RALLY 0 (world-speed w)))

;; rally-to-paused: World -> World
;; GIVEN: A world
;; RETURNS: The world that should follow the given world when its stateswitches
;;          from rally to paused
;; DESIGN STRATEGY: Use simpler functions

(define (rally-to-paused w)
  (make-world (set-all-ball-vel-zero (world-balls w))
              (make-racket (get-racket-x w) (get-racket-y w) 0 0 #false 0 0)
              PAUSED (/ 3 (world-speed w)) (world-speed w)))

;; set-all-ball-vel-zero: BallList -> BallList
;; GIVEN: A ballList
;; RETURNS: A ballList with all velocities 0
;; DESIGN STRATEGY: Use Observer Template for BallList

(define (set-all-ball-vel-zero bl)
  (map (lambda (single-ball) (make-ball (ball-x single-ball)
                                        (ball-y single-ball) 0 0)) bl))

;;  (cond
;;    [(empty? bl) empty]
;;    [else (append (list (make-ball (ball-x (first bl))
;;                                          (ball-y (first bl)) 0 0))
;;                  (set-all-ball-vel-zero (rest bl)))]))

;; draw-court: World -> Image
;; GIVEN: A world
;; RETURNS: The court of that world
;; DESIGN STRATEGY: Use simpler functions

(define (draw-court w)
  (empty-scene COURT-WIDTH COURT-HEIGHT (if (string=? (world-state w) PAUSED)
                                            "yellow" "white")))

;; ball-position-list: BallList -> PositionList
;; GIVEN: A list of balls
;; RETURNS: A list of the positions of those balls
;; DESIGN STRATEGY: Use Observer Template on BallList

(define (ball-position-list ballslist)
  (map
   ;; Ball -> Position
   ;; RETURNS: The position of the ball as its coordinates
   (lambda (single-ball) (make-posn (ball-x single-ball)
                                        (ball-y single-ball))) ballslist))

;;  (cond
;;    [(empty? ballslist) empty]
;;    [(= 1 (length ballslist)) (list (make-posn (ball-x (first ballslist))
;;                                               (ball-y (first ballslist))))]
;;    [else (append (list (make-posn (ball-x (first ballslist))
;;                                          (ball-y (first ballslist))))
;;                  (ball-position-list (rest ballslist)))]))

;; world-to-scene: World -> Scene
;; GIVEN: Any world that is possible for the simulation
;; RETURNS: A Scene that prtrays the given world
;; DESIGN STRATEGY: Use simpler functions

(define (world-to-scene w)
  (if (racket-selected? (world-racket w))
      (place-images (append (make-list (length (world-balls w)) BALL-IMAGE)
                            (list RACKET-IMAGE)
                            (list CURSOR-IMAGE))
                    (append (ball-position-list (world-balls w))
                            (list (make-posn (get-racket-x w)
                                                    (get-racket-y w)))
                            (list (make-posn (+ (get-racket-x w)
                                                       (get-racket-dx w))
                                                    (+ (get-racket-y w)
                                                       (get-racket-dy w)))))
                    (draw-court w))
      (place-images (append (make-list (length (world-balls w)) BALL-IMAGE)
                            (list RACKET-IMAGE))
                    (append (ball-position-list (world-balls w))
                            (list (make-posn (get-racket-x w)
                                                    (get-racket-y w))))
                    (draw-court w))))

;; world-ready-to-serve?: World -> Boolean
;; GIVEN: A world
;; RETURNS: True iff the world is in its ready-to-serve state
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLE:
;;    (world-ready-to-serve? (initial-world 1/24)) => true
;;    (world-ready-to-serve? (make-world (make-ball 100 100 0 0 )
;;                             (make-racket 200 200 0 0 #false 0 0) RALLY 0 1))
;;                                   => false

(define (world-ready-to-serve? w)
  (string=? (world-state w) READY-TO-SERVE))

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

;; get-racket-selected?: World -> Boolean
;; GIVEN: A world
;; RETURNS: true iff the racket in that world is selected
;; DESIGN STRATEGY: Use simpler functions:

(define(get-racket-selected? w)
  (racket-selected? (world-racket w)))

;; get-racket-dx: World -> Integer
;; GIVEN: A world
;; RETURNS: The x-coordinate of the distance between the racket and the cursor
;;          in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-racket-dx w)
  (racket-dx (world-racket w)))

;; get-racket-dy: World -> Integer
;; GIVEN: A world
;; RETURNS: The y-coordinate of the distance between the racket and the cursor
;;          in that world
;; DESIGN STRATEGY: Use simpler functions

(define (get-racket-dy w)
  (racket-dy (world-racket w)))

;; TESTING:

(begin-for-test

  (check-equal? (initial-world 1)
                (make-world (list (make-ball 330 384 0 0))
                            (make-racket 330 384 0 0 #false 0 0)
                            READY-TO-SERVE 0 1)
                "The function should return the initial state.")

  (check-equal? (world-after-tick (make-world (list (make-ball 300 300 5 5))
                                              (make-racket 300 400 5 5 #false
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 305 305 5 5))
                            (make-racket 305 405 5 5 #false 0 0)
                            RALLY 0 1)
                "The function should call the rally case")

  (check-equal? (world-after-tick (make-world (list (make-ball 300 300 0 0))
                                              (make-racket 20 20 0 0 #false 0 0)
                                              PAUSED 30 1))
                (make-world (list (make-ball 300 300 0 0))
                            (make-racket 20 20 0 0 #false 0 0)
                            PAUSED 29 1)
                "The function should call the paused case")

  (check-equal? (world-after-tick (initial-world 1))
                (initial-world 1)
                "The function should call the ready-to-serve case")

  (check-equal? (world-after-tick (make-world (list (make-ball 200 650 0 10))
                                              (make-racket 30 30 0 0 #false 0 0)
                                              RALLY 0 1))
                (rally-to-paused (make-world (list)
                                             (make-racket 30 30 0 0 #false 0 0)
                                             RALLY 0 1))
                "The function should pause the simulation")

  (check-equal? (world-after-tick (make-world (list (make-ball 250 250 0 10))
                                              (make-racket 250 260 0 -8 #false
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 250 244 0 -18))
                            (make-racket 250 252 0 0 #false 0 0)
                            RALLY 0 1)
                "The ball should bounce off the racket")

  (check-equal? (world-after-tick (make-world (list (make-ball 250 250 0 0)
                                                    (make-ball 250 640 0 20)
                                                    (make-ball 250 250 10 10))
                                              (make-racket 30 30 0 0 #false 0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 250 250 0 0)
                                  (make-ball 250 660 0 20)
                                  (make-ball 260 260 10 10))
                            (make-racket 30 30 0 0 #false 0 0) RALLY 0 1)
                "One ball should disappear")

  (check-equal? (world-after-tick (make-world (list (make-ball 5 5 -20 -20)
                                                    (make-ball 420 5 20 -20)
                                                    (make-ball 5 200 -20 -20)
                                                    (make-ball 420 200 20 -20)
                                                    (make-ball 250 5 -20 -20))
                                              (make-racket 200 200 0 0 #false
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 15 15 20 20)
                                  (make-ball 410 15 -20 20)
                                  (make-ball 15 180 20 -20)
                                  (make-ball 410 180 -20 -20)
                                  (make-ball 230 15 -20 20))
                            (make-racket 200 200 0 0 #false 0 0) RALLY 0 1)
                "The balls all bounce off of different surfaces")

  (check-equal? (world-after-tick (make-world (list (make-ball 50 200 -20 0))
                                              (make-racket 25 190 -20 10 #false
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 30 200 -20 0))
                            (make-racket 23 200 0 10 #false 0 0)
                            RALLY 0 1)
                "The racket hits the left wall")

  (check-equal? (world-after-tick (make-world (list (make-ball 250 250 0 0))
                                              (make-racket 400 400 30 0 #false
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 402 400 0 0 #false 0 0)
                            RALLY 0 1)
                "The racket hits the right wall")

  (check-equal? (world-after-tick (make-world (list (make-ball 250 250 0 0))
                                              (make-racket 250 630 0 30 #false
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 250 649 0 0 #false 0 0)
                            RALLY 0 1)
                "The racket hits the back wall")

  (check-equal? (world-after-tick (make-world (list (make-ball 250 250 0 0))
                                              (make-racket 250 250 0 0 #true
                                                           0 0)
                                              RALLY 0 1))
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 250 250 0 0 #true 0 0)
                            RALLY 0 1)
                "The racket is selected")

  (check-equal? (world-after-tick (make-world (list (make-ball 250 250 0 0))
                                              (make-racket 300 300 0 0 #false
                                                           0 0)
                                              PAUSED 1 1))
                (initial-world 1)
                "The world should go to ready-to-serve state")

  (check-equal? (world-after-key-event
                 (make-world (list (make-ball 250 250 0 0))
                             (make-racket 300 300 0 0
                                          #false 0 0)
                             RALLY 0 1) " ")
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 300 300 0 0 #false 0 0)
                            PAUSED 3 1)
                "The world enters paused state on hitting space")

  (check-equal? (world-after-key-event
                 (make-world (list (make-ball 250 250 0 0))
                             (make-racket 300 300 0 0
                                          #false 0 0)
                             RALLY 0 1) "up")
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 300 300 0 -1 #false 0 0)
                            RALLY 0 1)
                "The vy of the racket decreases on an up press")

  (check-equal? (world-after-key-event
                 (make-world (list (make-ball 250 250 0 0))
                             (make-racket 300 300 0 0
                                          #false 0 0)
                             RALLY 0 1) "down")
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 300 300 0 1 #false 0 0)
                            RALLY 0 1)
                "The vy of the racket increases on a down press")

  (check-equal? (world-after-key-event
                 (make-world (list (make-ball 250 250 0 0))
                             (make-racket 300 300 0 0
                                          #false 0 0)
                             RALLY 0 1) "right")
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 300 300 1 0 #false 0 0)
                            RALLY 0 1)
                "The vx of the racket increases on a right press")

  (check-equal? (world-after-key-event
                 (make-world (list (make-ball 250 250 0 0))
                             (make-racket 300 300 0 0
                                          #false 0 0)
                             RALLY 0 1) "left")
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 300 300 -1 0 #false 0 0)
                            RALLY 0 1)
                "The vx of the racket decreases on a left press")

  (check-equal? (world-after-key-event
                 (make-world (list (make-ball 250 250 0 0))
                             (make-racket 300 300 0 0
                                          #false 0 0)
                             RALLY 0 1) "b")
                (make-world (list (make-ball 250 250 0 0)
                                  (make-ball 330 384 3 -9))
                            (make-racket 300 300 0 0 #false 0 0)
                            RALLY 0 1)
                "The world adds another ball on a b press")

  (check-equal? (world-after-key-event (initial-world 1) "q")
                (initial-world 1)
                "The world should be the same on an unused key press")

  (check-equal? (world-after-key-event (make-world (list
                                                    (make-ball 250 250 0 0))
                                                   (make-racket 300 300 0 0
                                                                #false 0 0)
                                                   PAUSED 3 1) " ")
                (make-world (list (make-ball 250 250 0 0))
                            (make-racket 300 300 0 0 #false 0 0)
                            PAUSED 3 1)
                "Space has no effect on the paused state")

  (check-equal? (world-after-key-event (initial-world 1) "left")
                (initial-world 1)
                "Left has no effect on the ready-to-serve state")

  (check-equal? (world-after-key-event (initial-world 1) "right")
                (initial-world 1)
                "Right has no effect on the ready-to-serve state")

  (check-equal? (world-after-key-event (initial-world 1) "up")
                (initial-world 1)
                "Up has no effect on the ready-to-serve state")

  (check-equal? (world-after-key-event (initial-world 1) "down")
                (initial-world 1)
                "Down has no effect on the ready-to-serve state")

  (check-equal? (world-after-key-event (initial-world 1) "b")
                (initial-world 1)
                "B has no effect on the ready-to-serve state")

  (check-equal? (world-after-key-event (initial-world 1) " ")
                (ready-to-rally (initial-world 1))
                "The spacebar changes the state to rally")

  (check-equal? (world-after-mouse-event (initial-world 1) 200 200 BUTTON-DOWN)
                (initial-world 1)
                "The mouse has no effect in the ready-to-serve state")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 30 30 0 0 #false 0 0)
                                          PAUSED 3 1)
                                         200 200 "button-down")
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 30 30 0 0 #false 0 0)
                            PAUSED 3 1)
                "The mouse has no effect in the paused state")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 30 30 0 0 #false 0 0)
                                          RALLY 0 1) 35 35 "button-down")
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 30 30 0 0 #true 5 5)
                            RALLY 0 1)
                "The racket should be selected on button down")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 250 250 0 0 #false 0 0)
                                          RALLY 0 1) 300 300 BUTTON-DOWN)
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 250 250 0 0 #false 0 0)
                            RALLY 0 1)
                "The racket should not be selected as the event is too far")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 250 250 0 0 #true 0 0)
                                          RALLY 0 1) 300 300 DRAG)
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 300 300 0 0 #true 0 0)
                            RALLY 0 1)
                "The racket should move as it is dragged")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 250 250 0 0 #true 0 0)
                                          RALLY 0 1) 250 250 BUTTON-UP)
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 250 250 0 0 #false 0 0)
                            RALLY 0 1)
                "The button up should deselect the racket")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 250 250 0 0 #false 0 0)
                                          RALLY 0 1) 425 0 "leave")
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 250 250 0 0 #false 0 0)
                            RALLY 0 1)
                "Leave is not a valid mouse event")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 250 250 0 0 #false 0 0)
                                          RALLY 0 1) 250 250 BUTTON-UP)
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 250 250 0 0 #false 0 0)
                            RALLY 0 1)
                "Button up does nothing if the racket is not selected")

  (check-equal? (world-after-mouse-event (make-world
                                          (list (make-ball 20 20 0 0))
                                          (make-racket 250 250 0 0 #false 0 0)
                                          RALLY 0 1) 250 250 DRAG)
                (make-world (list (make-ball 20 20 0 0))
                            (make-racket 250 250 0 0 #false 0 0)
                            RALLY 0 1)
                "Drag does nothing if the racket is not selected")

  (check-equal? (world-to-scene (make-world (list (make-ball 250 250 0 0)
                                                  (make-ball 200 200 0 0))
                                            (make-racket 300 300 0 0
                                                         #true 15 15)
                                            RALLY 0 1))
                (place-images (list (circle 3 "solid" "black")
                                    (circle 3 "solid" "black")
                                    (rectangle 47 7 "solid" "green")
                                    (circle 4 "solid" "blue"))
                              (list (make-posn 250 250)
                                    (make-posn 200 200)
                                    (make-posn 300 300)
                                    (make-posn 315 315))
                              (empty-scene 425 649 "white")) "The world is in
rally state with the racket selected")

  (check-equal? (world-to-scene (make-world (list (make-ball 250 250 0 0))
                                            (make-racket 300 300 0 0 #false 0 0)
                                            PAUSED 3 1))
                (place-images (list (circle 3 "solid" "black")
                                    (rectangle 47 7 "solid" "green"))
                              (list (make-posn 250 250)
                                    (make-posn 300 300))
                              (empty-scene 425 649 "yellow"))
                "The world is in paused state")
  )