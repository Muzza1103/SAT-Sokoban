(define (domain sokoban)
  (:requirements :strips :typing)

  (:types player box cell)

  (:predicates
    (at-player ?p - player ?c - cell)
    (at-box ?b - box ?c - cell)

    (adj-right ?c1 ?c2 - cell)
    (adj-down  ?c1 ?c2 - cell)

    ;; walls peuvent rester "statics" (pas utilisées dans les préconditions)
    (wall ?c - cell)

    ;; case libre et praticable (pas wall, pas box)
    (clear ?c - cell)
  )

  ;; ================= MOVE RIGHT =================
  (:action move-right
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
      (at-player ?p ?from)
      (adj-right ?from ?to)
      (clear ?to)
    )
    :effect (and
      (not (at-player ?p ?from))
      (at-player ?p ?to)
    )
  )

  ;; ================= MOVE LEFT =================
  (:action move-left
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
      (at-player ?p ?from)
      (adj-right ?to ?from)
      (clear ?to)
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
      (clear ?to)
    )
    :effect (and
      (not (at-player ?p ?from))
      (at-player ?p ?to)
    )
  )

  ;; ================= MOVE UP =================
  (:action move-up
    :parameters (?p - player ?from ?to - cell)
    :precondition (and
      (at-player ?p ?from)
      (adj-down ?to ?from)
      (clear ?to)
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
      (clear ?c3)
    )
    :effect (and
      (not (at-player ?p ?c1))
      (at-player ?p ?c2)

      (not (at-box ?b ?c2))
      (at-box ?b ?c3)

      (clear ?c2)
      (not (clear ?c3))
    )
  )

  ;; ================= PUSH LEFT =================
  (:action push-left
    :parameters (?p - player ?b - box ?c1 ?c2 ?c3 - cell)
    :precondition (and
      (at-player ?p ?c1)
      (adj-right ?c2 ?c1)
      (adj-right ?c3 ?c2)
      (at-box ?b ?c2)
      (clear ?c3)
    )
    :effect (and
      (not (at-player ?p ?c1))
      (at-player ?p ?c2)

      (not (at-box ?b ?c2))
      (at-box ?b ?c3)

      (clear ?c2)
      (not (clear ?c3))
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
      (clear ?c3)
    )
    :effect (and
      (not (at-player ?p ?c1))
      (at-player ?p ?c2)

      (not (at-box ?b ?c2))
      (at-box ?b ?c3)

      (clear ?c2)
      (not (clear ?c3))
    )
  )

  ;; ================= PUSH UP =================
  (:action push-up
    :parameters (?p - player ?b - box ?c1 ?c2 ?c3 - cell)
    :precondition (and
      (at-player ?p ?c1)
      (adj-down ?c2 ?c1)
      (adj-down ?c3 ?c2)
      (at-box ?b ?c2)
      (clear ?c3)
    )
    :effect (and
      (not (at-player ?p ?c1))
      (at-player ?p ?c2)

      (not (at-box ?b ?c2))
      (at-box ?b ?c3)

      (clear ?c2)
      (not (clear ?c3))
    )
  )
)