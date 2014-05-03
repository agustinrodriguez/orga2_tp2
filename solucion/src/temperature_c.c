
#include <math.h>
#include "tp2.h"


bool between(unsigned int val, unsigned int a, unsigned int b)
{
	return a <= val && val <= b;
}


void temperature_c    (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size)
{
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	int suma = 0;
	double divido = 0;
	for (int i_d = 0, i_s = 0; i_d < filas; i_d++, i_s++) {
		for (int j_d = 0, j_s = 0; j_d < cols; j_d++, j_s++) {
			rgb_t *p_d = (rgb_t*)&dst_matrix[i_d][j_d*3];
			rgb_t *p_s = (rgb_t*)&src_matrix[i_d][j_d*3];
			suma = p_s->r + p_s->b + p_s->g;
			divido = (double)suma/3;
			if (between(divido,0,31)){
				p_d->r = 0;
				p_d->g =0;
				p_d->b = (128+ (4*divido));
			}
			if (between(divido,32,95)){
				p_d->r = 0;
				p_d->g =(divido-32)*4;
				p_d->b = 255;
			}	
			if (between(divido,96,159)){
				p_d->r = (divido-96)*4;
				p_d->g =255;
				p_d->b = 255-((divido-96)*4);
			}
			if (between(divido,160,223)){
				p_d->r = 255;
				p_d->g = 255 - ((divido-160)*4);
				p_d->b = 0;
			}
			if (between(divido,224,255)){
				p_d->r = 255-(divido-224)*4;
				p_d->g =0;
				p_d->b = 0;
			}
		}
	}
}
