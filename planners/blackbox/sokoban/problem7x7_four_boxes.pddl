(define (problem sokoban7x7_four_boxes)
  (:domain sokoban)

  (:objects
    p1 - player
    b1 b2 b3 b4 - box

    c1 c2 c3 c4 c5 c6 c7
    c8 c9 c10 c11 c12 c13 c14
    c15 c16 c17 c18 c19 c20 c21
    c22 c23 c24 c25 c26 c27 c28
    c29 c30 c31 c32 c33 c34 c35
    c36 c37 c38 c39 c40 c41 c42
    c43 c44 c45 c46 c47 c48 c49
    - cell
  )

  (:init
    ;; Player
    (at-player p1 c1)

    ;; Boxes
    (at-box b1 c16)
    (at-box b2 c19)
    (at-box b3 c30)
    (at-box b4 c33)

    ;; Walls (optionnel)
    (wall c8) (wall c9)
    (wall c11) (wall c12)
    (wall c24)
    (wall c39)

    ;; CLEAR
    (clear c1) (clear c2) (clear c3) (clear c4) (clear c5) (clear c6) (clear c7)
    (clear c10) (clear c13) (clear c14)
    (clear c15) (clear c17) (clear c18) (clear c20) (clear c21)
    (clear c22) (clear c23) (clear c25) (clear c26) (clear c27) (clear c28)
    (clear c29) (clear c31) (clear c32) (clear c34) (clear c35)
    (clear c36) (clear c37) (clear c38) (clear c40) (clear c41) (clear c42)
    (clear c43) (clear c44) (clear c45) (clear c46) (clear c47) (clear c48) (clear c49)

    ;; ================= ADJ-RIGHT =================
    (adj-right c1 c2) (adj-right c2 c3)
    (adj-right c3 c4) (adj-right c4 c5)
    (adj-right c5 c6) (adj-right c6 c7)

    (adj-right c8 c9) (adj-right c9 c10)
    (adj-right c10 c11) (adj-right c11 c12)
    (adj-right c12 c13) (adj-right c13 c14)

    (adj-right c15 c16) (adj-right c16 c17)
    (adj-right c17 c18) (adj-right c18 c19)
    (adj-right c19 c20) (adj-right c20 c21)

    (adj-right c22 c23) (adj-right c23 c24)
    (adj-right c24 c25) (adj-right c25 c26)
    (adj-right c26 c27) (adj-right c27 c28)

    (adj-right c29 c30) (adj-right c30 c31)
    (adj-right c31 c32) (adj-right c32 c33)
    (adj-right c33 c34) (adj-right c34 c35)

    (adj-right c36 c37) (adj-right c37 c38)
    (adj-right c38 c39) (adj-right c39 c40)
    (adj-right c40 c41) (adj-right c41 c42)

    (adj-right c43 c44) (adj-right c44 c45)
    (adj-right c45 c46) (adj-right c46 c47)
    (adj-right c47 c48) (adj-right c48 c49)

    ;; ================= ADJ-DOWN =================
    (adj-down c1 c8) (adj-down c8 c15)
    (adj-down c15 c22) (adj-down c22 c29)
    (adj-down c29 c36) (adj-down c36 c43)

    (adj-down c2 c9) (adj-down c9 c16)
    (adj-down c16 c23) (adj-down c23 c30)
    (adj-down c30 c37) (adj-down c37 c44)

    (adj-down c3 c10) (adj-down c10 c17)
    (adj-down c17 c24) (adj-down c24 c31)
    (adj-down c31 c38) (adj-down c38 c45)

    (adj-down c4 c11) (adj-down c11 c18)
    (adj-down c18 c25) (adj-down c25 c32)
    (adj-down c32 c39) (adj-down c39 c46)

    (adj-down c5 c12) (adj-down c12 c19)
    (adj-down c19 c26) (adj-down c26 c33)
    (adj-down c33 c40) (adj-down c40 c47)

    (adj-down c6 c13) (adj-down c13 c20)
    (adj-down c20 c27) (adj-down c27 c34)
    (adj-down c34 c41) (adj-down c41 c48)

    (adj-down c7 c14) (adj-down c14 c21)
    (adj-down c21 c28) (adj-down c28 c35)
    (adj-down c35 c42) (adj-down c42 c49)
  )

  (:goal
    (and
      (at-box b1 c46)
      (at-box b2 c47)
      (at-box b3 c48)
      (at-box b4 c49)
    )
  )
)