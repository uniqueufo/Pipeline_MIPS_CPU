`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:40:27 05/26/2018 
// Design Name: 
// Module Name:    adder_32bits 
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
module adder_32bits(a,b,ci,s,co);
	input [31:0] a,b;
	input ci;
	output[31:0] s;
	output co;
	wire c3,c7,c11,c15,c19,c23,c27;
	adder_ahead adder0(.a(a[3:0]),.b(b[3:0]),.cin(ci),.sum(s[3:0]),.cout(c3));
	adder_4bits adder1(.a(a[7:4]),.b(b[7:4]),.ci(c3),.s(s[7:4]),.co(c7));
	adder_4bits adder2(.a(a[11:8]),.b(b[11:8]),.ci(c7),.s(s[11:8]),.co(c11));
	adder_4bits adder3(.a(a[15:12]),.b(b[15:12]),.ci(c11),.s(s[15:12]),.co(c15));
	adder_4bits adder4(.a(a[19:16]),.b(b[19:16]),.ci(c15),.s(s[19:16]),.co(c19));
	adder_4bits adder5(.a(a[23:20]),.b(b[23:20]),.ci(c19),.s(s[23:20]),.co(c23));
	adder_4bits adder6(.a(a[27:24]),.b(b[27:24]),.ci(c23),.s(s[27:24]),.co(c27));
	adder_4bits adder7(.a(a[31:28]),.b(b[31:28]),.ci(c27),.s(s[31:28]),.co(co));
endmodule 