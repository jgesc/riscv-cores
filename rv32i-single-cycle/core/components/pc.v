module ProgramCounter
#(
  parameter integer WIDTH = 30
)
(
  input   logic [WIDTH-1:0] jmp_addr,
  input   logic             set,
  input   logic             clk,
  output  logic [WIDTH-1:0] out,
  output  logic [WIDTH-1:0] n_pc
);

  // PC Memory
  logic [WIDTH-1:0] pc;

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
