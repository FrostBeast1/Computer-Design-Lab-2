module wallace(In1, In2, Product);
    parameter BUS_WIDTH = 8;
    parameter PRODUCT_WIDTH = 16;

    input  wire [BUS_WIDTH - 1:0]  In1, In2;
    output wire [PRODUCT_WIDTH - 1:0] Product;

    // -------------------------------------------------------
    // Partial products - all 8 bits wide (unshifted)
    // -------------------------------------------------------
    wire [7:0] PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7;

    partial_product pp_gen(
        .A
		  (In1), .B(In2),
        .PP0(PP0), .PP1(PP1), .PP2(PP2), .PP3(PP3),
        .PP4(PP4), .PP5(PP5), .PP6(PP6), .PP7(PP7)
    );

    // -------------------------------------------------------
    // Pad and shift each PP to 16 bits
    // pp0 = PP0 << 0  → { 8'b0,  PP0 }
    // pp1 = PP1 << 1  → { 7'b0,  PP1, 1'b0 }
    // ...etc
    // -------------------------------------------------------
    wire [15:0] pp0 = { {8{1'b0}},  PP0                };
    wire [15:0] pp1 = { {7{1'b0}},  PP1,  1'b0         };
    wire [15:0] pp2 = { {6{1'b0}},  PP2,  2'b0         };
    wire [15:0] pp3 = { {5{1'b0}},  PP3,  3'b0         };
    wire [15:0] pp4 = { {4{1'b0}},  PP4,  4'b0         };
    wire [15:0] pp5 = { {3{1'b0}},  PP5,  5'b0         };
    wire [15:0] pp6 = { {2{1'b0}},  PP6,  6'b0         };
    wire [15:0] pp7 = { {1{1'b0}},  PP7,  7'b0         };

    // -------------------------------------------------------
    // Layer 1: 8 -> 6  (CSA outputs are 17 bits: [16:0])
    // -------------------------------------------------------
    wire [16:0] l1_s0, l1_c0, l1_s1, l1_c1;

    carry_save_adder #(.BUS_WIDTH(16)) csa_l1_0(
        .PP1(pp0), .PP2(pp1), .PP3(pp2),
        .Save(l1_s0), .Carry(l1_c0)
    );
    carry_save_adder #(.BUS_WIDTH(16)) csa_l1_1(
        .PP1(pp3), .PP2(pp4), .PP3(pp5),
        .Save(l1_s1), .Carry(l1_c1)
    );

    // -------------------------------------------------------
    // Layer 2: 6 -> 4  (use [15:0] slices as CSA inputs)
    // -------------------------------------------------------
    wire [16:0] l2_s0, l2_c0, l2_s1, l2_c1;

    carry_save_adder #(.BUS_WIDTH(16)) csa_l2_0(
        .PP1(l1_s0[15:0]), .PP2(l1_c0[15:0]), .PP3(l1_s1[15:0]),
        .Save(l2_s0), .Carry(l2_c0)
    );
    carry_save_adder #(.BUS_WIDTH(16)) csa_l2_1(
        .PP1(l1_c1[15:0]), .PP2(pp6),         .PP3(pp7),
        .Save(l2_s1), .Carry(l2_c1)
    );

    // -------------------------------------------------------
    // Layer 3: 4 -> 3  (l2_c1 passes through)
    // -------------------------------------------------------
    wire [16:0] l3_s0, l3_c0;

    carry_save_adder #(.BUS_WIDTH(16)) csa_l3_0(
        .PP1(l2_s0[15:0]), .PP2(l2_c0[15:0]), .PP3(l2_s1[15:0]),
        .Save(l3_s0), .Carry(l3_c0)
    );

    // -------------------------------------------------------
    // Layer 4: 3 -> 2
    // -------------------------------------------------------
    wire [16:0] l4_s0, l4_c0;

    carry_save_adder #(.BUS_WIDTH(16)) csa_l4_0(
        .PP1(l3_s0[15:0]), .PP2(l3_c0[15:0]), .PP3(l2_c1[15:0]),
        .Save(l4_s0), .Carry(l4_c0)
    );

    // -------------------------------------------------------
    // Final adder - drop bit 16 from CSA outputs
    // -------------------------------------------------------
    wire cout_unused;

    parallel_adder #(.BUS_WIDTH(16)) finalAdder(
        .Save(l4_s0[15:0]),
        .Carry(l4_c0[15:0]),
        .Out(Product),
        .Cout(cout_unused)
    );

endmodule