module RegisterFile
#(
  parameter integer WIDTH = 32,
  parameter integer REGNO = 32
)
(
  input   logic [WIDTH-1:0] r_addr_1,
  input   logic [WIDTH-1:0] r_addr_2,
  input   logic [WIDTH-1:0] w_addr,
  input   logic [WIDTH-1:0] in,
  input   logic             we,
  input   logic             clk,
  output  logic [WIDTH-1:0] out_1,
  output  logic [WIDTH-1:0] out_2
);

  // Register memory
  logic [WIDTH-1:0] r [0:REGNO-1];
  initial r[0] = 0;

  // Initialize to 0
  initial begin
    integer i;
    for (i=0; i < REGNO; i=i+1)
      r[i] = 0;
  end

  // Memory output
  always @ ( r_addr_1 ) begin
    out_1 <= r[r_addr_1];
  end
  always @ ( r_addr_2 ) begin
    out_2 <= r[r_addr_2];
  end

  // Write to register
  always @ ( negedge clk ) begin
    if(we && w_addr != 0)
      r[w_addr] <= in;
  end

endmodule
