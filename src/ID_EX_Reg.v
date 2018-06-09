`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    04:50:16 06/06/2018 
// Design Name: 
// Module Name:    ID_EX_Reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ID_EX_Reg(d1,d2,d3,d4,d5,d6,d7,d8,
					r,clk,q1,q2,q3,q4,q5,q6,q7,q8
    );
	input r;
	input clk;
	input [1:0] d1;
	input [3:0] d2;
	input [7:0] d3;
	input [31:0] d4,d5,d6,d7;
	input [14:0] d8;
	output [1:0] q1;
	output [3:0] q2;
	output [7:0] q3;
	output [31:0] q4,q5,q6,q7;
	output [14:0]q8;
	reg [1:0] q1;
	reg [3:0] q2;
	reg [7:0] q3;
	reg [31:0] q4,q5,q6,q7;
	reg [14:0] q8;
	always @ (posedge clk)
	if (r)
		begin
			q1 <= 0;q5 <= 0;
			q2 <= 0;q6 <= 0;
			q3 <= 0;q7 <= 0;
			q4 <= 0;q8 <= 0;
		end
	else
		begin
			q1 <= d1;q5 <= d5;
			q2 <= d2;q6 <= d6;
			q3 <= d3;q7 <= d7;
			q4 <= d4;q8 <= d8;
		end
endmodule
