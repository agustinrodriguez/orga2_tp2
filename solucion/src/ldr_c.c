
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
    int max = 4876875; // 5*5*255*3*255;
    double sumargb = 0;
    double varr = 0;
    double varg = 0;
    double varb = 0;
    for (int i = 0; i < filas; i++) {
        for (int j = 0; j < cols; j++) {
            rgb_t *p_d = (rgb_t*) &dst_matrix[i][j * 3];
            rgb_t *p_s = (rgb_t*) &src_matrix[i][j * 3];
            if (i < 2 || j < 2 || (i + 2) >= filas || (j + 2) >= cols) {
                *p_d=*p_s;
            } else {
                sumargb = 0;
                for (int i_p = i-2; i_p <= i+2; ++i_p) {
                    for (int j_p = j-2; j_p <= j+2; ++j_p) {
                        rgb_t *s_s = (rgb_t*) &src_matrix[i_p][j_p*3];
                        sumargb += s_s->r + s_s->g + s_s->b;
                    }
                }

                sumargb = sumargb/max;

                varr = (double) (p_s->r * alfa * sumargb);
                varg = (double) (p_s->g * alfa * sumargb);
                varb = (double) (p_s->b * alfa * sumargb);

                p_d->b= MIN(MAX(( p_s->b + varg),0),255);
                p_d->g= MIN(MAX(( p_s->g + varb),0),255);
                p_d->r= MIN(MAX(( p_s->r + varr),0),255);
            }
        }
    }
}
