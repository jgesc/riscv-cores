module BranchController
(
  input   logic         cmp_z,      // Comparison from Z flag or ALU output
  input   logic         cmp_inv,    // Invert comparison condition
  input   logic [1:0]   bra_mode,   // Branching mode
  input   logic [31:0]  src_alu,
  input   logic [31:0]  src_imm,
  input   logic [31:0]  pc,
  input   logic         alu_z,      // Z flag of the ALU
  output  logic [31:0]  jmp_addr,   // Immediate output
  output  logic         jmp_enable  // Set PC
);

  // Branch mode
  localparam [1:0] BRA_DISABLE = 2'b00; // Do not branch
  localparam [1:0] BRA_JMP = 2'b01;     // Inconditional branch
  localparam [1:0] BRA_CMP = 2'b10;     // Conditional branch
  localparam [1:0] BRA_ALU = 2'b11;     // Inconditional branch to ALU address

  always @* begin
    case (bra_mode)

      BRA_JMP: begin
        jmp_addr <= pc + src_imm;
        jmp_enable <= 1;
      end

      BRA_CMP: begin
        jmp_addr <= pc + src_imm;
        jmp_enable <= (cmp_z ? alu_z : src_imm) ^ cmp_inv;
      end

      BRA_ALU: begin
        jmp_addr <= src_alu;
        jmp_enable <= 1;
      end

      BRA_DISABLE: jmp_enable <= 0;
    endcase
  end

endmodule
