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

	cmpl $AVAILABLE, AVAILABLE_OFFSET
	jne  next
	
	cmpl %edx, %ecx
	jl allocate_less
	#cmpl %edx, %ecx # not sure if needed.
	je allocate_equal
	
next:
	
	movl SIZE_OFFSET(%eax), %edx
	movl %edx, previous_size
	addl %edx, %eax
	addl $HEADER_SIZE, %eax
	jmp  loop
			  
increase_brk:

	movl $BREAK, %eax
	
	addl %ecx, %ebx
	addl $HEADER_SIZE, %eax
	int $SYSCALL

	pushl %eax
	pushl %ebx
	pushl %ecx

	movl $BREAK, %eax
	int $SYSCALL

	cmpl $0, %eax
	je error

	popl %eax
	popl %ebx
	popl %ecx

	movl $UNAVAILABLE, AVAIL_OFFSET(%eax)
	movl %ecx, SIZE_OFFSET(%eax)

	movl previous_size, PREVIOUS_SIZE_OFFSET(%eax)
	
	addl $HEADER_SIZE, %eax
	movl %ebx, current_break
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
	movl previous_size, PREVIOUS_SIZE_OFFSET(%eax)
	
	addl %ecx, %eax
	addl $HEADER_SIZE, %eax
	movl $AVAILABLE, AVAIL_OFFSET(%eax)
	movl %ecx, PREVIOUS_SIZE_OFFSET(%eax)

	subl %ecx, %edx 	
	movl %edx, SIZE_OFFSET(%eax)
	
	subl %ecx, %eax
	
	popl %ebp
	ret
	
error:

	movl $0, %eax
	popl %ebp
	ret
	
# meuLiberaMem --------------------------------------------------------------------------#

# imprMapa ------------------------------------------------------------------------------#

.globl	imprMapa
.type	imprMapa, @function

imprMapa:
























