;
; Author : Paschal Ahanmisi 
; Date : October 2026 
 
; Copyright (c) 2026 <pastechnology1@gmail.com>

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

;  note of function 


SECTION .data
	
SECTION .bss
SECTION .text 
; int parse_impl_singleline(void* payload_addr , void* parsed_addr , unsigedn char* my_target_id  , size_t sz );
; NOTE : on global_parse_impL_singleline  ; cannot be less than a cache lien DONE for uptimal loads and reads 
global parse_impl_singleline 
; parseimpl(void* py_addr , void* parsed_addr , size_t sz ){
; There should be startegy for single line 
; There should be for multiple reads 

; NOTE : singel line is useful 
	; int count = 0 ; 
	; int amoutn = 0 
	; while(sz >= count ){
	; for now alwasy assume sttuff is aligned topgether 
		; if(py_addr[count] != '8' ){ /* could use a cmp with fix and 8 
			; find_start_point();
		;}
		; count = count + 13
		; size sz_inner = convertTointegrer(py_addr[coutn]); 
		; int k = 0 ; 
		; while(k < sz_inner){ // this can be converted into a straight loop that evrthing is found at once 
			;find next | and then use that as incrementing to saving
			;if unknown value just skip parsing it 
			; until loop is finshed 
		; }
	; }
;}
parse_impl_single : 
; starting base model implentation
	mov rbp , rsp 
	sub rsp , 16 
	mov rcx , r11 ; moving rcx to r11 
	; IMplement to check for start of 8=FIX...
	; Note assuming the offset has been determinged here of 8= FIX 
	mov qword [rsp] , 0x0101010101010101 ; Get mask ready

	vpbroadcastq ymm0 , qword[rsp]; mov mask to ymm0 

	mov r10 , qword[rdi+12] ; moving the size to r10

	vmovdqa ymm1 , [rdi] ; move first 32 bytes

	vpcmpeqb ymm2 , ymm1 , ymm0 ; compare bytes to find start of header (0x01)

	vpmovmskb r9 , ymm2 ; mov mask position to r9 

	lzcnt rcx , r9 ; count the number of leaidng zero bits of the mask 0x01 

	add rcx , 1 ; add 1 to the shift 

	sub r10 , 0x3030303030303030 ; mask to bring out only characters

	shl r9 , cl ; shift after the 1st 0x01 mask 

	lzcnt rcx , r9 ; shift after 2nd 0x01 mask
	
	 ; shr r10 , cl ; seperate the the size alone as stand alone single digit ascii 

	;=================== changing to count length ================== ; delete this later
; EVEN 
	mov r13 , r10 ; take a copy of r10 the digits i.e [ 1 , 2 , 3, 4, 0 , 0 ,0 ,0 ] 
	mov r12 , 0x00FF00FF00FF00FF ; mask for even bytes 
	and r13 , r12 ; mask to onyl get even positions 

; ODD 
	shr r10 ,  8 ; mOve postions to even address 
	and r10 , r12 ; mask for only the even position  
 ; Multiply the tens by 10
	lea r13 , [r13 + (r13 * 4)] 
	lea r13 , [r10 + (r13*2)]

	; Multiply now by 100
	mov r10 , r13 
	mov r12 , 0x0000FFFF0000FFFF
	and r13 , r12 3

; oDD 
	shr r10 , 16 
	and r10 , r12 
	; mutiply by 100 
	imul  r13 , r13 , 100
	add r10 , r13 
	bswap r10 , r10 ; correct the positioning of the value in order to us e it  


	
	
; in case th e 8 byte are lost 
resync_scan : 
end : 
	add rsp , 16
	mov rsp , rbp
	ret 
section .note.GNU-stack noalloc noexec nowrite progbits
