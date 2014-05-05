global tiles_asm

%define tamx [rbp + 16]
%define tamy [rbp + 24]
%define offsetx [rbp + 32]
%define offsety [rbp + 40]

section .data


section .text
;void tiles_asm(unsigned char *src,
;              unsigned char *dst,
;              int filas,
;              int cols,
;              int src_row_size,
;              int dst_row_size );


tiles_asm:

; rdi = matriz fuente
; rsi = matriz destino
; rdx = filas
; rcx = columnas 
; r8 = src_row_size
; r9 = dst_row_size
; rbp + 16 = tamx
; rbp + 24 = tamy
; rbp + 32 = offsetx
; rbp + 40 = offsety

	push rbp
	mov rbp, rsp            ; armar stackframe
	push rbx
	push r12
	push r13
	push r14
	push r15

	MOV R14, RDI ; r14 = matriz fuente
	MOV R15, RSI ; r15 = matriz destino
	mov rbx, rcx ; rbx = columnas 
	;add r14, r8 ; r14 = final linea actual scr
	;add r14, r8
	mov r11d, offsety			;R11 = offsety
	mov rax, r8			;rax = rsc_row_size
	mul r11 ;eax = offsety*rsc_row_size
	mov r11, rax
	add rdi, r11 ; rdi = rdi + (offsety+src_row_size)
	mov r12d, offsetx
	add rdi, r12 ; el puntero apunta a la columna del cuadro a replicar 
	add rdi, r12
	add rdi, r12
	mov R13d, tamx 
	mov ax, r13w ; ax parte baja de tamx	
	mov edx, tamx
	shr edx, 16				;DX = parte alta de tamx
	mov r13w, 15	;R13W = 15
	div r13w				;AX = tamx/15 , DX = resto
	xor r12, r12
	mov r12w, dx		; r12w = resto tamx/15
	xor r13, r13
	mov r13w, ax ; r13 = tamx/5	
	mov ax, r9w		;aX = parte baja de dst_row_size
	mov edx, r9d
	shr edx, 16				;DX = parte alta de dst_row_size
	xor r11, r11
	mov r11w, 15	;R13W = 15
	div r11w				;AX = dst_row_size/15 , DX = resto
	xor r15, r15
	mov r15w, ax ; r15w = dst_row_size/15
	xor r11, r11
	mov r11, rdi ; r11d para volver alprincipio del cuadro
	mov r10d, tamy ; en r10 esta la cantidad de columnas del cuadro

.ciclo_por_linea_dst:
		xor rcx, rcx
		mov cx, r13w ; cantidad de veces a ciclar una linea del cuadro a replicar
.ciclo_linea_cuadro:
			movdqu xmm0, [rdi]		;levanto 5 pixels de fuente
			movdqu [rsi], xmm0		;los copio a destino
			add rsi, 15
			add rdi, 15 ; adelanto punteros
			dec ax
			cmp word ax, 0
			je .terminaLineaDst
			loop .ciclo_linea_cuadro
			cmp word r12w, 0			;quedan pixels desalineados?
			je .noquedanDesalineados
			movdqu xmm0, [rdi]
			movdqu [rsi], xmm0
			add rsi, r12 ; adelanto el puntero solo lo que llene
			add dx, r12w ; le agrego el resto al resto de la linea de dst
			jmp .noquedanDesalineados

.terminaLineaDst:
		cmp word dx, 15 ; quedan mas de 15 desalineados?
		jge .aumentarAX
		cmp word dx, 0 ; quedan desalineados?
		je .finLineaDst 
		movdqu xmm0, [rdi]
		movdqu [rsi], xmm0
		add rsi, rdx
		jmp .finLineaDst
.aumentarAX:
	mov r9d, edx
	mov ax, dx		;aX = parte baja de dst_row_size
	mov edx, r9d 
	shr edx, 16				;dx = parte alta de dst_row_size
	xor r9, r9
	mov r9w, 15	;R13W = 15
	div r9w				;AX = dst_row_size/15 , DX = resto
	jmp .ciclo_por_linea_dst
		
.noquedanDesalineados:
		mov rdi, r14 ; pongo el puntero de nuevo en el principio de linea del cuadro
		jmp .ciclo_por_linea_dst
.finLineaDst:
		mov rdi, r14 ; pongo el puntero al principio del cuadro
		add rdi, r8 ; paso a la prox linea del cuadro
		;mov rdi, rsi
		mov r14, rdi ; actualizo principioo de nueva linea
		dec r10d
		cmp r10d, 0
		je .finCuadro
.sigue:		
		add eax, r15d 
		dec rbx  ; decremento cantidad de columnas
		jnz .ciclo_por_linea_dst		
		jmp .fin
.finCuadro:
	mov rdi, r11 ; rdi vuelve al principio del cuadro
	mov r14, r11 
	mov r10d, tamy
	jmp .sigue
	
.fin:	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
