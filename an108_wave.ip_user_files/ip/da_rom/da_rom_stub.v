// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2700185 Thu Oct 24 18:46:05 MDT 2019
// Date        : Fri Jan 28 15:26:30 2022
// Host        : lscs-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub E:/waveform/an108_wave.srcs/sources_1/ip/da_rom/da_rom_stub.v
// Design      : da_rom
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2019.2" *)
module da_rom(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,addra[8:0],douta[7:0]" */;
  input clka;
  input ena;
  input [8:0]addra;
  output [7:0]douta;
endmodule
