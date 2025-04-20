.data
    #listInput: .string "ADD(;)~ADD(aaa)~A DD(a)~ADD(b)~ADD(a)~ADD(2)~ADD(E)~ADD(r)~ADD(4)~ADD(,)~ADD(w)~PRINT~SORT~PRINT~"
    listInput: .string "ADD(1) ~ ADD(a) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~ ADD(9) ~SORT~PRINT~DEL(b) ~DEL(B)~PRI~PRINT~"
    commandBuffer: .word 0, 0, 0, 0, 0, 0, 0, 0   # 8 parole = 32 byte     
    
    counter: .word 0 # counter degli elementi nella lista
    head: .word 0    # pointer alla testa della lista ovviamente nullo
    
    # DEBUG STRING
    add:   .string "ADD"
    del:   .string "DEL"
    sort:  .string "SORT"
    print: .string "PRINT"
    rev:   .string "REV"
    
    # Command messages
    add_msg:   .string "element added:"
    print_msg: .string "print list:"
    dell_msg:  .string "element deleted succesfully"
    rev_msg:   .string "list reverted succesfully"
    sort_msg:  .string "list sorted succesfully"
    invd_msg:  .string "invalid command"
    loop_msg:  .string "loop detected"



#######################################################

#                REGISTRI IMPORTANTI                  #

# s0 -> indirizzo stringa comandi
# s1 -> indirizzo buffer comandi  
# a1 -> il ritorno di tutte le funzioni 

#########################################################

.text

    la s0, listInput        # s0 -> stringa
    la s1, commandBuffer    # s1 -> buffer

parse_loop:
    lbu t0, 0(s0)
    beq t0, zero, parse_end   # raggiungo il fine stringa
    
    li t1, 126                # valore della tilde
    beq t0, t1, handle_tilde

    # caricamento nel buffer del carattere letto
    sb t0, 0(s1)           # carcica il valore nel buffer 
    addi s1, s1, 1         # incrementa pointer command list
    addi s0, s0, 1         # incrementa pointer buffer
    j parse_loop   

handle_tilde:
    li   t1, 0
    sb   t1, 0(s1)         # null-terminate comando
    la   a0, commandBuffer # parametro per parse_command

    addi sp, sp, -4
    sw   ra, 0(sp)         # salva return address
    jal  parse_command
    lw   ra, 0(sp)         # ripristina return address
    addi sp, sp, 4         # ripulisci lo stack

    j    reset_buffer

wait_tilde:
    lbu t0, 0(s0)
    beq t0, zero, parse_end
    li t1, 126
    beq t0, t1, reset_buffer
    addi s0, s0, 1
    j wait_tilde

reset_buffer:
    addi s0, s0, 1
    la s1, commandBuffer   # rimetto il puntatore all'inizio del buffer
    j parse_loop

parse_end: # fine del programma
    li a7, 10
    ecall

#######################################################
# parse_command -> controlla e smista il comando
#######################################################
parse_command:
    la t0, commandBuffer
    
    addi sp, sp, -4     # spazio sullo stack
    sw ra, 0(sp)        # salvo il return address

parsing:
    lb t1, 0(t0)           # carico il primo carattere
    li t2, 32              # spazio
    beq t1, t2, skip_space_parsing

    # check se inizia con A
    li t2, 65              # 'A'
    beq t1, t2, check_ADD

    # check se inizia con D
    li t2, 68              # 'D'
    beq t1, t2, check_DEL

    # check se inizia con P
    li t2, 80              # 'P'
    beq t1, t2, check_PRINT

    # check se inizia con S
    li t2, 83              # 'S'
    beq t1, t2, check_SORT

    # check se inizia con R 
    li t2, 82              # 'R'
    beq t1, t2, check_REV

    j invalid

skip_space_parsing:
    addi t0, t0, 1
    j parsing

