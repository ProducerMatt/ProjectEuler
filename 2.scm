;; fib list+target
(define (fib-lt target)
  (define (iter l)
    (if (>= (car l) target)
        (cdr l)
        (iter (cons
               (+ (cadr l)
                  (car l))
               l))))
  (iter '(2 1)))

(define (consider l)
  (define (iter i ll)
    (if (< (length ll) 2)
        i
        (iter (+ i (car ll))
              (cddr ll))))
  (iter 0
        (if (even? (length l))
            (cdr l)
            l)))
