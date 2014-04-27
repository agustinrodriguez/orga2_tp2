global popart_asm

%define pixels_por_ciclo 15

section .data

section .text
;void tiles_asm(unsigned char *src, RDI
;              unsigned char *dst, RSI
;              int filas, RDX
;              int cols, RCX
;              int src_row_size, R8
;              int dst_row_size ); R9

popart_asm:
	push RBP
	mov RBP, RSP
	push R12
	push R13

	mov R12, RDX ; R12 = RDX = filas
	mov R13, RCX ; R13 = RCX = cols

	xor R10, R10 ; R10 = 0

	; Pixels a procesar = filas * cols
	; Bytes a procesar = filas * cols * 3
	mov R10D, R13D ; R10D = cols
	mov EAX, 3
	mul R10D
	mov R10D, EAX ; R10D = cols * 3
	mov EAX, R12D
	mul R10D
	mov R10D, EAX ; R10 = filas * cols * 3

	.ciclo:
		cmp R10D, 0 ; si recorri todos los bytes
		jle .fin
		movdqu XMM0, [RDI]

		movdqu [RSI], XMM0

		add RDI, pixels_por_ciclo
		add RSI, pixels_por_ciclo
		sub R10D, pixels_por_ciclo
		jmp .ciclo

	.fin:
	pop R13
	pop R12
	pop RBP
    ret
