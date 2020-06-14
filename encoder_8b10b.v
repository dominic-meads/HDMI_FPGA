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
	input A,B,C,D,E,F,G,H,		// 8 bit data inputs 
	input K,                	// control input, active HIGH for control, LOW for data
	input SBYTECLK,         	// clock to update and register signals
	output a,b,c,d,e,i,f,g,h,j  // 10 bit output, "a" is MSB and "j" is LSB
	);
	
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
	reg F4,G4,H4,K4,notS = 0;  // clocked registers
	wire notF_a_notG_a_notH, notF_a_notG, F_a_G, F_nequal_G_a_K, F_nequal_G_a_notH, F_a_G_a_H;  // output wires of Fig. 4 from top to bottom
	
	// Disparity control datatypes
	wire PD_1S6, ND0S6, ND_1S6, PD0S6, ND_1S4, ND0S4, PD_1S4, PD0S4;  // output wires of Fig. 5 from top to bottom
	wire notNDL6, notPDL6, COMPLS4, COMPLS6;  // output wires of Fig. 6 from top to bottom (I'm not sure what the dotted line PDL4 represents)
	reg r1, r2 = 0;  // clocked registers seen in Fig. 6. r1 is closest to top of page
	
	
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
	assign L40 = ~((n_A_a_B) | (n_C_a_D));  // NOR: see note at beginning of module
	assign L04 = ~((n_nA_a_nB) | (n_nC_a_nD));
	assign L13 = ~((n_A_nequal_B) | (n_nC_a_nD)) | ~((n_C_nequal_D) | (n_nA_a_nB));  // two NOR gate equivalents ORed
	assign L31 = ~((n_A_nequal_B) | (n_C_a_D)) | ~((n_C_nequal_D) | (n_A_a_B));
	assign L22 = ~((n_A_a_B) | (n_nC_a_nD)) | ~((n_C_a_D) | (n_nA_a_nB)) | ~((n_A_nequal_B) | (n_C_nequal_D)); 
		// end output wires
	// end 5b function
	
	
	// 3b function 
	always @ (negedge SBYTECLK)  // the article says "posedge of ~SBYTECLK," but that is equivalent to the negedge of SBYTECLK
		begin 
			F4 <= F;
			G4 <= G;
			H4 <= H;
			K4 <= K;
		end  // always 
	
	always @ (posedge SBYTECLK)  // S function 
		notS <= (notPDL6 & ~L31 & ~D & E) | (notNDL6 & ~L13 & D & ~E);
		
	assign notF_a_notG_a_notH = H4 & ~(F4 & G4);
	assign notF_a_notG = F4 & G4; 
	assign F_a_G = ~F4 & ~G4;
	assign F_nequal_G_a_K = ~K4 & (notF_a_notG | F_a_G);
	assign F_nequal_G_a_notH = H4 & (notF_a_notG | F_a_G);
	assign F_a_G_a_H = ~H4 & ~(~F4 & ~G4);
	// end 3b function
	
	
	// Disparity control 
		// start Fig. 5
	assign PD_1S6 = L13_a_D_a_E | (L22 & L31 & E);
	assign ND0S6 = PD_1S6; 
	assign ND_1S6 = (~L31 & D & E) | (~E & L22 & L13) | K;
	assign PD0S6 = (~E & L22 & L13) | K;
	assign ND_1S4 = F_a_G;
	assign ND0S4 = notF_a_notG;
	assign PD_1S4 = notF_a_notG & F_nequal_G_a_K;
	assign PD0S4 = F_a_G_a_H;
		// end Fig. 5
		// start Fig. 6
	assign notNDL6 = (~PD0S6 & COMPLS6) | (COMPLS6 & ND0S6) | (ND0S6 & PD0S6 & ~r2);
	assign notPDL6 = ~notNDL6;
	assign COMPLS4 = (ND_1S4 & r1) | (~r1 & PD_1S4);
	assign COMPLS6 = (ND_1S6 & r2) | (~r2 & PD_1S6);

	always @ (posedge SBYTECLK)
		r1 <= notNDL6;
	
	always @ (negedge SBYTECLK)  // or posedge of ~SBYTECLK
		r2 <= (~r1 & PD0S4 & ND0S4) | (ND0S4 & COMPLS4) | (COMPLS4 & ~PD0S4);
		// end Fig. 6
	// end Disparity control 	


endmodule 
