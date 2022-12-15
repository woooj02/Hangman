Title Hangman	
;Creator Name: Aryan Kafley
;Description : Simple Hangman Game
;Date : 5/8/2020

INCLUDE Irvine32.inc

MyStrLength PROTO	: PTR BYTE
strcmp PROTO		: PTR BYTE, : PTR BYTE, : DWORD
getString PROTO		: DWORD
findLetter PROTO	: PTR BYTE, : DWORD,    : BYTE
read_word PROTO		: PTR BYTE, : PTR BYTE, : DWORD
read_char PROTO		: PTR BYTE, : PTR BYTE, : DWORD

show_letters PROTO	: PTR BYTE

front_text PROTO
show_stats PROTO
game_won PROTO
game_lost PROTO

isUpper PROTO char	: BYTE
isLower PROTO char	: BYTE
toUpper PROTO char	: BYTE
toLower PROTO char	: BYTE
toLowerCase	PROTO	: PTR BYTE, : DWORD
getOffset PROTO		: PTR BYTE, : DWORD, : BYTE

	.data
String0 BYTE  "kiwi", 0h
String1 BYTE  "canoe", 0h
String2 BYTE  "doberman", 0h
String3 BYTE  "frame", 0h
String4 BYTE  "frugal", 0h
String5 BYTE  "orange", 0h
String6 BYTE  "frigate", 0h
String7 BYTE  "beauceron", 0h
String8 BYTE  "postal", 0h
String9 BYTE  "basket", 0h
String10 BYTE "cabinet", 0h
String11 BYTE "itch", 0h
String12 BYTE "hangman", 0h
String13 BYTE "mississippian", 0h
String14 BYTE "destroyer", 0h
String15 BYTE "mutt", 0h
String16 BYTE "fruit", 0h
String17 BYTE "protege", 0h
String18 BYTE "parisian", 0h
String19 BYTE "assembly", 0h
String20 BYTE "mast", 0h
String21 BYTE "blizzard", 0h
String22 BYTE "foxglove", 0h
String23 BYTE "klutz", 0h
String24 BYTE "pneumonia", 0h
String25 BYTE "triphthong", 0h
String26 BYTE "bayou", 0h
String27 BYTE "frazzled", 0h
String28 BYTE "flapjack", 0h
String29 BYTE "das", 0h

array    BYTE 32 dup(0)
in_str   BYTE 32 dup(0)
word_gs  BYTE 0
ltr_gs	 BYTE 0
ltr_left BYTE 0
len_str  DWORD 0

prompt0  BYTE "Word = ", 0h
prompt1  BYTE "Do you wish to guess a letter or the whole word: ( 1 for letter 2 for word ) ", 0h
prompt2a BYTE "That is incorrect - ", 0h
prompt2b BYTE " word guesses remaining", 0h
prompt3  BYTE "Guess a letter: ", 0h
prompt4  BYTE "Guess the word: ", 0h
prompt5  BYTE " letter guesses left)", 0h
prompt6  BYTE "That is correct. You win.", 0h
prompt7  BYTE "All the Chances are Expired, You are Lost.", 0h
prompt8  BYTE "Do you wish to play again (Y/N) ", 0h
prompt9  BYTE "Enter either Y or N ", 0h
prompt10 BYTE "Enter either 1 or 2 ", 0h
prompt11 BYTE "Sorry Character Guess Count is Spent, Try entering Word", 0h
prompt12 BYTE "Sorry Word Guess Count is Spent, Try entering Character", 0h
prompt13 BYTE "Thank You for Playing . . .", 0h
prompt14 BYTE "Entered Option : ", 0h
		.code
main PROC

play:

	INVOKE front_text				; print the basic rules of the game.
	mov  edx, OFFSET prompt14
	call WriteString	
	call ReadInt					; read the option
	call CrLf
	cmp  eax, 1						; check play option is selected
	jne  stats						; if play is not selected, check any other option selected
	call Randomize					; if play selected, seed the random values
	call Random32					; get the random value

	mov  edx, 0						; clear the edx for division operation
	mov  ebx, 30					; number of word
	idiv ebx						; divide the random number by numbers of words 
									; eax - quotient, edx - remainder
	INVOKE getString, edx			; get the address of the word with the offset of edx
	mov  esi, eax					; move the word address to esi
	INVOKE MyStrLength, eax			; find the length of the word
	mov  [len_str], eax				; store the length in a variable

	mov ecx, eax					; length of the word
	mov edx, OFFSET array			; address of the fill array
	mov BYTE PTR[edx + ecx * 2], 0	; place 0 in the offset length of the array, since the array
									; have two character '_' and ' ' so the length is multiplied by 2
