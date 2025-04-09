.data
    listInput: .string " ADD(a) ~ ADD(B) ~ DEL(xx) ~PRINT~SO RT~BAD~ADD (a)"
    commandBuffer: .space 64      # spazio per contenere singolo comando

.text
    la t0, listInput        # t0 -> stringa
    la t1, commandBuffer    # t1 -> buffer
    li t2, 0                # t2 -> flag "in comando"
    
parse_loop:
    lbu t3, 0(t0)
    beq t3, zero, parse_end

    li t4, 32               # valore di space    
    beq t3, t4, skip_space  # ignora spazi esterni

    li t4, '~'
    beq t3, t4, handle_tilde

    # controllo: se c'è spazio nel mezzo, comando invalido
    li t4, 32                       # valore di space
    beq t3, t4, invalid_command

    sb t3, 0(t1)
    addi t1, t1, 1
    addi t0, t0, 1
    j parse_loop

skip_space:
    addi t0, t0, 1
    j parse_loop

handle_tilde:
    li t4, 0
    sb t4, 0(t1)         # null-terminate comando
    la a0, commandBuffer
    jal parse_command    # validazione comando

    addi t0, t0, 1       # skip tilde
    la t1, commandBuffer
    j skip_space         # salta anche eventuali spazi dopo tilde

invalid_command:
    # scarta fino a prossimo ~
wait_tilde:
    lbu t3, 0(t0)
    beqz t3, parse_end
    li t4, '~'
    beq t3, t4, reset_buffer
    addi t0, t0, 1
    j wait_tilde

reset_buffer:
    addi t0, t0, 1
    la t1, commandBuffer
    j parse_loop

parse_end:
    li a7, 10
    ecall

#######################################################
# parse_command — controlla e smista il comando
#######################################################
parse_command:
    # controllo se inizia con "ADD("
    la t2, commandBuffer
    lb t3, 0(t2)
    lb t4, 1(t2)
    lb t5, 2(t2)

    li t6, 'A'
    bne t3, t6, check_del
    li t6, 'D'
    bne t4, t6, check_del
    li t6, 'D'
    bne t5, t6, check_del

    lb t6, 3(t2)
    li t7, '('
    bne t6, t7, invalid

    lb t6, 4(t2)         # carattere parametro
    lb t7, 5(t2)
    li t8, ')'
    bne t7, t8, invalid

    lb t9, 6(t2)
    bnez t9, invalid     # dopo ')' deve esserci null

    # comando valido: chiama handle_add
    jal handle_add
    ret

check_del:
    li t6, 'D'
    bne t3, t6, check_print
    li t6, 'E'
    bne t4, t6, check_print
    li t6, 'L'
    bne t5, t6, check_print

    lb t6, 3(t2)
    li t7, '('
    bne t6, t7, invalid

    lb t6, 4(t2)
    lb t7, 5(t2)
    li t8, ')'
    bne t7, t8, invalid

    lb t9, 6(t2)
    bnez t9, invalid

    jal handle_del
    ret

check_print:
    lb t3, 0(t2)
    li t4, 'P'
    bne t3, t4, invalid
    lb t3, 1(t2)
    li t4, 'R'
    bne t3, t4, invalid
    lb t3, 2(t2)
    li t4, 'I'
    bne t3, t4, invalid
    lb t3, 3(t2)
    li t4, 'N'
    bne t3, t4, invalid
    lb t3, 4(t2)
    li t4, 'T'
    bne t3, t4, invalid
    lb t3, 5(t2)
    bnez t3, invalid     # dopo T deve esserci null

    jal handle_print
    ret

invalid:
    # comando malformattato ? ignorato
    ret

#######################################################
# Stub delle procedure vere
#######################################################

handle_add:
    # azione finta per ADD
    li a7, 1
    li a0, 100
    ecall
    ret

handle_del:
    li a7, 1
    li a0, 200
    ecall
    ret

handle_print:
    li a7, 1
    li a0, 300
    ecall
    ret
