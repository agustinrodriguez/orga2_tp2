
global ldr_asm

section .data

section .rodata align = 16
;mascaras en DB
	MASK_1_COLOR: DB 0x00, 0x03, 0x06, 0x09, 0x0C, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80
	MASK_1_COLORGREEN: DB 0x01, 0x04,0x07, 0x0A, 0x0D, 0x80, 0x80, 0x80, 0x80, 0x80,0x80,0x80,0x80,0x80,0x80,0x80
	MASK_1_COLORBLUE: DB 0x02,0x05, 0x08, 0x0B, 0x0E, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 , 0x80, 0x80, 0x80, 0x80, 0x80
	MASKPARACASOSPOSITIVOS: DB 0x00,0x02,0x04,0x06,0x08,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80,0x80
	MASK_FIN: DB 0x02,0x01,0x00,0x05,0x04,0x03,0x08,0x07,0x06,0x0B,0x0A,0x09,0x0E,0x0D,0x0C,0x80
	MASKCOLORROJO: DB 0x00,0x80,0x80,0x01,0x80,0x80,0x02,0x80,0x80,0x03,0x80,0x80,0x04,0x80,0x80,0x80
	MASKCOLORVERDE: DB 0x80,0x00,0x80,0x80,0x01,0x80,0x80,0x02,0x80,0x80,0x03,0x80,0x80,0x04,0x80,0x80
	MASKCOLORAZUL: DB 0x80,0x80,0x00,0x80,0x80,0x01,0x80,0x80,0x03,0x80,0x80,0x04,0x80,0x80,0x05,0x80
	MALFA: DB 0x00,0x80,0x80,0x80,0x00,0x80,0x80,0x80,0x00,0x80,0x80,0x80,0x00,0x80,0x80,0x80
;mascaras en DW
	M255: DW 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
	M0: DW 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
;mascaras en DD
	MASK_MAX: DD 0x4A6A4B, 0x4A6A4B, 0x4A6A4B, 0x4A6A4B
	
	

section .text
;void ldr_asm    (
	;unsigned char *src, RDI
	;unsigned char *dst, RSI
	;int filas, RDX
	;int cols, RCX
	;int src_row_size, R8
	;int dst_row_size R9
	;int alfa) [RSP + 8]

