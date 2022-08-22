WLA_DIR=
ASM=$(WLA_DIR)wla-z80
LINKER=$(WLA_DIR)wlalink

OBJ = $(patsubst %.asm, build/$(PROGNAME)/%.o, $(SRC))


$(PROGNAME).$(EXT): build/$(PROGNAME) $(OBJ) $(PROGNAME).lkr
	$(LINKER) -d -r -v -s $(PROGNAME).lkr $(PROGNAME).$(EXT)


build/$(PROGNAME):
	mkdir -p build/$(PROGNAME)


$(PROGNAME).lkr: $(OBJ)
	echo [objects]> $(PROGNAME).lkr
	echo $(OBJ) | sed -e 's/ /\n/g' >> $(PROGNAME).lkr

build/$(PROGNAME)/%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm build/$(PROGNAME)/*.o $(PROGNAME).sym $(PROGNAME).lkr $(PROGNAME).$(EXT)
