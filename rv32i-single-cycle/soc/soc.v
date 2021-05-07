`include "core.v"
`include "rom.v"
`include "ram.v"

module SoC
#(
    parameter integer ROM_SIZE = 8192,    // 32 KB
    parameter integer RAM_SIZE = 4194304  // 16 MB
);

  /// Wiring
  // Common
  logic clk = 0;
  wire brk;

  // ROM
  wire [29:0] rom_addr;
  wire [31:0] rom_out;

  // RAM
  wire ram_r;
  wire [3:0] ram_w;
  wire [31:0] ram_in, ram_addr, ram_out;

  /// Components
  ROM#(.WORDS(ROM_SIZE)) rom (.addr(rom_addr), .out(rom_out));
  RAM#(.WORDS(RAM_SIZE)) ram (.clk(clk), .r(ram_r), .w(ram_w), .in(ram_in),
    .addr(ram_addr), .out(ram_out));
  Core core (.clk(clk), .rom_in(rom_out), .ram_in(ram_out), .ram_r(ram_r),
    .ram_w(ram_w), .rom_addr(rom_addr), .ram_out(ram_in), .ram_addr(ram_addr),
    .brk(brk));

  /// Simulation

  string memdump;
  string ramimg, romimg;

  // Check for breakpoint
  always @(posedge brk) begin
    $display("\nBreak point @ ", $time / 20, " clocks");

    if ($value$plusargs ("MEMDUMP=%s", memdump))
      $writememh(memdump, ram.mem);

    $finish(2);
    //$stop(0);
  end

  always @(negedge clk) begin
    if(core.regs.r[2] > RAM_SIZE) begin
      $display("STACK_POINTER_VIOLATION (%d)", core.regs.r[2]);
      $finish(0);
    end
    if(ram._addr > RAM_SIZE) begin
      $display("RAM_ACCESS_VIOLATION (%d)", ram._addr);
      $finish(0);
    end
  end

  always @ core.pc.out begin
    //$display("PC = %x", core.pc.out << 2);
    if((($time - 10) % 2000000) == 0) begin
      $display($time / 20, " clocks");
    end
  end

  initial begin
    // Parse comments
    if ($value$plusargs ("ROMIMG=%s", romimg))
      $readmemh(romimg, rom.data);
    else begin
      $display("Arguments:");
      $display("\t+ROMIMG=");
      $display("\t+RAMIMG=");
      $display("\t+MEMDUMP=");
      $finish(0);
    end
    if ($value$plusargs ("RAMIMG=%s", ramimg))
      $readmemh(ramimg, ram.mem);

    // Clock
    forever begin
      #10 clk = ~clk;
    end
  end

endmodule // SoC
