#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <omp.h>

#include "arqo3.h"

void calcular_mult(tipo **matriz1, tipo **matriz2, tipo ** matriz_res, int n);

int main( int argc, char *argv[])
{
	int n;
	tipo **m1=NULL;
	tipo **m2=NULL;
	tipo **m_res=NULL;
	struct timeval fin,ini;
	int hilos;

	printf("Word size: %ld bits\n",8*sizeof(tipo));

	if( argc!=3 )
	{
		printf("Error: ./%s <matrix size> <numero de hilos>\n", argv[0]);
		return -1;
	}
	/* Generacion de matrices a multiplicar y la matriz vacia para almacenar el resultado */
	n=atoi(argv[1]);
	hilos=atoi(argv[2]);
	m1=generateMatrix(n);
	if( !m1 )
	{
		return -1;
	}
	m2=generateMatrix(n);
	if( !m2 )
	{
		return -1;
	}
	m_res = generateEmptyMatrix(n);
	if( !m_res )
	{
		return -1;
	}

	omp_set_num_threads(hilos);
	gettimeofday(&ini,NULL);

	/* Main computation */
	calcular_mult(m1, m2, m_res, n);
	/* End of computation */

	gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

	free(m1);
	free(m2);
	free(m_res);
	return 0;
}

void calcular_mult(tipo **matriz1, tipo **matriz2, tipo ** matriz_res, int n)
{
	int i,j,k;
	tipo temp = 0;

	for(i=0;i<n;i++)
	{
		#pragma omp parallel for private(k,temp)
		for(j=0;j<n;j++)
		{
			temp = 0;
			for(k=0; k<n; k++){
				 temp += matriz1[i][k] * matriz2[k][j];
			}
			matriz_res[i][j] = temp;
		}
	}

	return;
}
