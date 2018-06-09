### <center> ------流水线多周期CPU设计
---------------------

###**实现的指令**
> (6条)算数运算指令：ADD ADDU SUB SUBU ADDI ADDIU
(11条)逻辑运算指令：AND OR NOR XOR ANDI ORI XORI SLT SLTI SLTU SLTIU
(5条)移位指令：SLL SLLV SRL SRLV SRA
(6条)条件分支指令：BEQ BNE BGEZ BGTZ BLEZ BLTZ
(2条)无条件跳转指令：J JR
(6条)存取数指令：LW LWL LWR SW SWL SWR
(12条)陷阱指令：TEQ TEQI TNE TNEI TGE TGEU TGEI TGEIU TLT TLTU TLTI TLTIU 



--------------------------------------------------------------
###**流水线各级设计思想**


>1) IF 级：取指令级。从 ROM 中读取指令，并在下一个时钟沿到来时把指令送
到 ID 级的指令缓冲器中。该级控制信号决定下一个指令指针的 PCSource 信号、
阻塞流水线的 PC_IFwrite 信号、清空流水线的 IF_flush 信号。

> 2）ID 级：指令译码器。对 IF 级来的指令进行译码，并产生相应的控制信号。
整个 CPU 的控制信号基本都是在这级上产生。该级自身不需任何控制信号。流水
线冒险检测也在该级进行，冒险检测电路需要上一条指令的 MemRead，即在检测
到冒险条件成立时，冒险检测电路产生 stall 信号清空 ID/EX 寄存器，插入一个
流水线气泡。分支指令的转发也在该级完成。

> 3）EX 级：执行级。该级进行算术或逻辑操作。此外 LW、SW 指令所用的 RAM 访
问地址也是在本级上实现。控制信号有 ALUCode、ALUSrcA、ALUScrB 和 RegDst，
根据这些信号确定 ALU 操作、选择两个 ALU 操作数 A、B，并确定目标寄存器。
另外，数据转发也在该级完成。数据转发控制电路产生 ForwardA 和 ForwardB
两组控制信号。

> 4）MEM 级：存储器访问级。只有在执行 LW、SW 指令时才对存储器进行读写，
对其他指令只起到一个周期的作用。该级只需存储器写操作允许信号 MemWrite。

> 5）WB 级：写回级。该级把指令执行的结果回写到寄存器文件中。该级设置信
号 MemtoReg 和寄存器写操作允许信号 RegWrite，其中 MemtoReg 决定写入寄存
器的数据来自于 MEM 级上的缓冲值或来自于 MEM 级上的存储器。


----------------------------------------
###**流水线冒险的处理**


> 1）**数据相关**

>     ①第 I 条指令的源操作寄存器与第 I-1 条指令（即上一条指令）的目标寄存器相重，导致的数据相关称为一阶数据相关。而I指令在第四时钟周期向 I-1 指令结果发出请求，请求时间晚于结果产生时间，所以只需要I-1指令结果产生之后直接将其转发给I指令就可以避免一阶数据相关。转发数据为 ALUResult_mem，数据转发由 Forwarding unit 单元控制，判断转发条件是否成立。
    转发条件 ForwardA、ForwardB 作为数据选择器的地址信号，转发条件不成立时，ALU 操作数从 ID/EX 流水线寄存器中读取；转发条件成立时，ALU 操作数取自数据旁路。转发条件：MEM 级指令是写操作，即 RegWrite_mem=1；MEM 级指令写回的目标寄存器不是$0，即 RegWriteAddr_mem≠0；MEM 级指令写回的目标寄存器与在EX级指令的寄存器是同一寄存器，即RegWriteAddr_mem=RsAddr_ex 或 RegWriteAddr_mem=RtAddr_ex。

>     ②I-2 指令在第 5 时钟周期写回寄存器，而 I 指令也在第 5 时钟周期对 I-2 指令的结果提出了请求，很显然 I 指令读取的数据是未被更新的错误内容。这类第I 条指令的源操作寄存器与第 I-2 条指令（即之上第二条指令）的目标寄存器相重，导致的数据相关称为二阶数据相关。如前所述，I 指令在第五时钟周期向 I-2 指令结果发出请求时，I-2 指令的结果已经产生。
        所以，同样采用“转发”，即通过 MEM/WB 流水线寄存器，将I-2 指令结果转发给 I 指令，而不需要先写回寄存器堆。转发数据为 RegWriteData_wb。转发条件：WB 级指令是写操作，即 RegWrite_wb=1；WB 级指令写回的目标寄存器不是$0，即 RegWriteAddr_wb≠0；WB 级指令写回的目 标 寄存器与在EX级指令的源寄存器是同一寄存器 ，即RegWriteAddr_wb=RsAddr_ex 或 RegWriteAddr_wb=RtAddr_ex；EX 冒险不成立，即 RegWriteAddr_mem≠RsAddr_ex 或 RegWriteAddr_mem=RtAddr_ex。

