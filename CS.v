`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input clk, reset; 
input [7:0] X;
output reg [9:0] Y;

reg [7:0]x_indata[8:0];
reg [3:0]counter;
wire [12:0]x_avg;
wire [12:0]x_appr;
wire [7:0]x_tmp[8:0];
wire [12:0]y_tmp;

wire [9:0]a,b,c,d ,e ,f ,g,h;
integer i;

always@(posedge clk or posedge reset)begin
	if(reset)begin
		counter=1'b1;
		for(i=0;i<9;i=i+1)begin
			x_indata[i]=0;
		end
	end
	else begin
		if(counter==4'd10)begin
			counter=counter%9;
		end
		case(counter)
			4'd1:begin x_indata[0]<=X; 	counter<=counter+1; end
			4'd2:begin x_indata[1]<=X;	counter<=counter+1; end
			4'd3:begin x_indata[2]<=X;	counter<=counter+1; end
			4'd4:begin x_indata[3]<=X;	counter<=counter+1; end
			4'd5:begin x_indata[4]<=X;	counter<=counter+1; end
			4'd6:begin x_indata[5]<=X;	counter<=counter+1; end
			4'd7:begin x_indata[6]<=X;	counter<=counter+1; end
			4'd8:begin x_indata[7]<=X;	counter<=counter+1; end
			4'd9:begin x_indata[8]<=X;	counter<=counter+1; end
		endcase
	end
end
always@(negedge clk)begin
	Y=y_tmp[12:3];
end
	assign x_avg=(x_indata[0]+x_indata[1]+x_indata[2]+x_indata[3]+x_indata[4]+x_indata[5]+x_indata[6]+x_indata[7]+x_indata[8])/9;
	assign x_tmp[0]=(x_indata[0]<=x_avg)?x_indata[0]:0;
	assign x_tmp[1]=(x_indata[1]<=x_avg)?x_indata[1]:0;
	assign x_tmp[2]=(x_indata[2]<=x_avg)?x_indata[2]:0;
	assign x_tmp[3]=(x_indata[3]<=x_avg)?x_indata[3]:0;
	assign x_tmp[4]=(x_indata[4]<=x_avg)?x_indata[4]:0;
	assign x_tmp[5]=(x_indata[5]<=x_avg)?x_indata[5]:0;
	assign x_tmp[6]=(x_indata[6]<=x_avg)?x_indata[6]:0;
	assign x_tmp[7]=(x_indata[7]<=x_avg)?x_indata[7]:0;
	assign x_tmp[8]=(x_indata[8]<=x_avg)?x_indata[8]:0;
	

	assign a=(x_tmp[0]>x_tmp[1])?x_tmp[0]:x_tmp[1];
	assign b=(x_tmp[2]>x_tmp[3])?x_tmp[2]:x_tmp[3];
	assign c=(x_tmp[4]>x_tmp[5])?x_tmp[4]:x_tmp[5];
	assign d=(x_tmp[6]>x_tmp[7])?x_tmp[6]:x_tmp[7];
	assign e=(x_tmp[8]>a)?x_tmp[8]:a;
	
	assign f=(b>c)?b:c;
	assign g=(d>e)?d:e;
	
	assign x_appr=(f>g)?f:g;
	assign y_tmp=((x_indata[0]+x_appr)+(x_indata[1]+x_appr)+(x_indata[2]+x_appr)+(x_indata[3]+x_appr)+(x_indata[4]+x_appr)+(x_indata[5]+x_appr)+(x_indata[6]+x_appr)+(x_indata[7]+x_appr)+(x_indata[8]+x_appr));
endmodule