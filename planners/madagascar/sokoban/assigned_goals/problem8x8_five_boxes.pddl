(define (problem sokoban8x8_five_boxes)
  (:domain sokoban)

  (:objects
    p1 - player
    b1 b2 b3 b4 b5 - box

    c1 c2 c3 c4 c5 c6 c7 c8
    c9 c10 c11 c12 c13 c14 c15 c16
    c17 c18 c19 c20 c21 c22 c23 c24
    c25 c26 c27 c28 c29 c30 c31 c32
    c33 c34 c35 c36 c37 c38 c39 c40
    c41 c42 c43 c44 c45 c46 c47 c48
    c49 c50 c51 c52 c53 c54 c55 c56
    c57 c58 c59 c60 c61 c62 c63 c64
    - cell
  )

  (:init

    ;; PLAYER
    (at-player p1 c1)

    ;; BOXES
    (at-box b1 c18)
    (at-box b2 c21)
    (at-box b3 c28)
    (at-box b4 c34)
    (at-box b5 c37)

    ;; WALLS
    (wall c9) (wall c10)
    (wall c12) (wall c13)
    (wall c27)
    (wall c44)

    ;; ================= ADJ-RIGHT =================

    ;; Ligne 1
    (adj-right c1 c2) (adj-right c2 c3) (adj-right c3 c4)
    (adj-right c4 c5) (adj-right c5 c6) (adj-right c6 c7)
    (adj-right c7 c8)

    ;; Ligne 2
    (adj-right c9 c10) (adj-right c10 c11) (adj-right c11 c12)
    (adj-right c12 c13) (adj-right c13 c14) (adj-right c14 c15)
    (adj-right c15 c16)

    ;; Ligne 3
    (adj-right c17 c18) (adj-right c18 c19) (adj-right c19 c20)
    (adj-right c20 c21) (adj-right c21 c22) (adj-right c22 c23)
    (adj-right c23 c24)

    ;; Ligne 4
    (adj-right c25 c26) (adj-right c26 c27) (adj-right c27 c28)
    (adj-right c28 c29) (adj-right c29 c30) (adj-right c30 c31)
    (adj-right c31 c32)

    ;; Ligne 5
    (adj-right c33 c34) (adj-right c34 c35) (adj-right c35 c36)
    (adj-right c36 c37) (adj-right c37 c38) (adj-right c38 c39)
    (adj-right c39 c40)

    ;; Ligne 6
    (adj-right c41 c42) (adj-right c42 c43) (adj-right c43 c44)
    (adj-right c44 c45) (adj-right c45 c46) (adj-right c46 c47)
    (adj-right c47 c48)

    ;; Ligne 7
    (adj-right c49 c50) (adj-right c50 c51) (adj-right c51 c52)
    (adj-right c52 c53) (adj-right c53 c54) (adj-right c54 c55)
    (adj-right c55 c56)

    ;; Ligne 8
    (adj-right c57 c58) (adj-right c58 c59) (adj-right c59 c60)
    (adj-right c60 c61) (adj-right c61 c62) (adj-right c62 c63)
    (adj-right c63 c64)

    ;; ================= ADJ-DOWN =================

    ;; Colonne 1
    (adj-down c1 c9) (adj-down c9 c17) (adj-down c17 c25)
    (adj-down c25 c33) (adj-down c33 c41) (adj-down c41 c49)
    (adj-down c49 c57)

    ;; Colonne 2
    (adj-down c2 c10) (adj-down c10 c18) (adj-down c18 c26)
    (adj-down c26 c34) (adj-down c34 c42) (adj-down c42 c50)
    (adj-down c50 c58)

    ;; Colonne 3
    (adj-down c3 c11) (adj-down c11 c19) (adj-down c19 c27)
    (adj-down c27 c35) (adj-down c35 c43) (adj-down c43 c51)
    (adj-down c51 c59)

    ;; Colonne 4
    (adj-down c4 c12) (adj-down c12 c20) (adj-down c20 c28)
    (adj-down c28 c36) (adj-down c36 c44) (adj-down c44 c52)
    (adj-down c52 c60)

    ;; Colonne 5
    (adj-down c5 c13) (adj-down c13 c21) (adj-down c21 c29)
    (adj-down c29 c37) (adj-down c37 c45) (adj-down c45 c53)
    (adj-down c53 c61)

    ;; Colonne 6
    (adj-down c6 c14) (adj-down c14 c22) (adj-down c22 c30)
    (adj-down c30 c38) (adj-down c38 c46) (adj-down c46 c54)
    (adj-down c54 c62)

    ;; Colonne 7
    (adj-down c7 c15) (adj-down c15 c23) (adj-down c23 c31)
    (adj-down c31 c39) (adj-down c39 c47) (adj-down c47 c55)
    (adj-down c55 c63)

    ;; Colonne 8
    (adj-down c8 c16) (adj-down c16 c24) (adj-down c24 c32)
    (adj-down c32 c40) (adj-down c40 c48) (adj-down c48 c56)
    (adj-down c56 c64)
  )

  (:goal
    (and
      (at-box b1 c63)
      (at-box b2 c64)
      (at-box b3 c62)
      (at-box b4 c60)
      (at-box b5 c61)
    )
  )
)