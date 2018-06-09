`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:37:16 05/26/2018 
// Design Name: 
// Module Name:    Registers 
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
module Registers (
// Outputs
RsData, RtData,
// Inputs
clk, WriteData, WriteAddr, RegWrite, RsAddr, RtAddr
);
input clk;
// Info for register write port
input [31:0]  WriteData;
input [4:0]  WriteAddr;
input RegWrite;
input [4:0]  RsAddr, RtAddr;
// Data from register read ports
output [31:0] RsData; // data output for read port A
output [31:0] RtData;  // data output for read port B
// 32-register memory declaration
reg [31:0] regs [31:0];
initial
begin
regs[0] = 0; 
regs[1] = 0;
regs[2] = 0;
regs[3] = 0;
regs[4] = 0;
regs[5] = 0;
regs[6] = 0;
regs[7] = 0;
regs[8] = 0;
regs[9] = 0;
regs[10] = 0;
regs[11] = 0;
regs[12] = 0;
regs[13] = 0;
regs[14] = 0;
regs[15] = 0;
regs[16] = 0;
regs[17] = 0;
regs[18] = 0;  
regs[19] = 0;  
regs[20] = 0;  
regs[21] = 0;  
regs[22] = 0;  
regs[23] = 0;  
regs[24] = 0;  
regs[25] = 0;
regs[26] = 0;  
regs[27] = 0;  
regs[28] = 0;  
regs[29] = 0;
regs[30] = 0;  
regs[31] = 0;  
end

//******************************************************************************
// get data from read registers
//******************************************************************************
assign RsData = (RsAddr == 5'b0) ? 32'b0 : regs[RsAddr];//
assign RtData = (RtAddr == 5'b0) ? 32'b0 : regs[RtAddr];//
//******************************************************************************
// write to register if necessary
//******************************************************************************
always @ (posedge clk) begin
  if (RegWrite)
regs[WriteAddr] <= WriteData;
end
endmodule
