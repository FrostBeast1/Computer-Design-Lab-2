module partial_product(A, B, PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7);
	parameter BUS_WIDTH = 8;
	parameter PRODUCT_WIDTH = 16;
 
	input wire [BUS_WIDTH - 1:0] A, B;
	output wire [PRODUCT_WIDTH - 1:0] PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7;
	
	// -------------------------------------------------------
	// Pad and shift each PP to 16 bits
	// pp0 = PP0 << 0  → { 8'b0,  PP0 }
	// pp1 = PP1 << 1  → { 7'b0,  PP1, 1'b0 }
	// ...etc
	// -------------------------------------------------------
	assign PP0 = {{8{1'b0}},	{A & {8{B[0]}}}		 };
	assign PP1 = {{7{1'b0}},	{A & {8{B[1]}}},	1'b0};
	assign PP2 = {{6{1'b0}},	{A & {8{B[2]}}},	2'b0};
	assign PP3 = {{5{1'b0}},	{A & {8{B[3]}}},	3'b0};
	assign PP4 = {{4{1'b0}},	{A & {8{B[4]}}},	4'b0};
	assign PP5 = {{3{1'b0}},	{A & {8{B[5]}}},	5'b0};
	assign PP6 = {{2{1'b0}},	{A & {8{B[6]}}},	6'b0};
	assign PP7 = {{1{1'b0}},	{A & {8{B[7]}}},	7'b0};
endmodule
