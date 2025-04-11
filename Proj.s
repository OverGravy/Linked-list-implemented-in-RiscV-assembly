.data
    listInput: .string " DEL(b)~ AD D(a)~ADD(a)~"
    commandBuffer: .word 0, 0, 0, 0, 0, 0, 0, 0   # 8 parole = 32 byte     
    # DEBUG STRING
    add:   .string "ADD"
    del:   .string "DEL"
    sort:  .string "SORT"
    print: .string "PRINT"
    rev:   .string "REV"

.text

    la t0, listInput        # t0 -> stringa
    la t1, commandBuffer    # t1 -> buffer
    li t2, 0                # t2 -> flag "in comando"

parse_loop:
    lbu t3, 0(t0)
    beq t3, zero, parse_end   # raggiungo il fine stringa

    li t4, 126             # valore della tilde
    beq t3, t4, handle_tilde

    # caricamento nel buffer del carattere letto se non ci sono spazi nel mezzo
    sb t3, 0(t1)           # carcica il valore nel buffer 
    addi t1, t1, 1         # incrementa pointer command list
    addi t0, t0, 1         # incrementa pointer buffer
    j parse_loop

skip_space:
    addi t0, t0, 1         # incremento puntatore in list input
    j parse_loop

handle_tilde:
    li t4, 0
    sb t4, 0(t1)         # null-terminate comando
    la a0, commandBuffer # preparazione parametri per il passaggio alla procedura
    jal parse_command    # validazione comando

    la t1, commandBuffer  # resetto il buffer
    j skip_space         # salta anche eventuali spazi dopo tilde

wait_tilde:
    lbu t3, 0(t0)
    beq t3, zero, parse_end
    li t4, 126
    beq t3, t4, reset_buffer
    addi t0, t0, 1
    j wait_tilde

reset_buffer:
    addi t0, t0, 1
    la t1, commandBuffer   #set again the pointer to the beginning of the buffer
    j parse_loop

parse_end: # fine del programma
    li a7, 10
    ecall

#######################################################
# parse_command ? controlla e smista il comando
#######################################################
parse_command:

    # per via della chiamata annidata all'handle delle istruzioni
    addi sp, sp, -4     # spazio sullo stack
    sw ra, 0(sp)        # salvo il return address
    la t2, commandBuffer

parsing:
    lb t3, 0(t2)           # carico il primo carattere
    li t4, 32
    beq t3, t4, skip_space_parsing

    # check se inizia con A
    li t4, 65    
    beq t3, t4, check_ADD

    # check se inizia con D
    li t4, 68
    beq t3, t4, check_DEL

    # check se inizia con P
    li t4, 80
    beq t3, t4, check_PRINT

    # check se inizia con S
    li t4, 83
    beq t3, t4, check_SORT

    # check se inizia con R 
    li t4, 82
    beq t3, t4, check_REV 

    # comando a caso, invalido
    j invalid

skip_space_parsing:
    addi t2, t2, 1
    j parsing
    


check_ADD:
    #parte di debug
    lb t3, 1(t2)
    li t4, 68               # 'D'
    bne t3, t4, invalid     # check D
    lb t3, 2(t2)
    li t4, 68               # 'D'
    bne t3, t4, invalid     # check D
    lb t3, 3(t2)
    li t4, 40               # "("
    bne t3, t4, invalid     # check "("
    lb t3, 4(t2)
    li t4, 41               # ")"
    beq t3, t4, invalid     # nessun parametro, check ")"
    lb t3, 5(t2)
    bne t3, t4, invalid     # ci sono più parametri o è sbagliato qualcosa
    
    # il comando ? corretto chiamo la handle
    lb a1, 4(t2) 
    jal handle_add
    j ret_to_main

check_DEL:
    lb t3, 1(t2)
    li t4, 69               # 'E'
    bne t3, t4, invalid     # check E
    lb t3, 2(t2)
    li t4, 76               # 'L'
    bne t3, t4, invalid     # check L
    lb t3, 3(t2)
    li t4, 40               # "("
    bne t3, t4, invalid     # check "("
    lb t3, 4(t2)
    li t4, 41               # ")"
    beq t3, t4, invalid     # nessun parametro, check ")"
    lb t3, 5(t2)
    bne t3, t4, invalid     # ci sono pi? parametri o ? sbagliato qualcosa
    
    # il comando ? corretto chiamo la handle
    lb a1, 4(t2) 
    jal handle_del
    j ret_to_main       # return al main

check_PRINT:    
    # gestione del comando PRINT (da implementare)
    j ret_to_main

check_SORT:
    # gestione del comando SORT (da implementare)
    j ret_to_main

check_REV:
    # gestione del comando REV (da implementare)
    j ret_to_main

invalid:
    # comando malformattato -> ignorato
    ret

ret_to_main:
    lw ra, 0(sp)        # recupero il return address
    addi sp, sp, 4      # pulisco lo stack
    ret

#######################################################
# Stub delle procedure vere
#######################################################

handle_add:
    # azione debug per add
    li a7, 4
    la a0, add
    ecall
    li a7, 11
    li a0, 40
    ecall
    mv a0, a1
    ecall
    li a0, 41
    ecall
    
    # actual implementazione di ADD
    
    ret

handle_del:
    # azione debug per del
    li a7, 4
    la a0, del
    ecall
    li a7, 11
    li a0, 40
    ecall
    mv a0, a1
    ecall
    li a0, 41
    ecall
    
    # actual implementazione di DEL
    
    ret

handle_print:
    li a7, 1
    li a0, 300
    ecall
    ret

#######################################################
# Stub di procedure utili
#######################################################

find_free_space:
# need to be implemented    