`timescale 1ns / 1ps

`timescale 1ns / 1ps

module tb;
  reg [7:0] data; 
  reg K;
  reg COMPLS6;
  wire [9:0] out;
  
  encoder_8b10b uut(data,K,COMPLS6,out);
  
  initial 
    begin  // test all possible 4-0, 0-4, 1-3, 3-1, and 2-2 one-zero combos 
      $dumpfile("dump.vcd");
      $dumpvars(0,uut);
      K = 0;
      COMPLS6 = 0;
      data = 8'b11100001;  // expect 100010 or 011101 for abcdei
      #1
      data = 8'b11111100;  // expect 001110 for abcdei
      #1
      data = 8'b11110001;  // expect 100011 for abcdei
      #1
      $finish;
    end 
endmodule 
