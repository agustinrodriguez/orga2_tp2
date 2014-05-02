global temperature_asm

%define pixels_por_ciclo 15

section .rodata align = 16
	MASK_1_COLOR: DB 0x00, 0x03, 0x06, 0x09, 0x0C, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
	MASK_1_COLORGREEN: DB 0x01, 0x04,0x07, 0x0A, 0x0D, 0x80, 0x80, 0x80, 0x80, 0x80,0x80,0x80,0x80,0x80,0x80,0x80
	MASK_1_COLORBLUE: DB 0x02,0x05, 0x08, 0x0B, 0x0E, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 , 0x80, 0x80, 0x80, 0x80, 0x80
;	UNO: DB 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x01, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80

	;MASCARA PARA CASO 255
	MASK_1: DB 0x80,0x80,0x00,0x80,0x80,0x00,0x80,0x80,0x00,0x80,0x80,0x00,0x80,0x80,0x00,0x80
	MASK_2: DB 0x80,0x00,0xFF,0x80,0x00,0xFF,0x80,0x00,0xFF,0x80,0x00,0xFF,0x80,0x00,0xFF,0x80
	MASK_3: DB 0x00,0xFF,0xFF-0x00,0x00,0xFF,0xFF-0x00,0x00,0xFF,0xFF-0x00,0x00,0xFF,0xFF-0x00,0x00,0xFF,0xFF-0x00,0x80
	MASK_4: DB 0xFF,0x00,0x80,0xFF,0x00,0x80,0xFF,0x00,0x80,0xFF,0x00,0x80,0xFF,0x00,0x80,0x80
	MASK_5: DB 0x00,0x80,0x80,0x00,0x80,0x80,0x00,0x80,0x80,0x00,0x80,0x80,0x00,0x80,0x80,0x80

	DIVIDO: DD 3,3,3,3

MASK_DE1WORDA3BYTES: DB 0x00,0x00,0x00,0x02,0x02,0x02,0x04,0x04,0x04,0x06,0x06,0x06,0x08,0x08,0x08,0x80


	
	MASK_31: DW 0x1F,0x1F,0x1F,0x1F,0x1F,0x1F,0x1F,0x1F
	MASK_95: DW 0x5F,0x5F,0x5F,0x5F,0x5F,0x5F,0x5F,0x5F
	MASK_159: DW 0x9F,0x9F,0x9F,0x9F,0x9F,0x9F,0x9F,0x9F
	MASK_223: DW 0xDF,0xDF,0xDF,0xDF,0xDF,0xDF,0xDF,0xDF

	M4: DW 0x04,0x04,0x04,0x04,0x04,0x04,0x04,0x04
	M32: DW 0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20
	M128: DW 0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80
	M255: DW 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	M96: DW 0x60,0x60,0x60,0x60,0x60,0x60,0x60,0x60
	M160: DW 0xA0,0xA0,0xA0,0xA0,0xA0,0xA0,0xA0,0xA0
	M224: DW 0xE0,0xE0,0xE0,0xE0,0xE0,0xE0,0xE0,0xE0

section .data

section .text
;void temperature_asm(unsigned char *src,
;              unsigned char *dst,
;              int filas,
;              int cols,
;              int src_row_size,
;              int dst_row_size);

temperature_asm:
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

		movdqu xmm10, [DIVIDO]
		
		movdqu xmm1, xmm0
		movdqu xmm2, xmm0
		XORPD xmm15, xmm15
		punpcklwd xmm1, xmm15
		punpckhwd xmm2, xmm15
		cvtdq2ps xmm1, xmm1
		cvtdq2ps xmm2, xmm2
		cvtdq2ps xmm10,xmm10

		divps XMM1, xmm10
		divps XMM2, xmm10

		CVTPS2DQ xmm1,xmm1
		CVTPS2DQ xmm2, xmm2
		PACKUSDW xmm1, xmm2


		movdqu xmm0, xmm1
		
		XORPD XMM1,XMM1
		XORPD XMM2, XMM2
		XORPD XMM3,XMM3
		XORPD XMM4,XMM4
		XORPD XMM5,XMM5

		
		XORPD XMM14,XMM14
		movdqu xmm15, XMM0 ; lo salvo 
		PCMPEQW XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR O IGUAL A CERO
		jge .chequeo

