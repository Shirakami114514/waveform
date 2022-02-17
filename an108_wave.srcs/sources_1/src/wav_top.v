module top(
	//system clocks
	input                       sys_clk,
	input                       rst_n,       //pl button 1
	input                       pl_key2_n,   //pl button 2

	//adc
	input[7:0]                  an108_adc_data,
	output                      an108_adc_clk,
	
	//dac
	output[7:0]                 an108_dac_data,
	output                      an108_dac_clk,
	//hdmi output        
            output                      TMDS_clk_p,
            output                      TMDS_clk_n,
            output[2:0]                 TMDS_data_p,       //rgb
            output[2:0]                 TMDS_data_n,        //rgb
            output [0:0]                hdmi_oen

);

wire                            video_clk;
wire                            video_clk5x;
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;

wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;

wire                            grid_hs;
wire                            grid_vs;
wire                            grid_de;
wire[7:0]                       grid_r;
wire[7:0]                       grid_g;
wire[7:0]                       grid_b;

wire                            wave0_hs;
wire                            wave0_vs;
wire                            wave0_de;
wire[7:0]                       wave0_r;
wire[7:0]                       wave0_g;
wire[7:0]                       wave0_b;

wire                            adc_clk;
wire                            adc0_buf_wr;
wire[10:0]                      adc0_buf_addr;
wire[7:0]                       adc0_buf_data;
wire                            dac_clk;
wire[7:0]                       dac_data;
reg[8:0]                        rom_addr;

wire                            osd_hs;
wire                            osd_vs;
wire                            osd_de;
wire[7:0]                       osd_r;
wire[7:0]                       osd_g;
wire[7:0]                       osd_b;

assign hdmi_hs     = osd_hs;
assign hdmi_vs    = osd_vs;
assign hdmi_de     = osd_de;
assign hdmi_r      = osd_r;
assign hdmi_g      = osd_g;
assign hdmi_b      = osd_b;

assign an108_adc_clk = adc_clk;
assign an108_dac_clk = dac_clk;
assign an108_dac_data = dac_data;

wire        button_plkey2; 
reg         freq_select;

