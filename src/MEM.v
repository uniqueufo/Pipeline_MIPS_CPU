`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:09:21 06/07/2018 
// Design Name: 
// Module Name:    MEM 
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
module MEM(ALUResult_mem,clk,reset,Addr,MemWriteData_mem,MemDout_wb,SelectMode
           ,LEFT_HALF_mem,RIGHT_HALF_mem,MemWrite_mem,data,sel
    );
	 input clk,reset,SelectMode;
	 input [31:0] ALUResult_mem;
	 input [5:0] Addr;
	 input [31:0]MemWriteData_mem;
	 input MemWrite_mem,LEFT_HALF_mem,RIGHT_HALF_mem;
	 output [7:0]data;
	 output [3:0]sel;
	 output [31:0]MemDout_wb;
	wire [5:0] theaddr;
   assign theaddr = ALUResult_mem[7:2];
	reg [31:0]count;
	reg [5:0]auto_inc_Addr;
	always@(posedge clk or negedge reset)
	if(~reset) begin
		count<=0;
		auto_inc_Addr<=0;
	end
	else 
		if(count==20000000) begin
			count<=0;
			if(auto_inc_Addr==6'd63)
				auto_inc_Addr<=0;
			else
				auto_inc_Addr<=auto_inc_Addr+6'b1;
		end
		else
			count<=count+32'b1;
	reg [5:0]R_Addr;
	always@*
		if(SelectMode)
			R_Addr=auto_inc_Addr;
		else
			R_Addr=Addr;
	wire [31:0] dpo;
	wire [31:0] MemWriteData_mem_true,MemDout_wb_true;
   assign MemWriteData_mem_true = LEFT_HALF_mem?(RIGHT_HALF_mem?{16'b0,MemWriteData_mem[15:0]}:{MemWriteData_mem[31:16],16'b0}):
	                               (RIGHT_HALF_mem?{16'b0,MemWriteData_mem[15:0]}:MemWriteData_mem);
	DataRAM DataRAM(.a(theaddr),.clk(clk),.dpra(R_Addr),.d(MemWriteData_mem_true),.spo(MemDout_wb_true),
	                .we(MemWrite_mem),.dpo(dpo));
	
	assign MemDout_wb= LEFT_HALF_mem?(RIGHT_HALF_mem?{16'b0,MemDout_wb_true[15:0]}:{MemDout_wb_true[31:16],16'b0}):
	                    (RIGHT_HALF_mem?{16'b0,MemWriteData_mem[15:0]}:MemDout_wb_true);
   
	DisPlay _Display (.clk(clk),.reset_n(reset),.q_a(dpo[15:0]),.data(data),.sel(sel));


endmodule
