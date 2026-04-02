// No need for third input
// Inputs Save Carry named after output of CarrySaveAdder
module parallel_adder (Save, Carry, Out, Cout);
	// Bus width of output, may change to bus width of input if it makes more sense later
	parameter BUS_WIDTH = 16;
	input [BUS_WIDTH - 1 : 0] Save, Carry;
	output [BUS_WIDTH - 1 : 0] Out;
	output Cout;
	
	assign {Cout, Out} = Save + Carry;
endmodule