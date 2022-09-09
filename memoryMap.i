.define SLOT_CODE     0
.define SLOT_RAM_CODE 1
.define SLOT_VARS     2

.define CODE_ADDR $0000
.define CODE_SIZE $1000

.define RAM_CODE_ADDR $C000
.define RAM_CODE_SIZE $1000

.define VARS_ADDR RAM_CODE_ADDR+RAM_CODE_SIZE
.define VARS_SIZE $1000


.memorymap
defaultslot 0
slot SLOT_CODE   CODE_ADDR CODE_SIZE
slot SLOT_RAM_CODE RAM_CODE_ADDR RAM_CODE_SIZE
slot SLOT_VARS   VARS_ADDR VARS_SIZE
.endme

.define BANK_CODE 0
.define BANK_RAM_CODE 1

.define RAMBANK_VARS 0

.rombankmap
bankstotal 2
banksize CODE_SIZE
banks 1
banksize RAM_CODE_SIZE
banks 1
.endro

.define ROM_SIZE CODE_SIZE+RAM_CODE_SIZE
.computesmschecksum
