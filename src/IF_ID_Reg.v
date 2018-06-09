`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    03:39:28 06/06/2018 
// Design Name: 
// Module Name:    IF_ID_Reg 
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
module IF_ID_Reg(d1,d2,en,r,clk,q1,q2
    );
	input en;
	input r;
	input clk;
	input [31:0] d1,d2;
	output [31:0] q1,q2;
	reg [31:0] q1,q2;
	always @ (posedge clk)
	if ( r )
		begin
			q1 <= 0;
			q2 <= 0;
		end
	else if (en)
		begin
			q1 <= d1;
			q2 <= d2;
		end
	else 
		begin
			q1 <= q1;
			q2 <= q2;
		end
endmodule
