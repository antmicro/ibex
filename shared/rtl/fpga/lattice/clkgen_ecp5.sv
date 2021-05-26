// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clkgen_lattice_ecp5 #(
    parameter clki_div = 1,
    parameter clkop_div = 24,
    parameter clkop_cphase = 9,
    parameter clkop_fphase = 0,
    parameter clkos_div = 20,
    parameter clkos_cphase = 0,
    parameter clkos_fphase = 0,
    parameter feedbk_path = "INT_OP",
    parameter clkfb_div = 1
)(
    input clk_in,
    input reset_n,
    output pll_locked,
    output clk_sys,
    output rst_sys_n
);
  wire locked_pll;
  wire clk_out;

  wire clkfb;
  (* FREQUENCY_PIN_CLKI="25" *)
  (* FREQUENCY_PIN_CLKOS="30" *)
  (* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
  EHXPLLL #(
          .PLLRST_ENA("DISABLED"),
          .INTFB_WAKE("DISABLED"),
          .STDBY_ENABLE("DISABLED"),
          .DPHASE_SOURCE("DISABLED"),
          .OUTDIVIDER_MUXA("DIVA"),
          .OUTDIVIDER_MUXB("DIVB"),
          .OUTDIVIDER_MUXC("DIVC"),
          .OUTDIVIDER_MUXD("DIVD"),
          .CLKI_DIV(clki_div),
          .CLKOP_ENABLE("ENABLED"),
          .CLKOP_DIV(clkop_div),
          .CLKOP_CPHASE(clkop_cphase),
          .CLKOP_FPHASE(clkop_fphase),
          .CLKOS_ENABLE("ENABLED"),
          .CLKOS_DIV(clkos_div),
          .CLKOS_CPHASE(clkos_cphase),
          .CLKOS_FPHASE(clkos_fphase),
          .FEEDBK_PATH(feedbk_path),
          .CLKFB_DIV(1)
      ) pll (
          .RST(1'b0),
          .STDBY(1'b0),
          .CLKI(clk_in),
//          .CLKOP(clkfb),
          .CLKOS(clk_out),
//          .CLKFB(clkfb),
          .PHASESEL0(1'b0),
          .PHASESEL1(1'b0),
          .PHASEDIR(1'b1),
          .PHASESTEP(1'b1),
          .PHASELOADREG(1'b1),
          .PLLWAKESYNC(1'b0),
          .ENCLKOP(1'b0),
          .LOCK(locked_pll)
  );
  // outputs
  assign pll_locked = locked_pll;
  // clock
  assign clk_sys = clk_out;

  // reset
  assign rst_sys_n = locked_pll & reset_n;
endmodule
