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

// TODO: OR DOT change? 
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

	// 5b function datatypes 
	wire not_A_nequal_B, not_C_nequal_D, L40, L04, L13, L31, L22; // output wires of Fig. 3 from top to bottom
	
	// 3b function datatypes
	reg F4,G4,H4,K4,notS = 0;  // clocked registers
	wire notF_a_notG_a_notH, notF_a_notG, F_a_G, F_nequal_G_a_K, F_nequal_G_a_notH, F_a_G_a_H;  // output wires of Fig. 4 from top to bottom
	
	// Disparity control datatypes
	wire PD_1S6, ND0S6, ND_1S6, PD0S6, ND_1S4, ND0S4, PD_1S4, PD0S4;  // output wires of Fig. 5 from top to bottom
	wire notNDL6, notPDL6, COMPLS4, COMPLS6;  // output wires of Fig. 6 from top to bottom (I'm not sure what the dotted line PDL4 represents)
	reg r1, r2 = 0;  // clocked registers seen in Fig. 6. r1 is closest to top of page
	
	// 5b function 
	assign not_A_nequal_B = (A & B) | (~A & ~B);
	assign not_C_nequal_D = (C & D) | (~C & ~D);
	assign L40 = ~(A & B) & ~(C & D);
	assign L04 = ~(~A & ~B) & ~(~C & ~D);
	assign L13 = (not_A_nequal_B & ~(~C & ~D)) | (not_C_nequal_D & ~(~A & ~B));
	assign L31 = (not_A_nequal_B & ~(C & D)) | (not_C_nequal_D & ~(A & B));
	assign L22 = (~(A & B) & ~(~C & ~D)) | (~(C & D) & ~(~A & ~B)) | (not_A_nequal_B & not_C_nequal_D);
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
