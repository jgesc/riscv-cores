// Basic integer ALU

module ALU
#(
  parameter integer WIDTH = 32
)
(
  input   logic [WIDTH-1:0] in_a,
  input   logic [WIDTH-1:0] in_b,
  input   logic [2:0]       op,
  input   logic             alt,
  output  logic [WIDTH-1:0] out,
  output  logic             c,
  output  logic             zero
);

  always @ (in_a, in_b, op, alt) begin
    // Select operation
    case (op)
      // Addition (ADD/SUB)
      3'b000: {c, out} <= alt ? in_a - in_b : in_a + in_b;
      // Left shift (SLL)
      3'b001: out <= in_a << in_b[4:0];
      // Less than (SLT)
      3'b010: out <= $signed(in_a) < $signed(in_b);
      // Less than unsigned (SLTU)
      3'b011: out <= in_a < in_b;
      // XOR
      3'b100: out <= in_a ^ in_b;
      // Right shift (SRL/SRA)
      3'b101: out <= alt ? $signed(in_a) >>> in_b[4:0] : in_a >> in_b[4:0];
      // OR
      3'b110: out <= in_a | in_b;
      // AND
      3'b111: out <= in_a & in_b;
    endcase
  end

  // Zero flag
  assign zero = |out;

endmodule