//pl button 2 to select freq
always@(posedge sys_clk)
begin
    if(button_plkey2==1'b0)
	     freq_select <=  freq_select+1'd1; 
	   else 
	     freq_select <=  freq_select;
end

ax_debounce pl_key2_m0
(
    .clk             (sys_clk       ),
    .rst             (~rst_n        ),
    .button_in       (pl_key2_n     ),
    .button_posedge  (              ),
    .button_negedge  (              ),
    .button_out      (button_plkey2 )
);

//generate video pixel clock
video_pll video_pll_m0
 (
	.clk_in1                    (sys_clk                  ),
	.clk_out1                   (video_clk                ),
	.clk_out2                   (video_clk5x              ),
	.reset                      (1'b0                     ),
	.locked                     (                         )
 );

adda_pll adda_pll_m0
 (
	.clk_in1                    (sys_clk                  ),
	.clk_out1                   (adc_clk                  ),
	.clk_out2                   (dac_clk                  ),
	.reset                      (1'b0                     ),
	.locked                     (                         )
 );
 
//dac 125Mhz/512 = 244.14khz
always@(posedge dac_clk)
begin
    case(freq_select)
	   1'b0:rom_addr <= rom_addr + 9'd1 ;  //rom_addr <= rom_addr + 9'd1; 
	   1'b1:rom_addr <= rom_addr + 9'd2 ;  //rom_addr <= rom_addr + 9'd1;
	endcase
end

/*
// sine wave
da_rom da_rom_m0 (
	.clka                       (dac_clk                 ),   
	.ena                        (1'b1                    ),     
	.addra                      (rom_addr                ), 
	.douta                      (dac_data                )  
);


// triangle wave 
da_rom_triangle da_rom_triangle0 (
	.clka                       (dac_clk                 ),   
	.ena                        (1'b1                    ),     
	.addra                      (rom_addr                ), 
	.douta                      (dac_data                )  
);
*/
/*
// saw tooth wave
da_rom_saw da_rom_saw0 (
	.clka                       (dac_clk                 ),   
	.ena                        (1'b1                    ),     
	.addra                      (rom_addr                ), 
	.douta                      (dac_data                )  
);

*/
// saw square wave
da_rom_square da_rom_square0 (
	.clka                       (dac_clk                 ),   
	.ena                        (1'b1                    ),     
	.addra                      (rom_addr                ), 
	.douta                      (dac_data                )  
);


draw_bg draw_bg_m0(
	.clk                        (video_clk                ),
	.rst                        (~rst_n                   ),
	.hs                         (video_hs                 ),
	.vs                         (video_vs                 ),
	.de                         (video_de                 ),
	.rgb_r                      (video_r                  ),
	.rgb_g                      (video_g                  ),
	.rgb_b                      (video_b                  )
);


rgb2dvi_0 rgb2dvi_m0 (
    // DVI 1.0 TMDS video interface
    .TMDS_Clk_p(TMDS_clk_p),
    .TMDS_Clk_n(TMDS_clk_n),
    .TMDS_Data_p(TMDS_data_p),
    .TMDS_Data_n(TMDS_data_n),
    .oen(hdmi_oen),
    //Auxiliary signals 
    .aRst_n(1'b1), //-asynchronous reset; must be reset when RefClk is not within spec
    
    // Video in
    .vid_pData({hdmi_r,hdmi_g,hdmi_b}),
    .vid_pVDE(hdmi_de),
    .vid_pHSync(hdmi_hs),
    .vid_pVSync(hdmi_vs),       
    .PixelClk(video_clk),
    
    .SerialClk(video_clk5x)// 5x PixelClk
    );

draw_grid  draw_grid_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk                  ),
	.i_hs                  (video_hs                   ),
	.i_vs                  (video_vs                   ),
	.i_de                  (video_de                   ),
	.i_data                ({video_r,video_g,video_b}  ),
	.o_hs                  (grid_hs                    ),
	.o_vs                  (grid_vs                    ),
	.o_de                  (grid_de                    ),
	.o_data                ({grid_r,grid_g,grid_b}     )
);

an108_adc an108_adc_m0(
	.adc_clk               (adc_clk                    ),
	.rst                   (~rst_n                     ),
	.adc_data              (an108_adc_data                ),
	.adc_data_valid        (1'b1                       ),
	.adc_buf_wr            (adc0_buf_wr                ),
	.adc_buf_addr          (adc0_buf_addr              ),
	.adc_buf_data          (adc0_buf_data              )
);

//display 50khz - 1Mhz
draw_wav draw_wav_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk                  ),
	.wave_color            (24'hff0000                 ),
	.adc_clk               (adc_clk                    ),
	.adc_buf_wr            (adc0_buf_wr                ),
	.adc_buf_addr          (adc0_buf_addr              ),
	.adc_buf_data          (adc0_buf_data              ),
	.i_hs                  (grid_hs                    ),
	.i_vs                  (grid_vs                    ),
	.i_de                  (grid_de                    ),
	.i_data                ({grid_r,grid_g,grid_b}     ),
	.o_hs                  (wave0_hs                   ),
	.o_vs                  (wave0_vs                   ),
	.o_de                  (wave0_de                   ),
	.o_data                ({wave0_r,wave0_g,wave0_b}  )
);

osd_display  osd_display_m0(
	.rst_n                 (rst_n                      ),
	.pclk                  (video_clk                  ),
	.i_hs                  (wave0_hs                   ),
	.i_vs                  (wave0_vs                   ),
	.i_de                  (wave0_de                   ),
	.i_data                ({wave0_r,wave0_g,wave0_b} ),
	.o_hs                  (osd_hs                     ),
	.o_vs                  (osd_vs                     ),
	.o_de                  (osd_de                     ),
	.o_data                ({osd_r,osd_g,osd_b}        )
);


endmodule