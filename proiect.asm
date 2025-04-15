; DX-BALL

; miscarea stanga-dreapta a paletei este activata de aparea tastei "A" (stanga)
; respectiv "D" (dreapta)

; dupa atingerea/spargerea celor 40 de caramizi de afiseaza pe ecran mesajul "YOU WON"

; daca mingea loveste peretii aceasta se reflecta sub aceasi unghi, mai putin
; cand loveste peretele de jos, in afara paletei, caz in care se afiseaza pe ecran mesajul "GAME OVER"


.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc


includelib canvas.lib
extern BeginDrawing: proc

public start

.data

;ecran
window_title DB "DX-BALL",0
area_width EQU 640
area_height EQU 480
area DD 0
format db "%d", 10, 0
counter DD 0 


;ciocnire pe verticala
xmin EQU 20
xmax EQU 640
ymin EQU 20
ymax EQU 450 


;argumente
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24


;simboluri
symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include ball.inc


;bricks
brick_x EQU 150
brick_y EQU 100
brick_h EQU 25
brick_l EQU 50
bricks_nb DD 40

dreptX dd 30
dreptY dd 60

;vectori de coordonate bricks
vect_x dd 60, 130, 200, 270, 340, 410, 480, 550
	   dd 60, 130, 200, 270, 340, 410, 480, 550
	   dd 60, 130, 200, 270, 340, 410, 480, 550
	   dd 60, 130, 200, 270, 340, 410, 480, 550	
	   dd 60, 130, 200, 270, 340, 410, 480, 550	
	   
vect_x_final dd 110, 180, 250, 320, 390, 460, 600, 650
			 dd 110, 180, 250, 320, 390, 460, 600, 650
			 dd 110, 180, 250, 320, 390, 460, 600, 650
			 dd 110, 180, 250, 320, 390, 460, 600, 650
			 dd 110, 180, 250, 320, 390, 460, 600, 650

vect_y dd 15, 15, 15, 15, 15, 15, 15, 15
	   dd 50, 50, 50, 50, 50, 50, 50, 50
	   dd 85, 85, 85, 85, 85, 85, 85, 85
	   dd 120, 120, 120, 120, 120, 120, 120, 120
	   dd 155, 155, 155, 155, 155, 155, 155, 155

vect_y_final dd 40, 40, 40, 40, 40, 40, 40, 40
			 dd 75, 75, 75, 75, 75, 75, 75, 75
			 dd 110, 110, 110, 110, 110, 110, 110, 110
			 dd 145, 145, 145, 145, 145, 145, 145, 145
			 dd 180, 180, 180, 180, 180, 180, 180, 180

color dd 0A770E2h, 09135FFH, 07C10E7h, 003619C3h, 04A8BE5h, 085B2EFh, 0ACCFFFh, 0CAE1FFh
	  dd 0CFA6FFh, 0A770E2h, 09135FFH, 07C10E7h,  03619C3h, 04A8BE5h, 085B2EFh, 0ACCFFFh
	  dd 0F69BFFh, 0CFA6FFh , 0A770E2h, 09135FFH, 07C10E7h, 03619C3h, 04A8BE5h, 085B2EFh
	  dd 0FFC3F5h, 0F69BFFh, 0CFA6FFh, 0A770E2h, 09135FFH, 07C10E7h, 03619C3h, 04A8BE5h
	  dd 0FEDFFFh, 0FFC3F5h, 0F69BFFh, 0CFA6FFh, 0A770E2h, 09135FFH, 07C10E7h, 03619C3h
	  
mat dd 1, 1, 1, 1, 1, 1, 1, 1
	dd 1, 1, 1, 1, 1, 1, 1, 1
	dd 1, 1, 1, 1, 1, 1, 1, 1 
	dd 1, 1, 1, 1, 1, 1, 1, 1
	dd 1, 1, 1, 1, 1, 1, 1, 1

;coordonate paleta
paleta_w EQU 100
paleta_h EQU 7
paleta_x DD 455
paleta_y DD 275


;minge
ball_width EQU 35
ball_height EQU 35
ball_x DD 200
ball_y DD 300
ball_speedx dd -10
ball_speedy dd 10

