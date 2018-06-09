`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:44:09 05/26/2018 
// Design Name: 
// Module Name:    Top 
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
module Top(clk,reset,Addr,SelectMode,JumpFlag,Instruction_if,ALUResult,PC,Stall,data,sel
//  DataTest,ControlTest
);
	input clk,reset;
	input [5:0]Addr;
	input SelectMode;
	output[2:0] JumpFlag;
	output [31:0] Instruction_if,ALUResult; 
	output [31:0] PC;
	output Stall;
	output [3:0]sel;
	output [7:0]data;
//IF module
	wire[31:0] Instruction_id;
	wire PC_IFWrite,J,JR,Z,TRAP,IF_flush;
	wire[31:0] JumpAddr,JrAddr,BranchAddr,NextPC_if,Instruction_if;
	assign JumpFlag={JR,J,Z};
	assign IF_flush=Z || J || JR ||TRAP;
	IF IF(.clk(clk),.reset(reset),.Z(Z),.J(J),.JR(JR),.TRAP(TRAP),
			.PC_IFWrite(PC_IFWrite),.JumpAddr(JumpAddr),
			.JrAddr(JrAddr),.BranchAddr(BranchAddr),
			.Instruction_if(Instruction_if),.PC(PC),
			.NextPC_if(NextPC_if));
// IF->ID Register
	wire[31:0] NextPC_id;
	IF_ID_Reg IF_ID_SegReg(.d1(Instruction_if),.d2(NextPC_if),.en(PC_IFWrite),.r(IF_flush|reset),
								  .clk(clk),.q1(Instruction_id),.q2(NextPC_id));




// ID Module
	wire[4:0] RtAddr_id,RdAddr_id,RsAddr_id;
	wire RegWrite_wb,MemRead_ex,MemWrite_ex,HALF_ex,MemtoReg_id,RegWrite_id,MemWrite_id,LEFT_HALF_id,RIGHT_HALF_id;
	wire MemRead_id,ALUSrcA_id,ALUSrcB_id,RegDst_id,stall;
	wire [31:0]ALUResult_ex;
	wire RegWrite_ex;
	wire[4:0] RegWriteAddr_wb,RegWriteAddr_ex,ALUCode_id;
	wire[31:0] MemDout_wb,RegWriteData_wb,Imm_id,Sa_id,RsData_id,RtData_id;
	wire[4:0] RegWriteAddr_mem;
	wire RegWrite_mem;
	ID ID(.clk(clk),.Instruction_id(Instruction_id),.NextPC_id(NextPC_id),
			.RegWrite_wb(RegWrite_wb),.RegWriteAddr_wb(RegWriteAddr_wb),
			.RegWriteData_wb(RegWriteData_wb),.MemRead_ex(MemRead_ex),
			.RegWriteAddr_ex(RegWriteAddr_ex),.MemtoReg_id(MemtoReg_id),
			.RegWrite_id(RegWrite_id),.MemWrite_id(MemWrite_id),
			.RegWrite_mem(RegWrite_mem),.RegWriteAddr_mem(RegWriteAddr_mem),
			.RegWriteData_mem(MemDout_wb),
			.MemRead_id(MemRead_id),.LEFT_HALF_id(LEFT_HALF_id),.RIGHT_HALF_id(RIGHT_HALF_id),
			.ALUCode_id(ALUCode_id),
			.ALUSrcA_id(ALUSrcA_id),.ALUSrcB_id(ALUSrcB_id),
			.RegDst_id(RegDst_id),.Stall(Stall),.Z(Z),.J(J),.TRAP(TRAP),
			.JR(JR),.PC_IFWrite(PC_IFWrite),.BranchAddr(BranchAddr),
			.ALUResult_ex(ALUResult_ex),.RegWrite_ex(RegWrite_ex),
			.JumpAddr(JumpAddr),.JrAddr(JrAddr),.Imm_id(Imm_id),
			.Sa_id(Sa_id),.RsData_id(RsData_id),.RtData_id(RtData_id),
			.RtAddr_id(RtAddr_id),.RdAddr_id(RdAddr_id),.RsAddr_id(RsAddr_id));
// ID->EX Register
	wire MemtoReg_ex,ALUSrcA_ex,ALUSrcB_ex,RegDst_ex,LEFT_HALF_ex,RIGHT_HALF_ex;
	wire[4:0] ALUCode_ex,RsAddr_ex,RtAddr_ex,RdAddr_ex;
	wire[31:0] Sa_ex,Imm_ex,RsData_ex,RtData_ex;
	ID_EX_Reg ID_EX_SegReg(.d1({MemtoReg_id,RegWrite_id}),.d2({MemWrite_id,MemRead_id,LEFT_HALF_id,RIGHT_HALF_id}),
							     .d3({ALUCode_id,ALUSrcA_id,ALUSrcB_id,RegDst_id}),.d4(Imm_id),
								  .d5(Sa_id),.d6(RsData_id),.d7(RtData_id),.d8({RsAddr_id,RtAddr_id,RdAddr_id}),
								  .r(Stall|reset),.clk(clk),
								  .q1({MemtoReg_ex,RegWrite_ex}),.q2({MemWrite_ex,MemRead_ex,LEFT_HALF_ex,RIGHT_HALF_ex}),
								  .q3({ALUCode_ex,ALUSrcA_ex,ALUSrcB_ex,RegDst_ex}),.q4(Imm_ex),
								  .q5(Sa_ex),.q6(RsData_ex),.q7(RtData_ex),.q8({RsAddr_ex,RtAddr_ex,RdAddr_ex}));
								  
								  



// EX Module
	wire[31:0] ALUResult_mem,MemWriteData_ex;
	
	EX EX(.RegDst_ex(RegDst_ex),.ALUCode_ex(ALUCode_ex),.ALUSrcA_ex(ALUSrcA_ex),
	      .ALUSrcB_ex(ALUSrcB_ex),.Imm_ex(Imm_ex),.Sa_ex(Sa_ex),.RsAddr_ex(RsAddr_ex),
			.RtAddr_ex(RtAddr_ex),.RdAddr_ex(RdAddr_ex),.RsData_ex(RsData_ex),
			.RtData_ex(RtData_ex),.RegWriteData_wb(RegWriteData_wb),.ALUResult_mem(ALUResult_mem),
			.RegWriteAddr_wb(RegWriteAddr_wb),.RegWriteAddr_mem(RegWriteAddr_mem),
			.RegWrite_wb(RegWrite_wb),.RegWrite_mem(RegWrite_mem),.RegWriteAddr_ex(RegWriteAddr_ex),
			.ALUResult_ex(ALUResult_ex),.MemWriteData_ex(MemWriteData_ex));
	assign ALUResult=ALUResult_ex;
//EX->MEM
	wire MemWrite_mem,MemtoReg_mem,LEFT_HALF_mem,RIGHT_HALF_mem;
	wire[31:0] MemWriteData_mem;
	EX_MEM_Reg EX_MEM_SegReg(.d1({RegWrite_ex,MemtoReg_ex}),.d2({MemWrite_ex,LEFT_HALF_ex,RIGHT_HALF_ex}),
									 .d3(ALUResult_ex),.d4(MemWriteData_ex),.d5(RegWriteAddr_ex),
									 .r(reset),.clk(clk),
									 .q1({RegWrite_mem,MemtoReg_mem}),.q2({MemWrite_mem,LEFT_HALF_mem,RIGHT_HALF_mem}),
									 .q3(ALUResult_mem),.q4(MemWriteData_mem),.q5(RegWriteAddr_mem));
	




//MEM Module
  MEM MEM(.ALUResult_mem(ALUResult_mem),.clk(clk),.reset(reset),.SelectMode(SelectMode),.Addr(Addr),.MemWriteData_mem(MemWriteData_mem)
                         ,.MemDout_wb(MemDout_wb),.MemWrite_mem(MemWrite_mem),.LEFT_HALF_mem(LEFT_HALF_mem),
								 .RIGHT_HALF_mem(RIGHT_HALF_mem),.data(data),.sel(sel));

						 
//MEM->WB
	wire MemToReg_wb;
	wire[31:0] ALUResult_wb;
	MEM_WB_Reg MEM_WB_SegReg(.d1({RegWrite_mem,MemtoReg_mem}),.d2(ALUResult_mem),.d3(RegWriteAddr_mem),
									.r(reset),.clk(clk),
									.q1({RegWrite_wb,MemToReg_wb}),.q2(ALUResult_wb),.q3(RegWriteAddr_wb));
	
	
//WB
assign RegWriteData_wb=MemToReg_wb?MemDout_wb:ALUResult_wb;
endmodule
