// Right bit shifter

module RightShifter
#(
  parameter integer WIDTH = 32,
  parameter integer DEPTH = 5
)
(
  input   logic [WIDTH-1:0] in,
  input   logic [DEPTH-1:0] shamt,
  input   logic             arith,
  output  logic [WIDTH-1:0] out
);

  // Intermediate wires
  logic [WIDTH-1:0] interm  [DEPTH+1];
  logic signed [WIDTH-1:0] interma [DEPTH+1];

  // Set first intermediate wire to input
  assign interm[0] = in;
  assign interma[0] = in;

  // Generate multiplexors
  genvar i;
  generate
    for(i = 0; i < DEPTH; i++) begin
      assign interm[i+1] = shamt[i] ? (interm[i] >> (1 << i)) : interm[i];
      assign interma[i+1] = shamt[i] ? (interma[i] >>> (1 << i)) : interma[i];
    end
  endgenerate

  // Set last intermediate wire as output
  assign out = arith ? interma[DEPTH] : interm[DEPTH];

endmodule
