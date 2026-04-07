module carry_save_adder #(parameter BUS_WIDTH = 16) (PP1, PP2, PP3, Save, Carry);
	input [BUS_WIDTH - 1 : 0] PP1, PP2, PP3;
	output [BUS_WIDTH : 0] Carry, Save;
	
	// Generate block to instantiate full adders for each bit position
	genvar i;
	generate
	// Pad the outputs correctly
		assign Carry[0] = 1'b0;
		assign Save[BUS_WIDTH]= 1'b0;
	// full_adder(In1, In2, Cin, Out, Cout);
		for (i = 0; i < BUS_WIDTH; i = i + 1) begin : bitPosition
			full_adder fa (
				.In1    (PP1[i]),
				.In2    (PP2[i]),
				.Cin  (PP3[i]),
				.Out  (Save[i]),
				.Cout (Carry[i+1])
			);
		end
	endgenerate
endmodule
