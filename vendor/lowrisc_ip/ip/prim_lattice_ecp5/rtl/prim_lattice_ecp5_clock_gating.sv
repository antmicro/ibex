// Copyright Antmicro.

module prim_lattice_ecp5_clock_gating #(
  parameter bit NoFpgaGate = 1'b0
) (
  input        clk_i,
  input        en_i,
  input        test_en_i,
  output logic clk_o
);

  if (NoFpgaGate) begin : gen_no_gate
    assign clk_o = clk_i;
  end else begin : gen_gate
    DCCA u_bufgce (
      .CLKI  (clk_i),
      .CE    (en_i | test_en_i),
      .CLKO  (clk_o)
    );
  end



endmodule
