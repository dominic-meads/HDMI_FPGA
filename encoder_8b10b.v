`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////////////////////////
//
//   PROJECT DESCRIPTION:	An 8b/10b encoder based soley upon the logic structure defined
// 							in the original 8b/10b IBM design article: "A DC-Balanced, 
// 							Partitioned-Block, 8B/10B Transmission Code," by Widmer and 
// 							Franaszek (1983).
//
//                          https://opencores.org/websvn/filedetails?repname=1000base-x&path=%2F1000base-x%2Ftrunk%2Fdoc%2F01-581v1.pdf 
//
//	            FILENAME:   encoder_8b10b.v
//	             VERSION:   1.0  6/12/2020
//                AUTHOR:   Dominic Meads
//
/////////////////////////////////////////////////////////////////////////////////////////

/* NOTE: In the IBM article, the little arrows on the inputs of the gates are inverters. 
		 This makes a regular AND gate (denoted "A") in paper, turn into a negative-AND,
		 which hase the logic function of NOR. There are two outputs (one is inverted). 
		 Therefore the outputs of gate "A" in the article are (from top to bottom): 
		 NOR and OR (~NOR). 
		 
		 Also important is the "OR DOT" gate. I posted a question on a forum about this:
		 https://www.eevblog.com/forum/projects/what-is-this-gate-in-this-8b10b-article/
		 I found that this has to do with the ECL chips the authors used to realize their
		 design. The logic function of OR DOT is true only when both inputs are equal, and 
		 therefore has a truth table identical to an XNOR gate. */ 

module encoder_8b10b(
	input [7:0] i_data8b,		    // 8 bit data  
	input K,                	// control input, ACTIVE HIGH for control, LOW for data
	input SBYTECLK,         	// clock to update and register signals
	output [9:0] o_data10b  // 10 bit output, "a" is MSB and "j" is LSB
	);
	
	// input assignments (Widmer & Franaszek form)
	wire A,B,C,D,E,F,G,H; 
	assign A = i_data8b[0];  // LSB
	assign B = i_data8b[1];
	assign C = i_data8b[2];
	assign D = i_data8b[3];
	assign E = i_data8b[4];
	assign F = i_data8b[5];
	assign G = i_data8b[6];
	assign H = i_data8b[7];
	
	/* The encoder consists of the 5 logic circuits shown in a block diagram in Fig. 1. 
	   1). 5b functions (shown in Fig. 3)
	   2). 3b functions (shown in Fig. 4)
	   3). Disparity control (shown in Figs. 5 and 6)
	   4). 5b/6b encoding switch (shown in Fig. 7)
	   5). 3b/4b encoding switch (shown in Fig. 8) */

	// 5b function datatypes -- ex. n_A_a_B = ~(A & B)
	wire n_A_nequal_B, n_nA_a_nB, n_A_a_B, n_C_nequal_D, n_nC_a_nD, n_C_a_D;  // intermediate wires of Fig. 3 from top to bottom
	wire L40, L04, L13, L31, L22; // output wires of Fig. 3 from top to bottom
	
	// 3b function datatypes
	reg F4,G4,H4,K4,nS = 0;  // clocked registers
	wire nF_a_nG_a_nH, nF_a_nG, F_a_G, F_nequal_G_a_K, F_nequal_G_a_nH, F_a_G_a_H;  // output wires of Fig. 4 from top to bottom
	
	// Disparity control datatypes
	wire PD_1S6, ND0S6, ND_1S6, PD0S6, ND_1S4, ND0S4, PD_1S4, PD0S4;  // output wires of Fig. 5 from top to bottom
	wire nNDL6, nPDL6, COMPLS4, COMPLS6;  // output wires of Fig. 6 from top to bottom (I'm not sure what the dotted line PDL4 represents)
	reg r1, r2 = 0;  // clocked registers seen in Fig. 6. r1 is closest to top of page
	
	// 5b/6b encoding (7 = Fig. 7)
	wire w7_2,w7_3,w7_4,w7_5,w7_6;  /* These are intermediate wires that will be the inputs to the bottom 5 XOR ("E") gates. There are 6 XOR gates 
									   in total in Fig. 7. XOR7_1 is at the top of Fig. 7, and XOR7_6 is the bottom (and last) XOR gate. The wires 
									   correspond to the idential numbered XOR gate. e.g. w7_2 is an input (in addition to COMPLS6) to XOR7_2: the second 
									   XOR gate from the top. */
	wire L13_a_D_a_E;  // output wire
	wire XNOR7_1,XNOR7_2,XNOR7_3,XNOR7_4,XNOR7_5,XNOR7_6;  // The inverted outputs of XOR gates (same order as above). Inject into FFs
	reg na,nb,nc,nd,ne,ni;  // complimented encoded outputs
	
	// 3b/4b encoding (8 = Fig. 8)
	wire w8_1,w8_2,w8_3,w8_4;  // intermediate wires to make life easier (exact same naming scheme as in lne 58)
	wire XNOR8_1,XNOR8_2,XNOR8_3,XNOR8_4; 
	reg nf,ng,nh,nj;
	
	
	// 5b function
		// intermediate wires
	assign n_A_nequal_B = ~(A ^ B);  // XNOR: see note at beginning of module
	assign n_nA_a_nB = ~(~A & ~B);
	assign n_A_a_B = ~(A & B);
	assign n_C_nequal_D = ~(C ^ D);
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
	
	
	// 3b function
		// sequential registers
	always @ (negedge SBYTECLK)  // the article says "posedge of ~SBYTECLK," but that is equivalent to the negedge of SBYTECLK
		begin 
			F4 <= F;
			G4 <= G;
			H4 <= H;
			K4 <= K;
		end  // always 
	
	always @ (posedge SBYTECLK)  // S function 
		nS <= ~(~(nPDL6 | ~L31 | ~D | E) ^ ~(nNDL6 | ~L13 | D | ~E));  // XNOR of two 4-input NOR equivalent gates
		// end sequential registers
		// output wires
	assign nF_a_nG_a_nH = ~(H4 | (F4 | G4));
	assign nF_a_nG = ~(F4 | G4); 
	assign F_a_G = ~(~F4 | ~G4);
	assign F_nequal_G_a_K = ~(~K4 | (nF_a_nG | F_a_G));
	assign F_nequal_G_a_nH = ~(H4 | (nF_a_nG | F_a_G));
	assign F_a_G_a_H = ~(~H4 | (~F4 | ~G4));
		// end output wires
	// end 3b function
	
	
	// Disparity control 
		// Fig. 5
	assign PD_1S6 = ~(L13_a_D_a_E ^ ~(L22 | L31 | E));
	assign ND0S6 = PD_1S6; 
	assign ND_1S6 = ~(~L31 | D | E) | ~(~E | L22 | L13) | K;
	assign PD0S6 = ~(~E | L22 | L13) | K;
	assign ND_1S4 = F_a_G;
	assign ND0S4 = nF_a_nG;
	assign PD_1S4 = nF_a_nG | F_nequal_G_a_K;
	assign PD0S4 = F_a_G_a_H;
		// end Fig. 5
		// Fig. 6
	assign nNDL6 = ~(~PD0S6 | COMPLS6) | (COMPLS6 & ND0S6) | ~(ND0S6 | PD0S6 | ~r2);
	assign nPDL6 = ~nNDL6;
	assign COMPLS4 = ~((ND_1S4 & r1) ^ (~r1 & PD_1S4));
	assign COMPLS6 = ~((ND_1S6 & r2) ^ (~r2 & PD_1S6));

	always @ (posedge SBYTECLK)
		r1 <= nNDL6;
	
	always @ (negedge SBYTECLK)  // or posedge of ~SBYTECLK
		r2 <= ~(~(~r1 | PD0S4 | ND0S4) ^ (ND0S4 & COMPLS4) ^ ~(COMPLS4 | ~PD0S4));
		// end Fig. 6
	// end Disparity control 


	// 5b/6b encoding
		// intermediate wires (see line 58)
	assign w7_2 = ~(L40 | ~B) | L04;
	assign w7_3 = ~((L04 | C) ^ ~(~L13 | ~E | ~D));
	assign w7_4 = ~(~D | L40);
	assign w7_5 = ~(((~L13 | ~E | ~D) & E) ^ ~(~L13 | E));  
	assign w7_6 = ~(~(E | ~L22) ^ ~(~L22 | ~K) ^ ~(~L04 | ~E) ^ ~(~E | ~L40) ^ ~(~E | ~L13 | D));  // Phew! Tough one haha
	assign L13_a_D_a_E = ~(~L13 | ~E | ~D);
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
	
	
	// 3b/4b encoding
		// intermediate wires
	assign w8_1 = ~(~F4 | ~(~(nS | ~F_a_G) ^ ~(~F_a_G | ~K4))); 
	assign w8_2 = G4 | nF_a_nG_a_nH;
	assign w8_3 = H4;
	assign w8_4 = ~(~(nS | ~F_a_G) ^ ~(~F_a_G | ~K4)) | F_nequal_G_a_nH;
	assign XNOR8_1 = ~(COMPLS4 ^ w8_1);
	assign XNOR8_2 = ~(COMPLS4 ^ w8_2);
	assign XNOR8_3 = ~(COMPLS4 ^ w8_3);
	assign XNOR8_4 = ~(COMPLS4 ^ w8_4);
		// end intermediate wires
		// outputs
	always @ (negedge SBYTECLK)
		begin 
			nf <= XNOR8_1;
			ng <= XNOR8_2;
			nh <= XNOR8_3;
			nj <= XNOR8_4;
		end  // always 
		// end outputs 
	// end 3b/4b encoding 
	
	
	// assign module outputs 
	assign o_data10b[9:0] = ~{na,nb,nc,nd,ne,ni,nf,ng,nh,nj};

endmodule  // encoder_8b10b
