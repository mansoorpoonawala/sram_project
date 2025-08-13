`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2025 12:01:08 AM
// Design Name: 
// Module Name: tb_sram_ethernet
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


module tb_sram_ethernet;
   parameter ADDR_WIDTH = 8;
   parameter DATA_WIDTH = 32;
   parameter PACKET_WIDTH = 8 + ADDR_WIDTH + DATA_WIDTH;
   parameter CLK_PERIOD = 10;


   logic                  clk;
   logic                  rst_n;
   logic [PACKET_WIDTH-1:0] packet_in;
   logic                  packet_valid;
   logic [PACKET_WIDTH-1:0] packet_out;
   logic                  packet_out_valid;


   top_module #(
       .ADDR_WIDTH(ADDR_WIDTH),
       .DATA_WIDTH(DATA_WIDTH),
       .PACKET_WIDTH(PACKET_WIDTH)
   ) dut (
       .clk(clk),
       .rst_n(rst_n),
       .packet_in(packet_in),
       .packet_valid(packet_valid),
       .packet_out(packet_out),
       .packet_out_valid(packet_out_valid)
   );


   // Clock generation
   initial begin
       clk = 0;
       forever #(CLK_PERIOD/2) clk = ~clk;
   end


   // Test class
   class Packet;
       rand bit [7:0] header;
       rand bit [ADDR_WIDTH-1:0] addr;
       rand bit [DATA_WIDTH-1:0] data;
       constraint valid_header { header inside {8'hAA, 8'hBB}; }
   endclass


   // Coverage
   covergroup cg_sram_ops @(posedge clk);
       coverpoint packet_in[PACKET_WIDTH-1:PACKET_WIDTH-8] {
           bins read_op  = {8'hAA};
           bins write_op = {8'hBB};
       }
       coverpoint packet_in[ADDR_WIDTH+DATA_WIDTH-1:DATA_WIDTH] {
           bins low_addr  = {[0:50]};
           bins mid_addr  = {[51:150]};
           bins high_addr = {[151:255]};
       }
   endgroup


   // Test procedure
   initial begin
       Packet pkt = new();
       cg_sram_ops cg = new();
       rst_n = 0;
       packet_in = 0;
       packet_valid = 0;
       #20 rst_n = 1;


       // Test 1: Write to SRAM via Ethernet
       repeat (10) begin
           assert(pkt.randomize() with {header == 8'hBB;});
           packet_in = {pkt.header, pkt.addr, pkt.data};
           packet_valid = 1;
           @(posedge clk);
           packet_valid = 0;
           @(posedge clk);
       end


       // Test 2: Read from SRAM via Ethernet
       repeat (10) begin
           assert(pkt.randomize() with {header == 8'hAA;});
           packet_in = {pkt.header, pkt.addr, {DATA_WIDTH{1'b0}}};
           packet_valid = 1;
           @(posedge clk);
           packet_valid = 0;
           @(posedge clk);
           @(posedge clk);
           if (packet_out_valid) begin
               assert(packet_out[DATA_WIDTH-1:0] == dut.sram_inst.mem[pkt.addr])
               else $error("Read data mismatch at addr %0h", pkt.addr);
           end
       end


       // Check coverage
       $display("Coverage: %0.2f%%", cg.get_coverage());
       #100 $finish;
   end

endmodule
