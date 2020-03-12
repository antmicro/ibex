module prim_clock_gating (
	clk_i,
	en_i,
	test_en_i,
	clk_o
);
	input clk_i;
	input en_i;
	input test_en_i;
	output wire clk_o;
	reg clk_en;
	always @(*)
		if ((clk_i == 1'b0))
			clk_en <= (en_i | test_en_i);
	assign clk_o = (clk_i & clk_en);
endmodule
