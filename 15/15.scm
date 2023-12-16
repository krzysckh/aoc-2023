(import
 (owl regex)
 (owl lazy))

(define input
  ((string->regex "c/,/")
   (foldr string-append "" (force-ll (lines (open-input-file "./in"))))))

(define (hash s acc)
  (cond
   ((string=? s "") acc)
   (else
    (let ((c (car (string->list s))))
      (hash
       (substring s 1 (string-length s))
       (modulo (* (+ acc c) 17) 256))))))
         
(define (put-boxes in acc)
  (cond
   ((null? in) acc)
   (else
    (let* ((_str (list->string ((string->regex "g/^(.*)(?=.$)/") (car in))))
           (n (- (last (string->list (car in)) -1) #\0))
           (op (if (has? (string->list (car in)) #\=) #\= #\-))
           (str (if (eq? op #\=) (substring _str 0 (- (string-length _str) 1)) _str)) ; quality code
           (bn (hash str 0)))
      (if (eq? op #\=)
          (put-boxes
           (cdr in)
           (map
            (lambda (v)
              (if (eq? (car v) bn)
                  (if (has? (map car (cdr v)) str)
                      `(,(car v) . ,(map (lambda (V) (if (string=? (car V) str)
                                                    `(,(car V) ,n)
                                                    V)) (cdr v)))

                      (append v `(,(list str n))))
                  v)) acc))
          (put-boxes
           (cdr in)
           (map
            (lambda (v)
              (if (eq? (car v) bn)
                  `(,(car v) . ,(filter (lambda (V) (not (string=? str (car V)))) (cdr v)))
                  v)) acc)))))))

(define (calc-power l)
  (sum
   (map (lambda (v)
          (sum (map (lambda (c) (* (+ (car v) 1) c (cadr (list-ref (cdr v) (- c 1)))))
                    (iota 1 1 (+ 1 (length (cdr v))))))) l)))

(print "p1: " (sum (map (lambda (v) (hash v 0)) input)))
(print "p2: " (calc-power (put-boxes input (map (lambda (v) `(,v)) (iota 0 1 256)))))
