.include "memoryMap.i"
.include "sfHw.i"
.include "psg.i"
.include "vdp.i"
  
  
.bank BANK_CODE slot SLOT_CODE
.org $00
  di
  im 1  
  jp main
  

.section "main" free  

  
.macro checkROMchecksum
  ld hl,$0000
  ld de,$0000
  ld bc,CODE_SIZE-$10 

; code from https://www.smspower.org/Development/BIOSes
Checksum: ;It sums bc bytes from offset hl into de
  ld     a,e          ; add (hl) to de
  add    (hl)
  ld     e,a
  ld     a,d
  adc    $00
  ld     d,a
  inc    hl           ; move pointer on and decrement counter
  dec    bc
  ld     a,b          ; repeat until counter is zero
  or     c
  jr     nz,Checksum
  ;ret
  ld hl,str_ok
  
  ld a,(CODE_SIZE-6)
  cp e
  jp nz,+
  ld a,(CODE_SIZE-5)
  cp d
  jp z,++
+:ld hl,str_bad
++
.endm



patFillCore:  
  ld a,c
  add hl,de
  ex de,hl  
-:ld (hl),a    
  cp $00
  jp nz,+
  ld a,c
+:dec a
  inc hl
  ld b,a;backup
  ld a,d
  cp h
  ld a,b
  jp nz,-  
  exx
  jp (hl)
    
  
patCheckCore:  
  ld a,c
  add hl,de
  ex de,hl  
-:cp (hl)  
  jp nz,patcheckfail
  cp $00
  jp nz,+
  ld a,c
+:dec a
  inc hl
  ld b,a;backup
  ld a,d
  cp h
  ld a,b
  jp nz,-
  ld hl,str_ok
  printm
  exx
  jp (hl)  
patcheckfail:
  ld a,h
  printByte 
  ld a,l
  printByte
  ld a,'='
  printChar
  ld a,(hl)
  printByte  
  exx
  ld a,' '
  printChar
  jp (hl)
  
str_bad:
.db "NG",0

str_ok:
.db "OK ",0
  
  
str_header:
.db "SF tester",0

str_rom:
.db "ROM ",0

str_ram:
.db "RAM ",0


.macro testRamPattern args pattern
  ld a,'*'  
  printChar
  ld a,pattern
  printByte
  ld a,'*'  
  printChar  
.repeat 16 index i
  ld hl,+
  exx
  ld de,$C000 
  ld hl,$400*(i+1)
  ld c,pattern-1
  jp patFillCore  
+:ld hl,+
  exx
  ld de,$C000
  ld hl,$400*(i+1)
  jp patCheckCore  
+:
.endr
.endm

  
main:
  ld sp,$FFFB  
  psg_initialize
  vdp_initialize  
  resetCursor
  ld hl,str_header
  printm
  
  moveCursor 1 
  ld hl,str_rom
  printm  
  checkROMchecksum
  printm

  moveCursor 2
  ld hl,str_ram
  printm

  moveCursor 3
  testRamPattern 251
  testRamPattern 241
  testRamPattern 239
  testRamPattern 233  
     
-:jp -
  
.ends   
