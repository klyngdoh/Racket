;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide
 tie
 defeated
 defeated?
 tie?
 defeat?
 outcome-tie-player1
 outcome-tie-player2
 outcome-defeat-winner
 outcome-defeat-loser
 outranks
 outranked-by
 list-equal?
 normalize-list
 rem-dupes)

(check-location "08" "q1.rkt")

;; DATA DEFINITIONS:

;; A Competitor is represented as a String, which represents the name of the
;;   competitor

;; An Outcome is one of:
;; -- a Tie
;; -- a Defeat

;; Observer Template:
;; outcome-fn: Outcome -> ?

;;(define (outcome-fn oc)
;;  (cond
;;    [(tie? oc) ...]
;;    [(defeat? oc) ...]))

;; A Tie is represented as a struct with the following fields:
;; Comp1: String - The string represents the name of the first competitor
;; Comp2: String - The string represents the name of the second competitor

;; Implementation:
(define-struct outcome-tie (player1 player2))

;; Constructor Template:
;; (make-outcome-tie String String)

;; Observer Template:
;; outcome-tie-fn: Tie -> ?
;; (define outcome-tie-fn t)
;;   (...
;;     (outcome-tie-player1 t)
;;     (outcome-tie-player2 t)))

;; A Defeat is represented as a struct with the following fields:
;; Comp1: String - The string represents the name of the winner
;; Comp2: String - The string represents the name of the loser

;; Implementation:
(define-struct outcome-defeat (winner loser))

;; Constructor Template:
;; (make-outcome-defeat String String)

;; Observer Template:
;; outcome-defeat-fn: Defeat -> ?
;; (define (outcome-defeat-fn d)
;;   (...
;;     (outcome-defeat winner d)
;;     (outcome-defeat loser d)))

;; FUNCTION DEFINITIONS:

;; tie: Competitor Competitor -> Tie
;; GIVEN: the names of two competitors
;; RETURNS: an indication that the two competitors have engaged in a contest,
;;          and the outcome was a tie
;; DESIGN STRATEGY: Use constructor template on Tie

(define (tie name1 name2)
  (make-outcome-tie name1 name2))

;; defeated: Competitor Competitor -> Defeat
;; GIVEN: the names of two competitors
;; RETURNS: an indication that the two competitors have engaged in a contest,
;;          with the first competitor defeating the second
;; DESIGN STRATEGY: Use constructor template on Defeat

(define (defeated win lose)
  (make-outcome-defeat win lose))

;; tie?: Outcome -> Boolean
;; GIVEN: an outcome
;; RETURNS: true iff it is a tie
;; DESIGN STRATEGY: Use observer template on Tie

(define (tie? oc)
  (outcome-tie? oc))

;; defeat?: Outcome -> Boolean
;; GIVEN: An outcome
;; RETURNS: true iff it is a defeat
;; DESIGN STRATEGY: Use observer template on Defeat

(define (defeat? oc)
  (outcome-defeat? oc))

;; defeated?: Competitor OutcomeList -> Boolean
;; GIVEN: the names of two competitors and a list of outcomes
;; RETURNS: true iff one or more of the outcomes states indicates that the  
;;          first competitor has defeated or tied the second
;; DESIGN STRATEGY: Use simpler functions

(define (defeated? name1 name2 oc-list)
  (or (member? (defeated name1 name2) oc-list)
      (member? (tie name1 name2) oc-list)
      (member? (tie name2 name1) oc-list)))

;; outranks: Competitor OutcomeList -> CompetitorList
;; GIVEN: the name of a competitor and a list of outcomes
;; RETURNS: a list of the competitors outranked by the given competitor,
;;          in alphabetical order
;; DESIGN STRATEGY: Use simpler functions

(define (outranks name oc-list)
  (normalize-list
   (outrank-helper (list name) oc-list
                   (foldr
                    ;; Outcome CompetitorList -> CompetitorList
                    (lambda (oc res) (append (loser-name name oc) res))
                    empty oc-list))))

;; outrank-helper: Competitor OutcomeList CompetitorList -> CompetitorList
;; GIVEN: A list of outcomes and a list of competitors
;; RETURNS: A list of all the competitors that are outranked by all the members
;;          in the list of competitors, until there are no more
;; DESIGN STRATEGY: Use simpler functions
;; HALTING MEASURE: Length of found - length of the competitors that are
;;                  outranked by the members of found

(define (outrank-helper original oc-list found)
  (if (list-equal? found (outrank-list (append original found) oc-list))
      found
      (outrank-helper original
                      oc-list
                      (normalize-list
                       (append found (outrank-list (append original found)
                                                   oc-list))))))

;; : CompetitorList OutcomeList -> CompetitorList
;; GIVEN: A list of competitors and a list of outcomes
;; RETURNS: The combined list of all the competitors each competitor in the 
;;          list outranks, based on the given list of outcomes
;; DESIGN STRATEGY: Use HOF foldr on CompetitorList

(define (outrank-list namelist oc-list)
  (foldr
   ;; Competitor CompetitorList -> CompetitorList
   (lambda (name res1)
     (append (foldr
              ;; Outcome CompetitorList -> CompetitorList
              (lambda (oc res) (append (loser-name name oc) res))
              empty oc-list) res1))
   empty namelist))

