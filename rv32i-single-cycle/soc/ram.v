module RAM
#(
  parameter integer WORDS = 32
)
(
  input                   clk,
  input                   r,
  input         [3:0]     w,
  input         [31:0]    in,
  input         [31:0]    addr,
  output logic  [31:0]    out
);

  logic [31:0] mem [0:WORDS-1];
  wire [29:0] _addr;

  initial begin
    integer i;
    for (i=0; i < WORDS; i=i+1)
      mem[i] = 0;
  end

  assign _addr = {2'b0, addr[29:2]};  // Most significant bit ignored so ROM and
                                      // RAM can have different address spaces

  always @ (_addr or r) begin
    if(r) out <= mem[_addr];
  end

  always @ (negedge clk) begin
    if(w[0]) mem[_addr[7:0]] = in[7:0];
    if(w[0]) mem[_addr[15:8]] = in[15:8];
    if(w[0]) mem[_addr[23:16]] = in[23:16];
    if(w[0]) mem[_addr[31:24]] = in[31:24];
  end

endmodule
