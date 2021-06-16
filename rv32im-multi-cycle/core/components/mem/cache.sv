// Direct-mapped cache write-back

module Cache
#(
  parameter integer WORD_SIZE_BITS    = 32,
  parameter integer BLOCK_OFFSET_BITS = 4,
  parameter integer INDEX_BITS        = 8
)
(
  input                           replace,
  input                           we,
  input                           clk,
  input   [WORD_SIZE_BITS-1:0]    addr,
  input   [WORD_SIZE_BITS-1:0]    data_write,
  output  [WORD_SIZE_BITS-1:0]    data_read,
  output  [WORD_SIZE_BITS-1:0]    mem_addr,
  output                          hit,
  output                          d
);

  // Calculate tag length
  localparam TAG_BITS = WORD_SIZE_BITS - BLOCK_OFFSET_BITS - INDEX_BITS;
  localparam CACHE_LINES = (2**BLOCK_OFFSET_BITS);

  // // Declare memory
  // typedef struct packed {
  //   bit [TAG_BITS-1:0] tag;
  //   bit d;
  //   bit [WORD_SIZE_BITS-1:0] block [0:(2**BLOCK_OFFSET_BITS)-1];
  // } st_cacheline;
  // st_cacheline mem[0:(INDEX_BITS**2)-1];
  //
  // // Initialize contents
  // initial begin
  //   integer i;
  //   for (i=0; i < (INDEX_BITS**2); i=i+1)
  //     mem[i] = 0;
  // end

  // Declare memory
  logic [TAG_BITS-1:0]        c_tag   [0:CACHE_LINES-1];
  logic                       c_d     [0:CACHE_LINES-1];
  logic [WORD_SIZE_BITS-1:0]  c_block [0:CACHE_LINES-1];

  // Initialize contents
  initial begin
    integer i;
    for (i=0; i < (INDEX_BITS**2); i=i+1)
      c_tag[i] = 0;
      c_d[i] = 0;
      c_block[i] = 0;
  end


  /// Cache memory access
  // Decompose address
  wire [TAG_BITS-1:0]           addr_tag;
  wire [INDEX_BITS-1:0]         addr_idx;
  wire [BLOCK_OFFSET_BITS-1:0]  addr_offset;

  assign addr_tag     = addr[WORD_SIZE_BITS-1:WORD_SIZE_BITS-TAG_BITS];
  assign addr_idx     = addr[WORD_SIZE_BITS-TAG_BITS-1:WORD_SIZE_BITS-TAG_BITS-INDEX_BITS];
  assign addr_offset  = addr[BLOCK_OFFSET_BITS-1:0];

  // Check for hit and dirty bits
  assign hit = (c_tag[addr_idx] == addr_tag);
  assign d = c_d[addr_idx];
  assign mem_addr = {addr_tag, addr_idx, addr_offset};

endmodule
