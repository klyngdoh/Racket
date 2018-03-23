;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")

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
 undefined-variables)

(check-location "07" "q1.rkt")

;; DATA DEFINTIONS:

;; An ArithmeticExpression is one of:
;; -- a Literal
;; -- a Variable
;; -- an Operation
;; -- a Call
;; -- a Block

;; Observer Template:
;; arithmetic-expression-fn: ArithmeticExpression -> ?

;; (define (arithmetic-expression-fn exp)
;;   (cond
;;     [(literal? exp)...]
;;     [(variable? exp)...]
;;     [(operation? exp)...]
;;     [(call? exp)...]
;;     [(block? exp)...]))
    
;; A Literal is represented as a struct with the following fields:
;; Value: Real - The number that represents the value of the literal

;; Implementation:
(define-struct literal (value))

;; Constructor Template:
;; (make-literal Real)

;; Observer Template:
;; literal-fn: Literal -> ?
;; (define (literal-fn l)
;;   (...
;;     (literal-value l)))

;; literal-value: Literal -> Real
;; GIVEN: A literal
;; RETURNS: the number it represents

;; A Variable is represented as a struct with the following fields:
;; Name: String - The name of that variable

;; Implementation:
(define-struct variable (name))

;; Constructor Template:
;; (make-variable String)

;; Observer Template:
;; variable-fn: Variable -> ?
;; (define (variable-fn v)
;;   (...
;;     (variable-name v)))

;; variable-name: Variable -> String
;; GIVEN: A variable
;; RETURNS: the name of that variable

;; An Operation is represented as a struct with the following fields:
;; Name: OperationName - The name of the operation represented.

;; Implementation:
(define-struct operation (name))

;; Constructor Template:
;; (make-operation OperationName)

;; An OperationName is represented as one of the following Strings:
;; -- "+"
;; -- "-"
;; -- "*"
;; -- "/"

;; Observer Template:
;; operation-name-fn: OperationName -> ?
;; (define (operation-fn op)
;;   (cond
;;     [(string=? op "+") ...]
;;     [(string=? op "-") ...]
;;     [(string=? op "*") ...]
;;     [(string=? op "/") ...]))

;; Observer Template:
;; operation-fn: Operation -> ?
;; (define (operation-fn o)
;;   (...
;;     (operation-name o)))

;; operation-name: Operation -> OperationName
;; GIVEN: An operation
;; RETURNS: the name of that operation

;; A Call is represented as a struct with the following fields:
;; -- Operator: ArithmeticExpression - The operator expression of the call
;; -- Operands: ArithmeticExpressionList - The operand expressions of the call

;; Implementation
(define-struct fncall(operator operands))

;; Constructor Template:
;; For Call:
;; (make-fncall ArithmeticExpression ArithmeticExpressionList)
;; For ArithmeticExpressionList:
;; An ArithmeticExpressionList is either:
;; -- empty
;; -- (cons ArithmeticExpression ArithmeticExpressionList)

;; Observer Template:

;; fncall-fn: Call -> ?
;; (define (fncall-fn c)
;;   (... (fncall-operation c)
;;        (aelist-fn (fncall-operands c))))

;; aelist-fn: ArithmeticExpressionList -> ?
;; (define (aelist-fn ael)
;;   (cond
;;     [(empty? ael)...]
;;     [else (... (fncall-fn (first ael)) (aelist-fn (rest ael)))]))

;; A Block is represented as a struct with the following fields:
;; -- Var: Variable - The variable defined by the block
;; -- Rhs: ArithmeticExpression - the expression whose value will become the
;;                                value of the variable defined by the block
;; -- Body: ArithmeticExpression - The expression whose value will become the
;;                                 value of the block expression

;; Implementation: 
(define-struct blexp (var rhs body))

;; Constructor Template:
;; (make-blexp Variable ArithmeticExpression ArithmeticExpression)

;; An OperationExpression is an ArithmeticExpression that is either:
;; -- An Operation
;; -- A Block whose body is an Operation Expression

;; A ConstantExpression is an ArithmeticExpression that is either:
;; -- A Literal
;; -- A Call whose operator is an OperationExpression and whose operands are all
;;    ConstantExpressions
;; -- A Block whose body is a ConstantExpression

;; FUNCTION DEFINITIONS:

