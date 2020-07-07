`timescale 1ns / 1ps

module tb;
	reg [7:0] i_data8b;		      
	reg K;                	
	reg SBYTECLK;         	
	wire [9:0] o_data10b;
	
	always #4 SBYTECLK = ~SBYTECLK;  // some random clk speed
	
	encoder_8b10b uut(i_data8b,K,SBYTECLK,o_data10b);
	
	initial
		begin 
			$dumpfile("dump.vcd");
			$dumpvars(0,uut);
			SBYTECLK = 0;
			K = 0;  // test Data for now
			i_data8b = 8'b10100011;
			#10
			i_data8b = 8'b11001110;
			#8
			i_data8b = 8'b00101111;
			#8
			$finish;
		end  // initial
endmodule  // tb
