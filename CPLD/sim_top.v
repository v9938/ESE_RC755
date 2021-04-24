
`timescale 1ns / 100ps

// Code write by V9938

module sim_top();
parameter CYC = 145;
reg 		SLT_CLOCK;
reg 		SLT_RESETn;
reg 		SLT_SLTSL;
reg			SLT_WEn;
reg			SLT_RDn;
reg [3:0]	SLT_A;
reg [7:0]	SLT_D;

wire [5:0]	ROM_BA;
wire			ROM_WEn;
wire			ROM_OEn;
wire			FRAM_CEn;
wire			ROM_CEn;

// -----------------------------------------------------------------
task write_task; // writeタスク (addr,data)
input [3:0] addr_task;
input [7:0] data_task;
begin
	#(CYC+25)		SLT_A = addr_task;	//170
	#(CYC+10-25)	SLT_SLTSL = 1'b0;	//130+170 =300
					SLT_RDn = 1'b1;
	#(55)			SLT_D = data_task;	//355=145+210
	#(80+CYC-5)		SLT_WEn = 1'b0;		

	#(CYC+5)		$display("Write Data[%4b]=%8b ====================",SLT_A,SLT_D);
					$display("ROM BA=%5b / ROM WE=%1b / ROM_OE=%1b ",ROM_BA,ROM_WEn,ROM_OEn);
					$display("ROM_CEn=%1b / FRAM_CEn=%1b ",ROM_CEn,FRAM_CEn);
	#(CYC-25)		SLT_WEn = 1'b1;
	#(25+10)		SLT_SLTSL = 1'b1;
	#(CYC-10)		SLT_D = 8'bzzzz_zzzz;
	#(CYC);
end
endtask

task read_task; // readタスク (addr)
input [3:0] addr_task;
input [7:0] data_task;
begin
	#(CYC+25)		SLT_A = addr_task;	//170
	#(CYC+10-25)	SLT_SLTSL = 1'b0;	//130+170 =300
					SLT_RDn = 1'b0;
					SLT_D = data_task;	//355=145+210
	#(55+80+CYC*2)	$display("Read Data[%4b]=%8b ====================",SLT_A,SLT_D);
					$display("ROM BA=%5b / ROM WE=%1b / ROM_OE=%1b ",ROM_BA,ROM_WEn,ROM_OEn);
					$display("ROM_CEn=%1b / FRAM_CEn=%1b ",ROM_CEn,FRAM_CEn);
	#(CYC-25)		SLT_WEn = 1'b1;
	#(25+10)		SLT_SLTSL = 1'b1;
	#(CYC-10)		SLT_D = 8'bzzzz_zzzz;
	#(CYC);
end
endtask
// -----------------------------------------------------------------

initial	begin
	#40 SLT_CLOCK = 1'b1;

	forever begin
		#(CYC) SLT_CLOCK = ~SLT_CLOCK;
	end
	
end
initial begin
	SLT_RESETn = 1'bz;
	#(CYC)	SLT_RESETn = 1'b0;
	#(CYC*2)	SLT_RESETn = 1'b1;
end

initial begin
	#(CYC*5) ;
	write_task (4'h0,8'h00);
	write_task (4'h1,8'h00);
	write_task (4'h2,8'h00);
	write_task (4'h3,8'h00);
	write_task (4'h4,8'h00);
	write_task (4'h5,8'h00);
	write_task (4'h6,8'h00);
	write_task (4'h7,8'h00);
	write_task (4'h8,8'h00);
	write_task (4'h9,8'h00);
	write_task (4'hA,8'h00);
	write_task (4'hB,8'h00);
	write_task (4'hC,8'h00);
	write_task (4'hD,8'h00);
	write_task (4'hE,8'h00);
	write_task (4'hF,8'h00);
	#(CYC*3) ;
	write_task (4'h0,8'h00);
	write_task (4'h1,8'h01);
	write_task (4'h2,8'h02);
	write_task (4'h3,8'h03);
	write_task (4'h4,8'h04);
	write_task (4'h5,8'h05);
	write_task (4'h6,8'h06);
	write_task (4'h7,8'h07);
	write_task (4'h8,8'h08);
	write_task (4'h9,8'h09);
	write_task (4'hA,8'h0A);
	write_task (4'hB,8'h0B);
	write_task (4'hC,8'h0C);
	write_task (4'hD,8'h0D);
	write_task (4'hE,8'h0E);
	write_task (4'hF,8'h0F);
	#(CYC*3) ;
	write_task (4'h4,8'h0B);
	write_task (4'h5,8'h0A);

	write_task (4'h6,8'h09);
	write_task (4'h7,8'h08);

	write_task (4'h8,8'h07);
	write_task (4'h9,8'h06);

	write_task (4'hA,8'h05);
	write_task (4'hB,8'h04);

	#(CYC*3) ;
	//SRAM BANK0
	write_task (4'hA,8'h10);
	write_task (4'hB,8'hAA);

	//SRAM BANK1
	write_task (4'hA,8'h30);
	write_task (4'hB,8'h55);

	//Flash mode
	read_task (4'h4,8'h00);
	read_task (4'h5,8'h11);
	
	write_task (4'hA,8'hFF);
	write_task (4'h4,8'h44);
	write_task (4'h5,8'h55);

	write_task (4'h6,8'h08);
	write_task (4'h6,8'hAA);
	write_task (4'h6,8'h08);
	write_task (4'h6,8'hBB);
	write_task (4'h6,8'h08);
	write_task (4'h6,8'hCC);

	write_task (4'hA,8'h0F);
	$finish;

end




// Instantiate the module
ESE_RC755 instance_name (
    .SLT_CLOCK(SLT_CLOCK), 
    .SLT_RESETn(SLT_RESETn), 
    .SLT_SLTSL(SLT_SLTSL), 
    .SLT_WEn(SLT_WEn), 
    .SLT_RDn(SLT_RDn), 
    .SLT_A(SLT_A), 
    .SLT_D(SLT_D), 
    .SW(1'b01), 
    .ROM_BA(ROM_BA), 
    .ROM_WEn(ROM_WEn), 
    .ROM_OEn(ROM_OEn), 
    .ROM_CEn(ROM_CEn), 
    .FRAM_CEn(FRAM_CEn)
    );


endmodule
