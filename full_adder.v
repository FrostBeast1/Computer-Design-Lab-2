module full_adder(In1, In2, Cin, Out, Cout);
	input In1, In2, Cin;
	output Out, Cout;
	
	assign {Cout, Out} = In1 + In2 + Cin;
endmodule