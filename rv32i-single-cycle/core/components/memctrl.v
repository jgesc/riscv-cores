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

always @* begin
  if (mem_enable) begin
    mem_addr <= addr_in;
    if (mem_rw_mode == 0) begin // Read
      mem_r <= 1;
      mem_w <= 0;

      case (mem_func)

        3'b000: begin // LB
          data_out <= {24'b0, mem_dr[7:0]};
        end

        3'b001: begin // LH
          data_out <= {16'b0, mem_dr[15:0]};
        end

        3'b010: begin // LW
          data_out <= mem_dr;
        end

        3'b100: begin // LBU
          data_out <= {{24{mem_dr[7]}}, mem_dr[7:0]};
        end

        3'b101: begin // LHU
          data_out <= {{16{mem_dr[15]}}, mem_dr[15:0]};
        end

        default: begin
          $display("Unknown MEM FUNC3 %b, aborting", mem_func);
          $finish(1);
        end

      endcase
    end else begin // Write
      mem_r <= 0;
      mem_w <= 1;

      mem_dw <= data_in;

      case (mem_func)

        3'b000: begin // SB
          mem_w <= 4'b0001;
        end

        3'b001: begin // SH
          mem_w <= 4'b0011;
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
