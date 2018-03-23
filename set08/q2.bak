;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require "q1.rkt")

(provide
 tie
 defeated
 defeated?
 outranks
 outranked-by
 power-ranking)

(check-location "08" "q2.rkt")

;; FUNCTION DEFINITIONS:

;; power-ranking: OutcomeList -> CompetitorList
;; GIVEN: A list of outcomes
;; RETURNS: a list of all competitors mentioned by one or more of the outcomes,
;;          without repetitions, with competitor A coming before competitor B in
;;          the list iff the power ranking of A is higher than the power ranking
;;          of B
;; DESIGN STRATEGY:

(define (power-ranking oc-list)
  (merge-sort (rem-dupes (get-competitor-list oc-list)) oc-list))

;; get-competitor-list: OutcomeList -> StringList
;; GIVEN: A list of outcomes
;; RETURNS: A list of all the competitors who participated in the outcomes
;; DESIGN STRATEGY: Divide into cases

(define (get-competitor-list oclist)
  (cond
    [(empty? oclist) empty]
    [(tie? (first oclist)) (append (list (outcome-tie-player1 (first oclist))
                                         (outcome-tie-player2 (first oclist)))
                                   (get-competitor-list (rest oclist)))]
    [else (append (list (outcome-defeat-winner (first oclist))
                        (outcome-defeat-loser (first oclist)))
                  (get-competitor-list (rest oclist)))]))

;; higher-rank?: Competitor Competitor OutcomeList -> Boolean
;; GIVEN: Two competitors and a list of outcomes
;; RETURNS: true iff the first competitor has a higher rank than the second
;; DESIGN STRATEGY: Divide into cases

(define (higher-rank? p1 p2 oclist)
  (cond
    [(< (length (outranked-by p1 oclist)) (length (outranked-by p2 oclist)))
     #true]
    [(> (length (outranked-by p1 oclist)) (length (outranked-by p2 oclist)))
     #false]
    [(> (length (outranks p1 oclist)) (length (outranks p2 oclist))) #true]
    [(< (length (outranks p1 oclist)) (length (outranks p2 oclist))) #false]
    [(> (get-percent p1 oclist) (get-percent p2 oclist)) #true]
    [(< (get-percent p1 oclist) (get-percent p2 oclist)) #false]
    [else (string<? p1 p2)]))

;; get-percent: Competitor OutcomeList -> Real
;; GIVEN: A competitor and a list of outcomes
;; RETURNS: That competitor's non-losing percentage
;; DESIGN STRATEGY:

(define (get-percent player oclist)
  (/ (non-loss player oclist) (total-participation player oclist)))

;; non-loss: Competitor OutcomeList -> NonNegInt
;; GIVEN: A competitor and a list of outcomes
;; RETURNS: The number of outcomes in which the competitor participates and does
;;          not lose
;; DESIGN STRATEGY: Use HOF filter on OutcomeList

(define (non-loss player oclist)
  (length (filter
           ;; OutcomeList -> Boolean
           (lambda (oc) (if (tie? oc)
                            (or (string=? player (outcome-tie-player1 oc))
                                (string=? player (outcome-tie-player2 oc)))
                            (string=? player (outcome-defeat-winner oc))))
                    oclist)))

;; total-participation: Competitor OutcomeList -> NonNegInt
;; GIVEN: A competitor and a list of outcomes
;; RETURNS: The number of outcomes in which the competitor participates
;; DESIGN STRATEGY: Use HOF filter on OutcomeList

(define (total-participation player oclist)
  (length (filter
           ;; OutcomeList -> Boolean
           (lambda (oc) (if (tie? oc)
                            (or (string=? player (outcome-tie-player1 oc))
                                (string=? player (outcome-tie-player2 oc)))
                            (or (string=? player (outcome-defeat-winner oc))
                                (string=? player (outcome-defeat-loser oc)))))
                    oclist)))

;; merge: SortedCompetitorList SortedCompetitorList OutcomeList ->
;;                                                          SortedCompetitorList
;; GIVEN: Two lists of competitors, sorted in decreasing power ranking and a
;;        list of outcomes
;; RETURNS: One sorted list of competitors containing all the competitors in
;;          the given lists
;; DESIGN STRATEGY: Divide into cases
;; HALTING MEASURE: Length of cl1 + Length of cl2

(define (merge cl1 cl2 oclist)
  (cond
    [(empty? cl1) cl2]
    [(empty? cl2) cl1]
    [(higher-rank? (first cl1) (first cl2) oclist) (append (list (first cl1))
                                                           (merge (rest cl1) cl2
                                                                  oclist))]
    [else (append (list (first cl2)) (merge cl1 (rest cl2) oclist))]))

;; merge-sort: CompetitorList OutcomeList -> SortedCompetitorList
;; GIVEN: A list of competitors and a list of outcomes
;; RETURNS: The given list of competitors but sorted by their power ranking
;; DESIGN STRATEGY: Divide into cases
;; HALTING MEASURE: Length of complist

(define (merge-sort complist oclist)
  (cond
    [(empty? complist) complist]
    [(empty? (rest complist)) complist]
    [else (merge (merge-sort (even-elements complist) oclist)
                 (merge-sort (odd-elements complist) oclist)
                 oclist)]))

;; odd-elements: XList -> XList
;; GIVEN: A list
;; RETURNS: A list of its elements at odd positions
;; DESIGN STRATEGY:

(define (odd-elements lst)
  (cond
    [(empty? lst) empty]
    [(empty? (rest lst)) (list (first lst))]
    [else (cons (first lst) (odd-elements (rest(rest lst))))]))

;; even-elements: XList -> XList
;; GIVEN: A list
;; RETURNS: A list of its elements at even positions
;; DESIGN STRATEGY:

(define (even-elements lst)
  (cond
    [(empty? lst) empty]
    [(empty? (rest lst)) empty]
    [else (cons (first (rest lst)) (even-elements (rest (rest lst))))]))

;; TESTING:

(begin-for-test

  (check-equal? (power-ranking (list (defeated "A" "D") (defeated "A" "E")
                                     (defeated "C" "B") (defeated "C" "F")
                                     (tie "D" "B") (defeated "F" "E")))
                (list "C" "A" "F" "E" "B" "D") "The ranking is CAFEBD")

  (check-equal? (power-ranking (list)) (list) "The ranking is empty")

  (check-equal? (power-ranking (list (defeated "E" "F") (tie "A" "B")
                                     (defeated "C" "F") (defeated "B" "D")
                                     (tie "A" "E") (defeated "A" "F")))
                (list "C" "A" "B" "E" "D" "F") "The ranking is CABEDF")

  (check-equal? (power-ranking (list (defeated "A" "D") (defeated "A" "E")
                                     (defeated "C" "B") (defeated "C" "F")
                                     (tie "D" "B") (defeated "F" "E")
                                     (defeated "A" "B")))
                (list "C" "A" "F" "E" "D" "B") "The ranking is CAFEDB")

  (check-equal? (power-ranking (list (tie "A" "B") (defeated "J" "D")
                                      (tie "B" "E") (defeated "A" "F")
                                      (defeated "G" "D") (tie "C" "B")
                                      (defeated "H" "D") (tie "I" "J")
                                      (defeated "C" "D") (tie "A" "G")
                                      (defeated "H" "B")))
                (list "H" "I" "J" "A" "C" "E" "G" "B" "F" "D")
                "The ranking is HIJACEGBFD")
  )