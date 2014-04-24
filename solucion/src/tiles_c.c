
#include "tp2.h"
#include <stdio.h>

void tiles_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size,
	int tamx,
	int tamy,
	int offsetx,
	int offsety)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	int cont_x = 0;
	int cont_y = 0;

	/*for (int i_d = 0, i_s = 0; i_d < filas; i_d++, i_s++) {
		for (int j_d = 0, j_s = 0; j_d < cols; j_d++, j_s++) {
			rgb_t *p_d = (rgb_t*)&dst_matrix[i_d][j_d*3];
			rgb_t *p_s = (rgb_t*)&src_matrix[i_s][j_s*3];
			*p_d = *p_s;
		}
	}

	printf("Ancho a copiar (x) %d", tamx);
	printf("\nAlto a copiar (y) %d", tamy);
	printf("\nAncho que se saltea (x) %d", offsetx);
	printf("\nAlto que se saltea (y) %d", offsety);*/
	cont_x = cols/tamx;
	cont_y = filas/tamy;


	for (int i_d = 0, i_s = offsetx; i_d < filas; i_d++,i_s++) {
		for (int j_d = 0, j_s = offsety; j_d < cols; j_d++,j_s++) {
			rgb_t *p_d = (rgb_t*)&dst_matrix[i_d][j_d*3];
			rgb_t *p_s = (rgb_t*)&src_matrix[i_s][j_s*3];
			*p_d = *p_s;

			//printf("\nx: %d; y: %d", cont_x, cont_y);
			if(j_s == cols)
			{
				j_s = offsety;
			//	cont_x--;
			}
			if(i_s == filas)
			{
				i_s = offsetx;
				cont_y--;
				cont_x--;
								
			}
			if (cont_y == 0 && cont_x == 0)
			{
				j_s = tamx;
				i_s = tamy;
			}
		
		}
	}

}