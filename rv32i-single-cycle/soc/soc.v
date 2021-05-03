`include "core.v"
`include "rom.v"
`include "ram.v"

module SoC
#(
    parameter integer ROM_SIZE = 4096,
    parameter integer RAM_SIZE = 4096
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
  always @(posedge brk) begin
    $display("Break point");


    if ($value$plusargs ("MEMDUMP=%s", memdump))
      $writememh(memdump, ram.mem);

    $finish(0);
    //$stop(0);
  end

  initial begin
    if ($value$plusargs ("ROMIMG=%s", romimg)) begin
      $readmemh(romimg, rom.data);
    end
    if ($value$plusargs ("RAMIMG=%s", ramimg))
      $readmemh(ramimg, ram.mem);
    //$readmemh("test.hex", rom.data);
    $monitor("%x", core.pc.pc);

    forever begin
      #10 clk = ~clk;
    end
  end



endmodule // SoC
