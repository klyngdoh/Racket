;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require rackunit)
(require "extras.rkt")
      
(provide
  make-lexer
  lexer-token
  lexer-input
  initial-lexer
  lexer-stuck?
  lexer-shift
  lexer-reset)

(check-location "02" "q1.rkt")

;; DATA DEFINITIONS:

;; REPRESENTATION:
;; A Lexer is represented as a struct (tokenString inputString),
;; with the following fields:
;; tokenString: String - The string of the characters that have already been
;;                       processed by the lexer
;; inputString: String - The string of the characters that have yet to be
;;                       processed by the lexer

;; IMPLEMENTATION

(define-struct lexer (token input))

;; CONSTRUCTOR TEMPLATE
;; make-lexer : String String -> Lexer
;; (make-lexer String String)
;; GIVEN: two strings s1 and s2
;; RETURNS: a Lexer whose token string is s1
;;     and whose input string is s2

;; OBSERVER TEMPLATE
;; lexer-token : Lexer -> String
;; GIVEN: a Lexer
;; RETURNS: its token string
;; EXAMPLE:
;;     (lexer-token (make-lexer "abc" "1234")) =>  "abc"

;; lexer-input : Lexer -> String
;; GIVEN: a Lexer
;; RETURNS: its input string
;; EXAMPLE:
;;     (lexer-input (make-lexer "abc" "1234")) =>  "1234"

;; (define (lexer-fn l)
;;   (...
;;   (lexer-token l)
;;   (lexer-input l)))

;; initial-lexer : String -> Lexer
;; GIVEN: an arbitrary string
;; RETURNS: a Lexer lex whose token string is empty
;;     and whose input string is the given string
;; DESIGN STRATEGY: Use Constructor Template
;; EXAMPLE: (initial-lexer "abc1234") => (make-lexer "" "abc1234")

(define (initial-lexer inputString)
  (make-lexer "" inputString))

;; first-char : String -> character
;; GIVEN: An arbitrary non-empty string
;; RETURNS: The first character of that string
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES: (first-char "Apple") => #\A

(define (first-char str)
  (string-ref str 0))

;; lexer-stuck? : Lexer -> Boolean
;; GIVEN: a Lexer
;; RETURNS: false if and only if the given Lexer's input string
;;     is non-empty and begins with an English letter or digit;
;;     otherwise returns true.
;; DESIGN STRATEGY:  Use simpler functions
;; EXAMPLES:
;;     (lexer-stuck? (make-lexer "abc" "1234"))  =>  false
;;     (lexer-stuck? (make-lexer "abc" "+1234"))  =>  true
;;     (lexer-stuck? (make-lexer "abc" ""))  =>  true

(define (lexer-stuck? lex)
  (or (string=? (lexer-input lex) "")
      (not-digit-or-alpha (first-char (lexer-input lex)))))
  
