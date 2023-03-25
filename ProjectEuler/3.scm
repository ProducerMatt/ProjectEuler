;; What is the largest prime factor of the number 600851475143 ?

(define (get-answer) (last-pair (factor-tree-rec 600851475143)))
(define (factor-tree x)
  (define half-x (truncate (/ x 2)))
  (define ii 100)
  ;; take a number, return a list of prime factors
  (reverse!
   (let iter ((low 2)
              (ll '()))
     (let* ((nl (cons low ll))
            (try (apply * nl)))
     (if (= ii 0)
         nl
       (begin (set! ii (1- ii))
              (cond ((> try x)
              (if (> low half-x)
                  (let ((last-good (car ll)))
                    (iter (find-next-prime last-good)
                          (cdr ll)))
                  (iter (find-next-prime low)
                        ll)))
             ((= try x) nl)
             ((< try x)
              (iter low nl)))))))))
(define (factor-tree-rec x)
   (let rec ((x x))
     (let ((divisor (smallest-divisor x)))
       (if (= x divisor)
           (cons x '())
           (append (cons divisor '())
                   (rec (/ x divisor)))))))
(define (find-next-prime x)
  (if (= x 2)
      3
      (let iter ((next-try (+ 2 x)))
        (if (prime? next-try)
            next-try
            (iter (+ 2 next-try))))))

(define (square x)
  (* x x))
;; square ends here
(define (smallest-divisor n)
  (if (divides? 2 n)                  ;; check for division by 2
      2
      (find-divisor n 3)))            ;; start find-divisor at 3

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n)
         n)
        ((divides? test-divisor n)
         test-divisor)
        (else (find-divisor
               n
               (+ 2 test-divisor))))) ;; just increase by 2

(define (divides? a b)
  (= (remainder b a) 0))
;; find-divisor-faster-real2 ends here
(define (prime? n)
  (= n (smallest-divisor n)))