fill_:
	mov BYTE PTR[edx + ecx * 2 - 2], '_'	; fill '_' in even places 0, 2, 4, 6, ....
	mov BYTE PTR[edx + ecx * 2 - 1], ' '	; fill ' ' in odd places 1, 3, 5, 7, ....
	loop  fill_						; loop till the size of length of the word

	mov [word_gs], 3				; number of word guess
	mov [ltr_gs], 5					; number of character guess
	mov [ltr_left], al				; number of character to find - total length of the word

play_loop:
	INVOKE show_letters, ADDR array	; Show colored alphabets (extra credit) 

	mov edx, OFFSET prompt0			; print the prompt
	call WriteString	

	mov edx, OFFSET array			; print the entered character or underscore
	call WriteString

	cmp [ltr_left], 0				; check if the number of character to find is 0
	jg play_check_guess				; if not zero, then play the game
	call CrLf		
	call CrLf
	mov  edx, OFFSET prompt6		; declare the winning
	call WriteString
	call CrLf
	INVOKE game_won					; update the stastics
	jmp finish						
play_check_guess:
	cmp [ltr_gs], 0					; check number of character guess expired
	jg play_continue				; continue the play if not
	cmp [word_gs], 0				; check number of word guess expired
	jg play_continue				; continue the play if not
	call CrLf
	call CrLf						; all the chanches are expired
	mov  edx, OFFSET prompt7		; declare the lose
	call WriteString
	call CrLf
	INVOKE game_lost				; update the stastics
	jmp finish						

play_continue:
	cmp [ltr_gs], 5					; if no character is gussed wrong dont print the character guess count
	je skip_char_guess_count		 
	
	mov al, '('						; print the number of character guess less
	call WriteChar
	movzx eax, [ltr_gs]
	call WriteDec
	mov edx, OFFSET prompt5
	call WriteString

skip_char_guess_count:
	call CrLf
	mov edx, OFFSET prompt1			; ask the user whether they wants to enter character or word
	call WriteString
	
	call ReadInt					; get the option
	cmp  eax, 1						; check if character option is selected
	jne  check_word					; else check word option
	cmp  [ltr_gs], 0				; check if character guess is expired
	je   character_count_expired	; deny the user if the character guess is expired
	INVOKE read_char, ADDR array, esi, [len_str] ; get the character from the user
	cmp  eax, -1					
	jne  correct_character			; if the character is not valid or wrong
	dec  [ltr_gs]					; decrement the character guess count 
	jmp	 play_loop					; loop back 
correct_character:					; else
	dec  [ltr_left]					; decrement the character left to find 
	jmp	 play_loop					; loop back
character_count_expired:			
	mov  edx, OFFSET prompt11		; character Guess count is expired
	call WriteString				; tell the user to select the alternate option
	call CrLf
	jmp	 play_loop					; loop back

check_word:	
	cmp  eax, 2						; check if the word option is selected
	jne  invalid_option				; else inform the user
	cmp  [word_gs], 0				; check if word guess is expired 
	je   word_count_expired			; deny the user if the word guess is expired
	INVOKE read_word, esi, ADDR in_str, [len_str] ; get the word from the user
	cmp  eax, 0						; check the entered word is correct
	jne  incorrect_guess
	call CrLf
	mov  edx, OFFSET prompt6		; if the word is correct 
	call WriteString				; then declare the winning
	call CrLf
	INVOKE game_won					; update the stastics
	jmp  finish
incorrect_guess:					; if incorrect word is entered
	dec  [word_gs]					; decrement the word guess 
	mov  edx, OFFSET prompt2a		; inform the user 
	call WriteString
	movzx  eax, [word_gs]
	call WriteDec
	mov  edx, OFFSET prompt2b
	call WriteString
	call CrLf
	jmp  play_loop					; loop back
invalid_option:
	mov  edx, OFFSET prompt10		; tell the user to enter to improper option 
	call WriteString
	call CrLf
	jmp  play_loop					; loop back
