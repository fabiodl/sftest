
.define MODETEXTTURNON  %11110000
;                        ||||| |`- Sprite Magnify
;                        ||||| `-- Sprite Size Select
;                        ||||`---- M2 
;                        |||`----- M1 (text is M1 M2 M3= 100) 
;                        ||`------ VBlank interrupts
;                        |`------- Enable display
;                        `-------- Vram 16K
  
.define FONT_CHARACTERS      95


.macro safeVdpHL  
  ld a,l
  out (PORT_VDP_CMD),a
.repeat 5
  nop
.endr
  ld a,h
  out (PORT_VDP_CMD),a
.repeat 4
  nop
.endr
.endm

.macro vdpOtir
-:outi   ;16
  nop    ;4
  jp nz,- ;10
.endm
  
  
.macro turnOffDisplay
  ld hl, ((VDPCMD_REG|$01)<<8)|$80
  safeVdpHL
  ld hl, ((VDPCMD_REG|$00)<<8)|$00
  safeVdpHL
.endm


.macro copyFont
-:
  vdpOtir
  dec a
  jp nz,-
.endm


.macro fontCopyMacro ARGS bytesPerChar,normalFontBegin,baseAddrH
  xor a
  out (PORT_VDP_CMD),a
  ld a,VDPCMD_VRAM_WR|((bytesPerChar*$20)>>8)|baseAddrH   ;8 bytes for each char before space
  out (PORT_VDP_CMD),a      
  ld hl,normalFontBegin
  
  ld a,((FONT_CHARACTERS*bytesPerChar)>>8)+1    ;number of 256 byte loops
  ld b,FONT_CHARACTERS*bytesPerChar-256*((FONT_CHARACTERS*bytesPerChar)>>8);remainder
  copyFont  
.endm  


  
.macro fontTextCopy
  fontCopyMacro 8,ModeTextFontData,0
.endm
  
.macro vdp_initialize
  turnOffDisplay
  ld c,PORT_VDP_CMD
  ld b,2*8
  ld hl,textRegs
  otir
  
  xor a
  out (PORT_VDP_CMD),a
  ld a,VDPCMD_VRAM_WR
  out (PORT_VDP_CMD),a

  ; 2. Output 16KB of zeroes
  ld bc, $4000    ; Counter for 16KB of VRAM
  ;ld bc,1
clearVRAMLoop:
  xor a
  out (PORT_VDP_DATA),a ; Output to VRAM address, which is auto-incremented after each write
  dec bc
  ld a,b
  or c
  jp nz,clearVRAMLoop
  ld c,PORT_VDP_DATA
  ;no palette
  fontTextCopy 
  ld hl,((VDPCMD_REG|$01)<<8)|MODETEXTTURNON
  safeVdpHL 

.endm


.macro printm
  xor a ;necessary for cp  
  ld c,PORT_VDP_DATA  
-:outi ;16  
  cp (hl)   ;7
  jp nz,-   ;10 
.endm

.macro resetCursor
  ld hl,(VDPCMD_VRAM_WR|$38)<<8
  safeVdpHL
.endm


.macro moveCursor ARGS row
  ld hl,((VDPCMD_VRAM_WR|$38)<<8) + 40*row
  safeVdpHL 
.endm
      
  
.section "font" free


textRegs:
.db $00,VDPCMD_REG|$00  ; disable external video & horizontal interrupt
.db $90,VDPCMD_REG|$01  ; Select 40 column mode, enable screen and disable vertical interrupt
.db $0E,VDPCMD_REG|$02  ; Set name table to $3800
.db $00,VDPCMD_REG|$03  ; Register 3 is ignored as 40 column mode does not need color table
.db $00,VDPCMD_REG|$04  ; Set pattern table to $0000
.db $00,VDPCMD_REG|$05  ; Registers 5 (Sprite attribute) & 6 (Sprite pattern) are ignored as 40 column mode does not have sprites
.db $00,VDPCMD_REG|$06
.db $30,VDPCMD_REG|$07  ; Set fg(high nibble ) and bg(low nibble

      
ModeTextFontData:
.include "msxFont.i"  


.ends
