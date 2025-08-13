`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2025 11:56:53 PM
// Design Name: 
// Module Name: ethernet_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ethernet_interface #(
   parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 32,
   parameter PACKET_WIDTH = 8 + ADDR_WIDTH + DATA_WIDTH // Header(8) + Addr + Data
) (
   input  wire                  clk,
   input  wire                  rst_n,
   input  wire [PACKET_WIDTH-1:0] packet_in,
   input  wire                  packet_valid,
   output reg  [PACKET_WIDTH-1:0] packet_out,
   output reg                   packet_out_valid,
   // SRAM interface
   output reg  [ADDR_WIDTH-1:0] sram_addr,
   output reg  [DATA_WIDTH-1:0] sram_data_in,
   output reg                   sram_write_en,
   output reg                   sram_read_en,
   input  wire [DATA_WIDTH-1:0] sram_data_out
);
   localparam HEADER_READ  = 8'hAA;
   localparam HEADER_WRITE = 8'hBB;


   reg [1:0] state;
   localparam IDLE = 2'b00, PROCESS = 2'b01, RESPOND = 2'b10;


   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           state <= IDLE;
           packet_out <= {PACKET_WIDTH{1'b0}};
           packet_out_valid <= 1'b0;
           sram_addr <= {ADDR_WIDTH{1'b0}};
           sram_data_in <= {DATA_WIDTH{1'b0}};
           sram_write_en <= 1'b0;
           sram_read_en <= 1'b0;
       end else begin
           case (state)
               IDLE: begin
                   sram_write_en <= 1'b0;
                   sram_read_en <= 1'b0;
                   packet_out_valid <= 1'b0;
                   if (packet_valid) begin
                       state <= PROCESS;
                       if (packet_in[PACKET_WIDTH-1:PACKET_WIDTH-8] == HEADER_WRITE) begin
                           sram_addr <= packet_in[ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
                           sram_data_in <= packet_in[DATA_WIDTH-1:0];
                           sram_write_en <= 1'b1;
                       end else if (packet_in[PACKET_WIDTH-1:PACKET_WIDTH-8] == HEADER_READ) begin
                           sram_addr <= packet_in[ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
                           sram_read_en <= 1'b1;
                       end
                   end
               end
               PROCESS: begin
                   sram_write_en <= 1'b0;
                   sram_read_en <= 1'b0;
                   if (packet_in[PACKET_WIDTH-1:PACKET_WIDTH-8] == HEADER_READ) begin
                       packet_out <= {HEADER_READ, {ADDR_WIDTH{1'b0}}, sram_data_out};
                       packet_out_valid <= 1'b1;
                   end
                   state <= RESPOND;
               end
               RESPOND: begin
                   packet_out_valid <= 1'b0;
                   state <= IDLE;
               end
               default: state <= IDLE;
           endcase
       end
   end
endmodule

