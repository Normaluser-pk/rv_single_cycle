`include "program_counter.v"
`include "instruction_memory.v"
`include "register_file.v"
`include "sign_extend.v"
`include "alu.v"
`include "control_unit_top.v"
`include "data_memory.v"
`include "pc_adder.v"
`include "mux.v"

module single_cycle_top(clk,rst);

    input clk,rst;

    wire [31:0] PC_Top,RD_Instr,RD1_Top,Imm_Ext_Top,ALUResult,ReadData,PCPlus4,RD2_Top,SrcB,Result;
    wire RegWrite,MemWrite,ALUSrc,ResultSrc;
    wire [1:0]ImmSrc;
    wire [2:0]ALUControl_Top;

    pc_module program_counter(
        .clk(clk),
        .rst(rst),
        .PC(PC_Top),
        .PC_Next(PCPlus4)
    );

    pc_adder pc_adder(
                    .a(PC_Top),
                    .b(32'd4),
                    .c(PCPlus4)
    );
    
    instruction_memory instruction_memory(
                            .rst(rst),
                            .A(PC_Top),
                            .RD(RD_Instr)
    );

    register_file register_file(
                            .clk(clk),
                            .rst(rst),
                            .WE3(RegWrite),
                            .WD3(Result),
                            .A1(RD_Instr[19:15]),
                            .A2(RD_Instr[24:20]),
                            .A3(RD_Instr[11:7]),
                            .RD1(RD1_Top),
                            .RD2(RD2_Top)
    );

    sign_extend sign_extend(
                        .In(RD_Instr),
                        .ImmSrc(ImmSrc[0]),
                        .Imm_Ext(Imm_Ext_Top)
    );

    mux mux_register_to_alu(
                            .a(RD2_Top),
                            .b(Imm_Ext_Top),
                            .s(ALUSrc),
                            .c(SrcB)
    );

    alu alu(
            .A(RD1_Top),
            .B(SrcB),
            .Result(ALUResult),
            .ALUControl(ALUControl_Top),
            .OverFlow(),
            .Carry(),
            .Zero(),
            .Negative()
    );

    control_unit_top control_unit_top(
                            .Op(RD_Instr[6:0]),
                            .RegWrite(RegWrite),
                            .ImmSrc(ImmSrc),
                            .ALUSrc(ALUSrc),
                            .MemWrite(MemWrite),
                            .ResultSrc(ResultSrc),
                            .Branch(),
                            .funct3(RD_Instr[14:12]),
                            .funct7(RD_Instr[6:0]),
                            .ALUControl(ALUControl_Top)
    );

    data_memory data_memory(
                        .clk(clk),
                        .rst(rst),
                        .WE(MemWrite),
                        .WD(RD2_Top),
                        .A(ALUResult),
                        .RD(ReadData)
    );

    mux mux_datamemory_to_register(
                            .a(ALUResult),
                            .b(ReadData),
                            .s(ResultSrc),
                            .c(Result)
    );

endmodule