ldr_asm:
	push RBP
	mov RBP, RSP
	push RBX
	push R12
	push R13
	push R14

	; mov EBX, [RSP + 48] ; EBX = alfa

	mov R12D, 0 ; R12D = 0 contador de filas
	mov R13D, 0 ; R13D = 0 contador de columnas
	mov R14D, 0 ; R14 es el offset de acceso a la imagen
	mov EBX, 0 ; EBX = contador de bytes recorridos en fila

	.recorrido_fila:
		cmp R13D, ECX ; si recorrio todas las columnas
		je .fin

	.recorrido_columna:
		cmp R12D, EDX ; si recorrio toda la columna
		je .siguiente_columna

		; me fijo si es borde o interior
		cmp R12D, 2
		jl .es_borde
		cmp R13D, 2
		jl .es_borde
		mov EAX, R12D ; EAX = contador de filas
		add EAX, 2
		cmp EAX, EDX ; (i + 2) >= filas
		jge .es_borde
		mov EAX, R13D ; EAX = contador de cols
		add EAX, 2
		cmp EAX, ECX
		jge .es_borde

		; es interior
			xor RAX, RAX
			mov EAX, EBX
			add EAX, R14D

			sub EAX, R8D ; RAX = RAX - R8D ; -1
			movdqu XMM2, [RDI + RAX - 6]
			sub EAX, R8D ; RAX = RAX - R18D - R8D
			movdqu XMM1, [RDI + RAX - 6] ; -2
			add EAX, R8D 
			add EAX, R8D ; RAX = RAX 
			movdqu XMM3, [RDI + RAX - 6] ; pixels centrales
			add EAX, R8D ; RAX = RAX + R8D
			movdqu XMM4, [RDI + RAX - 6] ; +1
			add EAX, R8D ; RAX = RAX + R8D + R8D
			movdqu XMM5, [RDI + RAX - 6] ; +2

			; ACA VA LO DE GUIDO
	
			movdqu xmm6, xmm3 ; es el mismo solo q lo salvo para poder usar los colores de los pixel por separado en el final
				
		;sumo los colores de cada pixel
				xor R15,R15
				movdqu xmm0, xmm3
				jmp .sumarColores
			.sigo:
				movdqu xmm3,xmm0
				movdqu xmm0, xmm2
				jmp .sumarColores
			.sigo2:
				movdqu xmm2,xmm0
				movdqu xmm0, xmm1
				jmp .sumarColores
			.sigo3:
				movdqu xmm1,xmm0
				movdqu xmm0, xmm4
				jmp .sumarColores
			.sigo4:
				movdqu xmm4,xmm0
				movdqu xmm0, xmm5
				jmp .sumarColores
			.sigo5:
				movdqu xmm5, xmm0

		; sumo los pixeles
				paddw xmm1, xmm2
				paddw xmm3, xmm1
				paddw xmm3, xmm4
				paddw xmm3, XMM5
				;convierto a dw y a float para division
				;vamos a tener q cambiar de float a double porq como el numero es gigantesco pone cero de una
				; voy a multiplicar ahora por alfa
				;convierto a float para multiplicar
				movdqu xmm15, [RSP + 48]
				pshufb xmm15, [MALFA] 
				;suponiendo que ya tengo el alfa
				;chequear si queda en dword, segun especificacion de clase va a los cuatro pack de dword sino es convertirlo y listo
				;yo no lo puedo chequear ya que en mi rsp+48 me da un numero q entra en qword recien
				jmp .multiplicarXAlfa
			.continuamos:
				;en xmm6 me habia guardado los colores de cada pixel "actuales"
				movdqu xmm0, xmm6
				jmp	.multiplicoColoresConAlfaYSumaRGBSobreMax
			.dividirPorMax:
				;tengo en xmm1 b b b b b
				;tengo en xmm2 g g g g g
				;tengo en xmm4 r r r r r
