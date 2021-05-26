// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module top_orangecrab (
    input               clk48,
    input               usr_btn,
    output              rgb_led0_r,
    output              rgb_led0_g,
    output              rgb_led0_b,
    output [12:0]       gpio0
);

  parameter int          MEM_SIZE     = 64 * 1024; // 64 kB
  parameter logic [31:0] MEM_START    = 32'h00000000;
  parameter logic [31:0] MEM_MASK     = MEM_SIZE-1;
  parameter              SRAMInitFile = "";

  logic clk_sys, rst_sys_n, reset_n;
  logic minor, major;

  // Instruction connection to SRAM
  logic        instr_req;
  logic        instr_gnt;
  logic        instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // Data connection to SRAM
  logic        data_req;
  logic        data_gnt;
  logic        data_rvalid;
  logic        data_we;
  logic  [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  // SRAM arbiter
  logic [31:0] mem_addr;
  logic        mem_req;
  logic        mem_write;
  logic  [3:0] mem_be;
  logic [31:0] mem_wdata;
  logic        mem_rvalid;
  logic [31:0] mem_rdata;


  ibex_top #(
     .RegFile(ibex_pkg::RegFileFPGA),
     .DmHaltAddr(32'h00000000),
     .DmExceptionAddr(32'h00000000)
  ) u_top (
     .clk_i                 (clk_sys),
     .rst_ni                (rst_sys_n),

     .test_en_i             ('b1),
     .scan_rst_ni           (1'b1),
     .ram_cfg_i             ('b0),

     .hart_id_i             (32'b0),
     // First instruction executed is at 0x0 + 0x80
     .boot_addr_i           (32'h00000000),

     .instr_req_o           (instr_req),
     .instr_gnt_i           (instr_gnt),
     .instr_rvalid_i        (instr_rvalid),
     .instr_addr_o          (instr_addr),
     .instr_rdata_i         (instr_rdata),
     .instr_err_i           ('b0),

     .data_req_o            (data_req),
     .data_gnt_i            (data_gnt),
     .data_rvalid_i         (data_rvalid),
     .data_we_o             (data_we),
     .data_be_o             (data_be),
     .data_addr_o           (data_addr),
     .data_wdata_o          (data_wdata),
     .data_rdata_i          (data_rdata),
     .data_err_i            ('b0),

     .irq_software_i        (1'b0),
     .irq_timer_i           (1'b0),
     .irq_external_i        (1'b0),
     .irq_fast_i            (15'b0),
     .irq_nm_i              (1'b0),

     .debug_req_i           ('b0),
     .crash_dump_o          (),

     .fetch_enable_i        ('b1),
     .alert_minor_o         (minor),
     .alert_major_o         (major),
     .core_sleep_o          ()
  );

  // Connect Ibex to SRAM
  always_comb begin
    mem_req        = 1'b0;
    mem_addr       = 32'b0;
    mem_write      = 1'b0;
    mem_be         = 4'b0;
    mem_wdata      = 32'b0;
    if (instr_req) begin
      mem_req        = (instr_addr & ~MEM_MASK) == MEM_START;
      mem_addr       = instr_addr;
    end else if (data_req) begin
      mem_req        = (data_addr & ~MEM_MASK) == MEM_START;
      mem_write      = data_we;
      mem_be         = data_be;
      mem_addr       = data_addr;
      mem_wdata      = data_wdata;
    end
  end

  // SRAM block for instruction and data storage
  ram_1p #(
    .Depth(MEM_SIZE / 4),
    .MemInitFile(SRAMInitFile)
  ) u_ram (
    .clk_i     ( clk_sys        ),
    .rst_ni    ( rst_sys_n      ),
    .req_i     ( mem_req        ),
    .we_i      ( mem_write      ),
    .be_i      ( mem_be         ),
    .addr_i    ( mem_addr       ),
    .wdata_i   ( mem_wdata      ),
    .rvalid_o  ( mem_rvalid     ),
    .rdata_o   ( mem_rdata      )
  );

  // SRAM to Ibex
  assign instr_rdata    = mem_rdata;
  assign data_rdata     = mem_rdata;
  assign instr_rvalid   = mem_rvalid;
  always_ff @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      instr_gnt    <= 'b0;
      data_gnt     <= 'b0;
      data_rvalid  <= 'b0;
    end else begin
      instr_gnt    <= instr_req && mem_req;
      data_gnt     <= ~instr_req && data_req && mem_req;
      data_rvalid  <= ~instr_req && data_req && mem_req;
    end
  end

  assign gpio0[0] = clk_sys;
  assign gpio0[1] = instr_rvalid;
  assign gpio0[2] = instr_rdata[12];
  assign gpio0[3] = instr_rdata[13];
  assign gpio0[4] = instr_rdata[14];
  assign gpio0[5] = instr_rdata[15];

  // Connect the LED output to the lower four bits of the most significant
  // byte
  logic [3:0] leds;
  always_ff @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      leds <= 4'b0;
    end else begin
      if (mem_req && data_req && data_we) begin
        for (int i = 0; i < 4; i = i + 1) begin
          if (data_be[i] == 1'b1) begin
            leds <= data_wdata[i*8 +: 4];
          end
        end
      end
    end
  end

  assign rgb_led0_g = leds[1];

  // Clock and reset
  clkgen_lattice_ecp5 #(
      .clki_div(2),
      .clkop_div(25),
      .clkos_div(20)
    )clkgen(
      .clk_in(clk48),
      .reset_n(reset_n),
      .clk_sys(clk_sys),
      .rst_sys_n(rst_sys_n)
    );

  assign gpio0[6] = rst_sys_n;

  assign reset_n = usr_btn;

endmodule
