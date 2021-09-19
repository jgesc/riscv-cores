module RAM
#(
  parameter integer ADDR_SIZE         = 24, // In bytes
  parameter integer BLOCK_BITS        = 128,
  parameter integer DELAY             = 50
)
(
  // Processor communication
  input   [ADDR_SIZE-1:0]         addr, // Memory address
  // Cache communication
  output logic                    ready,
  input logic                     mem_r,
  input logic                     mem_w,
  inout   [BLOCK_BITS-1:0]        mem_data
);

  // Declare memory
  logic [BLOCK_BITS-1:0]        mem   [0:(2**ADDR_SIZE)-1];

  logic mem_bus_output;
  logic [BLOCK_BITS-1:0] mem_buffer;
  assign mem_data = mem_bus_output ? mem_buffer : 'bz;

  // Initialize contents
  initial begin
    integer i, j;
    for (i=0; i < (2**ADDR_SIZE); i=i+1) begin
      mem[i] = 0;
    end
    ready = 1;
    mem_bus_output = 0;
  end

  always @ ( posedge mem_r, mem_w ) begin
    if (ready) begin
      ready <= 0;
      mem_bus_output = 0;
      if (mem_w) begin
        #1 mem[addr] = #DELAY mem_data;
      end else if (mem_r) begin
        mem_buffer = #DELAY mem[addr];
        mem_bus_output = 1;
      end
      ready <= 1;
    end
  end

endmodule
