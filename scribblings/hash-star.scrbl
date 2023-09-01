#lang scribble/manual
@require[@for-label[hash-star
                    racket/base
                    racket/function]]

@(begin (require scribble/eval)
        (define ev (make-base-eval))
        (ev '(require hash-star racket/function)))

@title{hash-star}
@author[(author+email "Lucas Sta Maria" "lucas@priime.dev")]

@defmodule[hash-star]

This package provides additional functions for interacting with hash
tables, specifically nested hash tables.

@defproc[(hash-ref* [ht hash?]
                    [key any/c] ...
                    [#:else default (or/c procedure? #f) #f])
         any]{

Traverses through the given hash table @racket{ht} with the
@racket{key}s in order. If at any point, a key isn't contained in a
traversed hash table, or traversal cannot progress because a value
wasn't a hash table, the function will error. A default value or
substitute error can replace the default error by passing in a lambda
into the @racket{#:else} keyword.

@examples[#:eval ev
  (hash-ref* (hash 'a 5))

  (hash-ref* (hash 'a 5) 'a)

  (hash-ref* (hash 'a (hash 'b 6)) 'a)

  (hash-ref* (hash 'a (hash 'b 6)) 'a 'b)

  (hash-ref* (hash 'a (hash 'b 6)) 'a 'b 'c)

  (hash-ref* (hash 'a (hash 'b 6))
             'a 'b 'c
             #:else (thunk #f))
]
}
