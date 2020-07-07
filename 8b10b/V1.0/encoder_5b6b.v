`timescale 1ns / 1ps

module encoder_5b6b(
  	input A,B,C,D,E,
  	input K,
  	input COMPLS6,
  	input SBYTECLK
	);


// 5b function datatypes -- ex. n_A_a_B = ~(A & B)
	wire n_A_nequal_B, n_nA_a_nB, n_A_a_B, n_C_nequal_D, n_nC_a_nD, n_C_a_D;  // intermediate wires of Fig. 3 from top to bottom
	wire L40, L04, L13, L31, L22; // output wires of Fig. 3 from top to bottom	

// 5b function
		// intermediate wires
	assign n_A_nequal_B = ~(A | B) | ~(~A | ~B);  
	assign n_nA_a_nB = ~(~A & ~B);
	assign n_A_a_B = ~(A & B);
 	assign n_C_nequal_D = ~(C | D) | ~(~C | ~D);
	assign n_nC_a_nD = ~(~C & ~D);
	assign n_C_a_D = ~(C & D);
		// end intermediate wires
		// output wires: "L" means logic function, Lxn = Logic function with "x" ones and "n" zeros (maintain disparity of +2, -2, or 0)
	assign L40 = ~((n_A_a_B) | (n_C_a_D));  // NOR: see note at beginning of module
	assign L04 = ~((n_nA_a_nB) | (n_nC_a_nD));
	assign L13 = ~((n_A_nequal_B) | (n_nC_a_nD)) | ~((n_C_nequal_D) | (n_nA_a_nB));  // two NOR gate equivalents ORed
	assign L31 = ~((n_A_nequal_B) | (n_C_a_D)) | ~((n_C_nequal_D) | (n_A_a_B));
	assign L22 = ~((n_A_a_B) | (n_nC_a_nD)) | ~((n_C_a_D) | (n_nA_a_nB)) | ~((n_A_nequal_B) | (n_C_nequal_D)); 
		// end output wires
	// end 5b function


	// 5b/6b encoding (7 = Fig. 7)
	wire w7_2,w7_3,w7_4,w7_5,w7_6;  /* These are intermediate wires that will be the inputs to the bottom 5 XOR ("E") gates. There are 6 XOR gates 
									   in total in Fig. 7. XOR7_1 is at the top of Fig. 7, and XOR7_6 is the bottom (and last) XOR gate. The wires 
									   correspond to the idential numbered XOR gate. e.g. w7_2 is an input (in addition to COMPLS6) to XOR7_2: the second 
									   XOR gate from the top. */
	//wire L13_a_D_a_E;  // output wire
	wire XNOR7_1,XNOR7_2,XNOR7_3,XNOR7_4,XNOR7_5,XNOR7_6;  // The inverted outputs of XOR gates (same order as above). Inject into FFs
	reg na,nb,nc,nd,ne,ni;  // complimented encoded outputs

	// 5b/6b encoding
		// intermediate wires (see line 58)
	assign w7_2 = ~(L40 | ~B) | L04;
  	assign w7_3 = (L04 | C) | ~(~L13 | ~E | ~D);
	assign w7_4 = ~(~D | L40);
  	assign w7_5 = ((~L13 | ~E | ~D) & E) | ~(~L13 | E);  
  	assign w7_6 = ~(E | ~L22) | ~(~L22 | ~K) | ~(~L04 | ~E) | ~(~E | ~L40) | ~(~E | ~L13 | D);  // Phew! Tough one haha
	//assign L13_a_D_a_E = ~(~L13 | ~E | ~D);
	assign XNOR7_1 = ~(A ^ COMPLS6);
	assign XNOR7_2 = ~(w7_2 ^ COMPLS6);
	assign XNOR7_3 = ~(w7_3 ^ COMPLS6);
	assign XNOR7_4 = ~(w7_4 ^ COMPLS6);
	assign XNOR7_5 = ~(w7_5 ^ COMPLS6);
	assign XNOR7_6 = ~(w7_6 ^ COMPLS6);
		// end intermediate wires 
		// outputs 
	always @ (posedge SBYTECLK)
		begin 
			na <= XNOR7_1;
			nb <= XNOR7_2;
			nc <= XNOR7_3;
			nd <= XNOR7_4;
			ne <= XNOR7_5;
			ni <= XNOR7_6;
		end  // always 
		// end outputs
	// end 5b/6b encoding
endmodule 
