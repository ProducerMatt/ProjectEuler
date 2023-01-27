;;     A keyboard has 3 broken keys.
;;     - None of the keys leave the letter they're supposed to.
;;     - One deletes the character before it.
;;     - One deletes two characters before it.
;;     - One deletes 3 characters before it.
;;
;;     Given a scrambled phrase, which keys were broken?

(use-srfis '(1))
(define P0-O "Blood is thicker than water")
(define P0-X "Bloos er water")
(define P0-K "KIN")

;; keys : list of broken keys, from least to most deletions
;; plaintext : unscrambled text
;(define (BrokenKeyboard keys plaintext) "ciphertext")
(define (BrokenKeyboard keys plaintext)
  (define kv
    (fold-right (lambda(char rest)
                  (if (null? rest)
                      (list (cons char (string-length keys)))
                      (cons (cons char (1- (cdar rest)))
                            rest)))
                '() (string->list keys)))
  (define (lookup char)
    (assq-ref kv char))
  (fold-right (lambda(char rest)
                (let ((k (lookup char)))
                  (if k
                      (if (< k (length rest))
                          (list-tail rest (1- k))
                          '())
                      (cons char rest))))
              '() (string->list plaintext)))

(define P1-O "Why did the chicken cross the road? To get to the other side")
(define P1-X "y d cros road?  Tot tr s")

;(define (BrokenKeyboard keys plaintext)
;  (define kv
;    (string-fold-right (lambda(k rest)
;            (if (null? rest)
;                (list (cons k 1))
;                  (append (list (cons k (1+ (cdar rest)))))))
;          '() keys))
;  (define (kons char rest)
;    (cond ((null? rest) (cons char '()))
;          (())
;  (string-fold-right (lambda(char rest)()) "" plaintext))
