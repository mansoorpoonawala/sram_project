`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2025 10:43:02 PM
// Design Name: 
// Module Name: sram_core
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


module sram_core #(
   parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 32
) (
   input  wire                  clk,
   input  wire                  rst_n,
   input  wire [ADDR_WIDTH-1:0] addr,
   input  wire [DATA_WIDTH-1:0] data_in,
   input  wire                  write_en,
   input  wire                  read_en,
   output reg  [DATA_WIDTH-1:0] data_out
);
   reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];


   always @(posedge clk or negedge rst_n) begin
       if (!rst_n) begin
           data_out <= {DATA_WIDTH{1'b0}};
       end else begin
           if (write_en) begin
               mem[addr] <= data_in;
           end
           if (read_en) begin
               data_out <= mem[addr];
           end
       end
   end
endmodule

