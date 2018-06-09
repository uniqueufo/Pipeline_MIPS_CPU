`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    05:03:03 06/06/2018 
// Design Name: 
// Module Name:    EX_MEM_Reg 
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
module EX_MEM_Reg(d1,d2,d3,d4,d5,
					r,clk,q1,q2,q3,q4,q5
    );
	 input r;
	input clk;
	input [1:0] d1;
	input [2:0]d2;
	input [31:0] d3,d4;
	input [4:0] d5;
	output [1:0] q1;
	output [2:0]q2;
	output [31:0] q3,q4;
	output [4:0] q5;
	reg [1:0] q1;
	reg [2:0]q2;
	reg [31:0] q3,q4;
	reg [4:0] q5;
	always @ (posedge clk)
	if (r)
		begin
			q1 <= 0;
			q2 <= 0;
			q3 <= 0;
			q4 <= 0;
			q5 <= 0;
		end
	else
		begin
			q1 <= d1;
			q2 <= d2;
			q3 <= d3;
			q4 <= d4;
			q5 <= d5;
		end
endmodule