word_count_expired:					; if word count expired
	mov  edx, OFFSET prompt11		; tell the user to select the alternate option
	call WriteString
	call CrLf
	jmp	 play_loop					; loop back

finish:								; on Closing the play
	call CrLf
	INVOKE show_stats				; print statistics
	call CrLf
	mov  edx, OFFSET prompt8		; prompt the user if willing to play again or not
	call WriteString
	call ReadChar					; read the user option
	call WriteChar					; print the value
	call CrLf
	call CrLf
	INVOKE toLower, al				; convert to lower case
	cmp al, 'y'						; check if y
	je play							; then restart the game
	cmp al, 'n'						; else
	je  ext							; exit
	mov  edx, OFFSET prompt9		; if not a valid character 
	call WriteString				; prompt the user to enter proper character
	call CrLf
	jmp  finish						; loop back

stats:
	cmp  eax, 2						; if Show stastics option is selected
	jne	 ext						; else jump to exit the program
	call CrLf
	INVOKE show_stats				; show the stastics
	call CrLf			
	jmp play						; loop back
ext:
	call CrLf
	mov  edx, OFFSET prompt13		; print the exit prompt
	call WriteString	
	exit							; exit the program
main ENDP

; Procedure to read a word guess
; input string		- address of the word
;		tmp_buffer	- address of the temporary buffer to hold the user string
;		strLen		- lenght of the word
; returns eax	- 0 if user string matched to the word
;	non-zero	- failed

read_word PROC string: PTR BYTE, tmp_buffer: PTR BYTE, strLen: DWORD
	mov  edx,OFFSET prompt4
	call WriteString				; prompt the user to enter the word

	mov  edx, tmp_buffer
	mov  ecx, 32
	call ReadString					; read the user string
	mov  ebx, eax					; move the number of character received
	mov  eax, strLen
	cmp  ebx, eax					; check if the length of enter word and length of word are same
	jne  word_exit					; exit if the word lengths are different
	push eax						; store the length of the user entered word
	INVOKE toLowerCase, tmp_buffer, eax	; convert the user text to lowercase for comparision
	pop eax							; restore the length of the user entered text
	INVOKE strcmp, string, tmp_buffer, eax ; compare the words 

word_exit:
	ret								; return from the procedure
read_word ENDP

; Procedure to Read character
; input    arr	- address of the display array
;		string	- address of the word
;		strLen  - length of the word
; return   eax	- -1 if charactor invalid or wrong
;					else character matched
read_char PROC arr: PTR BYTE, string: PTR BYTE, strLen: DWORD

	sub  esp, 4						; local variable
	mov  edx, OFFSET prompt3		; prompt the user to enter a character
	call WriteString

	call ReadChar					; read the character
	call WriteChar					; print it
	call CrLf
	mov  BYTE PTR [ebp - 1], al		; store the character in the local variable

	INVOKE toUpper, al				; convert the received character to uppercase
	INVOKE getOffset, arr, strLen, al;  get the index if already received
	push eax						; index + 1 position in the word

	mov  al, BYTE PTR [ebp - 1]		; get the received character
	INVOKE toLower, al				; convert to lower
	pop  ebx						; get the position if already received, used if word contain two or more same characters
	INVOKE findLetter, string, ebx, al ; find the position of the character in the buffer
	cmp  eax, -1					; if -1 return character not present in the word
	je  char_error					; print error
	push eax						; else new index of the character in the array
	mov  al, BYTE PTR [ebp - 1]		; get the character from the local array
	INVOKE toUpper, al				; convert the character to uppercase
	pop  ecx						; get the index
	mov  ebx, arr
	mov  [ebx + ecx * 2], al		; update the display array
char_error:
	add  esp, 4						; clear the local variable
	ret								; exit from the procedure
read_char ENDP

; Procedure to get the index of second or greater occurence of same character, For example if a word contains
; same character more than one then this procedure return index + 1 of the last occurence of the character
; Input		arr	- address of the display array
;		strLen	- length of the string
;	     char   - character to check 	
; return   index of the last occurence or zero

getOffset PROC arr: PTR BYTE, strLen: DWORD, char: BYTE
	push edi						; save the register

	mov  al, char					; character to find
	mov  ah, ' '					; since display array ' ' and character or '_'
	mov  ecx, 0						; clear the index
	mov  edi, arr					; address of the display array
	mov  edx, 0						; return value

