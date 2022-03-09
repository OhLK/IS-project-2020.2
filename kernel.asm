org 0x7e00
jmp 0x0000:start

%macro setText 3
	mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, %1   ; Linha
	mov dl, %2   ; Coluna
	int 10h

	mov si, %3
	call printf
%endmacro

start:
	call initVideo
	setText 15, 16, title
	call draw_logo
	call delay

	call menu
jmp $


%macro drawer 1
	mov ah, 0ch 
	mov al, %1
	mov bh, 0
%endmacro

%macro drawSquare 4
	mov cx, %1
	.draw_rows:
		mov dx, %2
		int 10h
		mov dx, %4
		int 10h
		inc cx
		cmp cx, %3
		je .end_column
		jmp .draw_rows
	.end_column:
		mov dx, %2
	.draw_columns:
		mov cx, %1
		int 10h
		mov cx, %3
		int 10h
		inc dx
		cmp dx, %4
    jne .draw_columns
%endmacro

%macro drawCursor 4
	mov cx, %1
	.draw_seg:
		mov dx, %3-1
		int 10h
		mov dx, %3
		int 10h
		inc cx
		cmp cx, %4
		je .end_column
		jmp .draw_seg
	.end_column:
		mov dx, %2
	.draw_columns:
		mov cx, %4-2
		int 10h
		mov cx, %4-1
		int 10h
		inc dx
		cmp dx, %3
	jne .draw_columns
%endmacro

%macro startTimer 1
    mov al, %1+48
		mov ah, 0eh ; modo de imprmir na tela
  	int 10h     ; imprime o que tá em al

    mov ah, 03h 
    mov ch, 0   
    mov cl, 0  
    mov dh, 0   
    mov dl, 1   
    int 1aH 

    .loop:
        mov ah, 02h ;
        int 1aH     
        cmp dh, %1h
        je good_job
        add dh, 48
        mov [time], dh
        mov ah, 02h  ; Setando o cursor
        mov bh, 0    ; Pagina 0
        mov dh, 12   ; Linha
        mov dl, 29 
        int 10h
        mov si, time
        call printf
    jmp .loop
%endmacro

getchar:
  mov ah, 00h
  int 16h
ret

printf:
	lodsb
	cmp al,0
	je .end

	mov ah, 0eh
	; Trocar por 0ah
	mov bl, 15
	int 10h

	mov dx, 0
	jmp printf

	.end:
	mov ah, 0eh
	mov al, 0xd
	int 10h
	mov al, 0xa
	int 10h
ret

initVideo:
	mov ah, 00h
	mov al, 13h
	int 10h
ret

menu:
	call initVideo
	call draw_logo
	; Desenha a borda
	call draw_border
	; Escreve nome de cada APP
	setText 1, 16, title
	setText 6, 4, app1
	setText 6, 26, app2
	setText 13, 4, app3
	setText 13, 26, app4
	setText 20, 4, app5
	setText 20, 26, app6
	; Desenha os retangulos
	call draw_box_app
	; Inicia a aplicação
	call first_cursor

delay:
	mov ah, 86h
	mov cx, 30
	mov dx, 500
	int 15h
ret

fast_delay:
	mov ah, 86h
	mov dx, 3000
	int 15h
ret

endline:
    mov ah, 02h ; setar o cursor
    mov bh, 0   ; pagina
    mov dl, 1
    inc dh
    int 10h
jmp teclado

delete_endline:
	cmp dh, 2 ;Linha inicial
	je teclado

	mov al, ' '
	mov ah, 09h ; codigo para printar caractere apenas onde esta o cursor
	mov bh, 0   ; seta a pagina
	mov bl, 15  ; seta a cor do caractere, nesse caso, branco
	int 10h

	mov ah, 02h ; setar o cursor
	mov bh, 0   ; pagina
	dec dh
	mov dl, 100
	int 10h

jmp teclado

backspace:
	cmp dl, 1
	je delete_endline

	mov al, ' '
	mov cx, 1
	mov ah, 09h ; codigo para printar caractere apenas onde esta o cursor
	mov bh, 0   ; seta a pagina
	mov bl, 15  ; seta a cor do caractere, nesse caso, branco
	int 10h

	mov ah, 02h ; setar o cursor
	dec dl ; coluna --
	mov bh, 0   ; pagina
    int 10h

jmp teclado


