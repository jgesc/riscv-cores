module ROM
#(
  parameter  SIZE  = 8192,
  parameter  WIDTH = 32
)
(
  input   [WIDTH-3:0] addr,
  output  [WIDTH-1:0] out
);

logic [WIDTH-1:0] data [0:SIZE-1];

assign out = data[addr];

endmodule // ROM
