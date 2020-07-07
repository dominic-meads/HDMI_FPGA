`timescale 1ns / 1ps

module tb;
  reg A,B,C,D; 
  
  _5bfunction uut(A,B,C,D);
  
  initial 
    begin  // test all possible 4-0, 0-4, 1-3, 3-1, and 2-2 one-zero combos 
      $dumpfile("dump.vcd");
      $dumpvars(0,uut);
      A = 1;
      B = 1;
      C = 1;
      D = 1; // L40 high:  WORKS
      #1
      A = 0;
      B = 0;
      C = 0;
      D = 0; // L04 high:  WORKS
      #1
      A = 1;
      B = 0;
      C = 0;
      D = 0; // L13 high: ALL WORK
      #1
      A = 0;
      B = 1;
      C = 0;
      D = 0; // L13 high
      #1
      A = 0;
      B = 0;
      C = 1;
      D = 0; // L13 high
      #1
      A = 0;
      B = 0;
      C = 0;
      D = 1; // L13 high
      #1
      A = 1;
      B = 1;
      C = 1;
      D = 0; // L31 high: ALL WORK
      #1
      A = 0;
      B = 1;
      C = 1;
      D = 1; // L31 high
      #1
      A = 1;
      B = 1;
      C = 0;
      D = 1; // L31 high
      #1
      A = 1;
      B = 0;
      C = 1;
      D = 1; // L31 high
      #1
      A = 1;
      B = 1;
      C = 0;
      D = 0; // L22 high: ALL WORK
      #1
      A = 0;
      B = 0;
      C = 1;
      D = 1; // L22 high
      #1
      A = 0;
      B = 1;
      C = 1;
      D = 0; // L22 high
      #1
      A = 1;
      B = 0;
      C = 0;
      D = 1; // L22 high
      #1
      $finish;
    end 
endmodule 
