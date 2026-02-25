(define (problem sokoban6x6_three_boxes)
  (:domain sokoban)

  (:objects
    p1 - player
    b1 b2 b3 - box

    c1 c2 c3 c4 c5 c6
    c7 c8 c9 c10 c11 c12
    c13 c14 c15 c16 c17 c18
    c19 c20 c21 c22 c23 c24
    c25 c26 c27 c28 c29 c30
    c31 c32 c33 c34 c35 c36
    - cell
  )

  (:init

    ;; Player
    (at-player p1 c1)

    ;; Boxes
    (at-box b1 c14)
    (at-box b2 c17)
    (at-box b3 c26)

    ;; Walls
    (wall c7) (wall c8)
    (wall c10) (wall c21)

    ;; ================= ADJACENCY =================

    ;; Horizontal adj-right
    (adj-right c1 c2) (adj-right c2 c3) (adj-right c3 c4)
    (adj-right c4 c5) (adj-right c5 c6)

    (adj-right c7 c8) (adj-right c8 c9)
    (adj-right c9 c10) (adj-right c10 c11)
    (adj-right c11 c12)

    (adj-right c13 c14) (adj-right c14 c15)
    (adj-right c15 c16) (adj-right c16 c17)
    (adj-right c17 c18)

    (adj-right c19 c20) (adj-right c20 c21)
    (adj-right c21 c22) (adj-right c22 c23)
    (adj-right c23 c24)

    (adj-right c25 c26) (adj-right c26 c27)
    (adj-right c27 c28) (adj-right c28 c29)
    (adj-right c29 c30)

    (adj-right c31 c32) (adj-right c32 c33)
    (adj-right c33 c34) (adj-right c34 c35)
    (adj-right c35 c36)

    ;; Vertical adj-down
    (adj-down c1 c7) (adj-down c2 c8)
    (adj-down c3 c9) (adj-down c4 c10)
    (adj-down c5 c11) (adj-down c6 c12)

    (adj-down c7 c13) (adj-down c8 c14)
    (adj-down c9 c15) (adj-down c10 c16)
    (adj-down c11 c17) (adj-down c12 c18)

    (adj-down c13 c19) (adj-down c14 c20)
    (adj-down c15 c21) (adj-down c16 c22)
    (adj-down c17 c23) (adj-down c18 c24)

    (adj-down c19 c25) (adj-down c20 c26)
    (adj-down c21 c27) (adj-down c22 c28)
    (adj-down c23 c29) (adj-down c24 c30)

    (adj-down c25 c31) (adj-down c26 c32)
    (adj-down c27 c33) (adj-down c28 c34)
    (adj-down c29 c35) (adj-down c30 c36)
  )

  (:goal
    (and
      (at-box b1 c34)
      (at-box b2 c35)
      (at-box b3 c36)
    )
  )
)