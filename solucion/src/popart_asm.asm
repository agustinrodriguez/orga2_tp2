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


	MASK_152: DW 0x98,0x98,0x98,0x98,0x98,0x80,0x80,0x80
	MASK_305: DW 0x131,0x131,0x131,0x131,0x131,0x131,0x131,0x131
	MASK_459: DW 0x1CB,0x1CB,0x1CB,0x1CB,0x1CB,0x1CB,0x1CB,0x1CB
	MASK_611: DW 0x263,0x263,0x263,0x263,0x263,0x263,0x263,0x263
	MASK_764: DW 0x2FC,0x2FC,0x2FC,0x2FC,0x2FC,0x2FC,0x2FC,0x2FC

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
		movdqu xmm2,xmm0
		
		pshufb XMM0, [MASK_1_COLOR] ; RED
		movdqu xmm10, xmm0
		XORPD xmm7,xmm7
		punpcklbw xmm10, xmm7 ; xmm1 = 0ja7j : : : j0ja0
		
		pshufb XMM1, [MASK_1_COLORGREEN] ; GREEN
		movdqu XMM12, xmm1
		XORPD xmm7,xmm7
		punpcklbw xmm12, xmm7 ; xmm1 = 0ja7j : : : j0ja0

		pshufb XMM2, [MASK_1_COLORBLUE] ; BLUE
		movdqu XMM14, xmm2
		XORPD xmm7,xmm7
		punpcklbw xmm14, xmm7 ; xmm1 = 0ja7j : : : j0ja0

		
		paddw xmm10,xmm12
		paddw xmm10,xmm14
		movdqu xmm0, xmm10
		
		XORPD XMM1,XMM1
		XORPD XMM2, XMM2
		XORPD XMM3,XMM3
		XORPD XMM4,XMM4
		XORPD XMM5,XMM5
		XORPD xmm10, xmm10

		XORPD XMM14,XMM14
		movdqu xmm15, XMM0 ; lo salvo 
		PCMPEQW XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR O IGUAL A CERO
		jge .chequeo

	.sigo:
		por XMM1,XMM2
		por XMM1,XMM3
		por XMM1,XMM4
		por XMM1,XMM5
		movdqu xmm0, xmm1
		;pshufb xmm0, [MASK_FIN] no se si hay q guardarlo al reves o no
		movdqu [RSI], XMM0
		add RDI, pixels_por_ciclo
		add RSI, pixels_por_ciclo
		sub R10D, pixels_por_ciclo
		jmp .ciclo

	.chequeo: 
		
		.sigoCon5:
			movdqu XMM14,[MASK_611]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14  ; COMPARO PACK A PACK SI ES MAYOR A 611
			jmp .elQuinto

		.sigoCon4:
			movdqu XMM14,[MASK_459]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 459
			jmp .elCuarto

		.sigoCon3:
			movdqu XMM14,[MASK_305]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14  ; COMPARO PACK A PACK SI ES MAYOR A 305
			jmp .elTercero

		.sigoCon2:
			movdqu XMM14,[MASK_152]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 152
			jmp .elSegundo

		.sigoCon1:
			movdqa XMM14,[MASK_152]
			movdqu XMM6, XMM10 ; me quedo con xmm10 y laburo con el de xmm6
			pcmpeqw XMM7,XMM7
			pxor xmm6, xmm7
			pand xmm14,xmm6
			movdqu xmm15,XMM0
			pcmpgtw XMM14, XMM15 ; COMPARO PACK A PACK SI ES MENOR A 152
			jmp .elPrimero
	
		
	.elPrimero:
		movdqu XMM13,[MASK_1]
		movdqu xmm11, xmm14
		PADDUSW XMM10, XMM14  ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM15,XMM15
		pxor xmm11, xmm15
		pand xmm0,xmm11
		pshufb XMM14, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm14
		movdqu xmm1, xmm13
		jmp .sigo
	
	.elSegundo:
		movdqu XMM13,[MASK_2]
		movdqu xmm11, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14
		pxor xmm11, xmm14
		pand xmm0,xmm11
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		movdqu xmm2, xmm13
		jmp .sigoCon1

	.elTercero:
		movdqu XMM13,[MASK_3]
		movdqu xmm11, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14 
		pxor xmm11, xmm14
		pand xmm0,xmm11

		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		movdqu xmm3, xmm13
		jmp .sigoCon2

	.elCuarto:
		movdqu XMM13,[MASK_4]
		movdqu xmm11, xmm15		
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14
		pxor xmm11, xmm14
		pand xmm0,xmm11
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		movdqu xmm4, xmm13
		jmp .sigoCon3

	.elQuinto:
		movdqu XMM13,[MASK_5]
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		movdqu xmm11, xmm15
		pcmpeqw XMM14,XMM14
		pxor xmm11, xmm14
		pand xmm0,xmm11
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		movdqu xmm5, xmm13
		jmp .sigoCon4

	.fin:
	pop R13
	pop R12
	pop RBP
    ret