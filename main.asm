.include "memoryMap.i"
.include "sfHw.i"
.include "psg.i"
.include "vdp.i"


.bank BANK_CODE slot SLOT_CODE
.org $00
  di
  im 1
  jp main

.org $66
  jr 0

.section "main" free


.macro checkROMchecksum
  ld hl,$0000
  ld de,$0000
  ld bc,ROM_SIZE-$10

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

  ld a,(ROM_SIZE-6)
  cp e
  jp nz,+
  ld a,(ROM_SIZE-5)
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


.macro testRamPattern args pattern address
  ld a,'*'
  printChar
  ld a,pattern
  printByte
  ld a,'*'
  printChar
.repeat 16 index i
  ld hl,+
  exx
  ld de,address
  ld hl,$400*(i+1)
  ld c,pattern-1
  jp patFillCore
+:ld hl,+
  exx
  ld de,address
  ld hl,$400*(i+1)
  jp patCheckCore
+:
.endr
.endm


dump:
  ld a,h          ;'
  printByte
  ld a,l
  printByte
  ld a,':'
  printChar
  exx
  ld b,$10         ;/'
dumploop:
  exx
  ld a,(hl)       ;'
  printByte
  ld a,' '
  printChar
  inc hl
  exx
  djnz dumploop ;/'
  jp (hl)


.macro dumpAt args addr
  ld hl,+
  exx
  ld hl,addr
  jp dump
+:
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

.ifdef TESTRAM
  moveCursor 2
  ld hl,str_ram
  printm
  moveCursor 3

  testRamPattern 251 $C000
  testRamPattern 241 $C000
  testRamPattern 239 $C000
  testRamPattern 233 $C000

  dumpAt $0000
  dumpAt $4000
  dumpAt $8000
  dumpAt $C000
.else

  ld hl,CODE_SIZE
  ld de,RAM_CODE_ADDR
  ld bc,RAM_CODE_SIZE
  ldir

  call testPPI
.endif




lock:jp lock

.ends

.bank BANK_RAM_CODE slot SLOT_RAM_CODE

.section "ramcode" free

str_regC:
.db "Reg C ",0

str_ppi:
.db "PPI ",0

str_ok_r:
.db "OK ",0

str_ng_r:
.db "NG ",0

lowram:
.db "Lowram ",0



printZ:
  ld hl,str_ok_r
  jp z,print
  ld hl,str_ng_r
print:
  printm
  ret

checkWr:
  ld b,a
  ld (hl),a
  ld a,(hl)
  cp b
  jp printZ



testPPI:
  moveCursor 2
  ld hl,str_ppi
  call print
setPorts:
  ld a,%10010010
       ;|io mode,
       ; ||group a mode 0,
       ;   |porta a input
       ;    |port c upper output
       ;     |group b mode 0
       ;      |port b input
       ;       |port c lower output
  out (PORT_SFPPI_CTRL),a
  ld a,$40  ;romsel =1,(ram)
  nop
  nop
  out (PORT_SFPPI_C),a
  ld hl,str_regC
  call print
  in a,(PORT_SFPPI_C)
  cp $40
  call printZ
  ld hl,lowram
  call print

  ld hl,$0000
  ld b,$55
  call checkWr

  ld hl,$1000
  ld b,$AA
  call checkWr



-:ld a,$40
  out (PORT_SFPPI_C),a
  jp -



.ends
