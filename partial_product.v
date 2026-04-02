module partial_product(A, B, PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7);
	input wire [7:0] A, B;
	output wire [7:0] PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7;
	
	assign PP0 = A & {8{B[0]}};
	assign PP1 = A & {8{B[1]}};
	assign PP2 = A & {8{B[2]}};
	assign PP3 = A & {8{B[3]}};
	assign PP4 = A & {8{B[4]}};
	assign PP5 = A & {8{B[5]}};
	assign PP6 = A & {8{B[6]}};
	assign PP7 = A & {8{B[7]}};
endmodule
