CC	=	gcc -g -m32
AS	=	as -g --32

ALLOC	=	alloc
TESTE	=	testeMalloc

OBJ	=	$(ALLOC).o \
		$(TESTE).o
		
alocador:	$(OBJ)
			$(CC) -o alocador $(OBJ)
		
alloc.o:	$(ALLOC).s
			$(AS) $(ALLOC).s -o $(ALLOC).o 
			
teste.o:	$(TESTE).c
			$(CC) -c $(TESTE).c
			
limpa:		
			@rm -f *~ *.bak core gmon.out
			
faxina:		limpa
			@rm -f *.o alocador
