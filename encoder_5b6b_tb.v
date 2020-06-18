`timescale 1ns / 1ps

module tb;
  reg A,B,C,D,E,K,COMPLS6,SBYTECLK;
  
  always #2 SBYTECLK = ~SBYTECLK;
  
  encoder_5b6b uut(A,B,C,D,E,K,COMPLS6,SBYTECLK);
  
  initial 
    begin  // test all possible 4-0, 0-4, 1-3, 3-1, and 2-2 one-zero combos 
      $dumpfile("dump.vcd");
      $dumpvars(0,uut);
	  SBYTECLK = 0;
      K = 0;  		// Data only
      COMPLS6 = 1;  // START RD @ 0 (-1);
      A = 1;
      B = 0;
      C = 0;
      D = 0;
      E = 0;        // abcdei = 011101
      #4
      COMPLS6 = 0;  // reverse RD
      A = 1;
      B = 1;
      C = 1;
      D = 0;
      E = 0;        // abcdei = 000111
      #4
      COMPLS6 = 1;  // reverse RD
      A = 0;
      B = 0;
      C = 0;
      D = 1;
      E = 1;        // abcdei = 110011
      #4
      COMPLS6 = 0;  // reverse RD
      A = 0;
      B = 1;
      C = 1;
      D = 1;
      E = 1;        // abcdei = 100001
      #4
      COMPLS6 = 1;  // reverse RD
      A = 1;
      B = 1;
      C = 1;
      D = 1;
      E = 1;        // abcdei = 101011
      #4
      $finish;
    end 
endmodule 
