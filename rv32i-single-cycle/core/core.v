`include "components/alu.v"
`include "components/regfile.v"
`include "components/controller.v"
`include "components/memctrl.v"
`include "components/pc.v"
`include "components/branch.v"

module Core
(
  input           clk,
  input   [31:0]  rom_in,
  input   [31:0]  ram_in,
  output          ram_r,
  output  [3:0]   ram_w,
  output  [29:0]  rom_addr,
  output  [31:0]  ram_out,
  output  [31:0]  ram_addr
);

  /// Constants
  // Register write sources
  localparam [1:0] RW_DISABLE = 2'b00;  // Do not write register
  localparam [1:0] RW_ALU = 2'b01;      // Write result from ALU
  localparam [1:0] RW_MEM = 2'b10;      // Load from memory
  localparam [1:0] RW_PC = 2'b11;       // Load from PC'

  /// Wiring
  // Common
  wire clk;

  // PC
  wire [31:0] pc_jmp_addr;
  wire [29:0] pc_out, pc_nout;
  wire pc_set;

  // Register file
  wire [31:0] reg_r_addr_1, reg_r_addr_2, reg_w_addr, reg_out_1,
    reg_out_2;
  logic [31:0] reg_in;
  logic reg_we;

  // ALU
  logic [31:0] alu_in_a, alu_in_b;
  wire [31:0] alu_out;
  wire [2:0] alu_op;
  wire alu_alt, alu_c, alu_zero;

  // Memory controller
  wire [31:0] mem_addr_in, mem_data_out;
  wire [2:0] mem_func;
  wire mem_rw_mode, mem_enable;

  // Branch controller
  wire [31:0] bra_src_imm;
  wire bra_mode, bra_jmp_enable, bra_cmp_inv, bra_cmp_z;

  // Instruction controller
  wire [31:0] inst_in, inst_imm_out;
  wire [1:0] inst_r_w_src;
  wire inst_alu_imm_b, inst_alu_pc_a;

  /// Components
  ProgramCounter pc (.jmp_addr(pc_jmp_addr[29:0]), .set(pc_set), .clk(clk),
    .out(pc_out), .n_pc(pc_nout));

  RegisterFile regs (.r_addr_1(reg_r_addr_1), .r_addr_2(reg_r_addr_2),
    .w_addr(reg_w_addr), .in(reg_in), .we(reg_we), .clk(clk), .out_1(reg_out_1),
    .out_2(reg_out_2));

  ALU alu (.in_a(alu_in_a), .in_b(alu_in_b), .op(alu_op), .alt(alu_alt),
    .out(alu_out), .c(alu_c), .zero(alu_zero));

  MemoryController mem (.mem_rw_mode(mem_rw_mode), .mem_enable(mem_enable),
    .mem_func(mem_func), .addr_in(alu_out), .mem_dr(ram_in),
    .data_out(mem_data_out), .mem_dw(ram_out), .mem_r(ram_r), .mem_w(ram_w),
    .mem_addr(ram_addr));

  BranchController bra (.cmp_z(bra_cmp_z), .cmp_inv(bra_cmp_inv),
    .bra_mode(bra_mode), .src_alu(alu_out), .src_imm(bra_src_imm),
    .pc({pc_out, 2'b00}), .alu_z(alu_z), .jmp_addr(pc_jmp_addr),
    .jmp_enable(pc_set));

  InstructionController inst (.in(inst_in), .r_s1(reg_r_addr_1),
    .r_s2(reg_r_addr_2), .r_d(reg_w_addr), .r_w_src(inst_r_w_src),
    .alu_imm_b(inst_alu_imm_b), .alu_pc_a(inst_alu_pc_a), .alu_op(alu_op),
    .alu_alt(alu_alt), .imm_out(inst_imm_out), .cmp_z(bra_cmp_z),
    .cmp_inv(bra_cmp_inv), .bra_mode(bra_mode), .mem_rw_mode(mem_rw_mode),
    .mem_enable(mem_enable), .mem_func(mem_func));

  /// Multiplexers
  // Register write source
  always @(inst_r_w_src or alu_out or mem_data_out or pc_out) begin
    reg_we = !RW_DISABLE;
    case (inst_r_w_src)
      RW_ALU: reg_in <= alu_out;
      RW_MEM: reg_in <= mem_data_out;
      RW_PC: reg_in <= pc_out;
    endcase
  end

  // ALU operand A
  assign alu_in_a = inst_alu_pc_a ? pc_out : reg_out_1;

  // ALU operand B
  assign alu_in_b = inst_alu_imm_b ? inst_imm_out : reg_out_2;

  /// I/O connections
  assign rom_addr = pc_out;
  assign inst_in = rom_in;

endmodule // Core