;ACA HAY Q CHEQUEAR
				movdqu xmm11, [MASK_MAX]
				cvtdq2pd xmm11,xmm11
				; movdqu xmm7, xmm3
				; movdqu xmm8, xmm3
				; XORPD xmm9, xmm9
				; punpcklwd xmm7, xmm9 ;parte baja
				; punpckhwd xmm8, xmm9 ;parte alta
				;blue
				movdqu XMM9, XMM1
				CVTPS2PD XMM1, XMM1
				PSRLDQ XMM9, 8d
				CVTPS2PD XMM9, XMM9
				CVTPS2PD XMM2, XMM2
				divpd xmm1,XMM11 
				divpd xmm9,xmm11
				divpd xmm2,xmm11

				CVTPD2DQ xmm1,xmm1
				CVTPD2DQ xmm9, xmm9
				CVTPD2DQ xmm2, xmm2
				PSLLDQ XMM9, 8d
				paddd xmm1,xmm9
				PACKUSDW xmm1, xmm2
			
				;GREEN
				movdqu XMM9, XMM5
				CVTPS2PD XMM5, XMM5
				PSRLDQ XMM9, 8d
				CVTPS2PD XMM9, XMM9
				CVTPS2PD XMM6, XMM6
				divpd xmm5,XMM11 
				divpd xmm9,xmm11
				divpd xmm6,xmm11

				CVTPD2DQ xmm5,xmm5
				CVTPD2DQ xmm9, xmm9
				CVTPD2DQ xmm6, xmm6
				PSLLDQ XMM9, 8d
				paddd xmm5,xmm9
				PACKUSDW xmm5, xmm6

				;rojo
				movdqu XMM9, XMM7
				CVTPS2PD XMM7, XMM7
				PSRLDQ XMM9, 8d
				CVTPS2PD XMM9, XMM9
				CVTPS2PD XMM8, XMM8
				divpd xmm7,XMM11 
				divpd xmm9,xmm11
				divpd xmm8,xmm11

				CVTPD2DQ xmm7,xmm7
				CVTPD2DQ xmm9, xmm9
				CVTPD2DQ xmm8, xmm8
				PSLLDQ XMM9, 8d
				paddd xmm7,xmm9
				PACKUSDW xmm7, xmm8

				;en xmm1 tengo blue
				;en xmm5 tengo GREEN
				;en xmm7 tengo rojo
				movdqu xmm2, xmm15
				movdqu xmm6, xmm15
				movdqu xmm8, xmm15

				pshufb XMM2, [MASK_1_COLOR] ; BLUE XMM0 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
				movdqu xmm10, XMM2
				punpcklbw XMM10, XMM9 ; XMM10 = |0 b0|0 b1|0 b2|0 b3|0 b4|
				
				pshufb XMM7, [MASK_1_COLORGREEN] ; GREEN XMM1 = |g0|g1|g2|g3|g4|0|0|0|0|0|0|0|0|0|0|0|
				movdqu XMM12, XMM7
				punpcklbw XMM12, XMM9 ; XMM12 = |0 g0|0 g1|0 g2|0 g3|0 g4|

				pshufb XMM8, [MASK_1_COLORBLUE] ; RED XMM2 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
				movdqu XMM14, XMM8
				punpcklbw XMM14, XMM9 ; XMM14 = |0 r0|0 r1|0 r2|0 r3|0 r4|












				movdqu xmm3, xmm0
				paddw xmm1, xmm3
				paddw xmm2, xmm3
				paddw xmm4, xmm3
				movdqu xmm0, xmm1
				xor r15, r15
				jmp .chequeo
			.verdes:
				movdqu xmm1, xmm0
				movdqu xmm0, xmm2
				jmp .chequeo
			.rojos:
				movdqu xmm2, xmm0
				movdqu xmm0, xmm4
				jmp .chequeo
			.juntoTodo:
				movdqu xmm4, xmm0
				pshufb xmm1, [MASKCOLORROJO]
				pshufb xmm2, [MASKCOLORVERDE]
				pshufb xmm4, [MASKCOLORAZUL]
				paddb xmm1, xmm2
				paddb xmm1, xmm4
				movdqu xmm0, xmm1
				pshufb xmm0, [MASK_FIN]
				jmp .finCiclo


			.finCiclo:
				movdqu [RSI], XMM0   ;esto no se si va aca o si le agregas algo y en donde
				jmp .seguir

		.es_borde: ; copio la misma imagen
			xor RAX, RAX
			mov EAX, EBX
			add EAX, R14D
			mov R15, [RDI + RAX]
			mov [RSI + RAX], R15

		.seguir:
		add R12D, 1
		add R14D, R8D ; R14D = R14D + src_row_size
		jmp .recorrido_columna


	.siguiente_columna:
		mov R12D, 0 ; contador de filas en 0
		add R13D, 1 ; avanzo contador de columnas
		add EBX, 3 ; avanzo contador de columnas
		mov R14D, 0 ; pongo en cero el offset de fila
		jmp .recorrido_fila

	.sumarColores:
		movdqu XMM7, XMM0 ; XMM1 = XMM0
		movdqu XMM8, XMM0 ; XMM2 = XMM0
		
		XORPD XMM9, XMM9 ; XMM7 = 0

		pshufb XMM0, [MASK_1_COLOR] ; BLUE XMM0 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
		movdqu XMM10, XMM0
		punpcklbw XMM10, XMM9 ; XMM10 = |0 b0|0 b1|0 b2|0 b3|0 b4|
		
		pshufb XMM7, [MASK_1_COLORGREEN] ; GREEN XMM1 = |g0|g1|g2|g3|g4|0|0|0|0|0|0|0|0|0|0|0|
		movdqu XMM12, XMM7
		punpcklbw XMM12, XMM9 ; XMM12 = |0 g0|0 g1|0 g2|0 g3|0 g4|

		pshufb XMM8, [MASK_1_COLORBLUE] ; RED XMM2 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
		movdqu XMM14, XMM8
		punpcklbw XMM14, XMM9 ; XMM14 = |0 r0|0 r1|0 r2|0 r3|0 r4|
	
		paddw XMM10, XMM12
		paddw XMM10, XMM14
		movdqu XMM0, XMM10 ; XMM0 = |b0 + g0 + r0|b1 + g1 + r1|b2 + g2 + r2|b3 + g3 + r3|b4 + g4 + r4|
		add r15, 1
		CMP r15, 1
		je .sigo
		CMP r15,2
		je .sigo2
		CMP r15,3
		je .sigo3
		CMP r15,4
		je .sigo4
		CMP r15,5
		je .sigo5

	.multiplicarXAlfa:
		movdqu xmm7, xmm3
		movdqu xmm8, xmm3
		XORPD xmm9, xmm9
		punpcklwd xmm7, xmm9
		punpckhwd xmm8, xmm9
		cvtdq2ps xmm7, xmm7
		cvtdq2ps xmm8, xmm8
		cvtdq2ps xmm15, xmm15

		mulps XMM7, xmm15
		mulps XMM8, xmm15

		CVTPS2DQ xmm7,xmm7
		CVTPS2DQ xmm8, xmm8
		movdqu xmm3, xmm7
		movdqu xmm4, xmm8
		jmp .continuamos

		.multiplicoColoresConAlfaYSumaRGBSobreMax:
			movdqu XMM7, XMM0 ; XMM1 = XMM0
			movdqu XMM8, XMM0 ; XMM2 = XMM0
			movdqu xmm15, xmm0 ; aca tengo los colores por separado sin ninguna operacion


			XORPD XMM9, XMM9 ; XMM7 = 0
			;multiplico blue 
			pshufb XMM0, [MASK_1_COLOR] ; BLUE XMM0 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
			movdqu XMM10, XMM0
			punpcklbw XMM10, XMM9 ; XMM10 = |0 b0|0 b1|0 b2|0 b3|0 b4|
			;movdqu xmm1, xmm10

			movdqu xmm13, XMM10
			movdqu xmm14, XMM10
			XORPD xmm9, xmm9
			punpcklwd xmm13, xmm9
			punpckhwd xmm14, xmm9
			cvtdq2ps xmm13, xmm13
			cvtdq2ps xmm14, xmm14
			cvtdq2ps xmm3, xmm3
			cvtdq2ps xmm4, xmm4

			mulps xmm13, xmm3
			mulps XMM14, xmm4
			movdqu XMM1, XMM13
			movdqu XMM2, XMM14

			;multiplico verde

			pshufb XMM7, [MASK_1_COLORGREEN] ; GREEN XMM1 = |g0|g1|g2|g3|g4|0|0|0|0|0|0|0|0|0|0|0|
			movdqu XMM11, XMM7
			punpcklbw XMM11, XMM9 ; XMM12 = |0 g0|0 g1|0 g2|0 g3|0 g4|
			movdqu xmm2, xmm11

			movdqu xmm13, XMM11
			movdqu xmm14, XMM11
			XORPD xmm9, xmm9 
			punpcklwd xmm13, xmm9
			punpckhwd xmm14, xmm9
			cvtdq2ps xmm13, xmm13
			cvtdq2ps xmm14, xmm14
			cvtdq2ps xmm3, xmm3
			cvtdq2ps xmm4, xmm4

			mulps xmm13, xmm3
			mulps XMM14, xmm4
			movdqu XMM5, XMM13
			movdqu XMM6, XMM14

			;multiplico red
			pshufb XMM8, [MASK_1_COLORBLUE] ; RED XMM2 = |b0|b1|b2|b3|b4|0|0|0|0|0|0|0|0|0|0|0|
			movdqu XMM12, XMM8
			punpcklbw XMM12, XMM9 ; XMM14 = |0 r0|0 r1|0 r2|0 r3|0 r4|
			movdqu xmm4, xmm12
		
			movdqu xmm13, XMM12
			movdqu xmm14, XMM12
			XORPD xmm9, xmm9
			punpcklwd xmm13, xmm9
			punpckhwd xmm14, xmm9
			cvtdq2ps xmm13, xmm13
			cvtdq2ps xmm14, xmm14
			cvtdq2ps xmm3, xmm3
			cvtdq2ps xmm4, xmm4

			mulps xmm13, xmm3
			mulps XMM14, xmm4
			movdqu XMM7, XMM13
			movdqu XMM8, XMM14



			; paddd XMM10, XMM11
			; paddd XMM10, XMM12
			; movdqu XMM0, XMM10 ; XMM0 = |p_s->b * alfa * sumargb/max|p_s->g * alfa * sumargb/max|b2 + g2 + r2|b3 + g3 + r3|b4 + g4 + r4|
			jmp .dividirPorMax


			.chequeo:
		movdqu XMM14,[M0]
		movdqu xmm15,xmm0
		pcmpgtw XMM15, XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 31
		jmp .elNumeroEsMayorACero

	.chequeoLosMenoresACero:
		movdqu XMM14,[M0]
		movdqu xmm15,xmm0
		pcmpgtw XMM14,XMM15 ; COMPARO PACK A PACK SI ES MAYOR A 31
		jmp .elNumeroNoEsMayorACero

	.chequeoLosMenoresA255:
		xorpd xmm0,xmm0
		orpd xmm0,xmm1
		orpd xmm0,xmm2
		movdqu XMM14,[M255]
		movdqu xmm15,xmm0
		pcmpgtw XMM14,XMM15 ; COMPARO PACK A PACK SI ES MAYOR A 31
		jmp .elNumeroEsMenorA255
	
	.chequeoLosMayoresA255:
		movdqu XMM14,[M255]
		movdqu xmm15,xmm0
		pcmpgtw XMM15,XMM14 ; COMPARO PACK A PACK SI ES MAYOR A 31
		jmp .elNumeroEsMayorA255



		.elNumeroEsMayorACero:
			movdqu XMM13, xmm0
			movdqu xmm11, xmm15  ;ahora voy a invertir el registro con los casos positivos y negativos para asi sacarlos de xmm0
			pcmpeqw XMM14,XMM14 
			pxor xmm11, xmm14
			pand xmm0,xmm11
			pshufb XMM15, [MASKPARACASOSPOSITIVOS]
			pand xmm13, xmm15
			movdqu xmm2, xmm13
			jmp .chequeoLosMenoresA255

		.elNumeroNoEsMayorACero:
			movdqu XMM13, [M0]
			pshufb XMM15, [MASKPARACASOSPOSITIVOS]
			pand xmm13, xmm15
			movdqu xmm2, xmm13
			jmp .chequeoLosMenoresA255

		.elNumeroEsMenorA255:
			movdqu XMM13, xmm0
			movdqu xmm11, xmm15  ;ahora voy a invertir el registro con los casos positivos y negativos para asi sacarlos de xmm0
			pcmpeqw XMM14,XMM14 
			pxor xmm11, xmm14
			pand xmm0,xmm11
			pshufb XMM15, [MASKPARACASOSPOSITIVOS]
			pand xmm13, xmm15
			movdqu xmm4, xmm13
			jmp .chequeoLosMayoresA255

		.elNumeroEsMayorA255:
			movdqu XMM13, [M255]
			pshufb XMM15, [MASKPARACASOSPOSITIVOS]
			pand xmm13, xmm15
			movdqu xmm4, xmm13
			jmp .juntoDatosYVuelvo


		.juntoDatosYVuelvo:
			add r15, 1
			xorpd xmm0,xmm0
			orpd xmm0,xmm3
			orpd xmm0,xmm4
			cmp r15,1
			je .verdes
			cmp r15,2
			je .rojos
			cmp r15,3
			je .juntoTodo





	.fin:
	pop R14
	pop R13
	pop R12
	pop RBX
	pop RBP
    ret
 
