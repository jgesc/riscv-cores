module ProgramCounter
#(
  parameter integer WIDTH = 30
)
(
  input   logic [WIDTH-1:0] jmp_addr,
  input   logic             set,
  input   logic             clk,
  output  logic [WIDTH-1:0] out,
  output  logic [WIDTH-1:0] n_pc_out
);

  logic [WIDTH-1:0] n_pc;

  assign n_pc_out = n_pc << 2;

  // PC Memory
  logic [WIDTH-1:0] pc = 0;

  // Positive clock edge
  always @ ( posedge clk ) begin
    out <= pc;
    n_pc <= pc + 1;
  end

  // Negative clock edge
  always @ ( negedge clk ) begin
    pc <= set ? jmp_addr : n_pc;
  end

endmodule