check_ADD:
    lb t1, 1(t0)
    li t2, 68               # 'D'
    bne t1, t2, invalid
    lb t1, 2(t0)
    li t2, 68               # 'D'
    bne t2, t1, invalid
    lb t1, 3(t0)
    li t2, 40               # "("
    bne t2, t1, invalid
    lb t1, 4(t0)
    li t2, 41               # ")"
    beq t2, t1, invalid
    lb t1, 5(t0)
    bne t1, t2, invalid
    
    lb a1, 4(t0)              #passo il carattere da inserire in a1
    jal handle_add
    
    #ritorno al main
    j ret_to_main

check_DEL:
    lb t1, 1(t0)
    li t2, 69               # 'E'
    bne t1, t2, invalid
    lb t1, 2(t0)
    li t2, 76               # 'L'
    bne t1, t2, invalid
    lb t1, 3(t0)
    li t2, 40               # "("
    bne t1, t2, invalid
    lb t1, 4(t0)
    li t2, 41               # ")"
    beq t1, t2, invalid
    lb t1, 5(t0)
    bne t1, t2, invalid

    #parametro da passare alla chiamata della funzione
    lb a1, 4(t0)
    jal handle_del
    
   #ritorno al main
    j ret_to_main

check_PRINT:
    lb t1, 1(t0)
    li t2, 82               # 'R'
    bne t2, t1, invalid
    lb t1, 2(t0)
    li t2, 73               # 'I'
    bne t1, t2, invalid
    lb t1, 3(t0)
    li t2, 78               # 'N'
    bne t1, t2, invalid
    lb t1, 4(t0)
    li t2, 84               # 'T'
    bne t1, t2, invalid
  
    jal handle_print
    
    #ritorno al main
    j ret_to_main

check_SORT:
    lb t1, 1(t0)
    li t2, 79               # 'O'
    bne t2, t1, invalid
    lb t1, 2(t0)
    li t2, 82               # 'R'
    bne t1, t2, invalid
    lb t1, 3(t0)
    li t2, 84               # 'T'
    bne t1, t2, invalid
  
    jal handle_sort
    #ritorno al main
    j ret_to_main

check_REV:
    lb t1, 1(t0)
    li t2, 69               # 'E'
    bne t2, t1, invalid
    lb t1, 2(t0)
    li t2, 86               # 'V'
    bne t1, t2, invalid
  
    jal handle_rev
    
    
    #ritorno al main
    j ret_to_main
    
invalid:
    # comando non riconosciuto, ritorna senza fare nulla
    li a7, 4
    la a0, invd_msg
    ecall
    
    li a0, 10           # newline
    li a7, 11
    ecall
    
    lw ra, 0(sp)        # recupero il return address
    addi sp, sp, 4      # pulisco lo stack
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
    addi sp, sp, -8
    sw a1, 0(sp)        # salva il carattere da inserire
    sw ra, 4(sp)        # salva il return address

    jal find_free_space
    beq a1, zero, add_end  # Nessun spazio disponibile

    mv a2, a1           # a2 = indirizzo nuovo nodo
    lw a1, 0(sp)        # riprendo il carattere da inserire
    addi sp, sp, 4      # pulisco parte della stack (lasciamo ra ancora lì)

    sb a1, 0(a2)        # salva carattere nel nodo
    sw zero, 1(a2)      # imposta il campo next a 0 (null)

    la t0, head
    lw t1, 0(t0)        # carica head
    beq t1, zero, add_first  # se head è 0, è il primo nodo

    # altrimenti cerca l'ultimo nodo
    mv t3, t1           # t3 = nodo corrente

find_last:
    addi t4, t3, 1      # t4 = campo next del nodo corrente
    lw t5, 0(t4)        # t5 = indirizzo del prossimo nodo
    beq t5, zero, link_new
    mv t3, t5           # t3 = nodo successivo
    j find_last

link_new:
    addi t4, t3, 1      # t4 = campo next dell'ultimo nodo
    sw a2, 0(t4)        # collega ultimo nodo al nuovo nodo
    j update_counter

add_first:
    sw a2, 0(t0)        # head = nuovo nodo

update_counter:
    la t0, counter
    lw t1, 0(t0)
    addi t1, t1, 1
    sw t1, 0(t0)

add_end:
    # stampa messaggio
    li a0, 10
    li a7, 11
    ecall

    la a0, add_msg
    li a7, 4
    ecall

    li a0, 32           # spazio
    li a7, 11
    ecall

    mv a0, a1           # carattere aggiunto
    li a7, 11
    ecall

    li a0, 10           # newline
    li a7, 11
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret


#DEL


handle_del:  
    # a1 -> carattere da cercare
    # t2 -> indirizzo nodo corrente
    # t3 -> indirizzo nodo precedente (se serve)

    la t0, head  
    lw t2, 0(t0)      # t2 = head (primo nodo)
    li t3, 0          # t3 = nodo precedente, inizialmente nullo

dell_loop: 
    beq t2, zero, end_dell   # lista vuota o fine lista

    lb t4, 0(t2)             # carico il carattere nel nodo corrente
    beq t4, a1, dell_node    # trovato nodo da eliminare?

    mv t3, t2                # t3 = nodo precedente
    addi t1, t2, 1           # t1 = indirizzo campo next
    lw t2, 0(t1)             # t2 = prossimo nodo
    j dell_loop

dell_node:
    # se il nodo da eliminare è il primo (t2 == head)
    la t5, head
    lw t6, 0(t5)
    bne t6, t2, not_first_node

    # è il primo nodo: aggiorna head al prossimo nodo
    # appunto se è 0 elimino la head praticamente
    addi t1, t2, 1       # t1 = campo next
    lw t4, 0(t1)         # t4 = prossimo nodo
    sw t4, 0(t5)         # head = prossimo nodo
    j cleanup_node

not_first_node:
    # nodo non in testa: collega il nodo precedente (t3) al successivo
    addi t1, t2, 1       # t1 = campo next del nodo corrente
    lw t4, 0(t1)         # t4 = prossimo nodo
    sw t4, 1(t3)         # aggiorna next del precedente

cleanup_node:
    # azzera i 5 byte del nodo eliminato
    li t0, 0
    sb t0, 0(t2)
    sb t0, 1(t2)
    sb t0, 2(t2)
    sb t0, 3(t2)
    sb t0, 4(t2)

    # decrementa counter
    la t5, counter
    lw t6, 0(t5)
    addi t6, t6, -1
    sw t6, 0(t5)

    # stampa messaggio di conferma
    li a0, 10        # newline
    li a7, 11
    ecall

    li a7, 4
    la a0, dell_msg
    ecall

    li a0, 32        # spazio
    li a7, 11
    ecall

    mv a0, a1        # stampa il carattere rimosso
    li a7, 11
    ecall

    li a0, 10
    li a7, 11
    ecall
    
    mv t2, t4        # t4 conteneva il nodo successivo prima del cleanup
    j dell_loop

end_dell:
    ret



#PRINT

handle_print:
    
    # msg per print 
    la a0, print_msg
    li a7, 4
    ecall
    
    # newline dopo il msg
    li a0, 10
    li a7, 11
    ecall
    
    
    # inizializzazione
    la t0, head  
    lw t2, 0(t0)      # carica indirizzo head

print_loop: 
    beq t2, zero, end_print   # se la lista è vuota, esci

    # stampa carattere
    li a7, 11
    lb a0, 0(t2)       # carica carattere da t2 come inidirizzo all'elemento della lista
    ecall

    # vado avanti nella lista
    mv t1, t2
    addi t1, t1, 1     # indirizzo del puntatore al prossimo nodo
    lw t2, 0(t1)       # t2 = indirizzo al prossimo nodo
    beq t2, zero, end_print

    li a0, 32          # spazio ' '
    li a7, 11
    ecall
     
    j print_loop

end_print:
    # newline finale
    li a0, 10
    li a7, 11
    ecall
    ret



    
#REV

handle_rev:
    
    la t0, head
    lw t1, 0(t0)         # t1 = current = head
    li t2, 0             # prev = NULL (zero)

rev_loop:
    beq t1, zero, rev_done   # se current è null, fine

    addi t3, t1, 1       # t3 = indirizzo campo next del nodo corrente
    lw t4, 0(t3)         # t4 = next = nodo successivo

    sw t2, 0(t3)         # current->next = prev

    # scambio puntatori
    mv t2, t1            # prev = current
    mv t1, t4            # current = next

    j rev_loop

