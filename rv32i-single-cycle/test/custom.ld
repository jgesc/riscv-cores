MEMORY {
    ROM (x)   : ORIGIN = 0x00000000, LENGTH = 32K
    RAM (rw)  : ORIGIN = 0x40000000, LENGTH = 4M
}

SECTIONS {
    . = ORIGIN(ROM);
    .text : {
        KEEP(*(.stack))
        KEEP(*(.text))
        . = ALIGN(4);
    } >ROM

    . = ORIGIN(RAM);

    .rodata ALIGN(4) : {
      *(.rodata)         /* .rodata sections (constants, strings, etc.) */
      *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
      *(.sdata)
      . = ALIGN(4);
    } >RAM

    .data ALIGN(4) : {
        *(.data)
        . = ALIGN(4);
    } >RAM
}