gO_loop:
	mov  bx, WORD PTR[edi + ecx * 2]; load each word  
	add  ecx, 1						; increment the index 
	cmp  ax, bx						; check if the character and array value are same
	jne  gO_loop_continue			; if not same then continue the loop
	mov  edx, ecx					; update the return value if same
gO_loop_continue:		
	cmp  ecx, strLen				; check if the index is less than the word length
	jl   gO_loop					; loop if less
		
	mov  eax, edx					; move the return value
	pop  edi						; restore register
	ret								; return from the procedure
getOffset ENDP

; Procedure check if the character is upper case
; input char - character to be checked
; return eax - 1 if uppercase, else 0
isUpper PROC char: BYTE
	mov bl, char					; if ('A' <= char <= 'Z')
	mov eax, 0						;		return 1
	cmp bl, 'A'						; else 
	jl iU_exit						;		return 0
	cmp bl, 'Z'
	jg iU_exit
	mov eax, 1
iU_exit:
	ret
isUpper ENDP

; Procedure check if the character is lower case
; input char - character to be checked
; return eax - 1 if lowercase, else 0
isLower PROC char: BYTE
	mov bl, char
	mov eax, 0
	cmp bl, 'a'						; if ('a' <= char <= 'z')
	jl iL_exit						;		return 1
	cmp bl, 'z'						; else 
	jg iL_exit						;		return 0
	mov eax, 1
iL_exit:
	ret
isLower ENDP

; Procedure converts the given character in to upper case
; input char - character to be checked
; return eax - uppercase character
toUpper PROC char: BYTE
	mov bl, char
	INVOKE isUpper, char			; check if the character is upper case
	cmp eax, 0						; if upper case then exit the subroutine
	jne tU_exit						; if lower case 
	mov bl, char
	add bl, 'A' - 'a'				; convert to uppercase
tU_exit:
	mov al, bl						; return value
	ret								; exit from the subroutine
toUpper ENDP

; Procedure converts the given character in to lower case
; input char - character to be checked
; return eax - lowercase character
toLower PROC char: BYTE	
	mov bl, char
	INVOKE isLower, char			; check if the character is lower case
	cmp eax, 0						; if lower case then exit 
	jne tL_exit						; if upper case
	mov bl, char
	add bl, 'a' - 'A'				; convert to lower case
tL_exit:
	mov al, bl						; return value
	ret								; exit the procedure
toLower ENDP

; Procedure that converts the string to lowercase string
; Input string - address to the string to convert
;		strLen - length of the string
; returns none.
toLowerCase PROC string: PTR BYTE, strLen: DWORD
	push esi						; save the register
	mov esi, string					; address of the string
	mov ecx, strLen					; length of the string
tLC_loop:
	mov bl, [esi + ecx - 1]			; get each byte
	INVOKE isUpper, bl				; check if upper case
	cmp eax, 0						
	je tLC_skip_lower				; else skip conversion
	mov bl, [esi + ecx - 1]			; if uppercase
	add bl, 'a' - 'A'				; convert to lower case
	mov [esi + ecx - 1], bl			; update string buffer
tLC_skip_lower:
	loop tLC_loop					; loop till all the characters are processed
tLC_exit:
	pop esi							; restore the register
	ret								; exit from the subroutine
toLowerCase ENDP

; Procedure finds the length of the given string
; input string - address of the string
;       eax - length of the string
MyStrLength PROC string: PTR BYTE
	push esi						; save the register

	mov  esi, string				; address of the string
	mov  ecx, 0						; index

strlen:
	mov  al, [esi + ecx]			; get each byte
	cmp  al, 0						
	je	 sL_done					; exit the loop if null character is reached
	add  ecx, 1						; increment the index
	jmp  strlen						; loop till the null character

sL_done:
	mov  eax, ecx					; return value

	pop  esi						; restore the register
	ret								; exit from the subroutine
MyStrLength ENDP

