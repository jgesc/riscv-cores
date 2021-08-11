// Direct-mapped cache write-back word-access

module Cache
#(
  parameter integer ADDR_SIZE         = 30,
  parameter integer WORD_SIZE         = 32,
  parameter integer BLOCK_OFFSET_BITS = 2,
  parameter integer INDEX_BITS        = 4
)
(
  input                           clk, // Clock
  // Processor communication
  input                           we, // Write enable
  input   [ADDR_SIZE-1:0]         addr, // Memory address
  input   [WORD_SIZE-1:0]         data_w, // Data to write
  output  [WORD_SIZE-1:0]         data_r, // Data to read
  output                          stall, // Stall
  // Memory communication
  input                           ready,
  output logic                    mem_r,
  output logic                    mem_w,
  inout   [(WORD_SIZE * (2**BLOCK_OFFSET_BITS))-1:0]         mem_data
);

  // Calculate tag length
  localparam TAG_BITS = ADDR_SIZE - BLOCK_OFFSET_BITS - INDEX_BITS;
  localparam CACHE_LINES = (2**INDEX_BITS);
  localparam WORDS_PER_LINE = (2**BLOCK_OFFSET_BITS);

  // Declare memory
  logic [TAG_BITS-1:0]        c_tag   [0:CACHE_LINES-1];
  logic                       c_d     [0:CACHE_LINES-1];
  logic [0:WORDS_PER_LINE-1][WORD_SIZE-1:0]       c_block [0:CACHE_LINES-1];

  // Initialize contents
  initial begin
    integer i, j;
    for (i=0; i < CACHE_LINES; i=i+1) begin
      c_tag[i] = 0;
      c_d[i] = 0;
      for (j = 0; j < WORDS_PER_LINE; j=j+1)
        c_block[i][j] = 0;
    end
  end


  /// Cache memory access
  // Decompose address
  wire [TAG_BITS-1:0]           addr_tag;
  wire [INDEX_BITS-1:0]         addr_idx;
  wire [BLOCK_OFFSET_BITS-1:0]  addr_offset;

  assign addr_tag     = addr[ADDR_SIZE-1:ADDR_SIZE-TAG_BITS];
  assign addr_idx     = addr[ADDR_SIZE-TAG_BITS-1:ADDR_SIZE-TAG_BITS-INDEX_BITS];
  assign addr_offset  = addr[BLOCK_OFFSET_BITS-1:0];

  // Check for hit and dirty bits
  wire hit;
  wire d;
  assign hit = (c_tag[addr_idx] == addr_tag);
  assign d = c_d[addr_idx];

  assign data_r = c_block[addr_idx][addr_offset];
  assign stall = !hit;

  assign mem_data = mem_w ? c_block[addr_idx] : 'bz;

  /// State machine - Main logic
  // S0 : Ready
  // S1 : Writting to memory
  // S2 : Reading from memory
  enum logic [1:0] {S0=2'b00, S1=2'b01, S2=2'b10} state;

  // At clock negedge
  always_ff @ (negedge clk) begin
    // If ready
    if(state == S0) begin
      // If cache-hit
      if (hit) begin
        // If write operation
        if (we) begin
          // Write values
          c_block[addr_idx][addr_offset] <= data_w;
          // Flag dirty bit
          c_d[addr_idx] = 1;
        end
      // If cache-miss
      end else begin
        // If block is dirty
        if (d) begin
          // Set write-back state
          state <= S1;
          // Assert write operation to memory
          mem_w <= 1;
        // If block is not dirty
        end else begin
          // Set replace state
          state <= S2;
          // Assert read operation to memory
          mem_r <= 1;
        end
      end
    end
  end

  // State transition
  always_ff @ (posedge ready) begin
    case (state)
      S1: begin
        mem_w <= 0; // De-assert memory write operation
        c_d[addr_idx] <= 0; // Clean dirty bit
        state <= S0; // Set state to ready
      end
      S2: begin
        mem_r <= 0; // De-assert memory read operation
        c_d[addr_idx] <= 0; // Clean dirty bit
        c_tag[addr_idx] <= addr_tag; // Update tag
        c_block[addr_idx][addr_offset] <= mem_data; // Store data in block
        state <= S0; // Set state to ready
      end
      default: ;
    endcase
  end


endmodule
