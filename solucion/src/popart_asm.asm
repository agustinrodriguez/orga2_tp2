global popart_asm

%define pixels_por_ciclo 15

section .rodata align = 16
	MASK_1_COLOR: DB 0x00, 0x03, 0x06, 0x09, 0x0C, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
	MASK_1_COLORGREEN: DB 0x01, 0x04,0x07, 0x0A, 0x0D, 0x80, 0x80, 0x80, 0x80, 0x80,0x80,0x80,0x80,0x80,0x80,0x80
	MASK_1_COLORBLUE: DB 0x02,0x05, 0x08, 0x0B, 0x0E, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 , 0x80, 0x80, 0x80, 0x80, 0x80
	
	MASK_FIN: DB 0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x00
	MASK_1: DB 0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0x00
	MASK_2: DB 0x7F,0x00,0x7F,0x7F,0x00,0x7F,0x7F,0x00,0x7F,0x7F,0x00,0x7F,0x7F,0x00,0x7F,0x00
	MASK_3: DB 0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0x00
	MASK_4: DB 0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00,0x00,0xFF,0x00
	MASK_5: DB 0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00,0xFF,0xFF,0x00


	MASK_DE1WORDA3BYTES: DB 0x00,0x00,0x00,0x02,0x02,0x02,0x04,0x04,0x04,0x06,0x06,0x06,0x08,0x08,0x08,0x80


	MASK_152: DW 0x0098,0x0098,0x0098,0x0098,0x0098,0x0080,0x0080,0x0080
	MASK_153: DW 0x0099,0x0099,0x0099,0x0099,0x0099,0x0080,0x0080,0x0080
	MASK_305: DW 0x0131,0x0131,0x0131,0x0131,0x0131,0x0131,0x0131,0x0131
	MASK_458: DW 0x01CA,0x01CA,0x01CA,0x01CA,0x01CA,0x01CA,0x01CA,0x01CA
	MASK_611: DW 0x0263,0x0263,0x0263,0x0263,0x0263,0x0263,0x0263,0x0263

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
	mov r15d, r10d
	mov EAX, R12D
	mul R10D
	mov R10D, EAX ; R10 = filas * cols * 3
	;xor r15,r15
	;mov R15D, R13D ; R10D = cols
	mov r14d, r15d
	mov r11, rdi
	mov r13, rsi


	.ciclo:
		cmp R10D, 0 ; si recorri todos los bytes
		jle .fin
		cmp r15d, 15
		jl .llegueAlFinalDeLaLinea
		movdqu XMM0, [RDI] ; XMM0(B) = |b0|g0|r0|b1|g1|r1|b2|g2|r2|b3|g3|r3|b4|g4|r4|b|

	.arranco:

		movdqu XMM1, XMM0 ; XMM1 = XMM0
		movdqu XMM2, XMM0 ; XMM2 = XMM0
		
		XORPD XMM7, XMM7 ; XMM7 = 0

		pshufb XMM0, [MASK_1_COLOR] ; BLUE XMM0 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
		movdqu XMM10, XMM0
		punpcklbw XMM10, XMM7 ; XMM10 = |0 b0|0 b1|0 b2|0 b3|0 b4|
		
		pshufb XMM1, [MASK_1_COLORGREEN] ; GREEN XMM1 = |g0|g1|g2|g3|g4|0|0|0|0|0|0|0|0|0|0|0|
		movdqu XMM12, XMM1
		punpcklbw XMM12, XMM7 ; XMM12 = |0 g0|0 g1|0 g2|0 g3|0 g4|

		pshufb XMM2, [MASK_1_COLORBLUE] ; RED XMM2 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
		movdqu XMM14, XMM2
		punpcklbw XMM14, XMM7 ; XMM14 = |0 r0|0 r1|0 r2|0 r3|0 r4|

		
		paddw XMM10, XMM12
		paddw XMM10, XMM14
		movdqu XMM0, XMM10 ; XMM0 = |b0 + g0 + r0|b1 + g1 + r1|b2 + g2 + r2|b3 + g3 + r3|b4 + g4 + r4|
		
		XORPD XMM1, XMM1
		XORPD XMM2, XMM2
		XORPD XMM3, XMM3
		XORPD XMM4, XMM4
		XORPD XMM5, XMM5
		XORPD XMM10, XMM10

		jmp .chequeo


	.llegueAlFinalDeLaLinea:
		xor r12, r12
		mov r12d, r15d
		;sub r12, 1
		movdqu xmm0, [RDI - pixels_por_ciclo + r12]
		jmp .arranco
	.terminoBorde:
		movdqu [RSI- pixels_por_ciclo + r12], XMM0
		add r11, r8
		add r13, r8
		mov RDI, r11
		mov r11, rdi
		mov RSI, r13
		mov r13, rsi
		sub R10D, r15d
		mov r15d, r14d
		jmp .ciclo


	.sigo:
		por XMM1, XMM2
		por XMM1, XMM3
		por XMM1, XMM4
		por XMM1, XMM5
		movdqu XMM0, XMM1
		cmp r15d, 15
		jl .terminoBorde
		;pshufb XMM0, [MASK_FIN] no se si hay q guardarlo al reves o no
		movdqu [RSI], XMM0
		sub r15d, pixels_por_ciclo
		add RDI, pixels_por_ciclo
		add RSI, pixels_por_ciclo
		sub R10D, pixels_por_ciclo
		jmp .ciclo

	.chequeo: 
		
		.sigoCon5:
			movdqu XMM14,[MASK_611]
			movdqu XMM15, XMM0
			pcmpgtw XMM15, XMM14  ; COMPARO PACK A PACK SI ES MAYOR A 611
			jmp .elQuinto

		.sigoCon4:
			movdqu XMM14,[MASK_458]
			movdqu XMM15, XMM0
			pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 459
			jmp .elCuarto

		.sigoCon3:
			movdqu XMM14,[MASK_305]
			movdqu XMM15, XMM0
			pcmpgtw XMM15, XMM14  ; COMPARO PACK A PACK SI ES MAYOR A 305
			jmp .elTercero

		.sigoCon2:
			movdqu XMM14,[MASK_152]
			movdqu XMM15, XMM0
			pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 152
			jmp .elSegundo

		.sigoCon1:
			movdqa XMM14,[MASK_153]
			movdqu XMM6, XMM10 ; me quedo con XMM10 y laburo con el de XMM6
			pcmpeqw XMM7, XMM7 ; XMM7 = |1|1|1|1|1|1|1|1|1|1|1|1|1|1|1|1
			pxor XMM6, XMM7 ; deja en 1 este caso y 0 los casos ya checkeados
			pand XMM14, XMM6 ; en XMM14 queda los 153 en los lugares que tengo que comparar
			movdqu XMM15, XMM0
			pcmpgtw XMM14, XMM15 ; COMPARO PACK A PACK SI ES MENOR A 153
			jmp .elPrimero
	
		
	.elPrimero:
		movdqu XMM13,[MASK_1]
		movdqu XMM11, XMM14
		PADDUSW XMM10, XMM14  ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM15,XMM15
		pxor XMM11, XMM15
		pand XMM0, XMM11
		pshufb XMM14, [MASK_DE1WORDA3BYTES]
		pand XMM13, XMM14 ; en XMM13 queda los colores a poner en el lugar que van
		movdqu XMM1, XMM13
		jmp .sigo
	
	.elSegundo:
		movdqu XMM13,[MASK_2]
		movdqu xmm11, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14
		pxor XMM11, XMM14
		pand XMM0, XMM11
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand XMM13, XMM15
		movdqu XMM2, XMM13
		jmp .sigoCon1

	.elTercero:
		movdqu XMM13, [MASK_3]
		movdqu XMM11, XMM15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14, XMM14 
		pxor XMM11, XMM14
		pand XMM0, XMM11

		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand XMM13, XMM15
		movdqu XMM3, XMM13
		jmp .sigoCon2

	.elCuarto:
		movdqu XMM13, [MASK_4]
		movdqu xmm11, xmm15		
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14, XMM14
		pxor XMM11, XMM14
		pand XMM0, XMM11
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand XMM13, XMM15
		movdqu XMM4, XMM13
		jmp .sigoCon3

	.elQuinto:
		movdqu XMM13, [MASK_5]
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		movdqu XMM11, XMM15
		pcmpeqw XMM14, XMM14
		pxor XMM11, XMM14
		pand XMM0, XMM11
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand XMM13, XMM15
		movdqu XMM5, XMM13
		jmp .sigoCon4

	.fin:
	pop R13
	pop R12
	pop RBP
    ret