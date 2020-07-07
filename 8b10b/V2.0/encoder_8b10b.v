`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////
//
//   PROJECT DESCRIPTION:	An 8b/10b encoder based largely upon the logic structure defined
// 							in the original 8b/10b IBM design article: "A DC-Balanced, 
// 							Partitioned-Block, 8B/10B Transmission Code," by Widmer and 
// 							Franaszek (1983).
//
//                          https://opencores.org/websvn/filedetails?repname=1000base-x&path=%2F1000base-x%2Ftrunk%2Fdoc%2F01-581v1.pdf 
//
//	            FILENAME:   encoder_8b10b.v
//	             VERSION:   2.0  7/6/2020
//                AUTHOR:   Dominic Meads
//
/////////////////////////////////////////////////////////////////////////////////////////

/* NOTE: In the IBM article, the little arrows on the inputs of the gates are inverters. 
		 This makes a regular AND gate (denoted "A") in paper, turn into a negative-AND,
		 which hase the logic function of NOR. There are two outputs (one is inverted). 
		 Therefore the outputs of gate "A" (with inverterted inputs) in the article are
		 (from top to bottom): NOR and OR (~NOR). 
		 
		 Also important is the "OR DOT" gate. I posted a question on a forum about this:
		 https://www.eevblog.com/forum/projects/what-is-this-gate-in-this-8b10b-article/
		 I found that this has to do with the ECL chips the authors used to realize their
		 design. The logic function of OR DOT is just an OR gate. The DOT refers to 
		 "emitter dotting," which is a technique used in ECL. */ 
		 
module encoder_8b10b(
	input [7:0] i_data,   // 8 bit data
	input K,              // control input ACTIVE HIGH
	output [9:0] o_data   // encoded 10b data
	);
	
	// input wires
	wire A,B,C,D,E,F,G,H;
	assign A = i_data[0];
	assign B = i_data[1];
	assign C = i_data[2];
	assign D = i_data[3];
	assign E = i_data[4];
	assign F = i_data[5];
	assign G = i_data[6];
	assign H = i_data[7];
	
	// output wires
	wire a,b,c,d,e,i,f,g,h,j;  
	
	// logic functions (fig. 3)
	wire L04,L40,L13,L31,L22;
	reg [2:0] line_sum; 
	
	always @ (*)
		begin
			line_sum = A + B + C + D;  // sum of i_data[3:0]
		end 
		
	assign L04 = (line_sum == 0) ? 1:0;  // 0 ones and 4 zeros
	assign L40 = (line_sum == 4) ? 1:0;  // 4 ones and 0 zeros
	assign L13 = (line_sum == 1) ? 1:0;  // 1 one and 3 zeros
	assign L31 = (line_sum == 3) ? 1:0;  // 3 ones and 1 zero
	assign L22 = (line_sum == 2) ? 1:0;  // 2 ones and 2 zeros
	
endmodule 
