`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:23:32 05/29/2018 
// Design Name: 
// Module Name:    InstructionROM 
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
module InstructionROM(addr,dout);
	input [5 : 0] addr;
	output [31 : 0] dout;
	reg [31 : 0] dout;
	always @(*)
	case (addr)
		6'd0:dout=32'h20080000;
		6'd1:dout=32'h01294826;
		6'd2:dout=32'h014a5026;
		6'd3:dout=32'h016b5826;
		6'd4:dout=32'h018c6026;
		6'd5:dout=32'h21290001;
		6'd6:dout=32'h214a0002;
		6'd7:dout=32'h216bffff;
		6'd8:dout=32'h8d0c0000;
		6'd9:dout=32'h21080004;
		6'd10:dout=32'h012b6820;
		6'd11:dout=32'had0d0000;
		6'd12:dout=32'h21080004;
		6'd13:dout=32'h012a6820;
		6'd14:dout=32'had0d0000;
		6'd15:dout=32'h21080004;
		6'd16:dout=32'h012b6822;
		6'd17:dout=32'had0d0000;
		6'd18:dout=32'h21080004;
		6'd19:dout=32'h01496823;
		6'd20:dout=32'had0d0000;
		6'd21:dout=32'h21080004;
		6'd22:dout=32'h012b6824;
		6'd23:dout=32'had0d0000;
		6'd24:dout=32'h21080004;
		6'd25:dout=32'h316d0010;
		6'd26:dout=32'had0d0000;
		6'd27:dout=32'h21080004;
		6'd28:dout=32'h012a6825;
		6'd29:dout=32'had0d0000;
		6'd30:dout=32'h21080004;
		6'd31:dout=32'h01696827;
		6'd32:dout=32'had0d0000;
		6'd33:dout=32'h21080004;
		6'd34:dout=32'h01696826;
		6'd35:dout=32'had0d0000;
		6'd36:dout=32'h21080004;
		6'd37:dout=32'h21ad0001;
		6'd38:dout=32'h1da00001;
		6'd39:dout=32'h08000025;
		6'd40:dout=32'had0d0000;
		6'd41:dout=32'h21080004;
		6'd42:dout=32'h15a90001;
		6'd43:dout=32'h01ad6826;
		6'd44:dout=32'had0d0000;
		6'd45:dout=32'h21080004;
		6'd46:dout=32'h200e00c8;
		6'd47:dout=32'h01ad6826;
		6'd48:dout=32'h01c00008;
		6'd49:dout=32'h21ad0010;
		6'd50:dout=32'h21ad0008;
		6'd51:dout=32'had0d0000;
		6'd52:dout=32'h21080004;
		6'd53:dout=32'h200e2000;
		6'd54:dout=32'h8dc90000;
		6'd55:dout=32'h014b4820;
		6'd56:dout=32'h01295820;
		6'd57:dout=32'had0b0000;
		6'd58:dout=32'h0800003a;
		default:dout=32'h00000000;
	endcase
endmodule 