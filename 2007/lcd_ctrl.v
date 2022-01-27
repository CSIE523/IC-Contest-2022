module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output  reg[7:0]   dataout;
output  reg        output_valid;
output  reg        busy;

localparam REFLASH=3'd0;
localparam LOADDATA=3'd1;
localparam ZOOMIN=3'd2;
localparam ZOOMOUT=3'd3;
localparam SHIFT_RIGHT=3'd4;
localparam SHIFT_LEFT=3'd5;
localparam SHIFT_UP=3'd6;
localparam SHIFT_DOWN=3'd7;
localparam WAIT_CMD = 1'b0;
localparam PROCESS  = 1'b1;  

reg [7:0]img_buf[63:0];
reg [2:0]cmd_use;
reg [7:0]counter;
reg [2:0]x_tmp,y_tmp;
reg magnifi;
reg cur_state,next_state;

integer i;

	always@(posedge clk or posedge reset)begin
		if(reset)begin
			cur_state<=WAIT_CMD;
		end
		else begin
			cur_state<=next_state;
		end
	end
	
	always@(*)begin
		case(cur_state)
			WAIT_CMD:begin
				if(cmd_valid)begin
					next_state=PROCESS;
				end
				else begin
					next_state=WAIT_CMD;
				end
			end
			PROCESS:begin
				if((cmd_use==REFLASH)&&counter==8'd15)begin
					next_state=WAIT_CMD;
				end
				else begin
					next_state=PROCESS;
				end
			end
		endcase
	end
	
	always@(posedge clk or posedge reset)begin
		if(reset) begin
			counter<=0;
			x_tmp<=0;
			y_tmp<=0;
			output_valid<=1'b0;
			magnifi<=0;
			busy<=1'd0;
		end
		else begin
			if(cur_state==WAIT_CMD)begin
				if(cmd_valid)begin
					cmd_use<=cmd;
					busy<=1'd1;
				end
				counter<=8'd0;
				output_valid<=1'd0;
			end
			else begin
				case(cmd_use)
					REFLASH:begin
						output_valid<=1'b1;
						if(magnifi==1'b0)begin
							case(counter)
								8'd0:begin dataout<=img_buf[0]; end
								8'd1:begin dataout<=img_buf[2]; end
								8'd2:begin dataout<=img_buf[4]; end
								8'd3:begin dataout<=img_buf[6]; end
								8'd4:begin dataout<=img_buf[16]; end
								8'd5:begin dataout<=img_buf[18]; end
								8'd6:begin dataout<=img_buf[20]; end
								8'd7:begin dataout<=img_buf[22]; end
								8'd8:begin dataout<=img_buf[32]; end
								8'd9:begin dataout<=img_buf[34]; end
								8'd10:begin dataout<=img_buf[36]; end
								8'd11:begin dataout<=img_buf[38]; end
								8'd12:begin dataout<=img_buf[48]; end
								8'd13:begin dataout<=img_buf[50]; end
								8'd14:begin dataout<=img_buf[52]; end
								8'd15:begin dataout<=img_buf[54]; end
							endcase
						end
						else begin
							case(counter)
								8'd0:begin dataout<=img_buf[8*y_tmp+x_tmp]; end
								8'd1:begin dataout<=img_buf[8*y_tmp+x_tmp+1]; end
								8'd2:begin dataout<=img_buf[8*y_tmp+x_tmp+2]; end
								8'd3:begin dataout<=img_buf[8*y_tmp+x_tmp+3]; end
								8'd4:begin dataout<=img_buf[8*(y_tmp+1)+x_tmp]; end
								8'd5:begin dataout<=img_buf[8*(y_tmp+1)+x_tmp+1]; end
								8'd6:begin dataout<=img_buf[8*(y_tmp+1)+x_tmp+2]; end
								8'd7:begin dataout<=img_buf[8*(y_tmp+1)+x_tmp+3]; end
								8'd8:begin dataout<=img_buf[8*(y_tmp+2)+x_tmp]; end
								8'd9:begin dataout<=img_buf[8*(y_tmp+2)+x_tmp+1]; end
								8'd10:begin dataout<=img_buf[8*(y_tmp+2)+x_tmp+2]; end
								8'd11:begin dataout<=img_buf[8*(y_tmp+2)+x_tmp+3]; end
								8'd12:begin dataout<=img_buf[8*(y_tmp+3)+x_tmp]; end
								8'd13:begin dataout<=img_buf[8*(y_tmp+3)+x_tmp+1]; end
								8'd14:begin dataout<=img_buf[8*(y_tmp+3)+x_tmp+2]; end
								8'd15:begin dataout<=img_buf[8*(y_tmp+3)+x_tmp+3]; end
							endcase
						end
						counter<=counter+8'd1;
						if(counter==8'd15)begin
							counter<=0;
							busy<=0;
						end
					end
					LOADDATA:begin
						img_buf[counter]<=datain;
						counter<=counter+8'd1;
						if(counter==8'd63)begin
							x_tmp<=3'd0;
							y_tmp<=3'd0;
							counter<=0;
							magnifi<=0;
							cmd_use<=REFLASH;
						end
					end
					ZOOMIN:begin
						x_tmp<=3'd2;
						y_tmp<=3'd2;
						magnifi<=1'b1;
						cmd_use<=REFLASH;
					end
					ZOOMOUT:begin
						x_tmp<=3'd0;
						y_tmp<=3'd0;
						magnifi<=1'b0;
						cmd_use<=REFLASH;
					end
					SHIFT_RIGHT:begin
						if(magnifi==1'b1)begin
							if(x_tmp<3'd4)begin
								x_tmp<=x_tmp+3'd1;
							end
						end
						else begin
							
						end
						cmd_use<=REFLASH;
					end
					SHIFT_LEFT:begin
						if(magnifi==1'b1)begin
							if(x_tmp>3'd0)begin
								x_tmp<=x_tmp-3'd1;
							end
						end
						cmd_use<=REFLASH;
					end
					SHIFT_UP:begin
						if(magnifi==1'b1)begin
							if(y_tmp>3'd0)begin
								y_tmp<=y_tmp-3'd1;
							end
						end
						cmd_use<=REFLASH;
					end
					SHIFT_DOWN:begin
						if(magnifi==1'b1)begin
							if(y_tmp<3'd4)begin
								y_tmp<=y_tmp+3'd1;
							end
						end
						cmd_use<=REFLASH;
					end
				endcase
			end
		end
	end
endmodule