teclado:
	mov ah, 0   ; prepara o ah para a chamada do teclado
	int 16h     ; interrupcao para ler o caractere e armazena-lo em al

	cmp al, 8
	je backspace
	cmp al, 27
	je menu
	cmp dl, 100
	je endline
	
	mov ah, 02h ; setar o cursor
	mov bh, 0   ; pagina
	inc dl
	int 10h

	mov ah, 09h ; codigo para printar caractere apenas onde esta o cursor
	mov bh, 0   ; seta a pagina
	int 10h

jmp teclado

draw_logo:
	mov si, lacoste
	mov dx, 0            ; Y
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0        ; X
	.for2:
		cmp cl, byte[bx]
		je .endfor2
		lodsb
		push dx
		push cx
		mov ah, 0ch
		add dx, 70
		add cx, 140
		int 10h
		pop cx
		pop dx
		inc cx
		jmp .for2
	.endfor2:
		inc dx
		jmp .for1
	.endfor1:
ret

box_app1: 
	drawSquare 20, 145, 100, 180
box_app2:
	drawSquare 200, 35, 280, 70
box_app3:
	drawSquare 200, 90, 280, 125
box_app4:
	drawSquare 200, 145, 280, 180
box_app5:
	drawSquare 20, 35, 100, 70
box_app6:
	drawSquare 20, 90, 100, 125
ret

draw_box_app:
	drawer 9
	call box_app1
ret

draw_border:
	drawer 9
	mov cx, 0
	.draw_seg:
		mov dx, 0
		int 10h
		mov dx, 199
		int 10h
		inc cx
		cmp cx, 319
		je .end_column
		jmp .draw_seg
	.end_column:
		mov dx, 0
	.draw_columns:
		mov cx, 0
		int 10h
		mov cx, 319
		int 10h
		inc dx
		cmp dx, 199
		jne .draw_columns
	ret

cursor_app1: 
	drawCursor 85, 54, 67, 98
cursor_app2:
	drawCursor 85, 109, 122, 98
cursor_app3:
	drawCursor 85, 164, 177, 98
cursor_app4:
	drawCursor 265, 54, 67, 278
cursor_app5:
	drawCursor 265, 109, 122, 278
cursor_app6:
	drawCursor 265, 164, 177, 278
ret

bad_input:
	setText 15, 20, error
	call delay
jmp start

good_job:
	setText 20, 4, work
	call delay
jmp start

loading_app:
	call loading_limit
	call loading
	call loading_off
	call loading_limit
ret

background_white:
	; Set background white
	mov ah, 0ch 
	mov al, 0fh
	mov bh, 0
	mov cx, 0
	mov dx, 0
	.draw_seg:
		int 10h
		inc cx
		cmp cx, 320
		je .jump_row
		jne .draw_seg
	.back_column:
		mov cx, 0
		jmp .draw_seg
	.jump_row:
		inc dx
		cmp dx, 200
		jne .back_column
ret

first_cursor:
	drawer 0
	call cursor_app2
	drawer 2
	drawCursor 85, 54, 67, 98

  call getchar

  cmp al, 13
	je init_browser
	cmp al, 'w'
  je third_cursor
	cmp al, 'a'
  je fourth_cursor
  cmp al, 's'
  je second_cursor
	cmp al, 'd'
  je fourth_cursor

  jmp first_cursor
ret

init_browser:
	call loading_app
	call initVideo
	call background_white
	call draw_dino
	setText 11, 13, offline
	setText 14, 3, text_fun1
	setText 15, 3, text_fun2
	setText 18, 12, try
	call draw_esq_button

	call getchar

	cmp al, 27
	je menu
jmp init_browser

second_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 85, 109, 122, 98

  call getchar

  cmp al, 13
	je initPhotos
	cmp al, 'w'
  je first_cursor
	cmp al, 'a'
  je fifth_cursor
  cmp al, 's'
  je third_cursor
	cmp al, 'd'
  je fifth_cursor

  jmp second_cursor
ret

%macro loadPhotos 1
  call video
  call %1
  call hold
%endmacro

initPhotos:
	call loading_app
	loadPhotos japan
	loadPhotos france
	loadPhotos england
	loadPhotos brasil
	loadPhotos italy
	loadPhotos russia
	loadPhotos germany
ret

third_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 85, 164, 177, 98

  call getchar
  
	; cmp al, 13
  ; je 
	cmp al, 'w'
  je second_cursor
	cmp al, 'a'
  je sixth_cursor
  cmp al, 's'
  je first_cursor
	cmp al, 'd'
  je sixth_cursor

  jmp third_cursor