;; not-digit-or-alpha : character -> Boolean
;; GIVEN: a character
;; RETURNS: True iff the provided character is not a digit or an alphabet
;; DESIGN STRATEGY: Transcribe Formula - Compare values
;; EXAMPLES:
;; (not-digit-or-alpha #\X) => #false
;; (not-digit-or-alpha #\+) => #true

(define (not-digit-or-alpha ch)
  (or (char<? ch #\0) (char<? #\9 ch #\A) (char<? #\Z ch #\a) (char>? ch #\z)))

;; shift-token : Lexer -> String
;; GIVEN: A Lexer at a certain state
;; RETURNS: The characters of the Lexer's token string, followed by the first
;;          character of the Lexer's input string
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES: (shift-token (make-lexer "abc" "1234")) => "abc1"

(define (shift-token lex)
  (add-char (lexer-token lex) (first-char (lexer-input lex))))

;; shift-input : Lexer -> String
;; GIVEN: A Lexer at a certain state
;; RETURNS: All but the first character of the Lexer's input string
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES: (shift-input (make-lexer "abc" "1234")) => "234"

(define (shift-input lex)
  (remove-first-char (lexer-input lex)))

;; lexer-shift : Lexer -> Lexer
;; GIVEN: a Lexer
;; RETURNS:
;;   If the given Lexer is stuck, returns the given Lexer.
;;   If the given Lexer is not stuck, then the token string
;;       of the result consists of the characters of the given
;;       Lexer's token string followed by the first character
;;       of that Lexer's input string, and the input string
;;       of the result consists of all but the first character
;;       of the given Lexer's input string.
;; DESIGN STRATEGY: Divide into cases
;; EXAMPLES:
;;     (lexer-shift (make-lexer "abc" ""))
;;         =>  (make-lexer "abc" "")
;;     (lexer-shift (make-lexer "abc" "+1234"))
;;         =>  (make-lexer "abc" "+1234")
;;     (lexer-shift (make-lexer "abc" "1234"))
;;         =>  (make-lexer "abc1" "234")

(define (lexer-shift lex)
  (if(lexer-stuck? lex) lex 
     (make-lexer (shift-token lex) (shift-input lex))))

;; add-char : String Character -> String
;; GIVEN: An arbitrary string and a character
;; RETURNS: A string with the same text, and with the character appended at the
;;          end
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES: (add-char "Apple" #\s) => "Apples"

(define (add-char str ch)
  (string-append str (make-string 1 ch)))

;; remove-first-char : String -> String
;; GIVEN: An arbitrary non-empty String
;; RETURNS: A string with the same text, but with its first character removed
;; DESIGN STRATEGY: Use simpler functions
;; EXAMPLES: (remove-first-char "Apple") => "pple"

(define (remove-first-char str)
  (substring str 1))

;; lexer-reset : Lexer -> Lexer
;; GIVEN: a Lexer
;; RETURNS: a Lexer whose token string is empty and whose
;;     input string is empty if the given Lexer's input string
;;     is empty and otherwise consists of all but the first
;;     character of the given Lexer's input string.
;; DESIGN STRATEGY: Use Constructor Template
;; EXAMPLES:
;;     (lexer-reset (make-lexer "abc" ""))
;;         =>  (make-lexer "" "")
;;     (lexer-reset (make-lexer "abc" "+1234"))
;;         =>  (make-lexer "" "1234")

(define (lexer-reset lex)
  (make-lexer "" (if (string=? (lexer-input lex) "") ""
                     (remove-first-char (lexer-input lex)))))

;; TESTING:

(begin-for-test
  
  (check-equal? (initial-lexer "abc1234") (make-lexer "" "abc1234")
                 "The token string should be empty and the input string should
 be the same as the string provided")

  (check-equal? (not-digit-or-alpha #\X) #false "The function should return true
iff the character provided is not a digit or an alphabet")

  (check-equal? (not-digit-or-alpha #\+) #true "The function should return true
iff the character provided is not a digit or an alphabet")

  (check-equal? (first-char "Apple") #\A "The function should return the first
character of the string")

  (check-equal? (remove-first-char "Apple") "pple" "The function should return
the a string with the same text but with its first character removed")

  (check-equal? (lexer-stuck? (make-lexer "abc" "1234")) #false "The function
should return false as the input string is non-empty and begins with a number")

  (check-equal? (lexer-stuck? (make-lexer "abc" "+1234")) #true "The function
should return true as the input string begins with a non-digit and non-alphabet
character")

  (check-equal? (lexer-stuck? (make-lexer "abc" "")) #true "The function should
return true as the input string is empty")

  (check-equal? (add-char "Apple" #\s) "Apples" "The function should append the
character to the end of the string")

  (check-equal? (shift-token (make-lexer "abc" "1234")) "abc1" "The function
should return the characters of the Lexer's token string followed by the first
character of the Lexer's input string")

  (check-equal? (shift-input (make-lexer "abc" "1234")) "234" "The function
should return all but the first character of the lexer's input string")

  (check-equal? (lexer-shift (make-lexer "abc" "")) (make-lexer "abc" "") "The
function should return the same Lexer as it is stuck")

  (check-equal? (lexer-shift (make-lexer "abc" "+1234"))
                (make-lexer "abc" "+1234") "The function should return the same
Lexer as it is stuck")

  (check-equal? (lexer-shift (make-lexer "abc" "1234"))
                (make-lexer "abc1" "234") "The function should return a new
state of the Lexer with the token string being appended with the first character
of the input string, and the input string without its first character, as it is
not stuck")

  (check-equal? (lexer-reset (make-lexer "abc" "")) (make-lexer "" "") "The
function should return an empty token string and an empty input string since
the given input string is also empty")

  (check-equal? (lexer-reset (make-lexer "abc" "+1234")) (make-lexer "" "1234")
                "The function should return an empty token string and the input
string without its first character")
  )