`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
// Company: illegal function call
// Engineer: @v9938
// 
// Create Date:    04/21/2021 
// Design Name: ESE GameMaster2 Bank Controller
// Module Name:    ESE_RC755
// Project Name: ESE GameMaster2
// Target Devices: XC9536XL
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision 1.0 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//for Product
`define USE_SW

module ESE_RC755(
	input SLT_CLOCK,				//from MSX Slot
	input SLT_RESETn,				//from MSX Slot
	input SLT_SLTSL,				//from MSX Slot
	input SLT_WEn,					//from MSX Slot
	input SLT_RDn,					//from MSX Slot
    input [15:12] SLT_A,			//from MSX Slot
    input [7:0] SLT_D,				//from MSX Slot
    input SW_ROMenable,				//Setting for ROM enable (H)
    input SW_MRAMenable,			//Setting for MRAM use (L:1Mbit+64KMRAM / H: 4Mbit )
    output [18:13] ROM_BA,			//To Flash ROM / MRAM
    output ROM_WEn,					//To Flash ROM / MRAM
    output ROM_OEn,					//To Flash ROM / MRAM 
    output ROM_CEn,					//To Flash ROM
    output FRAM_CEn					//To MRAM
    );

//	Address Decoder==========================
// BANK REG
// 	Bank 1: 4000h - 5FFFh  Å¶ROM_BA 0000
//	Bank 2: 6000h - 7FFFh
//	Bank 3: 8000h - 9FFFh
//	Bank 4: A000h - BFFFh
// change banks:
//	Bank 1: <none>
//	Bank 2: 6000h - 6FFFh (6000h used)
//	Bank 3: 8000h - 8FFFh (8000h used)
//	Bank 4:	A000h - AFFFh (A000h used)
//	SRAM write: B000h - BFFFh

	wire Bank1Sel,Bank1ControlSel,Bank1FlashControl;
	wire Bank2Sel,Bank2ControlSel;
	wire Bank3Sel,Bank3ControlSel;
	wire Bank4Sel,Bank4ControlSel,Bank4RamSel;
	wire SltControl;

	assign Bank1Sel			= (SLT_A[15:13]==3'b010);
	assign Bank2Sel 		= (SLT_A[15:13]==3'b011);
	assign Bank3Sel 		= (SLT_A[15:13]==3'b100);
	assign Bank4Sel 		= (SLT_A[15:13]==3'b101);
	
	assign Bank1ControlSel 	= (SLT_A[15:12]==4'b0100);
	assign Bank2ControlSel 	= (SLT_A[15:12]==4'b0110);
	assign Bank3ControlSel 	= (SLT_A[15:12]==4'b1000);
	assign Bank4ControlSel 	= (SLT_A[15:12]==4'b1010);
	assign Bank4RamSel 		= (SLT_A[15:12]==4'b1011);

//	Slot control==========================

	`ifdef USE_SW
	assign SltControl	= (SW_ROMenable) ? SLT_SLTSL : 1'b1;
	`else
	assign SltControl	= SLT_SLTSL;
	`endif
	
//	Bank Control ==========================
//	bit      |  0 |  1 |  2 |  3 |      4       |  5 | 6 | 7 |
//	function | R0 | R1 | R2 | R3 | 1=SRAM/0=ROM | S0 | X | X |
//If bit 4 is reset, bits 0 - 3 select the ROM page as you would expect them to do. Bits 5 - 7 are ignored now.
//If bit 4 is set, bit 5 selects the SRAM page (first or second 4Kb of the 8Kb). Bits 6 - 7 and bits 0 - 3 are ignored now.

	reg [5:0] Bank2Reg;
	reg [5:0] Bank2RegPre;
	reg [5:0] Bank3Reg;
	reg [5:0] Bank4Reg;
	reg FlashControlEnable;

	wire BankControlWrn;
	assign BankControlWrn	= ~(SLT_WEn |SltControl);


	always @(posedge SLT_CLOCK or negedge SLT_RESETn) begin
		if (!SLT_RESETn) begin
//			Bank1Reg <= 6'b00_0000;
			Bank2Reg 	<= 6'b00_0001;
			Bank2RegPre <= 6'b00_0001;
			Bank3Reg 	<= 6'b00_0010;
			Bank4Reg 	<= 6'b00_0011;
			FlashControlEnable <= 1'b0;
		end
		else begin
		// Bank2 Delay:
		// BANK2 area will be used by Flash programming. 
		// If BANK2 switchs at the same time as programming, Flash Address hold time short.
		// Therefore, it is delayed by 1clock.

			Bank2Reg[5:0] <= Bank2RegPre[5:0];
			if (BankControlWrn & Bank2ControlSel) Bank2RegPre 	<= SLT_D[5:0];
			if (BankControlWrn & Bank3ControlSel) Bank3Reg	 	<= SLT_D[5:0];
			if (BankControlWrn & Bank4ControlSel) Bank4Reg 		<= SLT_D[5:0];
			if (BankControlWrn & Bank4ControlSel) FlashControlEnable <= SLT_D[7];
		end
	end

//	Select Bank ==========================
//	Bank 4:	A000h - AFFFh (A000h used) bit7 = 1'b1 Flash Write mode
//  Bank 1: 4000h-4fffh = Flash Address 2000-2fffh (BA1) MSX:4AAAh -> Flash:2AAAh
//  Bank 1: 5000h-5fffh = Flash Address 5000-5fffh (BA2) MSX:5555h -> Flash:5555h
	
	wire [5:0] SelectControlReg;
	wire MRAMControlEnable;

	//Select BankReg
	assign SelectControlReg[5:0] = 	Bank2Sel ? Bank2Reg[5:0] :
									Bank3Sel ? Bank3Reg[5:0] :
									Bank4Sel ? Bank4Reg[5:0] : 
									FlashControlEnable ? (Bank1ControlSel ? 6'b00_0001 : 6'b00_0010) : 6'b00_0000;
	//MRAM enable bit
	`ifdef USE_SW
	assign MRAMControlEnable 	= (SW_MRAMenable) ? 1'b0 : SelectControlReg[4];
	`else
	assign MRAMControlEnable 	= SelectControlReg[4];
	`endif

	//ROM/MRAM Address 
	wire RomAddressEn;

	assign RomAddressEn  = 		~(Bank1Sel | Bank2Sel | Bank3Sel | Bank4Sel);
	assign ROM_BA[16:13] =		(MRAMControlEnable == 1'b0) ? SelectControlReg[3:0] 	: {3'b000,SelectControlReg[5]};
	assign ROM_BA[18:17] =		SelectControlReg[5:4];

	// Maek ROM Conrol
    assign ROM_WEn =			SLT_WEn;
    assign ROM_OEn =			SLT_RDn | RomAddressEn;
    assign ROM_CEn =			SltControl | RomAddressEn | ~(MRAMControlEnable == 1'b0);
    assign FRAM_CEn =			SltControl | ~Bank4RamSel | ~(MRAMControlEnable == 1'b1);

endmodule