ret

fourth_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 265, 54, 67, 278

  call getchar
  
	cmp al, 13
	je notes_app
	cmp al, 'w'
  je sixth_cursor
	cmp al, 'a'
  je first_cursor
  cmp al, 's'
  je fifth_cursor
	cmp al, 'd'
  je first_cursor

  jmp fourth_cursor
ret

notes_app:
	call loading_app
	; Init Video
	mov ah, 0
  mov al, 2h
  int 10h
	; Set background Color
  mov ah, 0Bh
  mov bh, 0
  mov bl, 1
  int 10h

	setText 1, 1, ESC
	setText 1, 33, bloco_de_notas
	mov ah, 02h ; Setando o cursor
  mov dh, 2   ; Linha
	mov dl, 1   ; Coluna
	int 10h

  jmp teclado

fifth_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 265, 109, 122, 278

  call getchar

  cmp al, 13
	je time_app
	cmp al, 'w'
  je fourth_cursor
	cmp al, 'a'
  je second_cursor
  cmp al, 's'
  je sixth_cursor
	cmp al, 'd'
  je second_cursor

  jmp fifth_cursor
ret

await_3: startTimer 3
await_5: startTimer 5
await_9: startTimer 9

time_app:
	call loading_app
	call initVideo
	setText 1, 14, time_to_rest
	setText 5, 4, instruction_time
	setText 9, 27, timer
	setText 9, 4, time_3
	setText 12, 4, time_5
	setText 15, 4, time_9
	setText 22, 11, obs
	call draw_esq_button

	mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 15   ; Linha
	mov dl, 29   ; Coluna
	int 10h

	call getchar
	cmp al, '1'
	je await_3
	cmp al, '2'
	je await_5
	cmp al, '3'
	je await_9
	cmp al, 27
	je menu
	call bad_input
jmp time_app

sixth_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 265, 164, 177, 278

  call getchar
  ; cmp al, 13 e jogar para o app
  
	cmp al, 'w'
  je fifth_cursor
	cmp al, 'a'
  je third_cursor
  cmp al, 's'
  je fourth_cursor
	cmp al, 'd'
  je third_cursor

  jmp sixth_cursor
ret

draw_dino: 
	mov si, dino
	mov dx, 0           
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0       
		.for2:
			cmp cl, byte[bx]
			je .endfor2
			lodsb
			push dx ; Draw pixel
			push cx
			mov ah, 0ch
			add dx, 50
			add cx, 130
			int 10h
			pop cx
			pop dx
			inc cx
			jmp .for2
		.endfor2:
		inc dx
		jmp .for1
	.endfor1:
	ret

draw_esq_button:
	mov si, esc_button
	mov dx, 0            ; Y
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0        ; X
	.for2:
		cmp cl, byte[bx]
		je .endfor2
		lodsb
		push dx
		push cx
		mov ah, 0ch
		add dx, 2
		add cx, 2
		int 10h
		pop cx
		pop dx
		inc cx
		jmp .for2
	.endfor2:
		inc dx
		jmp .for1
	.endfor1:
ret

data:
	; SO interface
	title db 'TchucoOS', 0
	app1 db 'Browser', 0
	app2 db 'Notes', 0
	app3 db 'Photos', 0
	app4 db 'RestTime', 0
	app5 db 'Terminal', 0
	app6 db 'About', 0
	; Browser APP
	offline db "Sem internet", 0
	text_fun1 db "Retire os cabos de rede e roteador", 0
	text_fun2 db "Desconecte de sua rede Wi-Fi", 0
	try db "Tente novamente", 0
	; Time to Rest APP
	time_to_rest db 'Time to Rest', 0
	instruction_time db 'Quantos minutos deseja descansar?', 0
	obs db 'Minutos = Segundos', 0
	work db 'Acabou o descanso, bom trabalho!', 0
	error db 'Digite 1, 2 ou 3', 0
	timer db 'Timer', 0
	time db 8,0
	choice db 8, 0
	time_3 db '1. 3 minuto', 0
	time_5 db '2. 5 minutos', 0
	time_9 db '3. 9 minutos', 0
	; Notes app
	bloco_de_notas db 'Bloco de notas', 0
	ESC db 'ESC', 0

lacoste db 35, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 8, 2, 2, 0, 2, 2, 2, 2, 8, 8, 0, 0, 0, 0, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 6, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 0, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 8, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

