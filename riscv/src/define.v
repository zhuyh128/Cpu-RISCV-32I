`ifndef __DEFINES__
`define __DEFINES__

`define Opcode_Interval     6:0
`define Opcode_Width        7
`define Rs1_Interval        19:15
`define Rs2_Interval        24:20
`define Rd_Interval         11:7
`define Reg_Width           5
`define Reg_Cnt             32
`define Func3_Interval      14:12
`define Func7_Interval      31:25
`define Imm_Interval        31:20
`define Jmm_Interval        31:12

`define Class_Opcode_NOP    7'b0000000
`define Op_Imm              7'b0010011
`define Op_                 7'b0110011
`define LUI_                7'b0110111
`define AUIPC_              7'b0010111
`define JAL_                7'b1101111
`define JALR_               7'b1100111
`define BRANCH_             7'b1100011
`define Store_              7'b0100011
`define Load_               7'b0000011

`define EXE_NOP_OP   5'b00000
`define EXE_AND_OP   5'b00001
`define EXE_OR_OP    5'b00010
`define EXE_XOR_OP   5'b00011

`define EXE_SLL_OP   5'b00100
`define EXE_SRL_OP   5'b00101
`define EXE_SRA_OP   5'b00110

`define EXE_ADD_OP   5'b00111
`define EXE_SLT_OP   5'b01000
`define EXE_SLTU_OP  5'b01001
`define EXE_SUB_OP   5'b01010

`define EXE_JAL_OP   5'b01011
`define EXE_JALR_OP  5'b01100
`define EXE_BEQ_OP   5'b01101
`define EXE_BNE_OP   5'b01110
`define EXE_BLT_OP   5'b01111
`define EXE_BGE_OP   5'b10000
`define EXE_BLTU_OP  5'b10001
`define EXE_BGEU_OP  5'b10010

`define EXE_LB_OP  	 5'b10011
`define EXE_LH_OP  	 5'b10100
`define EXE_LW_OP  	 5'b10101
`define EXE_LBU_OP 	 5'b10110
`define EXE_LHU_OP 	 5'b10111
`define EXE_SB_OP  	 5'b11000
`define EXE_SH_OP  	 5'b11001
`define EXE_SW_OP  	 5'b11010

`define EXE_LUI_OP   5'b11011
`define EXE_AUIPC_OP 5'b11100

`define FUNCT3_BEQ   3'b000
`define FUNCT3_BNE   3'b001
`define FUNCT3_BLT   3'b100
`define FUNCT3_BGE   3'b101
`define FUNCT3_BLTU  3'b110
`define FUNCT3_BGEU  3'b111

`define FUNCT3_LB    3'b000
`define FUNCT3_LH    3'b001
`define FUNCT3_LW    3'b010
`define FUNCT3_LBU   3'b100
`define FUNCT3_LHU   3'b101 

`define FUNCT3_SB    3'b000
`define FUNCT3_SH    3'b001
`define FUNCT3_SW    3'b010

`define FUNCT3_ADDI  3'b000
`define FUNCT3_SLTI  3'b010
`define FUNCT3_SLTIU 3'b011
`define FUNCT3_ANDI  3'b111
`define FUNCT3_ORI   3'b110
`define FUNCT3_XORI  3'b100
`define FUNCT3_SLLI  3'b001
`define FUNCT3_SRLI  3'b101
`define FUNCT3_SRAI  3'b101

`define FUNCT3_ADD   3'b000
`define FUNCT3_SLT   3'b010
`define FUNCT3_SLTU  3'b011
`define FUNCT3_AND   3'b111
`define FUNCT3_OR    3'b110
`define FUNCT3_XOR   3'b100
`define FUNCT3_SLL   3'b001
`define FUNCT3_SRL   3'b101
`define FUNCT3_SUB   3'b000
`define FUNCT3_SRA   3'b101

`define FUNCT7_SRLI  7'b0000000
`define FUNCT7_SRAI  7'b0100000
`define FUNCT7_SRL   7'b0000000
`define FUNCT7_SRA   7'b0100000
`define FUNCT7_ADD   7'b0000000
`define FUNCT7_SUB   7'b0100000

`define aluOpBus       7:0
`define aluInstTypeBus 2:0

`define max4		   4'hf
`define max32		   32'hffffffff

`define RegAddrBus     4:0
`define RegBus         31:0
`define RegCnt         32
`define RegStatusCnt   2:0
`define RegWidth       32
`define RegNum         32
`define RegBusWidth    5

`define ExecBus	   	   4:0
`define StallBus       6:0

`define OpCodeBus      6:0
`define funct7Bus      6:0
`define funct3Bus      2:0
`define immNumBus      31:0

`define MemAddrBus	   31:0
`define ByteBus		   7:0
`define TrueAddrBus	   16:0
`define MemDataType    2:0
`define MEM_BYTE	   3'b000
`define MEM_HALF	   3'b001
`define MEM_WORD	   3'b010
`define MEM_BU		   3'b100
`define MEM_HU		   3'b101

`endif