> 2）**数据冒险与阻塞**

>        当一条指令试图读取一个寄存器，而它前一条指令是 lw 指令，并且该 lw 指令写入的是同一个寄存器时，定向转发的方法就无法解决问题。这类冒险不同于数据相关冒险，需要单独一个“冒险检测单元（Hazard Detector）”，它在 ID 级完成。冒险成立的条件为：上一条指令是 lw 指令，即MemRead_ex=1；在 EX 级的 lw 指令与在 ID 级的指令读写的是同一个寄存器，即RegWriteAddr_ex=RsAddr_id 或 RegWriteAddr_ex=RtAddr_id。冒险的解决：为解决数据冒险，我们引入流水线阻塞。当 Hazard Detector检测到冒险条件成立时，在 lw 指令和下一条指令之间插入阻塞，即流水线气泡（bubble), 使后一条指令延迟一个时钟周期执行，这样就将该冒险转化为二阶数据相关，可用转发解决。
>      如果处于 ID 级的指令被阻塞那么处于 IF 级的指令也必须阻塞，否则，处于ID级的指令就会丢失。防止这两条指令继续执行的方法是：保持 PC 寄存器和 IF/ID 流水线寄存器不变，同时插入一个流水线气泡。具体实现方法如下：在ID 级检测到冒险条件时， HazardDetector 输出两个信号：Stall 与 PC_IFWrite。Stall 信号将 ID/EX流水线寄存器中的 EX、MEM 和 WB 级控制信号全部清零。这些信号传递到流水线后面的各级，由于控制信号均为零，所以不会对任何寄存器和存储器进行写操作，高电平有效。PC_IFWrite 信号禁止 PC 寄存器和 IF/ID 流水线寄存器接收新数据，低电平有效。

> 3）**分支冒险**

>     采用提前分支指令的方法解决分支冒险。提前分支指令需要提前完成两个操作：
>     ① 计算分支的目的地址：
>      由于已经有了 PC 值和 IF/ID 流水线寄存器中的指令值，所以可以很方便地将 EX 级的分支地址计算电路移到 ID 级。我们针对所有指令都执行分支地址的计算过程，但只有在需要它的时候才会用到。
>     ② 判断分支指令的跳转条件：
>     我们将用于判断分支指令成立的 Zero 信号检测电路（Z test ）从 ALU 中独立出来，并将它从 EX 级提前至 ID 级。具体的设计将在 ID 级设计中介绍。在提前完成以上两个操作之外，我们还需丢弃 IF 级的指令。具体做法是：加入一个控制信号 IF_flush，做为 IF/ID 流水线寄存器的清零信号。当分支冒险成立，即 Z=1，则IF_flush=1，否则 IF_flush=0，故 IF_flush = Z。考虑到本系统还要实现的无条件跳转指令：J 和JR，在执行这两个指令时也必须要对 IF/ID 流水线寄存器进行清空，因此， IF_flush 的表达式应表示为：IF_flush = Z || J || JR。


###**流水线MIPS CPU主要功能模块**