;; lit: Real -> Literal
;; GIVEN: A real number
;; RETURNS: A literal that represents that number
;; DESIGN STRATEGY: Use Constructor Template on literal

(define (lit n)
  (make-literal n))

;; var: String -> Variable
;; GIVEN: a string
;; WHERE: the string begins with a letter and contains nothing but letters and
;;        digits
;; RETURNS: A variable whose name is the given string
;; DESIGN STRATEGY: Use Constructor Template on variable

(define (var s)
  (make-variable s))

;; op: OperationName -> Operation
;; GIVEN: the name of an operation
;; RETURNS: the operation with that name
;; DESIGN STRATEGY: Use Constructor Template on operation

(define (op s)
  (make-operation s))

;; call: ArithmeticExpression ArithmeticExpressionList -> Call
;; GIVEN: an operator expression and a list of operand expressions
;; RETURNS: a call expression whose operator and operands are given
;; DESIGN STRATEGY: Use Constructor Template on fncall

(define (call ae ael)
  (make-fncall ae ael))

;; call-operator: Call -> ArithmeticExpression
;; GIVEN: a call
;; RETURNS: The operator expression of that call
;; DESIGN STRATEGY: Use Observer Template on fncall

(define (call-operator c)
  (fncall-operator c))

;; call-operands: Call -> ArithmeticExpressionList
;; GIVEN: A call
;; RETURNS: the operand expressions of that call
;; DESIGN STRATEGY: Use Observer Template on fncall

(define (call-operands c)
  (fncall-operands c))

;; block: Variable ArithmeticExpression ArithmeticExpression ->
;;          ArithmeticExpression
;; GIVEN: A variable, an expression e0 and an expression e1
;; RETURNS: a block that defines the variable's value as the value of
;;          e0; the block's value will be the value for e1
;; DESIGN STRATEGY: Use Constructor Template on blexp

(define (block v e0 e1)
  (make-blexp v e0 e1))

;; block-var: Block -> Variable
;; GIVEN: A block
;; RETURNS: the variable defined by that block
;; DESIGN STRATEGY: Use Observer Template on blexp

(define (block-var b)
  (blexp-var b))

;; block-rhs: Block -> ArithmeticExpression
;; GIVEN: a block
;; RETURNS: the expression whose value will become the value of the variable
;;          defined by that block
;; DESIGN STRATEGY: Use Observer Template on blexp

(define (block-rhs b)
  (blexp-rhs b))

;; block-body: Block -> ArithmeticExpression
;; GIVEN: a block
;; RETURNS: the expression whose value will become the value of the block
;;          expression
;; DESIGN STRATEGY: Use Observer Template on blexp

(define (block-body b)
  (blexp-body b))

;; call?: ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true iff the expression is a call
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (call? ae)
  (fncall? ae))

;; block?: ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true iff the expression is a block
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (block? ae)
  (blexp? ae))

;; undefined-variables: ArithmeticExpression -> StringList
;; GIVEN: an arithmetic expression
;; RETURNS: a list of all the names of the undefined variables for the
;;          expression, without repetitions, in any order
;; DESIGN STRATEGY: Use simpler functions

(define (undefined-variables ae)
  (remove-duplicates (undef-var ae empty)))

;; undef-var: ArithmeticExpression StringList -> StringList
;; GIVEN: an arithmetic expression and a list of strings
;; WHERE: The list of strings contains all the variables that have been defined
;;        so far
;; RETURNS: a list of all the names of the undefined variables for the
;;          expression, in any order
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (undef-var ae defined)
  (cond
    [(literal? ae) empty]
    [(operation? ae) empty]
    [(variable? ae) (if (member? (variable-name ae) defined)
                        empty
                        (list (variable-name ae)))]
    [(call? ae) (append (undef-var (call-operator ae) defined)
                        (undef-var-list (call-operands ae) defined))]
    [(block? ae) (append (undef-var (block-rhs ae) defined)
                         (undef-var (block-body ae)
                                    (append (list
                                             (variable-name (block-var ae)))
                                            defined)))]))

;; undef-var-list: ArithemeticExpressionList -> StringList
;; GIVEN: A list of arithmetic expressions
;; RETURNS: a list of all the names of the undefined variables for all
;;          expressions, in any order
;; DESIGN STRATEGY: Use observer template on ArithmeticExpression

