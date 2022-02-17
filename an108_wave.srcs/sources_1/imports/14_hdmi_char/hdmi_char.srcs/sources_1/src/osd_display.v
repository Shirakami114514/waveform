module osd_display(
	input                       rst_n, 
	input                       pclk,
	input                       i_hs,
	input                       i_vs,
	input                       i_de,
	input[23:0]                 i_data,
	output                      o_hs,
	output                      o_vs,
	output                      o_de,
	output[23:0]                o_data
);
parameter OSD_WIDTH   =  12'd304;	
parameter OSD_HEGIHT  =  12'd32;

wire[11:0] 		pos_x;		
wire[11:0] 		pos_y;		
wire       		pos_hs;
wire       		pos_vs;
wire       		pos_de;
wire[23:0] 		pos_data;
reg	[23:0]  	v_data;
reg	[11:0]  	osd_x;
reg	[11:0]  	osd_y;
reg	[15:0]  	osd_ram_addr;
wire[7:0]  		q;
reg        		region_active;
reg        		region_active_d0;
reg        		region_active_d1;
reg        		region_active_d2;

reg        		pos_vs_d0;
reg        		pos_vs_d1;

assign o_data 	= v_data;
assign o_hs 	= pos_hs;
assign o_vs 	= pos_vs;
assign o_de 	= pos_de;


always@(posedge pclk)
begin
// if(pos_y >= 12'd9 && pos_y <= 12'd9 + OSD_HEGIHT - 12'd1 && pos_x >= 12'd9 && pos_x  <= 12'd9 + OSD_WIDTH - 12'd1)
	if(pos_y >= 12'd400 && pos_y <= 12'd400 + OSD_HEGIHT - 12'd1 && pos_x >= 12'd800 && pos_x  <= 12'd800 + OSD_WIDTH - 12'd1)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end

always@(posedge pclk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

always@(posedge pclk)
begin
	pos_vs_d0 <= pos_vs;
	pos_vs_d1 <= pos_vs_d0;
end


always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		osd_x <= osd_x + 12'd1;
	else
		osd_x <= 12'd0;
end

always@(posedge pclk)
begin
	if(pos_vs_d1 == 1'b1 && pos_vs_d0 == 1'b0)
		osd_ram_addr <= 16'd0;
	else if(region_active == 1'b1)
		osd_ram_addr <= osd_ram_addr + 16'd1;
end


always@(posedge pclk)
begin
	if(region_active_d0 == 1'b1)
		if(q[osd_x[2:0]] == 1'b1)
			v_data <= 24'hff0000;
		else
			v_data <= pos_data;	
	else
		v_data <= pos_data;
end

osd_rom osd_rom_m0 (
	.clka                       (pclk                    ),   
	.ena                        (1'b1                    ),     
	.addra                      (osd_ram_addr[15:3]      ), 
	.douta                      (q                       )  
);


timing_gen_xy timing_gen_xy_m0(
	.rst_n    (rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),
	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),
	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule