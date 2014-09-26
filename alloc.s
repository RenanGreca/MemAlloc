.section .data

#GLOBAL VARIABLES

heap_start:
	.long 0
	
current_brk:
	.long 0

previous_size:
	.long 0
	
#STRUCT
.equ HEADER_SIZE, 12

.equ AVAIL_OFFSET, 0
.equ PREV_SIZE_OFFSET, 4
.equ SIZE_OFFSET, 8

#CONSTANTS

.equ AVAILABLE, 1
.equ UNAVAILABLE, 0

.equ BREAK, 45
.equ SYSCALL, 0x80

.section .text

#FUNCTIONS

# meuAlocaMem ---------------------------------------------------------------------------#

debug0: .string "teste\n"
debug10: .string "valor: %d\n"

.globl	meuAlocaMem
.type	meuAlocaMem, @function

meuAlocaMem:

		pushl %ebp
		movl %esp, %ebp

		cmpl $0, heap_start
		jne end_if
	
		movl $BREAK, %eax
		movl $0,  %ebx
	
		int $SYSCALL
	
		incl %eax
		movl %eax, current_brk
		movl %eax, heap_start
	
	end_if:
	
		movl heap_start, 	%eax
		movl current_brk, 	%ebx
		movl 8(%ebp), 		%ecx		# 8 é o argumento. Tamanho a ser alocado.
	
	loop:

		cmpl %eax, %ebx
		je increase_brk
	
		movl SIZE_OFFSET(%eax), %edx
		cmpl $UNAVAILABLE, AVAIL_OFFSET(%eax)
		je  next
		
		cmpl %edx, %ecx 
		je allocate_equal
	
		cmpl %edx, %ecx # not sure if needed.
		jl allocate_less	

	next:
	
		movl SIZE_OFFSET(%eax), %edx
		movl %edx, previous_size
		
		addl SIZE_OFFSET(%eax), %eax
		addl $HEADER_SIZE, %eax
		jmp  loop
				  
	increase_brk:		

		#movl $BREAK, %eax
	
		addl %ecx, %ebx
		addl $HEADER_SIZE, %ebx
		#int $SYSCALL

		pushl %eax
		pushl %ebx
		pushl %ecx

		movl $BREAK, %eax
		int $SYSCALL

		cmpl $0, %eax
		je error

		popl %ecx
		popl %ebx
		popl %eax

		movl $UNAVAILABLE, AVAIL_OFFSET(%eax)
		movl %ecx, SIZE_OFFSET(%eax)

		movl previous_size, %ecx
		movl %ecx, PREV_SIZE_OFFSET(%eax)
	
		addl $HEADER_SIZE, %eax
		movl %ebx, current_brk
		popl %ebp
		ret	

	allocate_equal:

		movl $UNAVAILABLE, AVAIL_OFFSET(%eax)
		addl $HEADER_SIZE, %eax 
		popl %ebp
		ret

	allocate_less:

		subl $HEADER_SIZE, %edx
		cmpl %ecx, %edx
		jle next
	
		movl $UNAVAILABLE, AVAIL_OFFSET(%eax)
		movl %ecx, SIZE_OFFSET(%eax)
		
		movl previous_size, %ecx			# Salva o tamanho do segmento anterior
		movl %ecx, PREV_SIZE_OFFSET(%eax)	# no header
		
		movl SIZE_OFFSET(%eax), %ecx
		
		addl %ecx, %eax
		addl $HEADER_SIZE, %eax
		
		
		subl %ecx, %edx 
		movl %edx, SIZE_OFFSET(%eax)
		movl $AVAILABLE, AVAIL_OFFSET(%eax)
		#movl %ecx, PREV_SIZE_OFFSET(%eax)

		subl %ecx, %eax
	
		popl %ebp
		ret
	
	error:

		movl $0, %eax
		popl %ebp
		ret
	
# meuLiberaMem --------------------------------------------------------------------------#

