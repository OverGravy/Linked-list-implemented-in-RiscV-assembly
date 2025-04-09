.data
    listInput: .string "DEL(b)~ADD(a)"
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

    li t4, 32               # valore di space    
    beq t3, t4, skip_space  # ignora spazi esterni

    li t4, 126             # valore della tilde
    beq t3, t4, handle_tilde

    # controllo: se c'è spazio nel mezzo, comando invalido e lo scarto 
    li t4, 32                       # valore di space
    beq t3, t4, invalid_command

    #caricamento nel buffer del carattere letto se non ci sono spazi nel mezzo
    sb t3, 0(t1)           # carcica il valore nel buffer 
    addi t1, t1, 1         # incrementa pointer command list
    addi t0, t0, 1         # incrementa pointer buffer
    j parse_loop

skip_space:
    addi t0, t0, 1 #incremento puntatore in list input
    j parse_loop

handle_tilde:
    li t4, 0
    sb t4, 0(t1)         # null-terminate comando
    la a0, commandBuffer # preparazione parametri per il passaggio alla procedura
    jal parse_command    # validazione comando

    addi t0, t0, 1       # skip tilde
    la t1, commandBuffer
    j skip_space         # salta anche eventuali spazi dopo tilde

invalid_command:
    # scarta fino a prossimo ~
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
# parse_command — controlla e smista il comando
#######################################################
parse_command:
    
    # per via della chiamata annidata all'handle delle istruzioni
    addi sp, sp, -4     # spazio sullo stack
    sw ra, 0(sp)        # salvo il return address
    
    la t2, commandBuffer
    lb t3, 0(t2)           # carico il primo carattere
    
    # check se inizia con A
    li t4, 65    
    beq t3, t4, check_ADD
     
    # check se inizia con D
    li t4, 68
    beq t3, t4, check_DELL
     
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

check_ADD:
    lb t3, 1(t2)
    li t4, 68              
    bne t3, t4, invalid     # check D
    lb t3, 2(t2)
    li t4, 68
    bne t3, t4, invalid     # check D
    lb t3, 3(t2)
    li t4, 40
    bne t3,t4, invalid      # check "("
    lb t3, 4(t2)
    li t4, 41
    beq t3, t4, invalid      # nessun parametro, check ")"
    lb t3, 5(t2)
    bne t3, t4, invalid      # ci sono più parametri o è sbagliato qualcosa
    
    # il comando è corretto chiamo la handle
    lb a1, 4(t2) 
    jal handle_add
    j ret_to_main
    

check_DELL:
    lb t3, 1(t2)
    li t4, 69              
    bne t3, t4, invalid     # check E
    lb t3, 2(t2)
    li t4, 76
    bne t3, t4, invalid     # check L
    lb t3, 3(t2)
    li t4, 40
    bne t3,t4, invalid      # check "("
    lb t3, 4(t2)
    li t4, 41
    beq t3, t4, invalid      # nessun parametro, check ")"
    lb t3, 5(t2)
    bne t3, t4, invalid      # ci sono più parametri o è sbagliato qualcosa
    
    # il comando è corretto chiamo la handle
    lb a1, 4(t2) 
    jal handle_del
    j ret_to_main       # return al main
    
check_PRINT:    

check_SORT:
    
check_REV:



invalid:
    # comando malformattato -> ignorato
    j ret_to_main
    
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
    # azione debug per add
    li a7, 4
    la a0, del
    ecall
    li a7, 11
    li a0, 40
    ecall
    mv a0, a1
    ecall
    
    
    # actual implementazione di ADD
    
    
    ret

handle_print:
    li a7, 1
    li a0, 300
    ecall
    ret
