`timescale 1ns / 1ps

module _5bfunction(
  	input A,B,C,D
);

// 5b function datatypes -- ex. n_A_a_B = ~(A & B)
	wire n_A_nequal_B, n_nA_a_nB, n_A_a_B, n_C_nequal_D, n_nC_a_nD, n_C_a_D;  // intermediate wires of Fig. 3 from top to bottom
	wire L40, L04, L13, L31, L22; // output wires of Fig. 3 from top to bottom	

// 5b function
		// intermediate wires
	assign n_A_nequal_B = ~(A | B) | ~(~A | ~B);  // OR DOT has something to do with ECL, but is just OR
	assign n_nA_a_nB = ~(~A & ~B);
	assign n_A_a_B = ~(A & B);
 	assign n_C_nequal_D = ~(C | D) | ~(~C | ~D);
	assign n_nC_a_nD = ~(~C & ~D);
	assign n_C_a_D = ~(C & D);
		// end intermediate wires
		// output wires: "L" means logic function, Lxn = Logic function with "x" ones and "n" zeros (maintain disparity of +2, -2, or 0)
	assign L40 = ~(n_A_a_B | n_C_a_D);  // NOR: see note at beginning of module
	assign L04 = ~(n_nA_a_nB | n_nC_a_nD);
	assign L13 = ~(n_A_nequal_B | n_nC_a_nD) | ~(n_C_nequal_D | n_nA_a_nB);  // two NOR gate equivalents ORed
	assign L31 = ~(n_A_nequal_B | n_C_a_D) | ~(n_C_nequal_D | n_A_a_B);
	assign L22 = ~(n_A_a_B | n_nC_a_nD) | ~(n_C_a_D | n_nA_a_nB) | ~(n_A_nequal_B | n_C_nequal_D); 
		// end output wires
	// end 5b function

endmodule 
