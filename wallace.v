module wallace(In1, In2, Product);
    parameter BUS_WIDTH = 8;
    parameter PRODUCT_WIDTH = 16;

    input  wire [BUS_WIDTH - 1:0]  In1, In2;
    output wire [PRODUCT_WIDTH - 1:0] Product;

    // -------------------------------------------------------
    // Partial products - all 16 bits wide (shifted)
    // -------------------------------------------------------
    wire [PRODUCT_WIDTH - 1:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;

    partial_product pp_gen(
        .A(In1), .B(In2), .PP0(pp0), .PP1(pp1), .PP2(pp2), 
		  .PP3(pp3), .PP4(pp4), .PP5(pp5), .PP6(pp6), .PP7(pp7)
    );

    // -------------------------------------------------------
    // Layer 1: 8 -> 6  (CSA outputs are 17 bits: [16:0])
    // -------------------------------------------------------
    wire [PRODUCT_WIDTH:0] l1_s0, l1_c0, l1_s1, l1_c1;

    carry_save_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) csa_l1_0(
        .PP1(pp0), .PP2(pp1), .PP3(pp2), .Save(l1_s0), .Carry(l1_c0)
    );
    carry_save_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) csa_l1_1(
        .PP1(pp3), .PP2(pp4), .PP3(pp5), .Save(l1_s1), .Carry(l1_c1)
    );

    // -------------------------------------------------------
    // Layer 2: 6 -> 4  (use [15:0] slices as CSA inputs)
    // -------------------------------------------------------
    wire [PRODUCT_WIDTH:0] l2_s0, l2_c0, l2_s1, l2_c1;

    carry_save_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) csa_l2_0(
        .PP1(l1_s0[PRODUCT_WIDTH - 1:0]), .PP2(l1_c0[PRODUCT_WIDTH - 1:0]),
		  .PP3(l1_s1[PRODUCT_WIDTH - 1:0]), .Save(l2_s0), .Carry(l2_c0)
    );
    carry_save_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) csa_l2_1(
        .PP1(l1_c1[PRODUCT_WIDTH - 1:0]), .PP2(pp6), .PP3(pp7),
        .Save(l2_s1), .Carry(l2_c1)
    );

    // -------------------------------------------------------
    // Layer 3: 4 -> 3  (l2_c1 passes through)
    // -------------------------------------------------------
    wire [PRODUCT_WIDTH:0] l3_s0, l3_c0;

    carry_save_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) csa_l3_0(
        .PP1(l2_s0[PRODUCT_WIDTH - 1:0]), .PP2(l2_c0[PRODUCT_WIDTH - 1:0]),
		  .PP3(l2_s1[PRODUCT_WIDTH - 1:0]), .Save(l3_s0), .Carry(l3_c0)
    );

    // -------------------------------------------------------
    // Layer 4: 3 -> 2
    // -------------------------------------------------------
    wire [PRODUCT_WIDTH:0] l4_s0, l4_c0;

    carry_save_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) csa_l4_0(
        .PP1(l3_s0[PRODUCT_WIDTH - 1:0]), .PP2(l3_c0[PRODUCT_WIDTH - 1:0]),
		  .PP3(l2_c1[PRODUCT_WIDTH - 1:0]), .Save(l4_s0), .Carry(l4_c0)
    );

    // -------------------------------------------------------
    // Final adder - drop bit 16 from CSA outputs
    // -------------------------------------------------------
    wire cout_unused;

    parallel_adder #(.BUS_WIDTH(PRODUCT_WIDTH)) finalAdder(
        .Save(l4_s0[PRODUCT_WIDTH - 1:0]), .Carry(l4_c0[PRODUCT_WIDTH - 1:0]),
        .Out(Product), .Cout(cout_unused)
    );

endmodule