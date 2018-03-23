;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
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
 variables-defined-by
 variables-used-by
 constant-expression?
 constant-expression-value)

(check-location "05" "q2.rkt")

;; DATA DEFINTIONS:

;; An ArithmeticExpression is one of:
;; -- a Literal
;; -- a Variable
;; -- an Operation
;; -- a Call
;; -- a Block

;; Observer Template:
;; arithmetic-expression-fn: ArithmeticExpression -> ?

;; (define (arithmetic-expression fn exp)
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

(define (lit n)
  (make-literal n))

;; var: String -> Variable
;; GIVEN: a string
;; WHERE: the string begins with a letter and contains nothing but letters and
;;        digits
;; RETURNS: A variable whose name is the given string

(define (var s)
  (make-variable s))

;; op: OperationName -> Operation
;; GIVEN: the name of an operation
;; RETURNS: the operation with that name

(define (op s)
  (make-operation s))

;; call: ArithmeticExpression ArithmeticExpressionList -> Call
;; GIVEN: an operator expression and a list of operand expressions
;; RETURNS: a call expression whose operator and operands are given

(define (call ae ael)
  (make-fncall ae ael))

;; call-operator: Call -> ArithmeticExpression
;; GIVEN: a call
;; RETURNS: The operator expression of that call

(define (call-operator c)
  (fncall-operator c))

;; call-operands: Call -> ArithmeticExpressionList
;; GIVEN: A call
;; RETURNS: the operand expressions of that call

(define (call-operands c)
  (fncall-operands c))

;; block: Variable ArithmeticExpression ArithmeticExpression ->
;;          ArithmeticExpression
;; GIVEN: A variable, an expression e0 and an expression e1
;; RETURNS: a block that defines the variable's value as the value of
;;          e0; the block's value will be the value for e1

(define (block v e0 e1)
  (make-blexp v e0 e1))

;; block-var: Block -> Variable
;; GIVEN: A block
;; RETURNS: the variable defined by that block

(define (block-var b)
  (blexp-var b))

;; block-rhs: Block -> ArithmeticExpression
;; GIVEN: a block
;; RETURNS: the expression whose value will become the value of the variable
;;          defined by that block

(define (block-rhs b)
  (blexp-rhs b))

;; block-body: Block -> ArithmeticExpression
;; GIVEN: a block
;; RETURNS: the expression whose value will become the value of the block
;;          expression

(define (block-body b)
  (blexp-body b))

;; call?: ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true iff the expression is a call

(define (call? ae)
  (fncall? ae))

;; block?: ArithmeticExpression -> Boolean
;; GIVEN: an arithmetic expression
;; RETURNS: true iff the expression is a block

(define (block? ae)
  (blexp? ae))

;; variables-defined-by: ArithmeticExpression -> StringList
;; GIVEN: an arithmetic expression
;; RETURNS: a list of the names of all the variables defined by all blocks that
;;          occur within the expression, without repetitions, in any order

(define (variables-defined-by ae)
  (remove-duplicates (sort (variables-def-by ae) string<?)))

;; remove-duplicates: StringList -> StringList
;; GIVEN: a list of strings, sorted alphabetically
;; RETURNS: a similar list of strings, but with duplicate elements removed

(define (remove-duplicates l)
  (cond
    [(empty? l) empty]
    [(= 1 (length l)) l]
    [(string=? (first l) (first (rest l))) (remove-duplicates (rest l))]
    [else (append (list (first l)) (remove-duplicates (rest l)))]))

;; variables-def-by: ArithmeticExpression -> StringList
;; GIVEN: an arithmetic expression
;; RETURNS: a list of the names of all the variables defined by all blocks that
;;          occur within the expression

(define (variables-def-by ae)
  (cond
    [(or (literal? ae) (variable? ae) (operation? ae)) empty]
    [(call? ae) (append (variables-def-by (call-operator ae))
                (variables-def-by-list (call-operands ae)))]
    [else (append (list (variable-name (block-var ae)))
                  (variables-def-by (block-rhs ae))
                  (variables-def-by (block-body ae)))]))

;; variables-def-by-list: ArithmeticExpressionList -> StringList
;; GIVEN: A list of arithmetic expressions
;; RETURNS: A list of the names of all the variables defined by all blocks that
;;          occur within the list of expressions

(define (variables-def-by-list ael)
  (cond
    [(empty? ael) empty]
    [(or (literal? (first ael)) (variable? (first ael))
         (operation? (first ael))) (variables-def-by-list (rest ael))]
    [(call? (first ael))
     (append (variables-def-by (call-operator (first ael)))
             (variables-def-by (first (call-operands (first ael))))
             (variables-def-by-list (rest (call-operands (first ael))))
             (variables-def-by-list (rest ael)))]
    [else (append (list (variable-name (block-var (first ael))))
                  (variables-def-by (block-rhs (first ael)))
                  (variables-def-by (block-body (first ael)))
                  (variables-def-by-list (rest ael)))]))

;; variables-used-by: ArithmeticExpression -> StringList
;; GIVEN: An arithmetic expression
;; RETURNS: a list of the names of all the variables used in the expression,
;;          including variables used in a block on the right hand side of its
;;          definition or in its body, but not including variables defined by a
;;          block unless they are also used, without repetition, in any order

(define (variables-used-by ae)
  (remove-duplicates (sort (variables-used ae) string<?)))

;; variables-used: ArithmeticExpression -> StringList
;; GIVEN: an arithmetic expression
;; RETURNS: a list of the names of all the variables used in the expression,
;;          including variables used in a block on the right hand side of its
;;          definition or in its body, but not including variables defined by a
;;          block unless they are also used

(define (variables-used ae)
  (cond
    [(or (literal? ae) (operation? ae)) empty]
    [(variable? ae) (list (variable-name ae))]
    [(call? ae) (append (variables-used (call-operator ae))
                (variables-used-list (call-operands ae)))]
    [else (append (variables-used (block-rhs ae))
                  (variables-used (block-body ae)))]))

;; variables-used-list: ArithmeticExpressionList -> StringList
;; GIVEN: A list of arithmetic expressions
;; RETURNS: a list of the names of all the variables used in the list of
;;          expressions, including variables used in a block on the right hand
;;          side of its definition or in its body, but not including variables
;;          defined by a block unless they are also used

(define (variables-used-list ael)
  (cond
    [(empty? ael) empty]
    [(or (literal? (first ael)) (operation? (first ael)))
     (variables-used-list (rest ael))]
    [(variable? (first ael)) (append (list (variable-name (first ael)))
                                     (variables-used-list (rest ael)))]
    [(call? (first ael))
     (append (variables-used (call-operator (first ael)))
             (variables-used (first (call-operands (first ael))))
             (variables-used-list (rest (call-operands (first ael))))
             (variables-used-list (rest ael)))]
    [else (append (variables-used (block-rhs (first ael)))
                  (variables-used (block-body (first ael)))
                  (variables-used-list (rest ael)))]))

;; constant-expression?: ArithmeticExpression -> Boolean
;; GIVEN: An arithmetic expression
;; RETURNS: true iff the expression is a constant expression

(define (constant-expression? ae)
  (cond
    [(literal? ae) #true]
    [(call? ae) (and (operation-expression? (call-operator ae))
                     (constant-expression-list? (call-operands ae)))]
    [(block? ae) (constant-expression? (block-body ae))]
    [else #false]))

;; constant-expression-list?: ArithmeticExpressionList -> Boolean
;; GIVEN: A list of arithmetic expressions
;; RETURNS: true iff all the expressions in the list are constant expressions

(define (constant-expression-list? ael)
  (cond
    [(empty? ael) #true]
    [(not (constant-expression? (first ael))) #false]
    [else (constant-expression-list? (rest ael))]))

;; operation-expression?: ArithmeticExpression -> Boolean
;; GIVEN: An arithmetic expression
;; RETURNS: true iff the expression is an operation expression

(define (operation-expression? ae)
  (cond
    [(operation? ae) #true]
    [(block? ae) (operation-expression? (block-body ae))]
    [else #false]))

;; constant-expression-value: ArithmeticExpression -> Real
;; GIVEN: An arithmetic expression
;; WHERE: the expression is a constant expression
;; RETURNS: the numerical value of the expression

(define (constant-expression-value ae)
  (cond
    [(literal? ae) (literal-value ae)]
    [(call? ae) (runop (operation-expression-value (call-operator ae))
                       (constant-expression-value-list (call-operands ae)))]
    [(block? ae) (constant-expression-value (block-body ae))]))

;; constant-expression-value-list: ArithmeticExpressionList -> RealList
;; GIVEN: A list of arithmetic expressions
;; WHERE: Every element in the list is a constant expression
;; RETURNS: A similar list with the numerical value of each expression

(define (constant-expression-value-list ael)
  (cond
    [(empty? ael) empty]
    [else (append (list (constant-expression-value (first ael)))
                  (constant-expression-value-list (rest ael)))]))

;; runop: Operation RealList -> Real
;; GIVEN: An operation and a list of real numbers
;; RETURNS: The numerical result of applying that operation to all the numbers

(define (runop op rl)
  (cond
    [(string=? "+" (operation-name op)) (list-sum rl)]
    [(string=? "*" (operation-name op)) (list-prod rl)]
    [(string=? "-" (operation-name op)) (list-sub rl)]
    [(and (string=? "/" (operation-name op)) (contains-zero? rl)) 0]
    [else (list-div rl)]))

;; list-sum: RealList -> Real
;; GIVEN: A list of real numbers
;; RETURNS: Their sum

(define (list-sum rl)
  (cond
    [(empty? rl) 0]
    [else (+ (first rl) (list-sum (rest rl)))]))

;; list-prod: RealList -> Real
;; GIVEN: A list of real numbers
;; RETURNS: Their product

(define (list-prod rl)
  (cond
    [(empty? rl) 1]
    [else (* (first rl) (list-prod (rest rl)))]))

;; list-sub: RealList -> Real
;; GIVEN: A list of real numbers
;; RETURNS: Their differences

(define (list-sub rl)
  (cond
    [(empty? rl) 0]
    [(= 1 (length rl)) (- 0 (first rl))]
    [else (- (first rl) (list-sum (rest rl)))]))

;; list-div: RealList -> Real
;; GIVEN: A list of real numbers
;; RETURNS: The quotient

(define (list-div rl)
  (cond
    [(empty? rl) 0]
    [(= 1 (length rl)) (/ 1 (first rl))]
    [else (/ (first rl) (list-prod (rest rl)))]))

;; contains-zero?: RealList -> Boolean
;; GIVEN: A list of real numbers
;; RETURNS: true iff one of the elements is zero

(define (contains-zero? rl)
  (cond
    [(empty? rl) #false]
    [(= 0 (first rl)) #true]
    [else (contains-zero? (rest rl))]))

;; operation-expression-value: ArithmeticExpression -> Operation
;; GIVEN: An arithmetic expression
;; WHERE: the expression is an operation expression

(define (operation-expression-value ae)
  (cond
    [(operation? ae) ae]
    [else (operation-expression-value (block-body ae))]))

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

  (check-equal? (variables-defined-by (block (var "x") (var "y")
                                             (call (block (var "z") (var "x")
                                                          (op "+"))
                                                   (list (block (var "x")
                                                                (lit 5)
                                                                (var "x"))
                                                         (var "x")))))
                (list "x" "z") "The variables defined by the function are x and
 z")

  (check-equal? (variables-defined-by (var "x")) (list) "The list should be
empty")

  (check-equal? (variables-defined-by (call (op "*")
                                            (list (lit 5) (lit 4)
                                                  (call (op "+")
                                                        (list (lit 5))))))
                (list) "The list should be empty")

  (check-equal? (variables-used-by (block (var "x") (var "y")
                                          (call (block (var "z") (var "x")
                                                          (op "+"))
                                                   (list (block (var "x")
                                                                (lit 5)
                                                                (var "x"))
                                                         (var "x")))))
                (list "x" "y") "The variables used by the function are x and y")

  (check-equal? (variables-used-by (call (op "*")
                                            (list (lit 5) (lit 4)
                                                  (call (op "+")
                                                        (list (lit 5))))))
                (list) "The list should be empty")

  (check-equal? (constant-expression? (call (var "f") (list (lit -3) (lit 44))))
                #false "The expression is not a constant expression")

  (check-equal? (constant-expression? (call (op "+") (list (var "x") (lit 44))))
                #false "The expression is not a constant expression")

  (check-equal? (constant-expression? (block (var "x") (var "y")
                                             (call
                                              (block (var "z")
                                                     (call (op "*")
                                                           (list (var "x")
                                                                 (var "y")))
                                                     (op "+"))
                                              (list (lit 3)
                                                    (call (op "*")
                                                          (list (lit 4)
                                                                (lit 5)))))))
                #true "The expression is a constant expression")

  (check-equal? (constant-expression-value (call (op "/")
                                                 (list (lit 15) (lit 3))))
                5 "15/3 = 5")

  (check-equal? (constant-expression-value (block (var "x") (var "y")
                                             (call
                                              (block (var "z")
                                                     (call (op "*")
                                                           (list (var "x")
                                                                 (var "y")))
                                                     (op "+"))
                                              (list (lit 3)
                                                    (call (op "*")
                                                          (list (lit 4)
                                                                (lit 5)))))))
                23 "3 + (4 * 5) = 23")

  (check-equal? (constant-expression-value (call (op "/") (list))) 0
                "The function should return 0 on an empty list")

  (check-equal? (constant-expression-value (call (op "/") (list (lit 15))))
                1/15 "The function should return the inverse of the number")

  (check-equal? (constant-expression-value (call (op "/")
                                                 (list (lit 5) (lit 0))))
                0 "The function should return 0 on division by zero")

  (check-equal? (constant-expression-value (call (op "-") (list))) 0
                "The function should return 0 on an empty list")

  (check-equal? (constant-expression-value (call (op "-") (list (lit 1))))
                -1 "The function should return the negative of the number")

  (check-equal? (constant-expression-value (call (op "-")
                                                 (list (lit 5) (lit 3))))
                2 "5-3 = 2")
  )