####<center>**IF段**
```verilog
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
```
####<center>**译码**
```verilog
module Decode(
// Outputs
	MemtoReg,RegWrite,MemWrite,MemRead,LEFT_HALF,RIGHT_HALF,ALUCode,ALUSrcA,ALUSrcB,
	RegDst,J ,JR,
// Inputs
	Instruction
);
input [31:0]  Instruction;  // current instruction
output  MemtoReg; // use memory output as data to write into register
output  RegWrite; // enable writing back to the register
output  MemWrite; // write to memory
output MemRead;
output LEFT_HALF;
output RIGHT_HALF;
output [4:0] ALUCode; // ALU operation select
output ALUSrcA,ALUSrcB;
output RegDst;
output J,JR;
//******************************************************************************
// instruction field
//******************************************************************************
wire [5:0] op;
wire [4:0] rt;
wire [5:0] funct;
assign op = Instruction[31:26];
assign funct  = Instruction[5:0];
assign rt = Instruction[20:16];
//******************************************************************************
//R_type instruction decode
//******************************************************************************
parameter R_type_op= 6'b000000;
parameter ADD_funct = 6'b100000;
parameter ADDU_funct = 6'b100001;
parameter AND_funct = 6'b100100;
parameter XOR_funct = 6'b100110;
parameter OR_funct = 6'b100101;
parameter NOR_funct = 6'b100111;
parameter SUB_funct = 6'b100010;
parameter SUBU_funct = 6'b100011;
parameter SLT_funct = 6'b101010;
parameter SLTU_funct = 6'b101011; 
parameter SLL_funct= 6'b000000;
parameter SLLV_funct=6'b000100;
parameter SRL_funct= 6'b000010;
parameter SRLV_funct=6'b000110;
parameter SRA_funct= 6'b000011;
parameter SRAV_funct=6'b000111;
parameter JR_funct= 6'b001000;
//******************************************************************************
// R_type1 instruction decode
//******************************************************************************
wire ADD,ADDU,AND,NOR,OR,SLT,SLTU,SUB,SUBU,XOR,SLLV, SRAV, SRLV,R_type1;
assign ADD  = (op == R_type_op) && (funct ==ADD_funct);
assign ADDU = (op == R_type_op) && (funct == ADDU_funct);
assign AND  = (op == R_type_op) && (funct == AND_funct);
assign NOR  = (op == R_type_op) && (funct == NOR_funct);
assign OR = (op == R_type_op) && (funct == OR_funct);
assign SLT  = (op == R_type_op) && (funct == SLT_funct);
assign SLTU  = (op == R_type_op) && (funct == SLTU_funct);
assign SUB  = (op == R_type_op) && (funct == SUB_funct);
assign SUBU = (op == R_type_op) && (funct == SUBU_funct);
assign XOR  = (op == R_type_op) && (funct == XOR_funct);
assign SLLV  = (op == R_type_op) && (funct == SLLV_funct);
assign SRAV = (op == R_type_op) && (funct == SRAV_funct);
assign SRLV  = (op == R_type_op) && (funct == SRLV_funct);
assign R_type1 =ADD || ADDU || AND || NOR || OR || SLT || SLTU || SUB
|| SUBU || XOR ||  SLLV || SRAV || SRLV;
//******************************************************************************
// R_type2 instruction decode
//******************************************************************************
wire SLL, SRA, SRL,R_type2;
assign SLL = (op == R_type_op) && (funct == SLL_funct) && (|Instruction);
assign SRA = (op == R_type_op) && (funct == SRA_funct);
assign SRL = (op == R_type_op) && (funct == SRL_funct);
assign R_type2=SLL || SRA || SRL; 
//******************************************************************************
// JR instruction decode
//******************************************************************************
assign JR = (op == R_type_op) && (funct == JR_funct);
//******************************************************************************
// branch instructions decode
//******************************************************************************
parameter BEQ_op= 6'b000100;
parameter BNE_op = 6'b000101;
parameter BGEZ_op= 6'b000001;
parameter BGEZ_rt= 5'b00001;
parameter BGTZ_op= 6'b000111;
parameter BGTZ_rt= 5'b00000;
parameter BLEZ_op = 6'b000110;
parameter BLEZ_rt = 5'b00000;
parameter BLTZ_op= 6'b000001;
parameter BLTZ_rt= 5'b00000;
wire BEQ, BGEZ, BGTZ, BLEZ, BLTZ, BNE,Branch;
assign BEQ = (op ==BEQ_op );
assign BNE = (op ==BNE_op );
assign BGEZ = (op == BGEZ_op) && (rt == BGEZ_rt);
assign BGTZ = (op == BGTZ_op) && (rt== BGTZ_rt);
assign BLEZ = (op == BLEZ_op) && (rt == BLEZ_rt);
assign BLTZ = (op == BLTZ_op) && (rt ==BLTZ_rt);
assign Branch=BEQ || BNE ||BGEZ || BGTZ || BLEZ ||BLTZ;
//******************************************************************************
// Jump instructions decode
//******************************************************************************
parameter J_op=6'b000010;
assign J=(op == J_op);
//******************************************************************************
// I_type instruction decode
//******************************************************************************
parameter ADDI_op = 6'b001000;
parameter ADDIU_op= 6'b001001;
parameter ANDI_op = 6'b001100;
parameter XORI_op = 6'b001110;
parameter ORI_op = 6'b001101;
parameter SLTI_op = 6'b001010;
parameter SLTIU_op= 6'b001011;
wire ADDI,ADDIU,ANDI,XORI,ORI,SLTI,SLTIU,I_type;
assign ADDI = (op == ADDI_op) ; 
assign ADDIU= (op == ADDIU_op) ;
assign ANDI= (op == ANDI_op) ;
assign XORI= (op == XORI_op) ;
assign SLTI= (op == SLTI_op) ;
assign SLTIU= (op == SLTIU_op) ;
assign ORI= (op == ORI_op) ; 
assign I_type=ADDI || ADDIU || ANDI || XORI || ORI || SLTI || SLTIU;
//******************************************************************************
// SW ,LW instruction decode
//******************************************************************************
parameter SW_op = 6'b101011;
parameter SWL_op = 6'b101010;
parameter SWR_op = 6'b101110;
parameter LW_op = 6'b100011;
parameter LWL_op = 6'b100010;
parameter LWR_op = 6'b100110;
wire SW,LW,SH,LH;
assign SW= (op == SW_op) ;
assign SWL= (op == SWL_op) ;
assign SWR= (op == SWR_op);
assign LW= (op == LW_op) ;
assign LWL= (op == LWL_op) ;
assign LWR= (op == LWR_op) ; 
//******************************************************************************
// Control Singal
//******************************************************************************
assign RegWrite= LW || LWL || LWR || R_type1 || R_type2 || I_type;
assign RegDst= R_type1 || R_type2;
assign MemWrite= SW || SWL || SWR;
assign MemRead= LW || LWL || LWR;
assign MemtoReg= LW || LWL || LWR;
assign ALUSrcA= R_type2;
assign ALUSrcB= LW || SW || LWL || LWR || SWL || SWR || I_type;
assign LEFT_HALF = SWL || LWL;
assign RIGHT_HALF = SWR || LWR;
//******************************************************************************
// ALUCode
//******************************************************************************//
parameter alu_add= 5'b00000;
parameter alu_and= 5'b00001;
parameter alu_xor= 5'b00010;
parameter alu_or = 5'b00011;
parameter alu_nor= 5'b00100;
parameter alu_sub= 5'b00101;
parameter alu_andi= 5'b00110;
parameter alu_xori= 5'b00111;
parameter alu_ori = 5'b01000;
parameter alu_jr = 5'b01001;
parameter alu_beq= 5'b01010;
parameter alu_bne= 5'b01011;
parameter alu_bgez= 5'b01100;
parameter alu_bgtz= 5'b01101;
parameter alu_blez= 5'b01110;
parameter alu_bltz= 5'b01111;
parameter alu_sll= 5'b10000;
parameter alu_srl= 5'b10001;
parameter alu_sra= 5'b10010; 
parameter alu_slt= 5'b10011;
parameter alu_sltu= 5'b10100; 
reg[4:0] ALUCode;
always@(*)
begin
if(op==R_type_op)
begin
case(funct)
ADD_funct :ALUCode<=alu_add;
ADDU_funct :ALUCode<=alu_add;
AND_funct :ALUCode<=alu_and;
XOR_funct :ALUCode<=alu_xor;
OR_funct :ALUCode<=alu_or;
NOR_funct :ALUCode<=alu_nor;
SUB_funct :ALUCode<=alu_sub;
SUBU_funct :ALUCode<=alu_sub;
SLT_funct :ALUCode<=alu_slt;
SLTU_funct :ALUCode<=alu_sltu;
SLL_funct :ALUCode<=alu_sll;
SLLV_funct :ALUCode<=alu_sll;
SRL_funct :ALUCode<=alu_srl;
SRLV_funct :ALUCode<=alu_srl;
SRA_funct :ALUCode<=alu_sra;
default :ALUCode<=alu_sra;
endcase
end
else
begin
case(op)
BEQ_op :ALUCode<=alu_beq;
BNE_op :ALUCode<=alu_bne;
BGEZ_op :begin if(rt==BGEZ_rt) ALUCode<=alu_bgez;end
BGTZ_op :begin if(rt==BGTZ_rt) ALUCode<=alu_bgtz;end
BLEZ_op :begin if(rt==BLEZ_rt) ALUCode<=alu_blez;end
BLTZ_op :begin if(rt==BLTZ_rt) ALUCode<=alu_bltz;end
ADDI_op :ALUCode<=alu_add;
ADDIU_op:ALUCode<=alu_add;
ANDI_op :ALUCode<=alu_andi;
XORI_op :ALUCode<=alu_xori;
ORI_op :ALUCode<=alu_ori;
SLTI_op :ALUCode<=alu_slt;
SLTIU_op:ALUCode<=alu_sltu;
SW_op :ALUCode<=alu_add;
LW_op :ALUCode<=alu_add;
default :ALUCode<=alu_add;
endcase
end
end
endmodule 
```


