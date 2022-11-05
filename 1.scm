(define (solution x)
  (apply +
         (filter (λ (x) (or (= 0 (remainder x 3))
                            (= 0 (remainder x 5))))
                 (map (λ (x) (+ 1 x))
                      (cdr (iota (- x 1)))))))


(define (solution2 x)
  (define (iter i ll)
    (if (= i 1)
        (apply + ll)
        (cond ((or (= 0 (modulo i 3))
                   (= 0 (modulo i 5)))
               (iter (- i 1)
                     (cons i ll)))
              (else (iter (- i 1) ll)))))

  (iter (- x 1) '()))

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

(define reps 100000)
(load "Matt.scm")
(define (bench)
  (echo "solution:"
        (cadr (mattbench2 (λ()
                            (solution 1000))
                          reps)))
  (echo "solution2:"
        (cadr (mattbench2 (λ()
                            (solution2 1000))
                          reps)))
  (echo "solution3:"
        (cadr (mattbench2 (λ()
                            (solution3 1000))
                          reps))))

;; solution: 239776.73923
;; solution2: 67562.9544
;; solution3: 24972.63739

;; Solution 3's simple iterative solution far outpaces the competition,
;; especially the high-abstraction model used in solution 1.
