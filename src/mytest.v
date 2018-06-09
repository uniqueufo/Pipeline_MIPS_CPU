`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   07:13:44 05/29/2018
// Design Name:   Top
// Module Name:   /home/ise/Pipeline_CPU/mytest.v
// Project Name:  Pipeline_CPU
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mytest;

	// Inputs
	reg clk;
	reg reset;

	// Outputs
	wire [2:0] JumpFlag;
	wire [31:0] Instruction_id;
	wire [31:0] ALU_A;
	wire [31:0] ALU_B;
	wire [31:0] ALUResult;
	wire [31:0] PC;
	wire [31:0] MemDout_wb;
	wire Stall;
	wire [31:0] ALUResult_mem;

	// Instantiate the Unit Under Test (UUT)
	Top uut (
		.clk(clk), 
		.reset(reset), 
		.JumpFlag(JumpFlag), 
		.Instruction_id(Instruction_id), 
		.ALU_A(ALU_A), 
		.ALU_B(ALU_B), 
		.ALUResult(ALUResult), 
		.PC(PC), 
		.MemDout_wb(MemDout_wb), 
		.Stall(Stall), 
		.ALUResult_mem(ALUResult_mem)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#10;clk = 1;reset = 1;
		#10;clk = 0;reset = 1;
		#10;clk = 1;reset = 1;
		#10;clk = 0;reset = 0;
		forever #10 clk = ~clk;
        
		// Add stimulus here

	end
      
endmodule

