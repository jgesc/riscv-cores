module ROM
#(
  parameter  WORDS  = 64,
  parameter  WIDTH = 32
)
(
  input   [WIDTH-3:0] addr,
  output  [WIDTH-1:0] out
);

logic [WIDTH-1:0] data [0:WORDS-1];

initial begin
  integer i;
  for (i=0; i < WORDS; i=i+1)
    data[i] = 0;
end

assign out = data[{1'b0, addr[WIDTH-4:0]}]; // Most significant bit ignored so ROM and
                                            // RAM can have different address spaces

endmodule // ROM
