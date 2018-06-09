`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:40:06 05/26/2018 
// Design Name: 
// Module Name:    adder_4bits 
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
module adder_4bits(a,b,ci,s,co);
	input [3:0] a,b;
	input ci;
	output [3:0] s;
	output co;
	wire [3:0] s0,s1;
	wire co0,co1;
	adder_ahead adder0(.a(a),.b(b),.cin(1'b0),.sum(s0),.cout(co0));
	adder_ahead adder1(.a(a),.b(b),.cin(1'b1),.sum(s1),.cout(co1));
	mux_2to1 mux1(.in0(s0),.in1(s1),.sel(ci),.out(s));
	assign co=((ci&co1)|co0);
endmodule 