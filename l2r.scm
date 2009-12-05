(define (object? code)
  (or (string? code) (number? code)
      (eq? 'nil code)
      (eq? 'true code) (eq? 'false code)))

(define (=? exp)
  (tagged-list? exp '=))

(define (def-arg-print lis)
  (dprint (car lis))
  (map (lambda (code)
	 (dprint ", " code)) (cdr lis)))

(define (dprint . lis)
  (map (lambda (code)
	 (display code out-p)) lis))

(define (set v)
  (dprint v " = "))

(define (putobject code argp)
  (if (string? code)
      (dprint "\"" code "\"")
      (dprint code))
  (if (not argp)
      (dprint "\n")))

(define true 'true)
(define false 'false)
(define nil 'nil)

(define (cons? code)
  (tagged-list? code 'cons))

(define (car? code)
  (tagged-list? code 'car))
(define (cdr? code)
  (tagged-list? code 'cdr))
(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      false))
(define (lparen)
  (dprint "("))
(define (rparen argp)
  (dprint ")" (if argp "" "\n")))
(define (args-compile args argp)
  (let ((code1 (list (compile (car args) #t))))
	(append
	 (list '(lparen))
	 (list code1)
	 (if (null? (cdr args))
	     '()
	     (map (lambda (code)
		    `((canma) 
		      ,(compile code #t)))
		  (cdr args)))
	 `((rparen ,argp)))))
(define (run? code)
  (symbol? (car code)))

(define (compile code argp)
  (cond ((object? code) `(putobject ,code ,argp))
	((symbol? code) `(putobject ',code ,argp))
	((=? code) 
	 `((set ',(cadr code)) ,(compile (caddr code) #f)))
	((cons? code)
	 `((lbrack) ,(compile (cadr code) #t) 
	   (canma) ,(compile (caddr code) #t)
	   (rbrack ,argp)))
	((car? code)
	 `(,(compile (cadr code) #t) 
	   (lbrack) (putobject 0 #t) (rbrack ,argp)))
	((cdr? code)
	 `(,(compile (cadr code) #t) 
	   (lbrack) (putobject 1 #t) (rbrack ,argp)))
	((if? code)
	 (if-compile (cdr code) argp))
	((def? code)
	 `(def ',(cdr code)))
	((->? code)
	 `(-> ',(cdr code)))
	((run? code)
	 `((putobject ',(car code) #t)
	   ,(if (null? (cdr code))
		       `(0-args ,argp)
		      (args-compile (cdr code) argp))))
	 
	)
)
(define (def? exp)
  (tagged-list? exp 'def))
(define (->? code)
  (tagged-list? code '->))
(define (def code)
  (dprint "def " (car code) "(")
  (def-arg-print (cadr code)) (dprint ")\n")
  (compile-print (program-list-compile (cddr code)))
  (dprint "end\n"))
(define (program-list-compile code-list)
  (map (lambda (a)
	 (compile a #f)) code-list))
(define (if-compile code argp)
  `((comprint "if ") ,(compile (car code) #f)
    ,(compile (cadr code) #f)
    (comprint "else\n") ,(compile (caddr code) #f)
    (comprint "end\n")))
    
(define (comprint abc)
  (dprint abc))
(define (if? exp)
  (tagged-list? exp 'if))

(define (0-args argp)
  (dprint "()" (if argp "" "\n")))
(define (lbrack)
  (dprint "["))

(define (rbrack argp)
  (dprint "]" (if argp "" "\n"))
)

(define (canma)
  (dprint ","))

(define (-> lam-list)
  (dprint "lambda {|")
  (def-arg-print (car lam-list)) 
  (dprint "|\n")
  (compile-print (program-list-compile (cdr lam-list)))
  (dprint "}\n"))

(define (compile-print asm-list)
  (if (not (null? asm-list))
      (if (symbol? (car asm-list))
	  (eval asm-list (interaction-environment))
	  (begin
	      (compile-print (car asm-list))
	      (compile-print (cdr asm-list))))))

(define out-p (open-output-file "l2r-test.rb"))
(define if-test '((= x 10)(if true (puts x) (puts "else"))))
(define def-test '((def test (a b) (puts a b)) (test 20 30)))
(define lambda-test '(
		      (= lam (-> (a b)
				 (puts a b)))
		      (lam.call 10 20)
		      )
)
;(display (program-list-compile lambda-test))
;(newline)
(compile-print (program-list-compile lambda-test))