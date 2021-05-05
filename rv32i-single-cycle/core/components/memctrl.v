module MemoryController
(
  input   logic         mem_rw_mode,// Memory read (0) or write (1)
  input   logic         mem_enable, // Enable memory
  input   logic [2:0]   mem_func,   // Memory function
  input   logic [31:0]  addr_in,    // Memory address
  input   logic [31:0]  data_in,    // Data input
  input   logic [31:0]  mem_dr,     // Memory data read
  output  logic [31:0]  data_out,   // Data output
  output  logic [31:0]  mem_dw,     // Memory data write
  output  logic         mem_r,      // Memory read
  output  logic [3:0]   mem_w,      // Memory write selector
  output  logic [31:0]  mem_addr    // Memory address
);

// Byte and Half selector
logic [7:0] sel_b;
logic [15:0] sel_h;

always @* begin
  if (mem_enable) begin
    mem_addr <= addr_in;
    if (mem_rw_mode == 0) begin // Read
      mem_r <= 1;
      mem_w <= 0;

      // Load Byte or Half
      if (mem_func[1:0] == 2'b00) begin
        case (mem_addr[1:0])
          2'b00: sel_b = mem_dr[7:0];
          2'b01: sel_b = mem_dr[15:8];
          2'b10: sel_b = mem_dr[23:16];
          2'b11: sel_b = mem_dr[31:24];
        endcase
      end

      if (mem_func[1:0] == 2'b01) begin
        case (mem_addr[1])
          1'b0: sel_h = mem_dr[15:0];
          1'b1: sel_h = mem_dr[31:16];
        endcase
      end

      // Perform load
      case (mem_func)

        3'b000: begin // LB
          data_out <= {{24{sel_b[7]}}, sel_b};
        end

        3'b001: begin // LH
          data_out <= {{16{sel_h[15]}}, sel_h};
        end

        3'b010: begin // LW
          data_out <= mem_dr;
        end

        3'b100: begin // LBU
          data_out <= {24'b0, sel_b};
        end

        3'b101: begin // LHU
          data_out <= {16'b0, sel_h};
        end

        default: begin
          $display("Unknown MEM FUNC3 %b, aborting", mem_func);
          $finish(1);
        end

      endcase
    end else begin // Write
      mem_r <= 0;
      mem_w <= 1;

      case (mem_addr[1:0])
        2'b00: mem_dw = data_in;
        2'b01: mem_dw = data_in << 8;
        2'b10: mem_dw = data_in << 16;
        2'b11: mem_dw = data_in << 24;
      endcase

      case (mem_func)

        3'b000: begin // SB
          mem_w <= 4'b0001 << mem_addr[1:0];
        end

        3'b001: begin // SH
          mem_w <= mem_addr[1] ? 4'b1100 : 4'b0011;
        end

        3'b010: begin // SW
          mem_w <= 4'b1111;
        end

        default: begin
          $display("Unknown MEM FUNC3 %b, aborting", mem_func);
          $finish(1);
        end

      endcase

    end
  end else begin
    mem_r = 0;
    mem_w = 0;
  end
end

endmodule