scor dd 0
game_over dd 0

.code


;fill bricks

dreptunghi2 proc
	push ebp
	mov ebp, esp
	mov ecx, [ebp + arg3]
	fill_start:
		mov eax, [ebp + arg5]
		add eax, [ebp + arg3]
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, [ebp + arg4]
		shl eax, 2
		mov esi, area
		add esi, eax

		push ecx
		mov ecx, [ebp + arg2]
	loop2:
		mov eax, [ebp + arg1]
		mov dword ptr[esi], eax 
		add esi, 4
		
		loop loop2
		pop ecx
		loop fill_start
		
	mov esp, ebp
	pop ebp
	ret 20
dreptunghi2 endp


;paleta

dreptunghi1 macro brick_x, brick_y, brick_l, brick_h, color
	local fill_start, loop2
	mov ecx, brick_l
	fill_start:
		mov eax, brick_x
		add eax, brick_l
		sub eax, ecx
		mov ebx, area_width
		mul ebx
		add eax, brick_y
		shl eax, 2
		mov esi, area
		add esi, eax

		push ecx
		mov ecx, brick_h
	loop2:

		mov dword ptr[esi], color 
		add esi, 4
		
		loop loop2
		pop ecx
		loop fill_start
endm		
		


;macro desenare 

make_image_macro macro drawArea, x, y
	push y
	push x
	push drawArea
	call make_image
	add esp, 12
endm


;pentru afisare litere
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], -1
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm



make_image proc
	push ebp
	mov ebp, esp
	pusha
	lea esi, ball_0
	
	
draw_image:
	mov ecx, ball_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, ball_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, ball_width ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_image endp
	

draw proc
	
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz afisare_litere
	
	;ecran negru
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12

	; mov eax, [ebp+arg2]
	; cmp eax, 'S'
	; jne ecran_start
	; jmp final_draw
	
; ecran_start:
	; mov eax, area_width
	; mov ebx, area_height
	; mul ebx
	; shl eax, 2
	; push eax
	; push 0
	; push area
	; call memset
	; add esp, 12
	; make_text_macro 'P', area, 300, 200
	; make_text_macro 'R', area, 310, 200
	; make_text_macro 'E', area, 320, 200
	; make_text_macro 'S', area, 330, 200
	; make_text_macro 'S', area, 340, 200
	; make_text_macro 'S', area, 280, 230
	; make_text_macro 'T', area, 300, 230
	; make_text_macro 'O', area, 310, 230
	; make_text_macro 'S', area, 330, 230
	; make_text_macro 'T', area, 340, 230
	; make_text_macro 'A', area, 350, 230			
	; make_text_macro 'R', area, 360, 230
	; make_text_macro 'T', area, 370, 230
	
afisare_litere:

	;afisare scor
	
	make_text_macro 'S', area, 10, 10
	make_text_macro 'C', area, 20, 10
	make_text_macro 'O', area, 30, 10
	make_text_macro 'R', area, 40, 10 
	
	mov ebx, 10
	mov eax, scor
	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 30
	
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 30
	
	
	;desenare minge
	
	make_image_macro area, ball_x, ball_y
	
	;ciocniri cu caramizile
	pusha
	
	mov esi, 0
	mov eax, ball_x
	add eax, 15
	mov ebx, ball_y
	add ebx, 15
	mov ecx, 39
ciocniri:	
	cmp eax, vect_x[ecx*4]
	jl next
	cmp eax, vect_x_final[ecx*4]
	jg next
	cmp ebx, vect_y[ecx*4]
	jl next
	cmp ebx, vect_y_final[ecx*4]
	jg next
	cmp mat[ecx*4], 1
	jne next 
	
modificare_matrice:
	mov mat[ecx*4], 0
	inc scor
	mov vect_x[ecx*4], 0
	mov vect_x_final[ecx*4], 0
	mov vect_y[ecx*4], 0
	mov vect_y_final[ecx *4], 0
	
 next:
	 dec ecx
	 cmp ecx, 0
	 jge ciocniri

	popa
	
	
	;desenarea caramizilor
desenare_bricks:

	mov ecx, 5		;5 linii

