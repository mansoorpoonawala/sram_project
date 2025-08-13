`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2025 11:58:36 PM
// Design Name: 
// Module Name: top_module
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


module top_module #(
   parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 32,
   parameter PACKET_WIDTH = 8 + ADDR_WIDTH + DATA_WIDTH
) (
   input  wire                  clk,
   input  wire                  rst_n,
   input  wire [PACKET_WIDTH-1:0] packet_in,
   input  wire                  packet_valid,
   output wire [PACKET_WIDTH-1:0] packet_out,
   output wire                  packet_out_valid
);
   wire [ADDR_WIDTH-1:0] sram_addr;
   wire [DATA_WIDTH-1:0] sram_data_in, sram_data_out;
   wire sram_write_en, sram_read_en;


   sram_core #(
       .ADDR_WIDTH(ADDR_WIDTH),
       .DATA_WIDTH(DATA_WIDTH)
   ) sram_inst (
       .clk(clk),
       .rst_n(rst_n),
       .addr(sram_addr),
       .data_in(sram_data_in),
       .write_en(sram_write_en),
       .read_en(sram_read_en),
       .data_out(sram_data_out)
   );


   ethernet_interface #(
       .ADDR_WIDTH(ADDR_WIDTH),
       .DATA_WIDTH(DATA_WIDTH),
       .PACKET_WIDTH(PACKET_WIDTH)
   ) eth_inst (
       .clk(clk),
       .rst_n(rst_n),
       .packet_in(packet_in),
       .packet_valid(packet_valid),
       .packet_out(packet_out),
       .packet_out_valid(packet_out_valid),
       .sram_addr(sram_addr),
       .sram_data_in(sram_data_in),
       .sram_write_en(sram_write_en),
       .sram_read_en(sram_read_en),
       .sram_data_out(sram_data_out)
   );
endmodule

