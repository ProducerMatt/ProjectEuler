(define (solution x)
  (apply +
         (filter (λ (x) (or (= 0 (remainder x 3))
                            (= 0 (remainder x 5))))
                 (map (λ (x) (+ 1 x))
                      (cdr (iota (- x 1)))))))


(define (solution2 x)
  (define ll '())
  (define (iter i)
    (if (= i 1)
        (apply + ll)
        (begin (cond ((or (= 0 (modulo i 3))
                          (= 0 (modulo i 5)))
                      (set! ll (append ll i))))
               (iter (- i 1)))))

  (iter (- x 1))) ;; Why doesn't append! work?

(define (solution3 x)
  (define (iter i n)
    (cond ((= i 1) n)
          ((or (= 0 (modulo i 3))
               (= 0 (modulo i 5)))
           (iter (- i 1) (+ i n)))
          (else (iter (- i 1) n))))

  (iter (- x 1) 0))

(define (matt-test)
  (display (solution 1000))
  (newline)
  (display (solution2 1000))
  (newline)
  (display (solution3 1000))
  (newline))
