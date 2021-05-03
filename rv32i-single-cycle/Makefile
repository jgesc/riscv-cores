make-all:
	iverilog -g2012 -I core -I soc soc/soc.v -o out

.PHONY: test
test:
	riscv64-unknown-elf-gcc -nostartfiles -nostdlib  -march=rv32i -mabi=ilp32 \
		-T test/custom.ld test/main.c /usr/lib/gcc/riscv64-unknown-elf/9.3.0/rv32i/ilp32/libgcc.a
	riscv64-unknown-elf-objcopy -O verilog --verilog-data-width 4 \
		--reverse-bytes 4 --only-section .text a.out text.hex
	riscv64-unknown-elf-objcopy -O verilog --verilog-data-width 4 \
		--reverse-bytes 4 --only-section .rodata a.out rodata.hex
	sed -i '1d' text.hex
