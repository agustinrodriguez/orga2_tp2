global tiles_asm

section .data

section .text
;void tiles_asm(unsigned char *src,
;              unsigned char *dst,
;              int filas,
;              int cols,
;              int src_row_size,
;              int dst_row_size );

tiles_asm:
	;R15 = PUNTERO A SRC
	;R14 = PUNTERO A DST
	;r13 = filas
	;r12 = cols
	; rbx = src_row
;	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
;	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
;	int cont_x = 0;
;	int cont_y = 0;

;	cont_x = cols/tamx;
;	cont_y = filas/tamy;


;	for (int i_d = 0, i_s = offsetx; i_d < filas; i_d++,i_s++) {
;		for (int j_d = 0, j_s = offsety; j_d < cols; j_d++,j_s++) {
;			rgb_t *p_d = (rgb_t*)&dst_matrix[i_d][j_d*3];
;			rgb_t *p_s = (rgb_t*)&src_matrix[i_s][j_s*3];
;			*p_d = *p_s;

		;	//printf("\nx: %d; y: %d", cont_x, cont_y);
		;	if(j_s == cols)
		;	{
		;		j_s = offsety;
		;	//	cont_x--;
		;	}
		;	if(i_s == filas)
		;	{
		;		i_s = offsetx;
		;		cont_y--;
		;		cont_x--;
								
		;	}
		;	if (cont_y == 0 && cont_x == 0)
		;	{
		;		j_s = tamx;
		;		i_s = tamy;
		;	}
		;}

;}

;}
	push rbp
	mov rbp, rsp            ; armar stackframe
	push rbx
	push r12
	push r13
	push r14
	push r15

	MOV R15, RDI
	MOV R14, RSI
	MOV R13, RDX
	MOV R12, RCX
	MOV RBX, R8

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
