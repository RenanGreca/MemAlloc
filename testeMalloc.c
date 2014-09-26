#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define MAX_ELEM 16
#define TAM_MAX  64
#define NUM_OPER 32


// ---------
 #define malloc  meuAlocaMem
 #define free    meuLiberaMem
 #define calloc  meuCalocaMem
 #define realloc meuRealocaMem
// ---------

extern void *malloc (int);
extern void *calloc (int, int);
extern void *realloc(void*, int);


int main ( int argc, char** argv ) {

  void *vetor[MAX_ELEM+1];
  int i, j, tam;

  // faz cada elemento do vetor apontar para NULL
  for (i=0; i<MAX_ELEM; i++)
    vetor[i] = NULL;

  // gera uma semente baseada no tempo atual para os números
  // aleatórios.
  srand (time(0));

  // inicia a metade superior do conjunto de elementos
  for ( i=0; i<MAX_ELEM/2; i++ ) {
    tam = rand () % TAM_MAX;  // tam = [0..TAM_MAX]
    printf("Alocando %d bytes em vetor[%d]\n", tam, i+1 );
    vetor[i] = malloc (tam+1); 
    imprMapaB();
    imprMapaA();
  }

  // Serão tentadas NUM_OPER operações de alocacao/liberacao 
  printf("Num Operacoes: %d\n", i);
  for (i=0; i<NUM_OPER; i++) 
    {
      j = rand () % MAX_ELEM;  // j = [0..TAM_MAX]
      if ( vetor[j] == NULL ) // aloca elemento
        { 
          tam = rand () % TAM_MAX;  // tam = [0..TAM_MAX]
          printf("Alocando %d bytes em vetor[%d]\n", tam, j+1 );
          vetor[j] = calloc (2, tam+1);
        } 
      else
        {
          tam = rand () % TAM_MAX;  // tam = [0..TAM_MAX]
          printf("Realocando %d bytes em vetor[%d]\n", tam, j+1 );
          //free ( vetor[j] );
          vetor[j] = realloc(vetor[j], tam+1);
        }
    	imprMapaB();
    	imprMapaA();
    }    

  // ---------
 //  imprMapa ();
  // ---------

  for (i=0; i<MAX_ELEM; i++)
    if (vetor[i] != NULL)
      free (vetor[i]);

  // ---------
 //  imprMapa ();
  // ---------


}
