module an108_adc(
	input                       adc_clk,
	input                       rst,
	input[7:0]                  adc_data,
	input                       adc_data_valid,
	output                      adc_buf_wr,
	output[11:0]                adc_buf_addr,
	output[7:0]                 adc_buf_data
);

//`define TRIGGER

localparam       S_IDLE    = 0;
localparam       S_SAMPLE  = 1;
localparam       S_WAIT    = 2;

reg[7:0] 		adc_data_d0;
reg[7:0] 		adc_data_d1;
reg[10:0] 		sample_cnt;
reg[31:0] 		wait_cnt;
reg[2:0] 		state;
assign adc_buf_addr = sample_cnt;
assign adc_buf_data = adc_data_d0;
assign adc_buf_wr 	= (state == S_SAMPLE && adc_data_valid == 1'b1) ? 1'b1 : 1'b0;
//register for adc data
always@(posedge adc_clk or posedge rst)
begin
	if(rst == 1'b1)
		adc_data_d0 <= 8'd0;
	else if(adc_data_valid == 1'b1)
		adc_data_d0 <= adc_data;
end
//register for adc data
always@(posedge adc_clk or posedge rst)
begin
	if(rst == 1'b1)
		adc_data_d1 <= 8'd0;
	else if(adc_data_valid == 1'b1)
		adc_data_d1 <= adc_data_d0;
end

always@(posedge adc_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		state <= S_IDLE;
		wait_cnt <= 32'd0;
		sample_cnt <= 11'd0;
	end
	else
		case(state)
			S_IDLE:
			begin
				state <= S_SAMPLE;
			end
			S_SAMPLE:
			begin
				if(adc_data_valid == 1'b1)
				begin
					if(sample_cnt == 11'd1900)	//sample 1280 data   set to 1279
					begin
						sample_cnt <= 11'd0;
						state <= S_WAIT;
					end
					else
					begin
						sample_cnt <= sample_cnt + 11'd1;
					end
				end
			end		
			S_WAIT:
			begin
				if(wait_cnt == 32'd25_000_000)	//wait for a while
				begin
					state <= S_SAMPLE;
					wait_cnt <= 32'd0;
				end
				else
				begin
					wait_cnt <= wait_cnt + 32'd1;
				end			
			end	
			default:
				state <= S_IDLE;
		endcase
end

endmodule