.globl	meuLiberaMem
.type	meuLiberaMem, @function

meuLiberaMem:
	movl 4(%esp), %eax		#parâmetro que indica a posição a ser liberada
	subl $HEADER_SIZE, %eax
	movl $AVAILABLE, AVAIL_OFFSET(%eax)
	ret
	
# meuCalocaMem --------------------------------------------------------------------------#

.globl	meuCalocaMem
.type	meuCalocaMem, @function

meuCalocaMem:
	
		pushl %ebp
		movl %esp, %ebp
		
		movl 8(%ebp), %eax		# número de elementos
		movl 12(%ebp), %ebx		# tamanho de cada elemento	
		mul %ebx
		
		pushl %eax	
		call meuAlocaMem
		
		movl %eax, %ebx
		movl %eax, %edx	
		popl %eax

		movl $1, %ecx
loop2:
		
		cmpl %ecx, %eax
		jge fim
		
		movl $0, 0(%ebx)
		
		incl %ecx
		incl %ebx
		
		jmp loop2


fim:	popl %ebp
		movl %edx, %eax
		
		ret

# meuRealocaMem-----------------------------------------------------------------------------#

debug1: .string "\nMeuRealocaMem :: Tamanho novo: %d; Tamanho antigo: %d\n"
debug2: .string "sameSize\n"
debug3: .string "smaller\n"
debug4: .string "greater\n"
debug5: .string "loop3\n"
debug6: .string "fim_loop3\n"
debug7: .string "inc_brk\n"
debug8: .string "valor: %d\n"
debug9: .string "teste\n"


.globl	meuRealocaMem
.type	meuRealocaMem, @function

meuRealocaMem:	

		pushl %ebp
		movl %esp, %ebp
		
		movl 12(%ebp), %eax		#	novo tamanho
		movl 8(%ebp), %ebx		#	ponteiro
		
		subl $HEADER_SIZE, %ebx	
		
		cmpl SIZE_OFFSET(%ebx), %eax
		je Lsame_size
		cmpl SIZE_OFFSET(%ebx), %eax
		jl smaller								#	Novo tamanho é menor que o atual
		cmpl SIZE_OFFSET(%ebx), %eax
		jg greater								#	Novo tamanho é maior que o atual

Lsame_size:										#	O tamanho passado como parâmetro é igual ao que o bloco já tem

		addl $HEADER_SIZE, %ebx
		movl %ebx, %eax
		popl %ebp
		ret

smaller:
		
		movl 12(%ebp), %edx						# %eax: novo tamanho

		addl $HEADER_SIZE, %edx					
		
		cmpl %edx, SIZE_OFFSET(%ebx) 			# if size(ebx) <= eax
		jle greater
		
		movl SIZE_OFFSET(%ebx), %ecx			# %ecx: tamanho antigo
		
		subl $HEADER_SIZE, %edx		
		
		movl %edx, SIZE_OFFSET(%ebx) 			# tamanho do primeiro bloco <= eax
		
		movl %ebx, %eax
		addl $HEADER_SIZE, %eax
		
		addl SIZE_OFFSET(%ebx), %ebx			# %ebx: aponta para o início do header segundo bloco
		addl $HEADER_SIZE, %ebx					
		
		movl $AVAILABLE, AVAIL_OFFSET(%ebx)		
		movl %edx, PREV_SIZE_OFFSET(%ebx)
		
		subl $HEADER_SIZE, %ecx
		subl %edx, %ecx	
		movl %ecx, SIZE_OFFSET(%ebx)
		
		
		popl %ebp		
		ret
		

greater:
		
		movl 12(%ebp), %eax

		movl %ebx, %edx
		addl SIZE_OFFSET(%ebx), %edx
		addl $HEADER_SIZE, %edx
		cmpl %edx, current_brk
		je	Rincrease_brk
		
		pushl %ebx
		pushl %eax
		
		call meuAlocaMem		#	Chama o alocador para alocar o espaço necessário

		movl %eax, %ecx			#	Ponteiro da nova posição
		
		popl %eax
		popl %ebx

		pushl %ecx		
		pushl %ebx						# ebx = ponteiro da posição antiga		

		popl %ebx
		popl %eax
		
		movl $AVAILABLE, AVAIL_OFFSET(%ebx)

		popl %ebp
		ret
		
Rincrease_brk:					#	O ponteiro parâmetro aponta para o último bloco de memória. Aumenta a break e o tamanho do bloco
		
		movl 12(%ebp), %eax

		movl %ebx, %edx
		#
		addl %eax, %edx
		
		pushl %eax
		pushl %ebx
		
		movl $BREAK, %eax
		movl %edx, %ebx
		int $SYSCALL
		
		addl SIZE_OFFSET(%ebx), %edx
		addl $HEADER_SIZE, %edx
		movl %edx, current_brk
		
		popl %ebx
		popl %eax
		
		movl 12(%ebp), %eax
	
		movl %eax, SIZE_OFFSET(%ebx)
		
		addl $HEADER_SIZE, %ebx
		movl %ebx, %eax
		
		popl %ebp
		ret	

# ---------------------------------------------------------------------------------------#

# imprMapaA ------------------------------------------------------------------------------#
# Este imprMapa imprime usando -s e *s

.globl	imprMapaA
.type	imprMapaA, @function

#----------------------------------------------------------------------------------------#

	msg1: .string "\nInicio heap: %p\n"
	msg2: .string "Segmento %d: %d bytes ocupados\n"
   	msg3: .string "Segmento %d: %d bytes livres\n"
   	msg4: .string "Segmentos Ocupados: %d / %d bytes\n"
   	msg5: .string "Segmentos Livres: %d / %d bytes\n---------\n"
   	free: .string "-"
	used: .string "*"
	end: .string "|"
	ln:   .string "\n"


	# Talvez Adicionar -4.
	.equ USED, -4   	# Guarda quantos segmentos são ocupados
	.equ FREE, -8        	# Guarda quantos segmentos são livre
	.equ SIZE_USED, -12  	# Guarda o espaço usado pelos segmentos ocupados
	.equ SIZE_FREE, -16	# Guarda o espaço usado pelos segmentos livres
	.equ CURRENT, -20      	# Número do segmento atual

#----------------------------------------------------------------------------------------#

imprMapaA:

		pushl %ebp
		movl %esp, %ebp

		subl $20, %esp

		movl $0, USED(%ebp)
	  	movl $0, FREE(%ebp)
	  	movl $0, SIZE_USED(%ebp)
	  	movl $0, SIZE_FREE(%ebp)
	  	movl $1, CURRENT(%ebp)                 
	
		movl heap_start, %eax

	while_not_brkA:

		cmpl %eax, current_brk
		jle end_memA

	if_usedA:
	
		cmpl $UNAVAILABLE, AVAIL_OFFSET(%eax)
		jne if_freeA

		addl $1, USED(%ebp)
		movl SIZE_OFFSET(%eax), %ebx
		addl %ebx, SIZE_USED(%ebp)
	
		pushl %eax
		
		#pushl SIZE_OFFSET(%eax)             # Empilha os parâmetros do printf para
		#pushl CURRENT(%ebp)                 # imprimir a msg2
	  	#pushl $msg2 	                    #
	  	#call printf     	            	#
	  	#addl $12, %esp 

		movl $used, %eax
		
		pushl %eax
		call printf
		popl %eax
		
		movl $1, %ecx
		jmp print_loopA

	if_freeA:
	
		addl $1, FREE(%ebp)
		movl SIZE_OFFSET(%eax), %ebx
		addl %ebx, SIZE_FREE(%ebp)
	
		pushl %eax
		
		#pushl SIZE_OFFSET(%eax)             # Empilha os parâmetros do printf para
		#pushl CURRENT(%ebp)                 # imprimir a msg3
	  	#pushl $msg3 	                    #
	  	#call printf     	           		#
	  	#addl $12, %esp 

		movl $free, %eax
		
		pushl %eax
		call printf
		popl %eax
		
		movl $1, %ecx
		#pushl %ecx
		jmp print_loopA
		
		
	print_loopA:								# %eax: livre/ocupado; %ebx: quantidade de bytes; %ecx: incrementador
	
		#popl %ecx
	
		cmpl %ebx, %ecx
		jge end_print_loopA

		incl %ecx
		
		pushl %ecx
				
		pushl %eax
		call printf
		popl %eax
		
		popl %ecx
		#pushl %ecx
		
		jmp print_loopA
		
	end_print_loopA:
	
		popl %eax
		
		pushl %eax
		
		movl $end, %eax
		
		pushl %eax
		call printf
		popl %eax
		
		popl %eax

		jmp next_segA
	 	
	next_segA:

		addl $1, CURRENT(%ebp)
		addl SIZE_OFFSET(%eax), %eax
		addl $HEADER_SIZE, %eax

		jmp while_not_brkA

	end_memA:
	
		pushl $ln
		call printf
		addl $4, %esp	

		addl $20, %esp

		popl %ebp
		ret

# imprMapaB ------------------------------------------------------------------------------#
# este imprMapa imprime com descrição

.globl	imprMapaB
.type	imprMapaB, @function

#----------------------------------------------------------------------------------------#

imprMapaB:

		pushl %ebp
		movl %esp, %ebp

		subl $20, %esp

		movl $0, USED(%ebp)
	  	movl $0, FREE(%ebp)
	  	movl $0, SIZE_USED(%ebp)
	  	movl $0, SIZE_FREE(%ebp)
	  	movl $1, CURRENT(%ebp)

		pushl heap_start                # Empilha os parâmetros do printf para
		pushl $msg1                     # para imprimir a msg1
		  	call printf                     #
		  	addl $8, %esp                   
	
		movl heap_start, %eax

	while_not_brkB:

		cmpl %eax, current_brk
		jle end_memB

	if_usedB:
	
		cmpl $UNAVAILABLE, AVAIL_OFFSET(%eax)
		jne if_freeB

		addl $1, USED(%ebp)
		movl SIZE_OFFSET(%eax), %ebx
		addl %ebx, SIZE_USED(%ebp)
	
		pushl %eax

		pushl SIZE_OFFSET(%eax)             # Empilha os parâmetros do printf para
		pushl CURRENT(%ebp)                 # imprimir a msg2
		  	pushl $msg2 	                    #
		  	call printf     	            #
		  	addl $12, %esp 

		popl %eax

		jmp next_segB

	if_freeB:
	
		addl $1, FREE(%ebp)
		movl SIZE_OFFSET(%eax), %ebx
		addl %ebx, SIZE_FREE(%ebp)
	
		pushl %eax

		pushl SIZE_OFFSET(%eax)             # Empilha os parâmetros do printf para
		pushl CURRENT(%ebp)                 # imprimir a msg2
		  	pushl $msg3 	                    #
		  	call printf     	            #
		  	addl $12, %esp 

		popl %eax

		jmp next_segB
	 	
	next_segB:

		addl $1, CURRENT(%ebp)
		addl SIZE_OFFSET(%eax), %eax
		addl $HEADER_SIZE, %eax

		jmp while_not_brkB

	end_memB:

		pushl SIZE_USED(%ebp)
		pushl USED(%ebp)
		pushl $msg4
		call printf
		addl $12, %esp

		pushl SIZE_FREE(%ebp)
		pushl FREE(%ebp)
		pushl $msg5
		call printf
		addl $12, %esp	

		addl $20, %esp

		popl %ebp
		ret
