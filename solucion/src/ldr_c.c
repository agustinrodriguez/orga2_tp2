
#include "tp2.h"

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2

void ldr_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size,
	int alfa)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
    int sumar,sumag,sumab = 0;
    int max = 5*5*255*3*255;
    int sumargb = 0;
    int multiplico = 1;
    double var = 0;
    int srcsuma = 0;
    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            rgb_t *p_d = (rgb_t*) &dst_matrix[i][j * 3];
            rgb_t *p_s = (rgb_t*) &src_matrix[i][j * 3];
            if (i < 2 || j < 2 || (i + 2) == filas || (j + 2) == cols){
                    *p_d=*p_s;
                }
            else{
                sumar = 0;
                sumag = 0;
                sumab = 0;
                //SI FUNCIONA ESTO ARMAR UNA FUNCION QUE HAGA ESTO PARA SIMPLIFICAR
                    for (int i_p = i-2; i_p <= i+2; ++i_p){
                        for (int j_p = j-2; j_p <= j+2; ++j_p){
                            rgb_t *s_s = (rgb_t*) &src_matrix[i_p][j_p*3];
                            sumar = sumar + s_s->r;
                        }
                    }
                         for (int i_p = i-2; i_p <= i+2; ++i_p){
                        for (int j_p = j-2; j_p <= j+2; ++j_p){
                            rgb_t *s_s = (rgb_t*) &src_matrix[i_p][j_p*3];
                            sumag = sumag + s_s->g;
                        }
                    }
                         for (int i_p = i-2; i_p <= i+2; ++i_p){
                        for (int j_p = j-2; j_p <= j+2; ++j_p){
                            rgb_t *s_s = (rgb_t*) &src_matrix[i_p][j_p*3];
                            sumab = sumab + s_s->b;
                        }
                    }
                    srcsuma = p_s->r + p_s->b + p_s->g;
                    sumargb = sumar + sumab + sumag;
                    multiplico = sumargb*srcsuma*alfa;
                    var= (double)multiplico/max;
                    //double prueba = MAX(( p_s->r + var),0);
                    p_d->r= MIN(MAX(( p_s->r + var),0),255);
                    p_d->b= MIN(MAX(( p_s->b + var),0),255);
                    p_d->g= MIN(MAX(( p_s->g + var),0),255);
                   // *p_d = *p_s;

/*
                    p_d->r = MIN(MAX( p_s->r + ((p_s->r * sumColores) / max), 0), 255);
                    p_d->g = MIN(MAX( p_s->g + ((p_s->g * sumColores) / max), 0), 255);
                    p_d->b = MIN(MAX( p_s->b + ((p_s->b * sumColores) / max), 0), 255);*/
            }
        }
    }
}
