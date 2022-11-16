;; What is the largest prime factor of the number 600851475143 ?

(define (prime-factors x)
  (define half (truncate (/ x 2)))
  (define (iter i ll)
    (cond ((>= i half) ll)
          ((prime? i))))
  (if (even? x)
      (iter 3 (list 2))
      (iter 3 '())))
