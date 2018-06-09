`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:08:45 05/29/2018 
// Design Name: 
// Module Name:    ID 
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
module ID(clk,Instruction_id, NextPC_id, RegWrite_wb, RegWriteAddr_wb, RegWriteData_wb,
			 MemRead_ex, RegWriteAddr_ex, MemtoReg_id, RegWrite_id, MemWrite_id, MemRead_id,LEFT_HALF_id,RIGHT_HALF_id,RegWriteAddr_mem,RegWrite_mem,RegWriteData_mem,
			 ALUCode_id, ALUSrcA_id, ALUSrcB_id, ALUResult_ex, RegWrite_ex, RegDst_id, Stall, Z, J, JR,TRAP, PC_IFWrite, BranchAddr,
			 JumpAddr, JrAddr, Imm_id, Sa_id, RsData_id, RtData_id, RsAddr_id, RtAddr_id, RdAddr_id);
	input clk;
	input [31:0] Instruction_id;
	input [31:0] NextPC_id;
	input RegWrite_wb;
	input [4:0] RegWriteAddr_wb;
	input [31:0] RegWriteData_wb;
	input MemRead_ex;
	input [4:0] RegWriteAddr_ex;
	input [4:0] RegWriteAddr_mem;
	input [31:0]ALUResult_ex;
	input  RegWrite_ex;
	input  RegWrite_mem;
	input [31:0]RegWriteData_mem;
	output MemtoReg_id;
	output RegWrite_id;
	output MemWrite_id;
	output MemRead_id;
	output LEFT_HALF_id;
	output RIGHT_HALF_id;
	output [4:0] ALUCode_id;
	output ALUSrcA_id;
	output ALUSrcB_id;
	output RegDst_id;
	output Stall;
	output Z;
	output J;
	output JR;
	output TRAP;
	output PC_IFWrite;
	output [31:0] BranchAddr;
	output [31:0] JumpAddr;
	output [31:0] JrAddr;
	output [31:0] Imm_id;
	output [31:0] Sa_id;
	output [31:0] RsData_id;
	output [31:0] RtData_id;
	output [4:0] RsAddr_id;
	output [4:0] RtAddr_id;
	output [4:0] RdAddr_id;

//get the addr from the instruction 
	assign RtAddr_id=Instruction_id[20:16];
	assign RdAddr_id=Instruction_id[15:11];
	assign RsAddr_id=Instruction_id[25:21];
	assign Sa_id = {27'b0,Instruction_id[10:6]};
	assign Imm_id={{16{Instruction_id[15]}},Instruction_id[15:0]};
//forwarding
	wire [1:0]ForwardA,ForwardB;
	assign  ForwardA[0]=RegWrite_ex  &&  (RegWriteAddr_ex!=0)  &&
				(RegWriteAddr_ex==Instruction_id[25:21]);
	assign  ForwardA[1]=RegWrite_mem	&&  (RegWriteAddr_mem!=0) &&
            (RegWriteAddr_mem==RsAddr_id) &&(RegWriteAddr_ex!=RsAddr_id);	
	assign  ForwardB[0]=RegWrite_ex  &&  (RegWriteAddr_ex!=0)  &&
				(RegWriteAddr_ex==Instruction_id[20:16]);
	assign  ForwardB[1]=RegWrite_mem &&  (RegWriteAddr_mem!=0) &&
	         (RegWriteAddr_mem==RtAddr_id) &&(RegWriteAddr_ex!=RtAddr_id);

//MUX for A
	reg[31:0] A;
	always@(*)
	begin
	case(ForwardA)
	2'b00:A<=RsData_id;
	2'b01:A<=ALUResult_ex;
	2'b10:A<=RegWriteData_mem;
	endcase
	end
//MUX for B
	reg[31:0] B;
	always@(*)
	begin
	case(ForwardB)
	2'b00:B<=RtData_id;
	2'b01:B<=ALUResult_ex;
	2'b10:B<=RegWriteData_mem;
	endcase
	end

//JumpAddress
	assign JumpAddr = {NextPC_id[31:28],Instruction_id[25:0],2'b00};
//BranchAddrress
	assign BranchAddr= NextPC_id+(Imm_id<<2);
//JrAddress
	assign JrAddr = RsData_id;
	
//Zero test
	reg Z;
	always@(*)
	begin
		case(ALUCode_id)
			5'b01010:Z<=&(A[31:0]~^B[31:0]);
			5'b01011:Z<=|(A[31:0]^B[31:0]);
			5'b01100:Z<=~A[31];
			5'b01101:Z<=~A[31] && (|A[31: 0]) ;
			5'b01110:Z<=A[31] || ~ (|A[31: 0]) ;
			5'b01111:Z<=A[31] ;
			default: Z<=1'b0;
		endcase
	end
	
//******************************************************************************
// Trap instructions decode
//******************************************************************************
parameter R_type=6'b000000;
parameter I_type=6'b000001;
parameter TEQ_funct=6'b110100;
parameter TNE_funct=6'b110110;
parameter TGE_funct=6'b110000;
parameter TGEU_funct=6'b110001;
parameter TLT_funct=6'b110010;
parameter TLTU_funct=6'b110011;	
wire TEQ,TEQI,TNE,TNEI,TGE,TGEU,TGEI,TGEIU,TLT,TLTU,TLTI,TLTIU;
assign TEQ = (Instruction_id[31:26]==R_type) &&	(Instruction_id[5:0]==TEQ_funct) && (RsData_id==RtData_id);
assign TNE = (Instruction_id[31:26]==R_type) && (Instruction_id[5:0]==TNE_funct) && (RsData_id!=RtData_id);
assign TGE = (Instruction_id[31:26]==R_type) && (Instruction_id[5:0]==TGE_funct) && (RsData_id>=RtData_id);
assign TGEU = (Instruction_id[31:26]==R_type) && (Instruction_id[5:0]==TGEU_funct) && (RsData_id>=RtData_id);
assign TLT = (Instruction_id[31:26]==R_type) && (Instruction_id[5:0]==TLT_funct)	&& (RsData_id<RtData_id);
assign TLTU = (Instruction_id[31:26]==R_type) && (Instruction_id[5:0]==TLTU_funct) && (RsData_id<RtData_id);
assign TEQI = (Instruction_id[31:26]==I_type) && (Instruction_id[20:16]==5'b01100) && (RsData_id=={{16{Instruction_id[15]}},Instruction_id[15:0]});
assign TNEI = (Instruction_id[31:26]==I_type) && (Instruction_id[20:16]==5'b01110) && (RsData_id!={{16{Instruction_id[15]}},Instruction_id[15:0]});
assign TGEI = (Instruction_id[31:26]==I_type) && (Instruction_id[20:16]==5'b01000) && (RsData_id>={{16{Instruction_id[15]}},Instruction_id[15:0]});
assign TGEIU = (Instruction_id[31:26]==I_type) && (Instruction_id[20:16]==5'b01100) && (RsData_id>={{16'b0},Instruction_id[15:0]});
assign TLTI = (Instruction_id[31:26]==I_type) && (Instruction_id[20:16]==5'b01100) && (RsData_id<{{16{Instruction_id[15]}},Instruction_id[15:0]});
assign TLTIU = (Instruction_id[31:26]==I_type) && (Instruction_id[20:16]==5'b01100) && (RsData_id<{{16'b0},Instruction_id[15:0]});
assign TRAP = TEQ||TEQI||TNE||TNEI||TGE||TGEU||TGEI||TGEIU||TLT||TLTU||TLTI||TLTIU;
//Hazard detectior
	parameter alu_beq = 5'b01010;
	parameter alu_bne = 5'b01011;
	parameter alu_bgez= 5'b01100;
	parameter alu_bgtz= 5'b01101;
	parameter alu_blez= 5'b01110;
	parameter alu_bltz= 5'b01111;
	assign Stall = MemRead_ex &&( (RegWriteAddr_ex == RsAddr_id)||(RegWriteAddr_ex ==
			 RtAddr_id));
	assign PC_IFWrite = ~Stall;
//  Decode inst
	Decode Decode(.MemtoReg(MemtoReg_id),.RegWrite(RegWrite_id),
              .MemWrite(MemWrite_id),.MemRead(MemRead_id),
				  .LEFT_HALF(LEFT_HALF_id),.RIGHT_HALF(RIGHT_HALF_id),
				  .ALUCode(ALUCode_id),.ALUSrcA(ALUSrcA_id),
				  .ALUSrcB(ALUSrcB_id),.RegDst(RegDst_id),
				  .J(J),.JR(JR),.Instruction(Instruction_id));
// Registers inst
//MultiRegisters inst
	wire [31:0] RsData_temp,RtData_temp;
	Registers Registers(
// Outputs
	.RsData(RsData_temp),
	.RtData(RtData_temp),
// Inputs
	.clk(clk),
	.WriteData(RegWriteData_wb),
	.WriteAddr(RegWriteAddr_wb),
	.RegWrite(RegWrite_wb),
	.RsAddr(RsAddr_id),
	.RtAddr(RtAddr_id)
	);
//RsSel & RtSel
	wire RsSel;
	wire RtSel;
	assign RsSel=RegWrite_wb&&(~(RegWriteAddr_wb==0))&& (RegWriteAddr_wb==RsAddr_id);
	assign RtSel=RegWrite_wb && (~(RegWriteAddr_wb==0)) && (RegWriteAddr_wb==RtAddr_id);
//MUX for RsData_id & MUX for RtData_id
	reg[31:0] RsData_id;
	always@(*)
	begin
	case(RsSel)
		1'b0:RsData_id<=RsData_temp;
		1'b1:RsData_id<=RegWriteData_wb;
	endcase
	end
	reg[31:0] RtData_id;
	always@(*)
	begin
	case(RtSel)
		1'b0:RtData_id<=RtData_temp;
		1'b1:RtData_id<=RegWriteData_wb;
	endcase
	end
endmodule 