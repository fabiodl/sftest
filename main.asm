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


.macro patFill16K
  ld hl,$4000
patFillCore:  
  xor a
  add hl,de
  ex de,hl  
-:ld (hl),a    
  cp c
  jp nz,+
  ld a,$FF
+:inc a
  inc hl
  ld b,a;backup
  ld a,d
  cp h
  ld a,b
  jp nz,-  
.endm
  

.macro patCheck16K
  ld hl,$4000
patCheckCore:  
  xor a
  add hl,de
  ex de,hl  
-:cp (hl)  
  jp nz,patcheckfail
  cp c
  jp nz,+
  ld a,$FF
+:inc a
  inc hl
  ld b,a;backup
  ld a,d
  cp h
  ld a,b
  jp nz,-
  ld hl,str_ok
  jp ++  
patcheckfail:
  ld hl,str_bad
++:
.endm

  
str_bad:
.db "NG",0

str_ok:
.db "OK",0
  
  
str_header:
.db "SF tester",0

str_rom:
.db "ROM ",0

str_ram:
.db "RAM ",0


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
  ld de,$C000
  ld c,10
  patFill16K
  ld de,$C000
  ld c,10
  patCheck16K
  printm
  

     
-:jp -
  
.ends   
