.define SLOT_CODE    0
.define SLOT_VARS    1

.define CODE_ADDR $0000
.define CODE_SIZE $2000

.define VARS_ADDR $C000
.define VARS_SIZE $1000

  
.memorymap
defaultslot 0
slot SLOT_CODE   CODE_ADDR CODE_SIZE
slot SLOT_VARS   $C000 $1000
.endme

.define BANK_CODE 0    
.define RAMBANK_VARS 0
    
.rombankmap
bankstotal 1
banksize CODE_SIZE
banks 1
.endro 

.define BANK_ROM_CODE BANK_CODE
.define SLOT_ROM_CODE SLOT_CODE

.define BANK_RAM_CODE BANK_CODE
.define SLOT_RAM_CODE SLOT_CODE

.define BANK_SYSRAM_CODE BANK_CODE
.define SLOT_SYSRAM_CODE SLOT_CODE

.computesmschecksum
