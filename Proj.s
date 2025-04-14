.data
    listInput: .string "PRINT~"
    commandBuffer: .word 0, 0, 0, 0, 0, 0, 0, 0   # 8 parole = 32 byte     
    
    counter: .word 0 # counter degli elementi nella lista
    head: .word 0    # pointer alla testa della lista ovviamente nullo
    
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
# parse_command -> controlla e smista il comando
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
    bne t3, t4, invalid     # ci sono pi� parametri o � sbagliato qualcosa
    
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
    bne t3, t4, invalid     # ci sono pi� parametri o � sbagliato qualcosa
    
    # il comando � corretto chiamo la handle
    lb a1, 4(t2) 
    jal handle_del
    j ret_to_main       # return al main

check_PRINT:    
    lb t3, 1(t2)
    li t4, 82               # 'R'
    bne t3, t4, invalid     # check R
    lb t3, 2(t2)
    li t4, 73               # 'I'
    bne t3, t4, invalid     # check I
    lb t3, 3(t2)
    li t4, 78               # 'N'
    bne t3, t4, invalid     # check N
    lb t3, 4(t2)
    li t4, 84               # 'T'
    bne t3, t4, invalid     # check T

    jal handle_print
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

#ADD

handle_add:
    
    #debugg add
    
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a1, 8(sp)

    jal find_free_space
    beq a0, zero, add_end  # Nessun spazio disponibile

    lw a1, 4(sp)           # Recupera il carattere

    # Salva carattere all'indirizzo libero
    sb a1, 0(a0)

    # Salva null next
    addi t1, a0, 1
    sw zero, 0(t1)

    # Carica head
    la t2, head
    lw t3, 0(t2)
    beq t3, zero, add_first

    # Cerca ultimo nodo
    mv t4, t3         # t4 = current
    
find_last:
    addi t5, t4, 1
    lw t6, 0(t5)
    beq t6, zero, link_new
    mv t4, t6
    j find_last

link_new:
    addi t5, t4, 1
    sw a0, 0(t5)
    j update_counter

add_first:
    sw a0, 0(t2)

update_counter:
    la t3, counter
    lw t4, 0(t3)
    addi t4, t4, 1
    sw t4, 0(t3)

add_end:
    lw ra, 0(sp)
    addi sp, sp, 8
    ret



#DEL


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



#print

handle_print:
    # stampa debug iniziale
    li a7, 4
    la a0, print
    ecall 

    # inizializzazione
    la t3, head  
    lw t3, 0(t3)      # carica indirizzo head

print_loop: 
    beq t3, zero, end_print   # se la lista � vuota, esci

    # stampa carattere
    lb a0, 0(t3)       # carica carattere
    li a7, 11
    ecall

    # stampa spazio dopo ogni carattere (opzionale)
    addi t4, t3, 1     # indirizzo del puntatore al prossimo nodo
    lw t4, 0(t4)       # t4 = prossimo nodo
    beq t4, zero, end_print

    li a0, 32          # spazio ' '
    li a7, 11
    ecall

    mv t3, t4          # passa al prossimo nodo
    j print_loop

end_print:
    # newline finale
    li a0, 10
    li a7, 11
    ecall
    ret


#######################################################
# Stub di procedure utili
#######################################################

# find_free_space
# Cerca un blocco libero da 5 byte (tutti zero) nella RAM
# a partire SEMPRE da 0x100, per una lunghezza fissa (es. 100 byte)
# OUT: a0 = indirizzo del primo blocco libero, 0 se non trovato

find_free_space:
    li t0, 0x100          # indirizzo base fisso
    li t4, 100            # dimensione fissa in byte
    li t1, 0              # offset

loop_search:
    bge t1, t4, not_found

    add t2, t0, t1        # t2 = indirizzo corrente

    lb t3, 0(t2)
    bne t3, zero, next
    lb t3, 1(t2)
    bne t3, zero, next
    lb t3, 2(t2)
    bne t3, zero, next
    lb t3, 3(t2)
    bne t3, zero, next
    lb t3, 4(t2)
    bne t3, zero, next

    add a0, t0, t1        #restituisco l'indirizzo in a0
    ret

next:
    addi t1, t1, 5        # salta al blocco successivo
    j loop_search

not_found:
    li a0, 0              # nessun blocco libero trovato
    ret