; Procedure returns the address of the word with the given offset from starting word
; input index - offset 
;		eax - address of the word
getString PROC index: DWORD

	mov  ebx, index					; compare the index from 0 - 29
	mov  eax, OFFSET String0		; return string address with that offset that matched
	cmp  ebx, 0
	je   gS_done
	mov  eax, OFFSET String1
	cmp  ebx, 1
	je   gS_done
	mov  eax, OFFSET String2
	cmp  ebx, 2
	je   gS_done
	mov  eax, OFFSET String3
	cmp  ebx, 3
	je   gS_done
	mov  eax, OFFSET String4
	cmp  ebx, 4
	je   gS_done
	mov  eax, OFFSET String5
	cmp  ebx, 5
	je   gS_done
	mov  eax, OFFSET String6
	cmp  ebx, 6
	je   gS_done
	mov  eax, OFFSET String7
	cmp  ebx, 7
	je   gS_done
	mov  eax, OFFSET String8
	cmp  ebx, 8
	je   gS_done
	mov  eax, OFFSET String9
	cmp  ebx, 9
	je   gS_done
	mov  eax, OFFSET String10
	cmp  ebx, 10
	je   gS_done
	mov  eax, OFFSET String11
	cmp  ebx, 11
	je   gS_done
	mov  eax, OFFSET String12
	cmp  ebx, 12
	je   gS_done
	mov  eax, OFFSET String13
	cmp  ebx, 13
	je   gS_done
	mov  eax, OFFSET String14
	cmp  ebx, 14
	je   gS_done
	mov  eax, OFFSET String15
	cmp  ebx, 15
	je   gS_done
	mov  eax, OFFSET String16
	cmp  ebx, 16
	je   gS_done
	mov  eax, OFFSET String17
	cmp  ebx, 17
	je   gS_done
	mov  eax, OFFSET String18
	cmp  ebx, 18
	je   gS_done
	mov  eax, OFFSET String19
	cmp  ebx, 19
	je   gS_done
	mov  eax, OFFSET String20
	cmp  ebx, 20
	je   gS_done
	mov  eax, OFFSET String21
	cmp  ebx, 21
	je   gS_done
	mov  eax, OFFSET String22
	cmp  ebx, 22
	je   gS_done
	mov  eax, OFFSET String23
	cmp  ebx, 23
	je   gS_done
	mov  eax, OFFSET String24
	cmp  ebx, 24
	je   gS_done
	mov  eax, OFFSET String25
	cmp  ebx, 25
	je   gS_done
	mov  eax, OFFSET String26
	cmp  ebx, 26
	je   gS_done
	mov  eax, OFFSET String27
	cmp  ebx, 27
	je   gS_done
	mov  eax, OFFSET String28
	cmp  ebx, 28
	je   gS_done
	mov  eax, OFFSET String29
	cmp  ebx, 29
gS_done:
	ret									; return the subroutine
getString ENDP

; Procedure compares two strings 
; input string_1 - address of the input string 1
;		string_2 - address of the input string 2
;		length   - length to be compared
; return eax - 0 if matched else non-zero
strcmp PROC string_1: PTR BYTE, string_2: PTR BYTE, strlen: DWORD
	push esi
	push edi							; save registers
	
	mov  esi, string_1					; address of the string 1
	mov  edi, string_2					; address of the string 2
	mov  ecx, strlen					; length of the string

sC_loop:
	lodsb								; load each byte from string 1 in al
	scasb								; compare al to corresponding byte in string 2
	jne sC_exit							; exit the loop if characters are different
	loop sC_loop						; loop till the length is check

sC_exit:
	mov eax, ecx						; move the result 0 is matched all the way to the length

	pop  esi
	pop  edi							; restore the register
	ret									; exit from the subroutine.
strcmp ENDP

; Procedure find the index of the character in given word
; input string - address of the input string
;		index - index to start search from
;		character  - character to be searched
; return eax - -1 if not found else index of the character
findLetter PROC string : PTR BYTE, index : DWORD, character : BYTE
	push esi

	mov  esi, string					; address of the string
	mov  ecx, index						; starting index

	mov  al, [esi + ecx]				; load the character from that index
	cmp  al, 0							; check if end of the string reached
	jne	 fL_checkChar					; check the character if not reached
	mov  eax, -1						; else not found , end reached
	jmp  fL_done						; return not found

fL_checkChar:
	cmp  al, character					; check if the characters are same
	jne	 fL_recur						; if not same do the recursive call
	mov  eax, ecx						; else move the index
	jmp  fL_done						; return

fL_recur:
	add	 ecx, 1							; increment the index
	INVOKE findLetter, esi, ecx, character; do the recursive call

fL_done:
	pop  esi							; restore the register
	ret									; return from the subroutine
findLetter ENDP

END main
