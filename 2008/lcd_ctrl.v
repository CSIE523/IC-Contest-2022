module LCD_CTRL(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [3:0]   cmd;
input           cmd_valid;
output  reg[7:0]   dataout;
output  reg        output_valid;
output  reg        busy;

localparam LOADDATA=4'd0;
localparam ROTATE_LEFT=4'd1;
localparam ROTATE_RIGHT=4'd2;
localparam ZOOMIN=4'd3;
localparam ZOOMFIT=4'd4;
localparam SHIFT_RIGHT=4'd5;
localparam SHIFT_LEFT=4'd6;
localparam SHIFT_UP=4'd7;
localparam SHIFT_DOWN=4'd8;
localparam WAIT_CMD=1'b0;
localparam PROCESS=1'b1;

reg [7:0]img_buf[107:0];
reg [3:0]cmd_use;
reg [7:0]counter;
reg [4:0]L,W;
reg inorfit;
reg cur_state,next_state;
reg [1:0]rotate;
reg display;
reg [4:0]out_counter;

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
				if(display==1'b1&&out_counter==8'd15)begin
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
			output_valid<=1'b0;
			inorfit<=0;
			busy<=1'd0;
			rotate<=2'b01;
			display<=1'b0;
			out_counter<=0;
		end
		else begin
			if(cur_state==WAIT_CMD)begin
				if(cmd_valid)begin
					cmd_use<=cmd;
					busy<=1'b1;
				end
				counter<=8'd0;
				out_counter<=5'd0;
				output_valid<=1'd0;
			end
			else begin
				if(display==1'b0)begin
					case(cmd_use)
						LOADDATA:begin
							img_buf[counter]<=datain;
							counter<=counter+8'd1;
							if(counter==8'd107)begin
								counter<=0;
								inorfit<=1'b1;
								rotate<=2'b01;
								display<=1'b1;
							end
						end
						ZOOMIN:begin
							L<=5'd6;
							W<=5'd5;
							inorfit<=1'b0;
							display<=1'b1;
						end
						ZOOMFIT:begin
							inorfit<=1'b1;
							display<=1'b1;
						end
						ROTATE_LEFT:begin
							if(inorfit==0) begin
								inorfit<=inorfit;
							end
							else begin
								rotate<=rotate-2'b1;
							end
							display<=1'b1;
						end
						ROTATE_RIGHT:begin
							if(inorfit==0) begin
								inorfit<=inorfit;
							end
							else begin
								rotate<=rotate+2'b1;
							end
							display<=1'b1;
						end
						SHIFT_RIGHT:begin
							if(inorfit==0) begin
								case(rotate)
									2'b00:begin 
										if(W<5'd7)begin
											W<=W+5'd1;
										end	
									end
									2'b01:begin
										if(L<5'd10)begin
											L<=L+5'd1;
										end
									end
									2'b10:begin
										if(W>5'd2)begin
											W<=W-5'd1;
										end
									end
								endcase
							end
							else begin
								inorfit<=inorfit;
							end
							display<=1'b1;
						end
						SHIFT_LEFT:begin
							if(inorfit==0) begin
								case(rotate)
									2'b00:begin
										if(W>5'd2)begin
											W<=W-5'd1;
										end
									end
									2'b01:begin
										if(L>5'd2)begin
											L<=L-5'd1;
										end
									end
									2'b10:begin
										if(W<5'd7)begin
											W<=W+5'd1;
										end
									end
								endcase
							end
							else begin
								inorfit<=inorfit;
							end
							display<=1'b1;
						end
						SHIFT_UP:begin
							if(inorfit==0) begin
								case(rotate)
									2'b00:begin 
										if(L<5'd10)begin
											L<=L+5'd1;
										end
									end
									2'b01:begin
										if(W>5'd2)begin
											W<=W-5'd1;
										end
									end
									2'b10:begin
										if(L>5'd2)begin
											L<=L-5'd1;
										end
									end
								endcase
							end
							else begin
								inorfit<=inorfit;
							end
							display<=1'b1;
						end
						SHIFT_DOWN:begin
							if(inorfit==0) begin
								case(rotate)
									2'b00:begin
										if(L>5'd2)begin
											L<=L-5'd1;
										end
									end
									2'b01:begin
										if(W<5'd7)begin
											W<=W+5'd1;
										end
									end
									2'b10:begin
										if(L<5'd10)begin
											L<=L+5'd1;
										end
									end
								endcase
							end
							else begin
								inorfit<=inorfit;
							end
							display<=1'b1;
						end
					endcase
				end
				else begin
					output_valid<=1'b1;
					if(inorfit==1'b0)begin
						case(rotate)
							2'b01:begin
								case(out_counter)
									8'd0:begin dataout<=img_buf[W*12+L-2*12-2]; end
									8'd1:begin dataout<=img_buf[W*12+L-2*12-1]; end
									8'd2:begin dataout<=img_buf[W*12+L-2*12-0]; end
									8'd3:begin dataout<=img_buf[W*12+L-2*12+1]; end
									8'd4:begin dataout<=img_buf[W*12+L-1*12-2]; end
									8'd5:begin dataout<=img_buf[W*12+L-1*12-1]; end
									8'd6:begin dataout<=img_buf[W*12+L-1*12-0]; end
									8'd7:begin dataout<=img_buf[W*12+L-1*12+1]; end
									8'd8:begin dataout<=img_buf[W*12+L-0*12-2]; end
									8'd9:begin dataout<=img_buf[W*12+L-0*12-1]; end
									8'd10:begin dataout<=img_buf[W*12+L-0*12-0]; end
									8'd11:begin dataout<=img_buf[W*12+L-0*12+1]; end
									8'd12:begin dataout<=img_buf[W*12+L+1*12-2]; end
									8'd13:begin dataout<=img_buf[W*12+L+1*12-1]; end
									8'd14:begin dataout<=img_buf[W*12+L+1*12-0]; end
									8'd15:begin dataout<=img_buf[W*12+L+1*12+1]; end
								endcase
							end
							2'b00:begin
								case(out_counter)
									8'd0:begin dataout<=img_buf[W*12+L-2*12+1]; end
									8'd1:begin dataout<=img_buf[W*12+L-1*12+1]; end
									8'd2:begin dataout<=img_buf[W*12+L-0*12+1]; end
									8'd3:begin dataout<=img_buf[W*12+L+1*12+1]; end
									8'd4:begin dataout<=img_buf[W*12+L-2*12-0]; end
									8'd5:begin dataout<=img_buf[W*12+L-1*12-0]; end
									8'd6:begin dataout<=img_buf[W*12+L-0*12-0]; end
									8'd7:begin dataout<=img_buf[W*12+L+1*12-0]; end
									8'd8:begin dataout<=img_buf[W*12+L-2*12-1]; end
									8'd9:begin dataout<=img_buf[W*12+L-1*12-1]; end
									8'd10:begin dataout<=img_buf[W*12+L-0*12-1]; end
									8'd11:begin dataout<=img_buf[W*12+L+1*12-1]; end
									8'd12:begin dataout<=img_buf[W*12+L-2*12-2]; end
									8'd13:begin dataout<=img_buf[W*12+L-1*12-2]; end
									8'd14:begin dataout<=img_buf[W*12+L-0*12-2]; end
									8'd15:begin dataout<=img_buf[W*12+L+1*12-2]; end
								endcase
							end
							2'b10:begin
								case(out_counter)
									8'd0:begin dataout<=img_buf[W*12+L+1*12-2]; end
									8'd1:begin dataout<=img_buf[W*12+L-0*12-2]; end
									8'd2:begin dataout<=img_buf[W*12+L-1*12-2]; end
									8'd3:begin dataout<=img_buf[W*12+L-2*12-2]; end
									8'd4:begin dataout<=img_buf[W*12+L+1*12-1]; end
									8'd5:begin dataout<=img_buf[W*12+L-0*12-1]; end
									8'd6:begin dataout<=img_buf[W*12+L-1*12-1]; end
									8'd7:begin dataout<=img_buf[W*12+L-2*12-1]; end
									8'd8:begin dataout<=img_buf[W*12+L+1*12-0]; end
									8'd9:begin dataout<=img_buf[W*12+L-0*12-0]; end
									8'd10:begin dataout<=img_buf[W*12+L-1*12-0]; end
									8'd11:begin dataout<=img_buf[W*12+L-2*12-0]; end
									8'd12:begin dataout<=img_buf[W*12+L+1*12+1]; end
									8'd13:begin dataout<=img_buf[W*12+L-0*12+1]; end
									8'd14:begin dataout<=img_buf[W*12+L-1*12+1]; end
									8'd15:begin dataout<=img_buf[W*12+L-2*12+1]; end
								endcase
							end
						endcase
					end
					else begin
						case(rotate)
							2'b01:begin
								case(out_counter)
									8'd0:begin dataout<=img_buf[13]; end
									8'd1:begin dataout<=img_buf[16]; end
									8'd2:begin dataout<=img_buf[19]; end
									8'd3:begin dataout<=img_buf[22]; end
									8'd4:begin dataout<=img_buf[37]; end
									8'd5:begin dataout<=img_buf[40]; end
									8'd6:begin dataout<=img_buf[43]; end
									8'd7:begin dataout<=img_buf[46]; end
									8'd8:begin dataout<=img_buf[61]; end
									8'd9:begin dataout<=img_buf[64]; end
									8'd10:begin dataout<=img_buf[67]; end
									8'd11:begin dataout<=img_buf[70]; end
									8'd12:begin dataout<=img_buf[85]; end
									8'd13:begin dataout<=img_buf[88]; end
									8'd14:begin dataout<=img_buf[91]; end
									8'd15:begin dataout<=img_buf[94]; end
								endcase
							end
							2'b00:begin
								case(out_counter)
									8'd0:begin dataout<=img_buf[22]; end
									8'd1:begin dataout<=img_buf[46]; end
									8'd2:begin dataout<=img_buf[70]; end
									8'd3:begin dataout<=img_buf[94]; end
									8'd4:begin dataout<=img_buf[19]; end
									8'd5:begin dataout<=img_buf[43]; end
									8'd6:begin dataout<=img_buf[67]; end
									8'd7:begin dataout<=img_buf[91]; end
									8'd8:begin dataout<=img_buf[16]; end
									8'd9:begin dataout<=img_buf[40]; end
									8'd10:begin dataout<=img_buf[64]; end
									8'd11:begin dataout<=img_buf[88]; end
									8'd12:begin dataout<=img_buf[13]; end
									8'd13:begin dataout<=img_buf[37]; end
									8'd14:begin dataout<=img_buf[61]; end
									8'd15:begin dataout<=img_buf[85]; end
								endcase
							end
							2'b10:begin
								case(out_counter)
									8'd0:begin dataout<=img_buf[85]; end
									8'd1:begin dataout<=img_buf[61]; end
									8'd2:begin dataout<=img_buf[37]; end
									8'd3:begin dataout<=img_buf[13]; end
									8'd4:begin dataout<=img_buf[88]; end
									8'd5:begin dataout<=img_buf[64]; end
									8'd6:begin dataout<=img_buf[40]; end
									8'd7:begin dataout<=img_buf[16]; end
									8'd8:begin dataout<=img_buf[91]; end
									8'd9:begin dataout<=img_buf[67]; end
									8'd10:begin dataout<=img_buf[43]; end
									8'd11:begin dataout<=img_buf[19]; end
									8'd12:begin dataout<=img_buf[94]; end
									8'd13:begin dataout<=img_buf[70]; end
									8'd14:begin dataout<=img_buf[46]; end
									8'd15:begin dataout<=img_buf[22]; end
								endcase
							end
						endcase
					end
					out_counter<=out_counter+8'd1;
					if(out_counter==5'd15)begin
						out_counter<=0;
						busy<=0;
						display<=1'b0;
					end
				end
			end
		end
	end
endmodule