(define (undef-var-list ael defined)
  (cond
    [(empty? ael) empty]
    [(or (literal? (first ael)) (operation? (first ael)))
     (undef-var-list (rest ael) defined)]
    [(variable? (first ael)) (if (member? (variable-name (first ael)) defined)
                                 (undef-var-list (rest ael) defined)
                                 (append (list (variable-name (first ael)))
                                         (undef-var-list (rest ael) defined)))]
    [(call? (first ael)) (append (undef-var (call-operator (first ael)) defined)
                                 (undef-var (first (call-operands (first ael)))
                                            defined)
                                 (undef-var-list (rest (call-operands
                                                        (first ael))) defined)
                                 (undef-var-list (rest ael) defined))]
    [(block? (first ael)) (append (undef-var (first ael) defined)
                                  (undef-var-list (rest ael) defined))]))

;; remove-duplicates: XList -> XList
;; GIVEN: Any list
;; RETURNS: A similar list but with all duplicate elements removed
;; DESIGN STRATEGY: Use HOF foldr on XList

(define (remove-duplicates any-list)
  (foldr
   ;; X XList -> XList
   (lambda (element lst)
           (if (not (member? element lst))
               (append (list element) lst)
               lst)) empty any-list))

;; TESTING:

(begin-for-test

  (check-equal? (literal-value (lit 17.4)) 17.4 "The function should return the
 value of the literal")

  (check-equal? (variable-name (var "x15")) "x15" "The function should return
the name of the variable")

  (check-equal? (operation-name (op "+")) "+" "The function should return the
name of the operation")

  (check-equal? (call-operator (call (op "-") (list (lit 7) (lit 2.5))))
                (op "-") "The function should return the operator")

  (check-equal? (call-operands (call (op "-") (list (lit 7) (lit 2.5))))
                (list (lit 7) (lit 2.5)) "The function should return the
operands")

  (check-equal? (block-var (block (var "x5") (lit 5)
                                  (call (op "*") (list (var "x6") (var "x7")))))
                (var "x5") "The function should return the defined variable")

  (check-equal? (block-rhs (block (var "x5") (lit 5)
                                  (call (op "*") (list (var "x6") (var "x7")))))
                 (lit 5) "The function should return the expression whose
value will become the value of the variable defined by the block")

  (check-equal? (block-body (block (var "x5") (lit 5)
                                  (call (op "*") (list (var "x6") (var "x7")))))
                (call (op "*") (list (var "x6") (var "x7"))) "The function
should return the expression whose value will become the value of the block
expression")

  (check-equal? (undefined-variables (call (var "f") (list (block (var "x")
                                                                  (var "x")
                                                                  (var "x"))
                                                           (block (var "y")
                                                                  (lit 7)
                                                                  (var "y"))
                                                           (var "z"))))
                (list "f" "x" "z") "The undefined variables are f x and z")

  (check-equal? (undefined-variables (block (var "x") (var "x") (var "x")))
                (list "x") "The undefined variable is x")

  (check-equal? (undefined-variables (call (op "+") (list (block (var "x")
                                                                 (var "x")
                                                                 (var "x"))
                                                          (block (var "y")
                                                                 (var "z")
                                                                 (var "x"))
                                                          (block (var "z")
                                                                 (var "y")
                                                                 (var "z"))
                                                          (lit 5)
                                                          (op "+")
                                                          (var "q"))))
                (list "z" "x" "y" "q")
                "The undefined variables are y z x and q")

  (check-equal? (undefined-variables (call (op "+") (list (block (var "a")
                                                                 (var "b")
                                                                 (var "c"))
                                                          (block (var "d")
                                                                 (var "a")
                                                                 (var "d"))
                                                          (block (var "b")
                                                                 (var "e")
                                                                 (var "e"))
                                                          (lit 5)
                                                          (op "+")
                                                          (var "q"))))
                (list "b" "c" "a" "e" "q")
                "The undefined variables are y z x and q")

  (check-equal? (undefined-variables (call (op "+")
                                           (list (block (var "a")
                                                        (lit 7)
                                                        (call (op "+")
                                                              (list (var "a")
                                                                    (var "b"))))
                                                 (call (op "+")
                                                       (list (lit 7)
                                                             (lit 9))))))
                (list "b") "The undefined variable is b")
  )