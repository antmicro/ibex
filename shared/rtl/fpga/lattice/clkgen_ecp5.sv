// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module clkgen_lattice_ecp5(
    input clk_25mhz,
    input reset_n,
    output clk_sys,
    output rst_sys_n
);
  logic locked_pll;
  logic clk_30;

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
          .CLKI_DIV(1),
          .CLKOP_ENABLE("ENABLED"),
          .CLKOP_DIV(24),
          .CLKOP_CPHASE(9),
          .CLKOP_FPHASE(0),
          .CLKOS_ENABLE("ENABLED"),
          .CLKOS_DIV(20),
          .CLKOS_CPHASE(0),
          .CLKOS_FPHASE(0),
          .FEEDBK_PATH("INT_OP"),
          .CLKFB_DIV(1)
      ) pll (
          .RST(1'b0),
          .STDBY(1'b0),
          .CLKI(clk_25mhz),
          .CLKOP(clkfb),
          .CLKOS(clk_30),
          .CLKFB(clkfb),
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
  // clock
  assign clk_sys = clk_30;

  // reset
  assign rst_sys_n = locked_pll & reset_n;
endmodule
