`include "core.v"
`include "rom.v"
`include "ram.v"

module SoC;

  /// Wiring
  // Common
  wire clk;

  // ROM
  wire [29:0] rom_addr;
  wire [31:0] rom_out;

  // RAM
  wire ram_r;
  wire [3:0] ram_w;
  wire [31:0] ram_in, ram_addr, ram_out;

  /// Components
  ROM rom (.addr(rom_addr), .out(rom_out));
  RAM ram (.clk(clk), .r(ram_r), .w(ram_w), .in(ram_in), .addr(ram_addr),
    .out(ram_out));
  Core core (.clk(clk), .rom_in(rom_out), .ram_in(ram_out), .ram_r(ram_r),
    .ram_w(ram_w), .rom_addr(rom_addr), .ram_out(ram_in), .ram_addr(ram_addr));

  /// Simulation
  initial begin
    $readmemh("IMAGE", rom.data);

  end



endmodule // SoC
