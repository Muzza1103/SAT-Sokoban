(define (domain sokoban)
  (:requirements :strips :typing :negative-preconditions :quantified-preconditions)

  (:types player box cell)

  (:predicates
    (at-player ?p - player ?c - cell)
    (at-box ?b - box ?c - cell)

    (adj-right ?c1 ?c2 - cell)
    (adj-down ?c1 ?c2 - cell)

    (wall ?c - cell)

    (goal ?c - cell)
  )

  ;; ================= MOVE RIGHT =================

  (:action move-right
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
        (at-player ?p ?from)
        (adj-right ?from ?to)
        (not (wall ?to))
        (not (exists (?b - box) (at-box ?b ?to)))
    )
    :effect (and
        (not (at-player ?p ?from))
        (at-player ?p ?to)
    )
  )

  ;; ================= MOVE LEFT =================
  ;; utilise adj-right inversé

  (:action move-left
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
        (at-player ?p ?from)
        (adj-right ?to ?from)
        (not (wall ?to))
        (not (exists (?b - box) (at-box ?b ?to)))
    )
    :effect (and
        (not (at-player ?p ?from))
        (at-player ?p ?to)
    )
  )

  ;; ================= MOVE DOWN =================

  (:action move-down
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
        (at-player ?p ?from)
        (adj-down ?from ?to)
        (not (wall ?to))
        (not (exists (?b - box) (at-box ?b ?to)))
    )
    :effect (and
        (not (at-player ?p ?from))
        (at-player ?p ?to)
    )
  )

  ;; ================= MOVE UP =================
  ;; utilise adj-down inversé

  (:action move-up
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
        (at-player ?p ?from)
        (adj-down ?to ?from)
        (not (wall ?to))
        (not (exists (?b - box) (at-box ?b ?to)))
    )
    :effect (and
        (not (at-player ?p ?from))
        (at-player ?p ?to)
    )
  )

  ;; ================= PUSH RIGHT =================

  (:action push-right
    :parameters (?p - player ?b - box ?c1 ?c2 ?c3 - cell)
    :precondition (and
        (at-player ?p ?c1)
        (adj-right ?c1 ?c2)
        (adj-right ?c2 ?c3)
        (at-box ?b ?c2)
        (not (wall ?c3))
        (not (exists (?b2 - box) (at-box ?b2 ?c3)))
    )
    :effect (and
        (not (at-player ?p ?c1))
        (at-player ?p ?c2)
        (not (at-box ?b ?c2))
        (at-box ?b ?c3)
    )
  )

  ;; ================= PUSH LEFT =================
  ;; inverse adj-right

  (:action push-left
    :parameters (?p - player ?b - box ?c1 ?c2 ?c3 - cell)
    :precondition (and
        (at-player ?p ?c1)
        (adj-right ?c2 ?c1)
        (adj-right ?c3 ?c2)
        (at-box ?b ?c2)
        (not (wall ?c3))
        (not (exists (?b2 - box) (at-box ?b2 ?c3)))
    )
    :effect (and
        (not (at-player ?p ?c1))
        (at-player ?p ?c2)
        (not (at-box ?b ?c2))
        (at-box ?b ?c3)
    )
  )

  ;; ================= PUSH DOWN =================

  (:action push-down
    :parameters (?p - player ?b - box ?c1 ?c2 ?c3 - cell)
    :precondition (and
        (at-player ?p ?c1)
        (adj-down ?c1 ?c2)
        (adj-down ?c2 ?c3)
        (at-box ?b ?c2)
        (not (wall ?c3))
        (not (exists (?b2 - box) (at-box ?b2 ?c3)))
    )
    :effect (and
        (not (at-player ?p ?c1))
        (at-player ?p ?c2)
        (not (at-box ?b ?c2))
        (at-box ?b ?c3)
    )
  )

  ;; ================= PUSH UP =================
  ;; inverse adj-down

  (:action push-up
    :parameters (?p - player ?b - box ?c1 ?c2 ?c3 - cell)
    :precondition (and
        (at-player ?p ?c1)
        (adj-down ?c2 ?c1)
        (adj-down ?c3 ?c2)
        (at-box ?b ?c2)
        (not (wall ?c3))
        (not (exists (?b2 - box) (at-box ?b2 ?c3)))
    )
    :effect (and
        (not (at-player ?p ?c1))
        (at-player ?p ?c2)
        (not (at-box ?b ?c2))
        (at-box ?b ?c3)
    )
  )
)