dino db 30, 31, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 7, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 7, 15, 15, 15, 15, 15, 15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 8, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 15, 7, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 15, 15, 15, 7, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 15, 15, 15, 15, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15

esc_button db 15, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 15, 15, 15, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 15, 12, 4, 4, 15, 15, 15, 4, 15, 15, 15, 4, 0, 0, 4, 15, 15, 15, 4, 15, 12, 4, 4, 15, 4, 4, 4, 0, 0, 4, 15, 4, 4, 4, 15, 15, 15, 4, 15, 4, 4, 4, 0, 0, 4, 15, 4, 4, 4, 4, 4, 15, 4, 15, 4, 4, 4, 0, 0, 12, 15, 15, 15, 4, 15, 15, 15, 4, 15, 15, 15, 12, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; ------- Código a parte -----------

hold:
	call getchar
	cmp al, 27
	je menu
	cmp al, ' '
	jne hold
ret

video:
	mov ah, 0 ; Set video mode
	mov al, 12h
	int 10h
ret

%macro setColor 1
  mov ah, 0ch
	mov bh, 0
	mov al, %1 ; cor
	int 10h
%endmacro

%macro setBackground 1
	mov ah, 0xb
	mov bh, 0
	mov bl, %1
	int 10h
%endmacro

%macro filled_circle 3
	push cx
	push dx

	mov ax, -%1
	push ax

	.loop_circle:
		pop ax
		cmp ax, %1
		je .done
		inc ax
		push ax

		mov bx, -%1
		push bx
		jmp .loop_circle2

	.loop_circle2:
		pop bx
		cmp bx, %1
		je .loop_circle
		inc bx
		push bx

		jmp .check

	.check:
		pop bx
		pop ax
		push ax
		push bx

		mov cx, ax
		mov dx, bx

		mul ax
		xchg ax, bx
		mul ax
		add ax, bx

		cmp ax, %2
		jg .loop_circle2

		pop bx
		pop ax
		pop dx
		pop cx
		push cx
		push dx
		push ax
		push bx

		add cx, ax
		add dx, bx

		setColor %3

		jmp .loop_circle2

	.done:
		pop dx
		pop cx
%endmacro

japan:
	mov dx, 0

	.jp_white:
		cmp dx, 480
		jg .jp_red
		mov cx, 0
		.jp_loop_white:
			setColor 15
			inc cx
			cmp cx, 640
			jl .jp_loop_white
			inc dx
			jmp .jp_white
	.jp_red:
		mov cx, 320
		mov dx, 240
		filled_circle 125, 15625, 4

	.jp_end:
		ret

france:
	setBackground 4

	mov dx, 0

	.fr_blue:
	cmp dx, 480
	jg .fr_next
	mov cx, 0 ; inicio da linha 
	.fr_loop_blue:
		setColor 1
		inc cx
		cmp cx, 214
		jl .fr_loop_blue
		inc dx
		jmp .fr_blue

	.fr_next:
		mov dx, 0

	.fr_white:
		cmp dx, 480
		jg .fr_end
		mov cx, 214
		.fr_loop_white:
			setColor 15
			inc cx
			cmp cx, 427
			jl .fr_loop_white
			inc dx
			jmp .fr_white

	.fr_end:
		ret

italy:
	setBackground 4

	mov dx, 0

	.it_green:
	cmp dx, 480
	jg .it_next
	mov cx, 0 ; inicio da linha 
	.it_loop_green:
		setColor 2
		inc cx
		cmp cx, 214
		jl .it_loop_green
		inc dx
		jmp .it_green

	.it_next:
		mov dx, 0

	.it_white:
		cmp dx, 480
		jg .it_end
		mov cx, 214
		.it_loop_white:
			setColor 15
			inc cx
			cmp cx, 427
			jl .it_loop_white
			inc dx
			jmp .it_white

	.it_end:
		ret

germany:
	mov dx, 160

	.gr_red:
		cmp dx, 320
		jg .gr_yellow
		mov cx, 0
		.gr_loop_red:
			setColor 4
			inc cx
			cmp cx, 640
			jl .gr_loop_red
			inc dx
			jmp .gr_red

	.gr_yellow:
		cmp dx, 480
		jg .gr_end
		mov cx, 0
		.gr_loop_yellow:
			setColor 14
			inc cx
			cmp cx, 640
			jl .gr_loop_yellow
			inc dx
			jmp .gr_yellow
	
	.gr_end:
		ret

