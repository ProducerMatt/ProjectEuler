;;     A keyboard has 3 broken keys.
;;     - None of the keys leave the letter they're supposed to.
;;     - One deletes the character before it.
;;     - One deletes two characters before it.
;;     - One deletes 3 characters before it.
;;
;;     Given a scrambled phrase, which keys were broken?

(use-srfis '(1))
(define P0-O "Blood is thicker than water")
(define P0-X "Bloos er  water")
(define P0-K "KIN")

;; keys : string of broken keys, from least to most deletions
;; plaintext : unscrambled text
                                        ;(define (BrokenKeyboard keys plaintext) "ciphertext")
(define (BrokenKeyboard keys plaintext)
  (define (NextChar char weight rest)
    (cons (cons (char-upcase char) weight)
          (cons (cons (char-downcase char) weight)
                rest)))
  ;; kv turns keys into a list containing chars and # of deletes
  ;; "KIN" -> '((K . 1)(I . 2)(N . 3))
  ;; usable as hash table by assq
  (define kv
    (fold-right (lambda(char rest)
                  (if (null? rest)
                      (NextChar char (string-length keys) rest)
                      (NextChar char (1- (cdar rest)) rest)))
                '() (string->list keys)))
  (define (lookup char)
    (assoc-ref kv char))

  (list->string
   (reverse (fold (lambda(char rest)
                    (let ((k (lookup char)))
                      (if k
                          (if (< k (length rest))
                              (list-tail rest k)
                              '())
                          (cons char rest))))
                  '() (string->list plaintext)))))

(define (BruteForce plaintext-temp desiredCipher-temp)
  (define plaintext (string-upcase plaintext-temp))
  (define desiredCipher (string-upcase desiredCipher-temp))
  (define char1
    (let recurse ((i 0)
                  (l (string-length desiredCipher)))
      (case ((not (char=? (string-ref plaintext i)
                          (string-ref desiredCipher i)))
             (string-ref desiredCipher i))
        ((< i l) (recurse (1+ i) l))
        (else #f))))
  (define allchars (char-set->list
                    (char-set-intersection char-set:upper-case
                                           (char-set-difference (string->char-set plaintext)
                                                                (string->char-set desiredCipher)))))
  (define (cmap proc)
    (map proc allchars))
  (let* ((result
          (cmap
           (lambda(char2)
             (if (eqv? char1 char2)
                 (list 'skip char2)
                 (cmap
                  (lambda(char3)
                    (if (or (eqv? char1 char3)
                            (eqv? char2 char3))
                        (list 'skip char3)
                        (let* ((this-key (list->string (list char1 char2 char3)))
                               (attempt (BrokenKeyboard this-key plaintext)))
                          (if (string=? attempt desiredCipher)
                              (error "Key found! " this-key)
                              (list 'not-found this-key)))))))))))
    (with-output-to-file "./error-dump.txt"
      (lambda()
        (write result)))
    (error "Key not found! Failure written out. Charset: " allchars)))

(define P1-O (string-upcase "Why did the chicken cross the road? To get to the other side"))
(define P1-X (string-upcase "y d cros road?  Tot tr s"))

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
