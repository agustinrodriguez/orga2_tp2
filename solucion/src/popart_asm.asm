global popart_asm

%define pixels_por_ciclo 15

section .rodata align = 16
	MASK_1_COLOR: DB 0x80, 0x00, 0x80, 0x03, 0x80, 0x60, 0x80, 0x90, 0x80, 0x0C, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
	UNO: DB 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80

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
		movdqu XMM0, [RDI] ; xmm0(B) = | b | g | r | b | g | r | b | g | r | b | g | r | b | g | r | b |

		movdqu XMM1, XMM0 ; XMM1 = XMM0
		movdqu XMM2, XMM0 ; XMM2 = XMM0
		movdqu XMM3, XMM0 ; XMM3 = XMM0

		pshufb XMM0, [MASK_1_COLOR] ; XMM0(B) = | 0 | b | 0 | b | 0 | b | 0 | b | 0 | b | 0 | 0 | 0 | 0 | 0 | 0 |

		movdqu XMM15, [MASK_1_COLOR]
		paddb XMM15, [UNO] ; configuro la mascara para que me queden los indices en el siguiente color
		pshufb XMM1, XMM15 ; XMM1(B) = | 0 | g | 0 | g | 0 | g | 0 | g | 0 | g | 0 | 0 | 0 | 0 | 0 | 0 |

		paddb XMM15, [UNO] ; configuro la mascara para que me queden los indices en el siguiente color
		pshufb XMM2, XMM15 ; XMM2 = | 0 | r | 0 | r | 0 | r | 0 | r | 0 | r | 0 | 0 | 0 | 0 | 0 | 0 |

		; sumos los words
		paddw XMM0, XMM1 ; XMM0 = | b + g | b + g | b + g | b + g | b + g | 0 | 0 | 0 |
		paddw XMM0, XMM2 ; XMM0 = | b + g + r | b + g + r | b + g + r | b + g + r | b + g + r | 0 | 0 | 0 |


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
