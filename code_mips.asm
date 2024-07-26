main:   addi $3, $0, 1
        add  $5, $0, $3
        sub  $7, $5, $3
        addi $4, $3, 4
        and  $2, $3, $4
        or   $5, $2, $7
To:     beq  $7, $3, next
		nop
		nop
        slt  $2, $4, $5
        sw   $4, 8151($4)
        lw   $2, 8155($5)
        nop
        addi $7, $2, -4
        j    To
        nop
        nop
next:   slt  $4, $7, $2
        and  $2, $7, $3
        lw   $7, 8155($2)
        sw   $5, 8195($2)
        beq  $5, $7, end
        or   $7, $5, $3
end:    lw  $4, 8195($7)
		nop
        j    main

