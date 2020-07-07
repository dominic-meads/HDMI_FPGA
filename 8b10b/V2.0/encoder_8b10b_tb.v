`timescale 1ns / 1ps

module tb;
  reg [7:0] data; 
  reg K;
  wire [9:0] out;
  
  encoder_8b10b uut(data,K,out);
  
  initial 
    begin  // test all possible 4-0, 0-4, 1-3, 3-1, and 2-2 one-zero combos 
      $dumpfile("dump.vcd");
      $dumpvars(0,uut);
      K = 0;
      data = 8'b11111111;// L40 high:  WORKS
      #1
      data = 8'b11110000; // L04 high:  WORKS
      #1
      data = 8'b11110001; // L13 high: ALL WORK
      #1
      data = 8'b11110010; // L13 high
      #1
      data = 8'b11110100; // L13 high
      #1
      data = 8'b11111000; // L13 high
      #1
      data = 8'b11110111; // L31 high: ALL WORK
      #1
      data = 8'b11111110; // L31 high
      #1
      data = 8'b11111011; // L31 high
      #1
      data = 8'b11111101; // L31 high
      #1
      data = 8'b11110011; // L22 high: ALL WORK
      #1
      data = 8'b11111100; // L22 high
      #1
      data = 8'b11110110; // L22 high
      #1
      data = 8'b11111001; // L22 high
      #1
      $finish;
    end 
endmodule 