####<center>**EX段**
```verilog
module EX(RegDst_ex, ALUCode_ex, ALUSrcA_ex, ALUSrcB_ex, Imm_ex, Sa_ex, RsAddr_ex,
RtAddr_ex,  RdAddr_ex,RsData_ex,  RtData_ex,  RegWriteData_wb,  ALUResult_mem,
RegWriteAddr_wb,  RegWriteAddr_mem,  RegWrite_wb,  RegWrite_mem,  RegWriteAddr_ex,
ALUResult_ex, MemWriteData_ex);
input RegDst_ex;
input [4:0] ALUCode_ex;
input ALUSrcA_ex;
input ALUSrcB_ex;
input [31:0] Imm_ex;
input [31:0] Sa_ex;
input [4:0] RsAddr_ex;
input [4:0] RtAddr_ex;
input [4:0] RdAddr_ex;
input [31:0] RsData_ex;
input [31:0] RtData_ex;
input [31:0] RegWriteData_wb;
input [31:0] ALUResult_mem;
input [4:0] RegWriteAddr_wb;
input [4:0] RegWriteAddr_mem;
input RegWrite_wb;
input RegWrite_mem;
output [4:0] RegWriteAddr_ex;
output [31:0] ALUResult_ex;
output [31:0] MemWriteData_ex;
//forwarding
wire[1:0] ForwardA,ForwardB;
assign  ForwardA[0]=RegWrite_wb  &&  (RegWriteAddr_wb!=0)  &&
(RegWriteAddr_mem!=RsAddr_ex) && (RegWriteAddr_wb==RsAddr_ex);
assign  ForwardA[1]=RegWrite_mem  &&  (RegWriteAddr_mem!=0)  &&
(RegWriteAddr_mem==RsAddr_ex);
assign  ForwardB[0]=RegWrite_wb  &&  (RegWriteAddr_wb!=0)  &&
(RegWriteAddr_mem!=RtAddr_ex) && (RegWriteAddr_wb==RtAddr_ex);
assign  ForwardB[1]=RegWrite_mem  &&  (RegWriteAddr_mem!=0)  &&
(RegWriteAddr_mem==RtAddr_ex);
//MUX for A
reg[31:0] A;
always@(*)
begin
case(ForwardA)
2'b00:A<=RsData_ex;
2'b01:A<=RegWriteData_wb;
2'b10:A<=ALUResult_mem;
endcase
end
//MUX for B
reg[31:0] B;
always@(*)
begin
case(ForwardB)
2'b00:B<=RtData_ex;
2'b01:B<=RegWriteData_wb;
2'b10:B<=ALUResult_mem;
endcase
end
//MUX for ALU_A
reg[31:0] ALU_A;
always@(*)
begin
case(ALUSrcA_ex)
1'b0:ALU_A<=A;
1'b1:ALU_A<=Sa_ex;
endcase
end
//MUX for ALU_B
reg[31:0] ALU_B;
always@(*)
begin
case(ALUSrcB_ex)
1'b0:ALU_B<=B;
1'b1:ALU_B<=Imm_ex;
endcase
end
assign MemWriteData_ex=B;
//ALU inst
ALU ALU (
// Outputs
.Result(ALUResult_ex),
.overflow(),
// Inputs
.ALUCode(ALUCode_ex),
.A(ALU_A),
.B(ALU_B)
);
//MUX for RegWriteAddr_ex
reg[4:0] RegWriteAddr_ex;
always@(*)
begin
case(RegDst_ex)
1'b0:RegWriteAddr_ex<=RtAddr_ex;
1'b1:RegWriteAddr_ex<=RdAddr_ex;
endcase
end
endmodule
```
####<center>**Top模块**
```verilog
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
```
###仿真测试
**仿真器中的值**
![Alt text](https://github.com/uniqueufo/Pipeline_MIPS_CPU/blob/master/%E4%BB%BF%E7%9C%9F%E6%B3%A2%E5%BD%A2.PNG)

**memory中的值**
![Alt text](https://github.com/uniqueufo/Pipeline_MIPS_CPU/blob/master/%E5%86%85%E5%AD%98%E5%86%85%E5%AE%B9.PNG)




