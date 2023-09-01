#lang racket/base

(require (only-in racket/contract/base
                  contract-out
                  ->*
                  any/c
                  any
                  or/c
                  listof))

(provide
 (contract-out
  #:unprotected-submodule no-contract
  [hash-ref*
   (->* (hash?)
        (#:else (or/c procedure? #f))
        #:rest (listof any/c)
        any)]))

(define (hash-ref*-error key layer)
  (error 'hash-ref*
         "no value found for key ~v that is ~s layers deep"
         key
         layer))

;; Traverse nested hashtables with the given keys, defaulting to the
;; given `default` function if the keys don't exist.
(define (hash-ref* ht #:else [default #f] . keys)
  (for/fold ([ht^ ht])
            ([key keys]
             [layer (in-naturals)])
    (cond [(and (hash? ht^)
                (hash-has-key? ht^ key))
           (hash-ref ht^ key)]
          [default (default)]
          [else (hash-ref*-error key layer)])))

(module+ test
  (require rackunit)
  (require (only-in racket/function
                    thunk)))

(module+ test
  (test-equal?
   "empty hash, no passed keys"
   (hash-ref* (hash))
   (hash))

  (test-equal?
   "simple hash, no passed keys"
   (hash-ref* (hash 'a 5 'b 6))
   (hash 'a 5 'b 6))

  (test-equal?
   "simple hash, good passed key"
   (hash-ref* (hash 'a 5 'b 6) 'a)
   5)

  (test-equal?
   "complex hash, good passed key"
   (hash-ref* (hash 'a (hash 'b 3)) 'a)
   (hash 'b 3))

  (test-equal?
   "complex hash, good passed keys"
   (hash-ref* (hash 'a (hash 'b 3)) 'a 'b)
   3)

  (test-equal?
   "simple hash, passed keys and default #f"
   (hash-ref* (hash 'a 5 'b 6)
              'a 'b
              #:else (thunk #f))
   #f)

  (test-equal?
   "simple hash, passed keys and default 5"
   (hash-ref* (hash 'a 5 'b 6)
              'a 'b
              #:else (thunk 5))
   5)

  (test-equal?
   "complex hash, passed keys and default #f"
   (hash-ref* (hash 'a (hash 'b 5))
              'a 'c
              #:else (thunk #f))
   #f)

  (test-equal?
   "complex hash, passed keys and default 2"
   (hash-ref* (hash 'a (hash 'b 5))
              'a 'b 'c
              #:else (thunk 2))
   2)

  (test-exn
   "empty hash, key not contained"
   exn:fail?
   (thunk (hash-ref* (hash) 'a)))

  (test-exn
   "simple hash, key not contained"
   exn:fail?
   (thunk (hash-ref* (hash 'a 5) 'b)))

  (test-exn
   "simple hash, keys not contained"
   exn:fail?
   (thunk (hash-ref* (hash 'a 5) 'a 'b)))

  (test-exn
   "complex hash, keys not contained"
   exn:fail?
   (thunk (hash-ref* (hash 'a (hash 'b 6))
                     'a 'c)))

  (test-exn
   "complex hash, deeper keys not contained"
   exn:fail?
   (thunk (hash-ref* (hash' (hash'b 5))
                     'a 'b 'c))))