rev_done:
    # aggiorna la head al nuovo primo nodo (che è prev)
    la t0, head
    sw t2, 0(t0)

    # stampa messaggio di conferma
    la a0, rev_msg
    li a7,4
    ecall

    li a0, 10
    li a7, 11
    ecall

    ret


#SORT

handle_sort:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    la t0, head
    lw a0, 0(t0)         # a0 = head
    beq a0, zero, sort_done   # se lista vuota, esci
    jal bubble_sort       # a0 = bubble_sort(head)
    sw a0, 0(t0)         # aggiorna head con nuova lista ordinata

    # messaggio di conferma
    la a0, sort_msg
    li a7, 4
    ecall

    li a0, 10
    li a7, 11
    ecall
sort_done:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret




#######################################################
# Stub di procedure utili
#######################################################

# find_free_space
# Cerca un blocco libero da 5 byte (tutti zero) nella RAM
# a partire SEMPRE da 0x100, per una lunghezza fissa (es. 100 byte)
# OUT: a1 = indirizzo del primo blocco libero, 0 se non trovato

find_free_space:
    li t0, 0x00000f54     # indirizzo base fisso
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

    add a1, t0, t1        #restituisco l'indirizzo in a0
    ret

next:
    addi t1, t1, 5        # salta al blocco successivo
    j loop_search

not_found:
    li a1, 0              # nessun blocco libero trovato
    ret
    
    
# bubble_sort
# a0 = head della lista
# ritorna: a0 = head della lista ordinata
# categorie: extra(0) < number(1) < lowercase(2) < uppercase(3)
bubble_sort:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    li t6, 0            # flag di scambio = false
    mv t0, a0           # t0 = puntatore al nodo corrente

bubble_pass:
    lw t1, 1(t0)        # t1 = puntatore al prossimo nodo
    beq t1, zero, pass_end
    lb t2, 0(t0)        # char1 = carattere attuale
    lb t3, 0(t1)        # char2 = carattere nel prossimo nodo

    # classifico char1 -> t4 usando s0
    li t4, 0            # default extra
    li s2, 48
    blt t2, s2, _t2_done  # sotto '0' => va negli extra
    li s2, 57
    ble t2, s2, set_t2_num # '0'-'9'
    li s2, 97
    blt t2, s2, t2_check_upper # tra ':' and '`'
    li s2, 122
    ble t2, s2, set_t2_lower # 'a'-'z' in questo intervallo
    j _t2_done
    
t2_check_upper:
    li s2, 65
    blt t2, s2, _t2_done
    li s2, 90
    ble t2, s2, set_t2_upper
    j _t2_done
    
set_t2_num:
    li t4, 1
    j _t2_done
    
set_t2_lower:
    li t4, 2
    j _t2_done
    
set_t2_upper:
    li t4, 3

_t2_done:
    # classifica char2 -> t5
    li t5, 0
    li s2, 48
    blt t3, s2, _t3_done
    li s2, 57
    ble t3, s2, set_t3_num
    li s2, 97
    blt t3, s2, _t3_check_upper
    li s2, 122
    ble t3, s2, set_t3_lower
    j _t3_done
    
_t3_check_upper:
    li s2, 65
    blt t3, s2, _t3_done
    li s2, 90
    ble t3, s2, set_t3_upper
    j _t3_done
    
set_t3_num:
    li t5, 1
    j _t3_done
    
set_t3_lower:
    li t5, 2
    j _t3_done
    
set_t3_upper:
    li t5, 3
    
_t3_done:
    # decido lo swap
    bgt t4, t5, do_swap
    beq t4, t5, no_swap
    blt t4, t5, no_swap
    blt t2, t3, no_swap

do_swap:
    sb t3, 0(t0)
    sb t2, 0(t1)
    li t6, 1           # mark del flag dello swap
    
no_swap:
    mv t0, t1          # punto al prossimo nodo
    j bubble_pass

pass_end:
    lw a0, 4(sp)       # ricarico la testa head
    beq t6, zero, end_sort
    li t6, 0           # reset flag
    jal bubble_sort     # chiamata ricorsiva

end_sort:
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


