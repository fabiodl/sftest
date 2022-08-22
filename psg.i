.macro psg_initialize
  ld a,%10011111
  out (PORT_PSG),a
  ld a,%10111111
  out (PORT_PSG),a
  ld a,%11011111
  out (PORT_PSG),a
  ld a,%11111111
  out (PORT_PSG),a
.endm

