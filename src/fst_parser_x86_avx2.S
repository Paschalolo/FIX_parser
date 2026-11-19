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

; input_buf -> rdi , output_buf -> rsi  ,  sz -> rdx 
parse_impl_singleline1:
	mov rbp , rsp 
	sub rsp , 16 ts: 6, done.
Counting objects: 10
	mov qword[rsp] , 0x0101010101010101
	vpbroadcastq ymm0 , qword[rsp] 

	add rsp , 16 
	mpv rsp , rbp 
	ret 
; This implementation will be used int hte multi line file 
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

	vmovdqa ymm3 , [rdi + 32 ] ; move second batch of the cache line reminaing 32 bytes 

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
	and r13 , r12 

; oDD 
	shr r10 , 16 
	and r10 , r12 
	; mutiply by 100 
	imul  r13 , r13 , 100
	add r10 , r13 
	bswap r10 , r10 ; correct the positioning of the value in order to us e it  

	; r10 contians size 
	;==== align to a 64 bytes 
	cmp r10 , 490
	jg cold_path_large

	; Loop program to finihs in one to two loop iteration for single scalar 
	; switch statement to jump to corrrect loop stage 
	; friction point 
one_line:
	; say registers containing the 54  , 40 , 35 
	; 54 = 0x35 , 0x34   40 = 0x34 ,  0x30   35 = 0x33  , 0x35  , = = 0x3D
	; NOte herre ymm0 - ymm5 is used 
	; note ymm0 contains buffer string 
	; ymm12 - ymm15 for hodlign results  
	mov qword[rsp] , 0x3533303434353D30

	; extracting for 54 
	vpbroadcastb ymm5  , byte[rsp + 2 ] ; hold mask  0x35 
	vpbroadcastb ymm6 , byte[rsp + 3 ]; Hold mask  0x34
	vpbroadcastb ymm7 , byte[rsp + 1] ; Holds mask 0x3D

	vpcmpeqb ymm12 , ymm1 , ymm5  
	vpcmpeqb ymm13 , ymm1 , ymm6 
	vpcmpeqb ymm14 , ymm1 , ymm7 
	
	; Here we shift the mask to find which masks together
	 ; move ymm12 by 2 bytes
	vpsrldq ymm12 , ymm12 , 2 ; shift those bytes by 2 to be inline with = to check 
	vpsrldq ymm13 , ymm13 , 1  ; shift the masked values by 1 to be in line with = to check 
	
	vpand ymm12 , ymm12 , ymm13 ; mask the two values 
	vpand ymm15 , ymm14 , ymm12 ; mask with = 
	; might do stuff with the positioning i.e move position to a gpr register


	; extracting for 40 
	
	vpbroadcastb ymm5  , byte[rsp + 4 ] ; hold mask  0x34 
	vpbroadcastb ymm6 , byte[rsp + 5 ]; Hold mask  0x30
	vpbroadcastb ymm7 , byte[rsp + 1] ; Holds mask 0x3D

	vpcmpeqb ymm12 , ymm1 , ymm5  
	vpcmpeqb ymm13 , ymm1 , ymm6 

	vpsrldq ymm12 , ymm12 , 2 ; shift those bytes by 2 to be inline with = to check 
	vpsrldq ymm13 , ymm13 , 1  ; shift the masked values by 1 to be in line with = to check 
	
	vpand ymm12 , ymm12 , ymm13 ; mask the two values 
	vpand ymm14 , ymm14 , ymm12 ; mask with =
	vpor ymm15 , ymm15 , ymm14 ; or the masks together 
	; extracting for 35 
	vpbroadcastb ymm5  , byte[rsp + 6 ] ; hold mask  0x33
	vpbroadcastb ymm6 , byte[rsp + 7]; Hold mask  0x35
	
	vpcmpeqb ymm12 , ymm1 , ymm5  
	vpcmpeqb ymm13 , ymm1 , ymm6 

	vpsrldq ymm12 , ymm12 , 2 ; shift those bytes by 2 to be inline with = to check 
	vpsrldq ymm13 , ymm13 , 1  ; shift the masked values by 1 to be in line with = to check 

	vpand ymm12 , ymm12 , ymm13 ; mask the two values 
	vpand ymm14 , ymm14 , ymm12 ; mask with =
	vpor ymm15 , ymm15 , ymm14 ; or the masks together

	; Now extarct the values of single byte number
	vpbroadcastb ymm5  , byte[rsp ] ; hold mask  0x30
	vpsubb ymm12 , ymm1 , ymm5
	vpand ymm12 , ymm15  , ymm12 ; Answer is in the ymm12 

	; extract the position for 49 56 and = this are the string extarction 
	; free register ymmm10 - ymm15 
	mov qword[rsp] , 0x0000003D36353934 ; move mask to it
	
	vpbroadcastb ymm5 , byte[rsp] ; move masj 0x34 
	vpbroadcastb ymm6 , byte[rsp+ 1] ; move masj 0x39 
	
	vpcmpeqb ymm12 ,  ymm1 , ymm5
	vpcmpeqb ymm13 , ymm1 , ymm6

	vpsrldq ymm12 , ymm12 , 2 ; shift mask 34 by 2 
	vpsrldq ymm13 , ymm13 ,  ; shift mask 39 by 1
	
	vpand ymm13 , ymm13 , ymm12 
	vpand ymm15 , ymm14 , ymm13 ; mask with = ymm14 contains position with it


	vpbroadcastb ymm5 , byte[rsp + 2 ] ; move masj 0x35 
	vpbroadcastb ymm6 , byte[rsp + 3 ] ; move masj 0x36

	vpcmpeqb ymm12 ,  ymm1 , ymm5
	vpcmpeqb ymm13 , ymm1 , ymm6

	vpsrldq ymm12 , ymm12 , 2 ; shift mask 35 by 2 
	vpsrldq ymm13 , ymm13 , 1 ; shift mask 36 by 1

	vpand ymm13 , ymm13 , ymm12 
	vpand ymm13 , ymm13 , ymm14 ; ymm14 contains the = mask
	vpor ymm15 , ymm13 , ymm15

	vpsrldq ymm15 , ymm15 , 1 ; shift to the actua;l strat position of the strings it contains the offset of the written string to start  o fthe string charcters
	
	; extract numbers larger numbers
	 ; ymm5 contains a mask of 0x35 and ymm14 contains mask of = 
	vpcmpeqb ymm12 , ymm1 ,  ymm5 ; mask all fives 
	vpsrldq ymm13 , ymm12 , 2 ; shift by 1 
	vpsrldq ymm12 , ymm12 , 1 ; shift by 1 

	vpand ymm13 , ymm12 , ymm13
	vpand ymm13 , ymm13 , ymm14 ; mask with =
	vpsrldq ymm13 , ymm13 , 1 ; contains position of stock 
	; 44 princing extract it and do it in xmm regitser before writing back
	; This is for pricing
	
	mov qword[rsp] , 0x343D  ; move mask to it 
	vpbroadcastb ymm5 , byte[rsp +  1 ] ; broadcast mask 0x34 
	vpbroadcastb ymm7 , byte[rsp  ] ; broadcast mask '='

	vpand ymm14 , ymm1 , ymm7 ; check reduduant might have been done before 
	vpand ymm12 , ymm1 , ymm5 ; mask all aperance of 0x34 
	vpsrldq ymm13 , ymm12 , 2 ; move mask to 2 bytes right 
	vpsrldq ymm12 , ymm12 , 1 ; move mask 1 byte right 

	vpand ymm13 , ymm13 , ymm12 ; mask to see whihc position aligns 
	vpand ymm13 , ymm13 , ymm14  ; see which have the position  
	vpsrldq ymm13 , ymm13 , 1 ; move mask 1 byte right
	
	; check flow of genral purpose setup
	vpmovmskb r8d , ymm13
	lzcnt eax , r8d
	lea rax , [rax +  1 ]
	 ; remember to check if zero use brancheless 
	 ; if zero 
	mov r8 , qword[rdi + rax] ; move mantissa 
	mov rcx , 0x2E2E2E2E2E2E2E2E ; mask for '.' 
	and rcx , r8 
	lzcnt rcx , rcx
	mov r8 , rcx 
	add rcx , rax 
	add rax , 9 
	cmp r8d , 32
	cmovne  rax , rcx 
	
	mov r9 , qword[rdi + rax ] ; move exponent
	; extarcting word in r8 and r9


	; finding 38 , 34 
two_line: 
three_line : 
four_line: 
five_lien: 
six_line : 
seven_line: 
eight_line:
; in case th e 8 byte are lost 
resync_scan : 
end : 
	add rsp , 16
	mov rsp , rbp
	vzeroupper 
	ret 

cold_path_large : 
	mov rax , -1 
	vzeroupper 
	ret 
section .note.GNU-stack noalloc noexec nowrite progbits