bricks_for1:
	mov esi, 5
	sub esi, ecx
	push ecx
	mov ecx, 8

bricks_for2:
	mov edi, 8		;8 coloane
	sub edi, ecx

	mov eax, esi
	mov edx, 8
	mul edx
	add eax, edi
	mov ebx, color[eax * 4]
	mov eax, mat[eax * 4]
	cmp eax, 0
	je continuare_bricks
	push esi
	push edi
	
	mov eax, 70		;70 de pixeli, 50 latime, 20 departare
	mul edi
	add eax, 60
	mov edi, eax

	mov eax, 35		;35 de pixeli,  20 inltime, 15 departare
	mul esi
	add eax, 15
	mov esi, eax


	pusha 		;push all
	push esi
	push edi
	push brick_h
	push brick_l
	push ebx
	call dreptunghi2

	popa
	
	pop edi
	pop esi

	
continuare_bricks:
	dec ecx
	cmp ecx, 0
	jg bricks_for2
	pop ecx
	dec ecx
	cmp ecx, 0
	jg bricks_for1
	
		
	;desenare paleta
	
	dreptunghi1 paleta_x, paleta_y, paleta_h, paleta_w, 0B385E5h
	
	
	; miscare stanga-dreapta paleta
	
	mov eax, [ebp+arg2]
	cmp eax, 'A'
	je left
	cmp eax, 'D'
	jne miscare_minge
	
	right:
	mov ebx, paleta_y
	add ebx, paleta_w 
	cmp ebx, 635
	jge miscare_minge
	
	add paleta_y, 10
	jmp miscare_minge
	
	left:
	
	mov ebx, paleta_y
	cmp ebx, 5
	jle miscare_minge
	
	sub paleta_y, 10
	jmp miscare_minge
	
	
;miscare minge, coliziuni cu peretii si paleta, reflectare

 miscare_minge:	
	
	;coliziuni
	
	;paleta
	 mov eax, ball_y
	 add eax, ball_height
	 cmp eax, paleta_x	
	 jge reflect_paleta
	
	
	;pe y
	mov eax, ball_y 
	mov ebx, ymax            
	cmp ebx, eax 
	jle change_speedy
	
	mov ebx, ymin - 10
	cmp ebx, eax 
	jge change_speedy

	;pe x
	cmp ball_x, xmin
	jle change_speedx
	
	cmp ball_x, xmax-30
	jge change_speedx
	jmp evt_timer
	
	
change_speedy:
	mov eax, 0
	sub eax, ball_speedy
	mov ball_speedy, eax
	jmp evt_timer 
	
	
change_speedx:
	mov eax, 0
	sub eax, ball_speedx
	mov ball_speedx, eax
	jmp evt_timer
	
	
reflect_paleta:
	mov eax, 0
	mov ebx, ball_speedy
	sub eax, ebx
	mov ball_speedy, eax
	
	
	
evt_timer:	
	
	;deplasare minge
	mov eax, ball_x
	add eax, ball_speedx
	mov ball_x, eax
	mov eax, ball_y
	add eax, ball_speedy
	mov ball_y, eax
	
	
comp_scor:
	cmp scor, 40
	je you_won
	jmp final_draw
	
you_won:

	;nu mai sunt caramizi de spart se afiseaza "you won"
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	make_text_macro 'Y', area, 300, 200
	make_text_macro 'O', area, 330, 200
	make_text_macro 'U', area, 360, 200
	make_text_macro 'W', area, 300, 250
	make_text_macro 'O', area, 330, 250
	make_text_macro 'N', area, 360, 250
	jmp final_draw
	
	
	
final_draw:

;daca mingea se afla in afara paletei se afiseaza "game over"
cmp game_over, 1
jne final
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	make_text_macro 'G', area, 280, 200
	make_text_macro 'A', area, 310, 200
	make_text_macro 'M', area, 340, 200
	make_text_macro 'E', area, 370, 200
	make_text_macro 'O', area, 280, 250
	make_text_macro 'V', area, 310, 250
	make_text_macro 'E', area, 340, 250
	make_text_macro 'R', area, 370, 250
	
final:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

	

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	; apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
