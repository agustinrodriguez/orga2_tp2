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
	mov eax, r8d			;eax = rsc_row_size
	mul r11d ;eax = offsety*rsc_row_size
	mov r11d, eax
	add rdi, r11 ; rdi = rdi + (offsety*src_row_size)
	mov r12d, offsetx
	add rdi, r12 ; el puntero apunta a la columna del cuadro a replicar 
	add rdi, r12
	add rdi, r12
	xor r12, r12
	mov r12d, tamx
	add r12d, tamx
	add r12d, tamx
	;add r12, 3
	xor r11, r11
	mov r11, rdi ; r11d para volver alprincipio del cuadro
	mov r14, r11
	mov r10d, tamy ; en r10 esta la cantidad de columnas del cuadro
	;inc r10d
	xor eax, eax
	mov eax, r8d ; eax le pongo el tamaño de linea de surce
.ciclo_por_linea_dst:
		xor r13, r13
		mov r13d, r12d ; cantidad de veces a ciclar una linea del cuadro a replicar
.ciclo_linea_cuadro:
			cmp eax, 15
			jb .terminaLineaDst
			cmp r13d, 15
			jb .tamxMenorA15
			movdqu xmm0, [rdi]		;levanto 5 pixels de fuente
			movdqu [rsi], xmm0		;los copio a destino
			add rsi, 15
			add rdi, 15 ; adelanto punteros
			sub r13d, 15
			sub eax, 15
			cmp eax, 15
			jb .terminaLineaDst
			cmp r13d, 15
			jg .ciclo_linea_cuadro
	cmp r13d, 0
	je .noquedanDesalineados
	movdqu xmm0, [rdi]
	movdqu [rsi], xmm0
	add rsi, r13 ; adelanto el puntero solo lo que me sobra 
	add rdi, r13
	sub eax, r13d
	jmp .noquedanDesalineados

.tamxMenorA15:
	cmp r13d, 0
	movdqu xmm0, [rdi]
	movdqu [rsi], xmm0
	add rsi, r13 ; adelanto el puntero solo lo que me sobra 
	sub eax, r13d
	cmp eax, 15
	jb .terminaLineaDst
	jmp .noquedanDesalineados
		
.terminaLineaDst:
		cmp eax, 0
		je .finLineaDst
		;cmp eax, r13d
		;jg .unaMas
		cmp rbx, 1
		je .elFINAL
		movdqu xmm0, [rdi]
		movdqu [rsi], xmm0
		add rsi, rax
		jmp .finLineaDst		
;.unaMas:
;	movdqu xmm0, [rdi]
;	movdqu [rsi], xmm0
;	add rsi, r13
;	sub eax, r13d
;	mov rdi, r14 ; pongo el puntero de nuevo en el principio de linea del cuadro
;	jmp .terminaLineaDst		
		
.noquedanDesalineados:
		mov rdi, r14 ; pongo el puntero de nuevo en el principio de linea del cuadro
		jmp .ciclo_por_linea_dst
.finLineaDst:
		cmp rbx, 1
		je .elFINAL
		mov rdi, r14 ; pongo el puntero al principio del cuadro
		add rdi, r8 ; paso a la prox linea del cuadro
		mov r14, rdi ; actualizo principio de nueva linea
		dec r10d
		cmp r10d, 0
		je .finCuadro
.sigue:	
		xor rax, rax
		add eax, r8d 
		dec rbx  ; decremento cantidad de columnas
		jmp .ciclo_por_linea_dst		
.finCuadro:
	mov rdi, r11 ; rdi vuelve al principio del cuadro
	mov r14, r11 
	mov r10d, tamy
	;inc r10d
	jmp .sigue

.renuevo:
	mov rdi, r14
.elFINAL:
	cmp r13d, 0
	je .renuevo
	cmp eax, 0 
	je .fin
	xor r12, r12
	mov r12, [rdi]
	mov [rsi], r12
	add rdi, 1
	add rsi, 1
	dec eax
	jmp .elFINAL 	
.fin:	
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
