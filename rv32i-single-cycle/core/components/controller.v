module InstructionController
(
  input   logic [31:0]  in,
  output  logic [31:0]  r_s1,       // rs1 field
  output  logic [31:0]  r_s2,       // rs2 field
  output  logic [31:0]  r_d,        // rd field
  output  logic [1:0]   r_w_src,    // Register write source
  output  logic         alu_imm_b,  // ALU in_b from register or immediate
  output  logic         alu_pc_a,   // ALU in_a from PC or register
  output  logic [2:0]   alu_op,     // ALU operation to use
  output  logic         alu_alt,    // ALU alternate operation mode
  output  logic [31:0]  imm_out,    // Immediate output
  output  logic         cmp_z,      // Comparison from Z flag or ALU output
  output  logic         cmp_inv,    // Invert comparison condition
  output  logic         bra_mode,   // Branching mode
  output  logic         mem_rw_mode,// Memory read (0) or write (1)
  output  logic         mem_enable, // Enable memory
  output  logic [2:0]   mem_func    // Memory function
);

  // Register write sources
  localparam [1:0] RW_DISABLE = 2'b00;  // Do not write register
  localparam [1:0] RW_ALU = 2'b01;      // Write result from ALU
  localparam [1:0] RW_MEM = 2'b10;      // Load from memory
  localparam [1:0] RW_PC = 2'b11;       // Load from PC'

  // Branch mode
  localparam [1:0] BRA_DISABLE = 2'b00; // Do not branch
  localparam [1:0] BRA_JMP = 2'b01;     // Inconditional branch
  localparam [1:0] BRA_CMP = 2'b10;     // Conditional branch
  localparam [1:0] BRA_ALU = 2'b11;     // Inconditional branch to ALU address


  always @ ( in ) begin

    alu_pc_a <= in[6:0] == 7'b0010111;

    case (in[6:0]) // Get OPCODE

      // Load upper immediate
      7'b1101111: begin
        alu_imm_b <= 1; // Operand B from immediate
        alu_op <= 3'b000; // ALU op
        alu_alt <= 0; // ALU alt
        imm_out <= {in[31:12], 12'b0}; // Get immediate
        bra_mode <= BRA_DISABLE; // Disable branching comparator
        r_w_src <= RW_ALU; // Enable register write
        r_s1 <= 0;
        r_d <= in[11:7];
        mem_enable <= 0;
      end

      // Add upper immediate program counter
      7'b0010111: begin
        alu_imm_b <= 1; // Operand B from immediate
        alu_op <= 3'b000; // ALU op
        alu_alt <= 0; // ALU alt
        imm_out <= {in[31:12], 12'b0}; // Get immediate
        bra_mode <= BRA_ALU; // Disable branching comparator
        mem_enable <= 0;
      end

      // Jump and link
      7'b1101111: begin
        imm_out <= {{11{in[31]}}, in[19:12], in[20], in[30:25], in[24:21], 1'b0};
        r_w_src <= RW_PC; // Write from PC'
        r_d <= in[11:7];
        bra_mode <= BRA_JMP;
        mem_enable <= 0;
      end

      // Jump and link relative
      7'b1100111: begin
        alu_imm_b <= 1; // Operand B from immediate
        alu_op <= in[14:12]; // ALU op
        alu_alt <= 0; // ALU alt
        imm_out <= {{20{in[31]}}, in[31:20]};
        bra_mode <= BRA_ALU; // Jump to result from ALU
        r_w_src <= RW_ALU; // Enable register write
        r_s1 <= in[19:15]; // Registers
        r_d <= in[11:7];
        mem_enable <= 0;
      end

      // Memory load
      7'b0000011: begin
        alu_imm_b <= 1; // Operand B from immediate
        alu_op <= 3'b000; // ALU op
        alu_alt <= 0; // ALU alt
        imm_out <= {{20{in[31]}}, in[31:20]};
        bra_mode <= BRA_DISABLE; // Jump to result from ALU
        r_w_src <= RW_MEM; // Enable register write
        r_s1 <= in[19:15]; // Registers
        r_d <= in[11:7];
        mem_enable <= 1;
        mem_rw_mode <= 0;
        mem_func <= in[14:12];
      end

      // Memory store
      7'b0100011: begin
        alu_imm_b <= 1; // Operand B from immediate
        alu_op <= 3'b000; // ALU op
        alu_alt <= 0; // ALU alt
        imm_out <= {{20{in[31]}}, in[31:25], in[11:7]};
        bra_mode <= BRA_DISABLE; // Jump to result from ALU
        r_w_src <= RW_MEM; // Enable register write
        r_s1 <= in[19:15]; // Registers
        r_s2 <= in[24:20];
        mem_enable <= 1;
        mem_rw_mode <= 1;
        mem_func <= in[14:12];
      end

      // Conditional branches
      7'b1100011: begin
        alu_imm_b <= 0; // Operand B from register
        imm_out <= {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
        r_w_src <= RW_DISABLE; // Disable register write
        bra_mode <= BRA_CMP; // Enable branching comparator
        // Registers
        r_s1 <= in[19:15];
        r_s2 <= in[24:20];
        // Branching condition
        cmp_z <= ~in[14];
        cmp_inv <= in[12];
        mem_enable <= 0;
      end

      // ALU Immediate
      7'b0010011: begin
        alu_imm_b <= 1; // Operand B from immediate
        alu_op <= in[14:12]; // ALU op
        alu_alt <= alu_op == 3'b101 ? in[30] : 0; // ALU alt
        imm_out <= {{20{in[31]}}, in[31:20]}; // Get immediate
        bra_mode <= BRA_DISABLE; // Disable branching comparator
        r_w_src <= RW_ALU; // Enable register write
        r_s1 <= in[19:15]; // Registers
        r_d <= in[11:7];
        mem_enable <= 0;
      end

      // ALU Register
      7'b0110011: begin
        alu_imm_b <= 0; // Operand B from register
        alu_op <= in[14:12]; // ALU op
        alu_alt <= in[30]; // ALU alt
        bra_mode <= 0; // Disable branching comparator
        r_w_src <= RW_ALU; // Enable register write
        r_s1 <= in[19:15]; // Registers
        r_s2 <= in[24:20];
        r_d <= in[11:7];
        mem_enable <= 0;
      end

      // Unknown OPCODE exception
      default: begin
        $display("Unknown OPCODE %b", in[6:0]);
        $finish(1);
      end
    endcase
  end

endmodule
