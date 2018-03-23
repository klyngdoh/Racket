;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
(require "q1.rkt")

(provide
 lit
 literal-value
 var
 variable-name
 op
 operation-name
 call
 call-operator
 call-operands
 block
 block-var
 block-rhs
 block-body
 literal?
 variable?
 operation?
 call?
 block?
 undefined-variables
 well-typed?)

(check-location "07" "q2.rkt")

;; is-int?: ArithmeticExpression StringListList-> Boolean
;; GIVEN: An arithmetic expression and a list of lists of strings
;; WHERE: The list of lists of Strings is the list of all variables that have 
;;        been defined so far and their types
;; RETURNS: true iff it is of type int
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (is-int? ae defined)
  (cond
    [(literal? ae) #true]
    [(operation? ae) #false]
    [(variable? ae) (string=? "Int" (last-occurrence-of defined
                                                        (variable-name ae)))]
    [(call? ae) (or (and (is-op0? (call-operator ae) defined)
                         (is-int?-list (call-operands ae) defined))
                    (and (is-op1? (call-operator ae) defined)
                         (is-int?-list (call-operands ae) defined)
                         (> (length (call-operands ae)) 0)))]
    [(block? ae) (and (well-typed-not-base? (block-rhs ae) defined)
                      (is-int? (block-body ae)
                               (append defined
                                       (list (list
                                              (variable-name (block-var ae))
                                              (get-type (block-rhs ae) defined)
                                              )))))]))

;; is-int?-list: ArithmeticExpressionList StringListList-> Boolean
;; GIVEN: A list of arithmetic expressions and a list of lists of strings
;; WHERE: The list of lists of Strings is the list of all variables that have 
;;        been defined so far and their types
;; RETURNS: true iff all of them are of type Int
;; DESIGN STRATEGY: Use HOF andmap on ael

(define (is-int?-list ael defined)
  (andmap
   ;; ArithmeticExpression -> Boolean
   (lambda (ae) (is-int? ae defined)) ael))

;; is-op0?: ArithmeticExpression StringListList -> Boolean
;; GIVEN: An arithmetic expression and a list of lists of strings
;; WHERE: The list of lists of Strings is the list of all variables that have 
;;        been defined so far and their types
;; RETURNS: true iff it is of type Op0
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (is-op0? ae defined)
  (cond
    [(or (call? ae) (literal? ae)) #false]
    [(variable? ae) (string=? "Op0" (last-occurrence-of defined
                                                        (variable-name ae)))]
    [(operation? ae) (or (string=? (operation-name ae) "+")
                         (string=? (operation-name ae) "*"))]
    [(block? ae) (and (well-typed-not-base? (block-rhs ae) defined)
                      (is-op0? (block-body ae)
                               (append defined
                                       (list (list
                                              (variable-name (block-var ae))
                                              (get-type (block-rhs ae) defined)
                                              )))))]))

;; is-op1?: ArithmeticExpression StringListList -> Boolean
;; GIVEN: An arithmetic expression and a list of lists of strings
;; WHERE: The list of lists of Strings is the list of all variables that have 
;;        been defined so far and their types
;; RETURNS: true iff it is of type Op1
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (is-op1? ae defined)
  (cond
    [(or (call? ae) (literal? ae)) #false]
    [(variable? ae) (string=? "Op1" (last-occurrence-of defined
                                                        (variable-name ae)))]
    [(operation? ae) (or (string=? (operation-name ae) "-")
                         (string=? (operation-name ae) "/"))]
    [(block? ae) (and (well-typed-not-base? (block-rhs ae) defined)
                      (is-op0? (block-body ae)
                               (append defined
                                       (list (list
                                              (variable-name (block-var ae))
                                              (get-type (block-rhs ae) defined)
                                              )))))]))

;; get-type: ArithmeticExpression StringListList -> String
;; GIVEN: An arithmetic expression and a list of lists of strings
;; WHERE: The list of lists of Strings is the list of all variables that have 
;;        been defined so far and their types
;; RETURNS: The type of the arithmetic expression
;; DESIGN STRATEGY: Divide into cases

(define (get-type ae defined)
  (cond
    [(is-op1? ae defined) "Op1"]
    [(is-op0? ae defined) "Op0"]
    [(is-int? ae defined) "Int"]))

;; well-typed?: ArithmeticExpression -> Boolean
;; GIVEN: An arithmetic expression
;; RETURNS: true iff it is not of type error
;; DESIGN STRATEGY: Use simpler functions

(define (well-typed? ae)
  (or (is-int? ae (list)) (is-op1? ae (list)) (is-op0? ae (list))))

;; well-typed-not-base?: ArithmeticExpression StringListList -> Boolean
;; GIVEN: An arithmetic expression and a list of lists of strings
;; WHERE: The list of lists of Strings is the list of all variables that have 
;;        been defined so far and their types
;; RETURNS: true iff it is not of type error
;; DESIGN STRATEGY: Use simpler functions

(define (well-typed-not-base? ae defined)
  (or (is-int? ae defined) (is-op0? ae defined) (is-op1? ae defined)))

;; last-occurrence-of: XListList X -> X
;; GIVEN: A list of lists and an item to search for
;; WHERE: The length of the inner lists are all 2
;; RETURNS: The second element of the last occurring list whose first element
;;          matches the given element.
;; DESIGN STRATEGY: Use simpler functions

(define (last-occurrence-of defined-list var-to-search)
  (find-last (list-with-only-searched defined-list var-to-search)))

;; find-last: StringListList -> String
;; GIVEN: A list of the names of defined variables and their types
;; WHERE: All the variables have the same name
;; RETURNS: The most recent type of that variable
;; DESIGN STRATEGY: Divide into cases

(define (find-last sll)
  (if (= (length sll) 0)
      "Error"
      (cond
        [(empty? (rest sll)) (first (rest (first sll)))]
        [else (find-last (rest sll))])))

;; list-with-only-searched: StringListList String -> StringListList
;; GIVEN: A list of the naems of all defined variables and their types, and a
;;        variable name to search
;; RETURNS: A similar list but containing only the variables to search for
;; DESIGN STRATEGY: Use HOF filter on StringListList

(define (list-with-only-searched strll str)
  (filter
   ;; StringList -> Boolean
   (lambda (stringlist) (string=? (first stringlist) str)) strll))

;; TESTING:

(begin-for-test

  (check-equal? (well-typed? (lit 17)) #true "It is of type Int")

  (check-equal? (well-typed? (var "x")) #false "It is of type Error")

  (check-equal? (well-typed? (block (var "f")
                                    (op "+")
                                    (block (var "x")
                                           (call (var "f") (list))
                                           (call (op "*")
                                                 (list (var "x"))))))
                #true "It is of type Int")

  (check-equal? (well-typed? (block (var "f")
                                    (op "+")
                                    (block (var "f")
                                           (call (var "f") (list))
                                           (call (op "-")
                                                 (list (var "f"))))))
                #true "It is of type Int")

  (check-equal? (well-typed? (block (var "f")
                                    (op "+")
                                    (block (var "x")
                                           (call (var "f") (list))
                                           (call (op "*")
                                                 (list (var "f"))))))
                #false "It is of type Error")

  (check-equal? (well-typed? (block (var "x")
                                    (op "-")
                                    (block (var "y")
                                           (call (var "x") (list))
                                           (var "y"))))
                #false "It is of type error")

  (check-equal? (well-typed? (block (var "x")
                                    (call (op "-") (list))
                                    (lit 7)))
                #false "It is of type Error")
  )