;; loser-name: Competitor Outcome -> StringList
;; GIVEN: The name of a competitor and an outcome
;; RETURNS: A list containing the name of the other competitor of the outcome
;;          if the given competitor won
;; DESIGN STRATEGY: Divide into cases

(define (loser-name name oc)
  (cond
    [(and (defeat? oc) (string=? (outcome-defeat-winner oc) name))
     (list (outcome-defeat-loser oc))]
    [(and (tie? oc) (string=? (outcome-tie-player1 oc) name))
     (list (outcome-tie-player2 oc))]
    [(and (tie? oc) (string=? (outcome-tie-player2 oc) name))
     (list (outcome-tie-player1 oc))]
    [else empty]))

;; outranked-by: Competitor OutcomeList -> CompetitorList
;; GIVEN: the name of a competitor and a list of outcomes
;; RETURNS: the list of the competitors that outrank the given competitor,
;;          in alphabetical order
;; DESIGN STRATEGY:

(define (outranked-by name oc-list)
  (normalize-list
   (outranked-by-helper (list name)
                        oc-list
                        (foldr
                         ;; Outcome CompetitorList -> CompetitorList
                         (lambda (oc res) (append (winner-name name oc) res))
                         empty oc-list))))

;; outrank-helper: Competitor OutcomeList CompetitorList -> CompetitorList
;; GIVEN: A list of outcomes and a list of competitors
;; RETURNS: A list of all the competitors that are outranked by all the members
;;          in the list of competitors, until there are no more
;; DESIGN STRATEGY: Use simpler functions
;; HALTING MEASURE: Length of found - length of the competitors that are
;;                  outranked by the members of found

(define (outranked-by-helper original oc-list found)
  (if (list-equal? found (outranked-by-list (append original found) oc-list))
      found
      (outranked-by-helper original
                           oc-list
                           (normalize-list
                            (append found (outranked-by-list (append original
                                                                     found)
                                                             oc-list))))))

;; : CompetitorList OutcomeList -> CompetitorList
;; GIVEN: A list of competitors and a list of outcomes
;; RETURNS: The combined list of all the competitors each competitor in the 
;;          list outranks, based on the given list of outcomes
;; DESIGN STRATEGY: Use HOF foldr on CompetitorList

(define (outranked-by-list namelist oc-list)
  (foldr
   ;; Competitor CompetitorList -> CompetitorList
   (lambda (name res1)
     (append (foldr
              ;; Outcome CompetitorList -> CompetitorList
              (lambda (oc res) (append (winner-name name oc) res))
              empty oc-list) res1))
   empty namelist))

;; winner-name: Competitor Outcome -> StringList
;; GIVEN: The name of a competitor and an outcome
;; RETURNS: A list containing the name of the other competitor of the outcome
;;          if the given competitor loses
;; DESIGN STRATEGY: Divide into cases

(define (winner-name name oc)
  (cond
    [(and (defeat? oc) (string=? (outcome-defeat-loser oc) name))
     (list (outcome-defeat-winner oc))]
    [(and (tie? oc) (string=? (outcome-tie-player1 oc) name))
     (list (outcome-tie-player2 oc))]
    [(and (tie? oc) (string=? (outcome-tie-player2 oc) name))
     (list (outcome-tie-player1 oc))]
    [else empty]))

;; list-equal?: StringList StringList -> Boolean
;; GIVEN: Two lists of strings
;; RETURNS: true iff the two normalized lists contain the same elements
;; DESIGN STRATEGY: Use simpler functions

(define (list-equal? lst1 lst2)
  (and (= (length (normalize-list lst1)) (length (normalize-list lst2)))
       (andmap string=? (normalize-list lst1) (normalize-list lst2))))

;; normalize-list: StringList -> StringList
;; GIVEN: Any list of strings
;; RETURNS: A similar list of strings but with all duplicates removed and all
;;          elements sorted
;; DESIGN STRATEGY: Use simpler functions

(define (normalize-list strlist)
  (sort (rem-dupes strlist) string<?))

;; rem-dupes: XList -> XList
;; GIVEN: Any list
;; RETURNS: A similar list but with all duplicate elements removed
;; DESIGN STRATEGY: Use HOF foldr on XList
 
(define (rem-dupes any-list)
  (foldr
   ;; X XList -> XList
   (lambda (element lst)
     (if (not (member? element lst))
         (append (list element) lst)
         lst)) empty any-list))

;; TESTING:

(begin-for-test

  (check-equal? (defeated? "A" "B" (list (defeated "A" "B") (tie "B" "C")))
                #true "A defeats B")

  (check-equal? (defeated? "B" "C" (list (defeated "A" "B") (tie "B" "C")))
                #true "B defeats C")

  (check-equal? (defeated? "B" "C" (list (defeated "A" "B") (tie "C" "B")))
                #true "B defeats C")

  (check-equal? (outranks "A" (list (defeated "A" "D") (defeated "A" "E")
                                    (defeated "C" "B") (defeated "C" "F")
                                    (tie "D" "B") (defeated "F" "E")))
                (list "B" "D" "E") "A outranks B, D and E")

  (check-equal? (outranked-by "B" (list (defeated "A" "D") (defeated "A" "E")
                                        (defeated "C" "B") (defeated "D" "C")
                                        (tie "D" "B") (defeated "F" "E")))
                (list "A" "B" "C" "D") "B is outranked by A, B, C and D")
  )