.chequeo: 
		
		.sigoCon5:
			movdqu XMM14,[MASK_223]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14  ; COMPARO PACK A PACK SI ES MAYOR A 223
			jmp .elQuinto

		.sigoCon4:
			movdqu XMM14,[MASK_159]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 159
			jmp .elCuarto

		.sigoCon3:
			movdqu XMM14,[MASK_95]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14  ; COMPARO PACK A PACK SI ES MAYOR A 95
			jmp .elTercero

		.sigoCon2:
			movdqu XMM14,[MASK_31]
			movdqu xmm15,xmm0
			pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 31
			jmp .elSegundo

		.sigoCon1:
			movdqa XMM14,[MASK_31]
			movdqu XMM6, XMM10 ; me quedo con xmm10 y laburo con el de xmm6
			pcmpeqw XMM7,XMM7
			pxor xmm6, xmm7
			pand xmm14,xmm6
			movdqu xmm15,XMM0
			pcmpgtw XMM14, XMM15 ; COMPARO PACK A PACK SI ES MENOR A 31
			jmp .elPrimero
	
		
	.elPrimero:
		movdqu xmm12, xmm15
		mulps xmm12, [M4]
		movdqu XMM13, [M128]
		SUBPS XMM13, xmm15
		pshufb xmm13, [MASK_1]  ;obtengo los valores rgb del caso 1 en cada pack
		movdqu xmm6,xmm10 ; copio para que los casos q estan en 0 no me los vuelva a contar y mal
		pcmpeqw XMM15,XMM15
		pxor xmm6, xmm15
		pand xmm13,xmm6

		pshufb XMM14, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm14
		PADDUSW XMM10, XMM14  ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM15,XMM15
		pxor xmm14, xmm15
		pand xmm0,xmm14
		movdqu xmm1, xmm13
		jmp .sigo
	
	.elSegundo:
		movdqu xmm13, xmm0
		SUBPS XMM13, [M32]
		mulps xmm13, [M4]
		pshufb xmm13, [MASK_2]  ;obtengo los valores rgb del caso 1 en cada pack
		movdqu xmm6,xmm10 ; copio para que los casos q estan en 0 no me los vuelva a contar y mal
		pcmpeqw XMM14,XMM14
		pxor xmm6, xmm14
		pand xmm13,xmm6

		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14
		pxor xmm15, xmm14
		pand xmm0,xmm15
		movdqu xmm2, xmm13
		jmp .sigoCon1

	.elTercero:
		movdqu xmm13, xmm0
		SUBPS XMM13, [M96]
		mulps xmm13, [M4]
		pshufb xmm13, [MASK_3]  ;obtengo los valores rgb del caso 1 en cada pack
		movdqu xmm6,xmm10 ; copio para que los casos q estan en 0 no me los vuelva a contar y mal
		pcmpeqw XMM14,XMM14
		pxor xmm6, xmm14
		pand xmm13,xmm6
	
		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14 
		pxor xmm15, xmm14
		pand xmm0,xmm15
		movdqu xmm3, xmm13
		jmp .sigoCon2

	.elCuarto:
		movdqu xmm13, xmm0
		SUBPS XMM13, [M160]
		mulps xmm13, [M4]
		movdqu xmm11, [M255]
		SUBPS xmm11, xmm13
		movdqu xmm13, xmm11
		pshufb xmm13, [MASK_4]  ;obtengo los valores rgb del caso 1 en cada pack
		movdqu xmm6,xmm10 ; copio para que los casos q estan en 0 no me los vuelva a contar y mal
		pcmpeqw XMM14,XMM14
		pxor xmm6, xmm14
		pand xmm13,xmm6


		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14
		pxor xmm15, xmm14
		pand xmm0,xmm15
		movdqu xmm4, xmm13
		jmp .sigoCon3

	.elQuinto:
		movdqu xmm13, xmm0
		SUBPS XMM13, [M224]
		movdqu xmm11, [M255]
		SUBPS xmm11, xmm13
		movdqu xmm13, xmm11
		pshufb xmm13, [MASK_5]  ;obtengo los valores rgb del caso 1 en cada pack

		pshufb XMM15, [MASK_DE1WORDA3BYTES]
		pand xmm13, xmm15
		PADDUSW XMM10, XMM15 ;este lo uso para poner en 1 los pack que ya tuvieron su caso
		pcmpeqw XMM14,XMM14
		pxor xmm15, xmm14
		pand xmm0,xmm15
		movdqu xmm5, xmm13
		jmp .sigoCon4




	.sigo:
		ORPD XMM1,XMM2
		ORPD XMM1,XMM3
		ORPD XMM1,XMM4
		ORPD XMM1,XMM5
		movdqu xmm0, xmm1
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
