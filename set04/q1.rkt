;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

(provide
 inner-product
 permutation-of?
 shortlex-less-than?
 permutations)

(check-location "04" "q1.rkt")

;; inner-product: RealList RealList -> Real
;; GIVEN: two lists of real numbers
;; WHERE: the two lists have the same length
;; RETURNS: the inner products of those lists
;; DESIGN STRATEGY: Use Observer Template on RealList 
;; EXAMPLES:
;; (inner-product (list 2.5) (list 3.0)) => 7.5
;; (inner-product (list 1 2 3 4) (list 5 6 7 8) => 70
;; (inner-product (list) (list)) => 0

(define (inner-product list1 list2)
  (cond
    [(empty? list1) 0]
    [else (+ (* (first list1) (first list2))
             (inner-product (rest list1) (rest list2)))]))

;; permutation-of?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; WHERE: neither list contains duplicate elements
;; RETURNS: true iff one of the lists is a duplicate of the other
;; EXAMPLES: Divide into cases
;; (permutation-of? (list 1 2 3) (list 1 2 3)) => true
;; (permutation-of? (list 3 1 2) (list 1 2 3)) => true
;; (permutation-of? (list 3 1 2) (list 1 2 4)) => false
;; (permutation-of? (list 1 2 3) (list 1 2)) => false
;; (permutation-of? (list) (list)) => true

(define (permutation-of? list1 list2)
  (if (same-length? list1 list2)
      (list-equal? (sort list1 <) (sort list2 <))
      #false))

;; list-equal?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; WHERE: the two lists have the same length
;; RETURNS: true iff the the two lists are equal
;; DESIGN STRATEGY: Use Observer Template for IntList
;; EXAMPLES:
;; (list-equal? (list 1 2 3) (list 1 2 3)) => true
;; (list-equal? (list 1 2 3) (list 1 2)) => false
;; (list-equal? (list 1 2 3) (list 1 2 4)) => false

(define (list-equal? l1 l2)
  (cond
    [(empty? l1) #true]
    [(first-element-equal? l1 l2) (list-equal? (rest l1) (rest l2))]
    [else #false]))

;; shortlex-less-than?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true iff
;;          the first list is shorter than the second, OR
;;          both are non-empty, have the same length and either the first
;;            element of the first list is less than the first element of the
;;            second list, OR
;;          the first elements are equal, and the rest of the first list is less
;;            than the rest of the second list according to shortlex-less-than?
;; DESIGN STRATEGY:
;; EXAMPLES:
;;   (shortlex-less-than? (list) (list)) => false
;;   (shortlex-less-than? (list) (list 3)) => true
;;   (shortlex-less-than? (list 3) (list)) => false
;;   (shortlex-less-than? (list 3) (list 3)) => false
;;   (shortlex-less-than? (list 3) (list 1 2)) => true
;;   (shortlex-less-than? (list 3 0) (list 1 2)) => false
;;   (shortlex-less-than? (list 0 3) (list 1 2)) => true
;;   (shortlex-less-than? (list 4 0 3) (list 4 1 2)) => true

(define (shortlex-less-than? list1 list2)
  (if (both-empty? list1 list2)
      #false
      (cond
        [(or (first-shorter? list1 list2)
         (and (same-length? list1 list2)
              (first-element-less? list1 list2)))
         #true]
        [(and (same-length? list1 list2) (first-element-equal? list1 list2))
         (shortlex-less-than? (rest list1) (rest list2))]
        [else #false])))

;; first-shorter?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true iff the length of the first list is less than the length of the
;;          second list
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;;   (first-shorter? (list) (list 1)) => true
;;   (first-shorter? (list 1 2) (list 1)) => false

(define (first-shorter? list1 list2)
  (< (length list1) (length list2)))

;; first-element-equal?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true iff the first elements of both lists are equal
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;;   (first-element-equal? (list 1 2 3) (list 1 3 2)) => true
;;   (first-element-equal? (list 3 2 1) (list 1 2 3)) => false

(define (first-element-equal? list1 list2)
  (= (first list1) (first list2)))

;; same-length?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true iff the lengths of the two lists are equal
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;; (same-length? (list 1 2 3) (list 3 2 1)) => true
;; (same-length? (list 1) (list 1 2)) => false

(define (same-length? list1 list2)
  (= (length list1) (length list2)))

;; both-empty?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true iff both lists are empty
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES:
;;   (both-empty? (list) (list)) => true
;;   (both-empty? (list 1) (list)) => false

(define (both-empty? list1 list2)
  (and (empty? list1) (empty? list2)))

;; first-element-less?: IntList IntList -> Boolean
;; GIVEN: two lists of integers
;; RETURNS: true iff the first element of the first list is less than the first
;;          element of the second list
;; DESIGN STATEGY: Use simpler functions
;; EXAMPLES:
;;   (first-element-less? (list 1 2 3) (list 2 3 4)) => true
;;   (first-element-less? (list 1 2 3) (list 1 2 3)) => false

(define (first-element-less? list1 list2)
  (< (first list1) (first list2)))

;; permutations: IntList -> IntListList
;; GIVEN: a list of integers
;; WHERE: the integers contain no duplicates
;; RETURNS: a list of all the permutations of that list, in shortlex order
;; EXAMPLES:
;; (permutations (list)) => (list (list))
;; (permutations (list 9)) => (list (list 9))
;; (permutations (list 3 1 2)) =>
;;   (list (list 1 2 3)
;;         (list 1 3 2)
;;         (list 2 1 3)
;;         (list 2 3 1)
;;         (list 3 1 2)
;;         (list 3 2 1))


(define (permutations lst)
  (perm-helper (sort lst <)))

;; perm-helper: IntList -> IntListList
;; GIVEN: a sorted list of integers
;; WHERE: the list contains no duplicates
;; RETURNS: a list of all the permutations of that list in shortlex order
;; DESIGN STRATEGY: Divide into cases

(define (perm-helper lst)
  (cond
    [(empty? lst) (list(list))]
    [(= 1 (length lst)) (list (list (first lst)))]
    [else
     (permute-each-element 0 lst)]))

;; permute-each-element: IntList -> IntListList
;; GIVEN: A list
;; RETURNS: The list of all the permutations, taking each element, placing it at
;;          the head and permuting the rest of the elements
;; DESIGN STRATEGY: Divide into cases

(define (permute-each-element n l)
  (cond
    [(= 2 (length l)) (permute-rest (list-ref l n) (remove (list-ref l n) l))]
    [(= n (- (length l) 1)) (permute-rest (list-ref l n)
                                          (remove (list-ref l n) l))]
    [else (append (permute-rest (list-ref l n) (remove (list-ref l n) l))
                  (permute-each-element (+ 1 n) l))]))

;; permute-rest: Int IntList -> IntListList
;; GIVEN: an integer and a list
;; RETURNS: A list of lists of the integer put at the head of all permutations
;;          of the rest of the list
;; DESIGN STRATEGY: Divide into cases

(define (permute-rest begin rem)
  (cond
    [(= 1 (length rem))
     (list (list begin (first rem)) (list (first rem) begin))]
    [else (append-to-each begin (permutations rem))]))

;; append-to-each: Int IntList -> IntListList
;; GIVEN: An integer and a list
;; RETURNS: The list of lists of the integer appended at the head of each
;;          element of a list
;; DESIGN STRATEGY: Divide into cases

(define (append-to-each n l)
  (cond
    [(= 1 (length l)) (list (append (make-list 1 n) (first l)))]
    [else (append (list (append (make-list 1 n) (first l)))
                  (append-to-each n (rest l)))]))

;; TESTING:

(begin-for-test

  (check-equal? (inner-product (list 1 2 3 4) (list 5 6 7 8)) 70 "The inner
product of these lists should be 70")

  (check-equal? (inner-product (list) (list)) 0 "The inner product of two empty
lists should be 0")

  (check-equal? (permutation-of? (list 1 2 3) (list 3 1 2)) #true "The two lists
are permutations of each other")

  (check-equal? (permutation-of? (list 3 1 2) (list 1 2 4)) #false "The two
lists are not permutations of each other")

  (check-equal? (permutation-of? (list) (list)) #true "Empty lists are
permutations of each other")

  (check-equal? (permutation-of? (list 1 2 3) (list 1 2)) #false "Two lists
cannot be permutations of each other if they have different lengths")

  (check-equal? (shortlex-less-than? (list) (list)) #false "The two lists are
equal")

  (check-equal? (shortlex-less-than? (list) (list 3)) #true "An empty list is
shorter than a non-empty list")

  (check-equal? (shortlex-less-than? (list 3) (list)) #false "An empty list is
shorter than a non-empty list")

  (check-equal? (shortlex-less-than? (list 3) (list 3)) #false "The two lists
are equal")

  (check-equal? (shortlex-less-than? (list 3) (list 1 2)) #true "The first list
has less elements, so it is shorter")

  (check-equal? (shortlex-less-than? (list 3 0) (list 1 2)) #false "The second
list is shorter as its first element is smaller")

  (check-equal? (shortlex-less-than? (list 0 3) (list 1 2)) #true "The first
list is shorter as its first element is smaller")

  (check-equal? (shortlex-less-than? (list 4 0 3) (list 4 1 2)) #true "The first
list is shorter as its first element is smaller")

  (check-equal? (permutations (list)) (list (list)) "The list of permutations of
an empty list is empty")

  (check-equal? (permutations (list 3)) (list (list 3)) "The list of
permutations of a list with one element, has one element")

  (check-equal? (permutations (list 3 4 5)) (list (list 3 4 5) (list 3 5 4)
                                                  (list 4 3 5) (list 4 5 3)
                                                  (list 5 3 4) (list 5 4 3))
                "The list of permutations of a list with three elements, has six
elements")
   )