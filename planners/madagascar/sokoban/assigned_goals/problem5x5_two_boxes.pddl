(define (problem sokoban5x5_two_boxes_harder)
  (:domain sokoban)

  (:objects
    p1 - player
    b1 b2 - box

    c1 c2 c3 c4 c5
    c6 c7 c8 c9 c10
    c11 c12 c13 c14 c15
    c16 c17 c18 c19 c20
    c21 c22 c23 c24 c25
    - cell
  )

  (:init

    ;; Positions initiales
    (at-player p1 c1)
    (at-box b1 c7)
    (at-box b2 c13)

    ;; WALLS
    (wall c6)
    (wall c8)
    (wall c17)

    ;; ADJ-RIGHT
    (adj-right c1 c2) (adj-right c2 c3) (adj-right c3 c4) (adj-right c4 c5)
    (adj-right c6 c7) (adj-right c7 c8) (adj-right c8 c9) (adj-right c9 c10)
    (adj-right c11 c12) (adj-right c12 c13) (adj-right c13 c14) (adj-right c14 c15)
    (adj-right c16 c17) (adj-right c17 c18) (adj-right c18 c19) (adj-right c19 c20)
    (adj-right c21 c22) (adj-right c22 c23) (adj-right c23 c24) (adj-right c24 c25)

    ;; ADJ-DOWN
    (adj-down c1 c6) (adj-down c2 c7) (adj-down c3 c8) (adj-down c4 c9) (adj-down c5 c10)
    (adj-down c6 c11) (adj-down c7 c12) (adj-down c8 c13) (adj-down c9 c14) (adj-down c10 c15)
    (adj-down c11 c16) (adj-down c12 c17) (adj-down c13 c18) (adj-down c14 c19) (adj-down c15 c20)
    (adj-down c16 c21) (adj-down c17 c22) (adj-down c18 c23) (adj-down c19 c24) (adj-down c20 c25)
  )

  (:goal
    (and
      (at-box b1 c24)
      (at-box b2 c25)
    )
  )
)