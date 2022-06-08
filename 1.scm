(define (problem x)
  (apply +
         (filter (λ (x) (or (= 0 (remainder x 3))
                            (= 0 (remainder x 5))))
                 (map (λ (x) (+ 1 x))
                      (cdr (iota (- x 1)))))))


(define (problem2 x)
  (define ll '())
  (define (iter i)
    (cond ((or (= 0 (modulo i 3))
               (= 0 (modulo i 5)))
           (append! ll i))
          ((> i 1) (iter (- i 1)))
          ((= i 1) (apply + ll))))

  (iter (- x 1))) ;; Why doesn't append! work?

(define (matt-test)
  (display (problem 1000))
  (newline)
  (display (problem2 1000))
  (newline))