russia:
	setBackground 4

	mov dx, 0

	.rs_white:
		cmp dx, 160
		jg .rs_blue
		mov cx, 0
		.rs_loop_white:
			setColor 15
			inc cx
			cmp cx, 640
			jl .rs_loop_white
			inc dx
			jmp .rs_white

	.rs_blue:
		cmp dx, 320
		jg .rs_end
		mov cx, 0
		.rs_loop_blue:
			setColor 1
			inc cx
			cmp cx, 640
			jl .rs_loop_blue
			inc dx
			jmp .rs_blue
	
	.rs_end:
		ret

england:
	mov dx, 0

	.en_white:
		cmp dx, 480
		jg .en_next
		mov cx, 0
		.en_loop_white:
			setColor 15
			inc cx
			cmp cx, 640
			jl .en_loop_white
			inc dx
			jmp .en_white

	.en_next:
		mov dx, 0

	.en_red_vertical:
		cmp dx, 480
		jg .en_next1
		mov cx, 280
		.en_loop_red1:
			setColor 4
			inc cx
			cmp cx, 360
			jl .en_loop_red1
			inc dx
			jmp .en_red_vertical

	.en_next1:
		mov dx, 200

	.en_red_horizontal:
		cmp dx, 280
		jg .en_end
		mov cx, 0
		.en_loop_red2:
			setColor 4
			inc cx
			cmp cx, 640
			jl .en_loop_red2
			inc dx
			jmp .en_red_horizontal

	.en_end:
		ret

brasil:
	setBackground 2

	mov dx, 0

	push cx
	push ax

	mov dx, 80
	mov cx, 320 ; Salva o inicio da linha amarela
	mov ax, 322 ; Salva o final  da linha amarela 

	.br_yellow:
		cmp dx, 240
		jg .br_yellowBottom
		push cx
		.br_loopLine:
			push ax
			setColor 14
			pop ax
			inc cx
			cmp cx, ax
			jl .br_loopLine
			inc dx
			add ax, 2
			pop cx
			sub cx, 2
			jmp .br_yellow

	.br_yellowBottom:
		cmp dx, 400
		jg .br_next
		push cx
		.br_loopLine1:
			push ax
			setColor 14
			pop ax
			inc cx
			cmp cx, ax
			jl .br_loopLine1
			inc dx
			sub ax, 2
			pop cx
			add cx, 2
			jmp .br_yellowBottom

	.br_next:
		pop ax
		pop cx

	mov cx, 320
	mov dx, 240
	call filled_circle 110, 12100, 1

	mov dx, 235
	mov cx, 225

	.br_white:
		cmp dx, 245
		jg .br_end
		push cx
		.loopLine4:
			setColor 15
			inc cx
			cmp cx, 420
			jl .loopLine4
			inc dx
			pop cx
			jmp .br_white

	.br_end:
		ret

; ------ Código a parte ------
loading:
	mov cx, 50
	loop_loading:
		call loading_unit
		inc cx
		push cx
		xor cx, cx
		call fast_delay
		pop cx
		cmp cx, 250
		jne loop_loading
		mov ah, 86h; INT 15h / AH = 86h
		mov cx, 10	
		xor dx, dx ;CX:DX = interval in microseconds
		mov dx, 40	
		int 15h
	ret

loading_off:
	mov cx, 50
	loop_loading_off:
		call loading_unit_off
		inc cx
		cmp cx, 250
		jne loop_loading_off
	ret

loading_unit_off:
	mov ax,0x0c00 ;Write graphics pixel, preto
	mov bh,0x00
	mov dx, 160
	loop_loading_unit_off:
		int 10h
		inc dx
		cmp dx, 170
		jne loop_loading_unit_off
	ret 

loading_limit:
	mov ax,0x0c0f ;Write graphics pixel,white
	mov bh,0x00
	mov dx, 160
	loop_loading_limit:
		mov cx, 49
		int 10h
		mov cx, 250
		int 10h
		inc dx
		cmp dx, 170
		jne loop_loading_limit
	ret

loading_unit:
	mov ax,0x0c02 ;Write graphics pixel, verde
	mov bh,0x00
	mov dx, 160
	loop_loading_unit:
		int 10h	
		inc dx
		cmp dx, 170
		jne loop_loading_unit
	ret 
; ------- Mikahel Leal Dias 
; ------- Igor Eduardo Mascarenhas 
; ------- André Luiz Figueirôa de Barros