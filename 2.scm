(define (solution target)
  (define (iter i x y sum)
    (cond ((>= x target) sum)
          ((even? x)
           (iter (1+ i)
                 (+ x y)
                 x
                 (+ x sum)))
          (else
           (iter (1+ i)
                 (+ x y)
                 x
                 sum))))
  (iter 2 2 1 2))
