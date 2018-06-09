`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:56:18 05/29/2018 
// Design Name: 
// Module Name:    IF 
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
module IF(clk, reset, Z, J, JR,TRAP,PC_IFWrite, JumpAddr, JrAddr, BranchAddr, Instruction_if,
		    PC,NextPC_if);
	input clk,reset;
	input Z,J,JR,TRAP;
	input PC_IFWrite;
	input [31:0] JumpAddr;
	input [31:0] JrAddr;
	input [31:0] BranchAddr;
	output [31:0] Instruction_if;
	output [31:0] PC,NextPC_if;
// MUX for PC
	reg[31:0] PC_in;
	always@(*)
	begin
		case({TRAP,JR,J,Z})
		4'b0000:PC_in<=NextPC_if;
		4'b0001:PC_in<=BranchAddr;
		4'b0010:PC_in<=JumpAddr;
		4'b0100:PC_in<=JrAddr;
		4'b1000:PC_in<=32'h00000064;
		endcase
	end
//PC REG
	reg[31:0] PC;
	always @ (posedge clk)
	begin
		if ( reset ) PC <= 32'b0;
		else if (PC_IFWrite) PC <= PC_in;
		else PC <= PC;
	end
//Adder for NextPC
	adder_32bits adder_32bits_inst(
	.a(PC),
	.b(32'b00000000000000000000000000000100),
	.ci(1'b0),
	.s(NextPC_if),
	.co());
//ROM
	InstructionROM InstructionROM(.a(PC[7:2]),.spo(Instruction_if));
endmodule
