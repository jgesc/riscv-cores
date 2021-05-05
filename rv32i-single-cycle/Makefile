RISCV_GCC = riscv64-unknown-elf-gcc
RISCV_OBJCOPY = riscv64-unknown-elf-objcopy
RISCV_LIBGCC = /usr/lib/gcc/riscv64-unknown-elf/9.3.0/rv32i/ilp32/libgcc.a

.PHONY: build-soc
build-soc:
	iverilog -g2012 -I core -I soc soc/soc.v -o riscv_core

.PHONY: build-test
build-test:
	# Compile test program
	$(RISCV_GCC) -nostartfiles -nostdlib  -march=rv32i -mabi=ilp32 \
		-T test/custom.ld test/*.c $(RISCV_LIBGCC)
	# Extract ROM and RAM images
	$(RISCV_OBJCOPY) -O verilog --verilog-data-width 4 \
		--reverse-bytes 4 --only-section .text a.out text.hex
	$(RISCV_OBJCOPY) -O verilog --verilog-data-width 4 \
		--reverse-bytes 4 --only-section .rodata a.out rodata.hex
	# Remove memory possition from extracted files
	sed -i '1d' text.hex
	sed -i '1d' rodata.hex

.PHONY: test
test: build-soc build-test
	./riscv_core +ROMIMG=text.hex +RAMIMG=rodata.hex +MEMDUMP=mem.hex

.PHONY: clean
clean:
	rm -f a.out mem.hex riscv_core rodata.hex text.hex
