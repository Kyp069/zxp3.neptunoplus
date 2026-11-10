`default_nettype none
//-------------------------------------------------------------------------------------------------
// This file is part of the ZX Spectrum +3 project for neptuno+ board.
// https://github.com/kyp069/zxp3.neptunoplus
//-------------------------------------------------------------------------------------------------
module npp
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,

	output wire[ 1:0] led,

	output wire       dramCk,
	output wire       dramCe,
	output wire       dramCs,
	output wire       dramWe,
	output wire       dramRas,
	output wire       dramCas,
	output wire[ 1:0] dramDQM,
	inout  wire[15:0] dramDQ,
	output wire[ 1:0] dramBA,
	output wire[12:0] dramA,

	output wire[ 1:0] sync,
	output wire[23:0] rgb,

	input  wire       tape,

	output wire       i2sCk,
	output wire       i2sWs,
	output wire       i2sQ,

	output wire       midi,
	input  wire       midiCk,
	input  wire       midiWs,
	input  wire       midiD,

	output wire       joyCk,
	output wire       joyLd,
	input  wire       joyD,

	input  wire       mbjoyCk,
	input  wire       mbjoyLd,
	output wire       mbjoyQ,

	input  wire       spiCk,
	input  wire       spiSs1,
	input  wire       spiSs2,
	input  wire       spiSs3,
	input  wire       spiMosi,
	output wire       spiMiso
);
//--- clock ---------------------------------------------------------------------------------------

	wire clockga, powerga;
	pll pll(clock50, clockga, powerga); // 56.7504 MHz

	wire clockula, powerula;
	pll1 pll1(clock50, clockula, powerula); // 56.0000 MHz

	wire clock = timing ? clockula : clockga;
	wire power = powerga && powerula;

	reg[3:0] ce;
	always @(negedge clock, negedge power) if(!power) ce <= 1'd0; else ce <= ce+1'd1;

	wire ne7M0 = ce[2:0] == 7;
	wire pe7M0 = ce[2:0] == 3;
	wire ne3M5 = ce[3:0] == 15;
	wire pe3M5 = ce[3:0] == 7;

//--- video ---------------------------------------------------------------------------------------

	wire r;
	wire g;
	wire b;
	wire i;
	wire hsync;
	wire vsync;

//--- audio ---------------------------------------------------------------------------------------

	wire[15:0] lmidi;
	wire[15:0] rmidi;

	i2s_decoder i2s_decoder(clock, lmidi, rmidi, midiCk, midiWs, midiD);

	wire[14:0] left;
	wire[14:0] right;

	wire[15:0] lmix = { 1'b0, lmidi[15:1] }^16'h4000+{ 1'd0,  left }+{ 4'd0, {12{ status[3] && ear}} };
	wire[15:0] rmix = { 1'b0, rmidi[15:1] }^16'h4000+{ 1'd0, right }+{ 4'd0, {12{ status[3] && ear}} };

	i2s i2s(clock, lmix, rmix, i2sCk, i2sWs, i2sQ);

//--- midi ----------------------------------------------------------------------------------------

	wire[7:0] midiQ;
	wire      midiS;

	serial_packer #(.CLK_SYS_HZ(56000000)) midi_packer(clock, midi, midiQ, midiS);

//--- mist ----------------------------------------------------------------------------------------

	wire[63:0] status;

	wire ps2kCk;
	wire ps2kD;

	wire[ 7:0] joy1;
	wire[ 7:0] joy2;

	wire[ 2:0] mbtns;
	wire[ 7:0] xaxis;
	wire[ 7:0] yaxis;

	wire       dioEn;
	wire[ 7:0] dioIx;
	wire[31:0] dioSz;
	wire[26:0] dioA;
	wire[ 7:0] dioD;
	wire       dioW;

	wire sdcCs;
	wire sdcCk;
	wire sdcMosi;
	wire sdcMiso;

	wire       fddCe;
	wire       fddRd;
	wire       fddWr;
	wire       fddA;
	wire[ 7:0] fddD;
	wire[ 7:0] fddQ;
	wire       fddMtr;

	wire       tapeBusy;
	wire       tapeEar;

	mist #(.RGBW(8)) mist
	(
		.clock  (clock  ),
		.power  (power  ),
		.spiCk  (spiCk  ),
		.spiSs1 (spiSs1 ),
		.spiSs2 (spiSs2 ),
		.spiSs3 (spiSs3 ),
		.spiMosi(spiMosi),
		.spiMiso(spiMiso),
		.status (status ),
		.r      (r      ),
		.g      (g      ),
		.b      (b      ),
		.i      (i      ),
		.hsync  (hsync  ),
		.vsync  (vsync  ),
		.rgb    (rgb    ),
		.sync   (sync   ),
		.midiQ  (midiQ  ),
		.midiS  (midiS  ),
		.ps2kCk (ps2kCk ),
		.ps2kD  (ps2kD  ),
		.joy1   (joy1   ),
		.joy2   (joy2   ),
		.mbtns  (mbtns  ),
		.xaxis  (xaxis  ),
		.yaxis  (yaxis  ),
		.dioEn  (dioEn  ),
		.dioIx  (dioIx  ),
		.dioSz  (dioSz  ),
		.dioA   (dioA   ),
		.dioD   (dioD   ),
		.dioW   (dioW   ),
		.sdcCs  (sdcCs  ),
		.sdcCk  (sdcCk  ),
		.sdcMosi(sdcMosi),
		.sdcMiso(sdcMiso),
		.fddCe  (fddCe  ),
		.fddRd  (fddRd  ),
		.fddWr  (fddWr  ),
		.fddA   (fddA   ),
		.fddD   (fddD   ),
		.fddQ   (fddQ   ),
		.fddMtr (fddMtr ),
		.tapePlay(~play ),
		.tapeStop(~stop ),
		.tapeBusy(tapeBusy),
		.tapeEar (tapeEar)
	);

//--- keyboard ------------------------------------------------------------------------------------

	wire      strb;
	wire[7:0] code;

	ps2k ps2k(clock, ps2kCk, ps2kD, strb, code);

	wire[7:0] row;
	wire[4:0] col;
	wire play;
	wire stop;
	wire F5;
	wire F9;

	matrix matrix(clock, strb, code, ~joy1[4:0], ~joy2[4:0], row, col, play, stop, F5, F9);

//--- memory --------------------------------------------------------------------------------------

	wire ready; // = 1'b1;
	wire rfsh;

	wire[13:0] a1;
	wire[ 7:0] q1 = dioEn ? 8'h00 : dprQ;
	wire       w1;

	wire[18:0] a2;
	wire[ 7:0] d2;
	wire[ 7:0] q2 = sdrQ[7:0]; // a2[18:17] == 2 ? ramQ2 : a2[18:17] == 1 ? ramQ1 : romQ; //
	wire       r2;
	wire       w2;

	// wire[7:0] romQ;
	// ram #(128) rom(clock, dioEn ? dioA[16:0] : a2[16:0], dioD, romQ, dioEn && dioW);

	// wire[7:0] ramQ1;
	// ram #(128) ram1(clock, a2[16:0], d2, ramQ1, w2 && a2[18:17] == 1);

	// wire[7:0] ramQ2;
	// ram #(128) ram2(clock, a2[16:0], d2, ramQ2, w2 && a2[18:17] == 2);

	wire[7:0] dprQ;
	dprs #(16) drp(clock, a1, dprQ, clock, { a2[15], a2[12:0] }, d2, w1);

	reg r2p;
	always @(posedge clock, negedge reset) if(!reset) r2p <= 1'b0; else if(pe3M5) r2p <= r2;

	wire[23:0] sdrA = { 5'd0, dioEn ? dioA[18:0] : a2 };
	wire[15:0] sdrD = { 8'hFF, dioEn ? dioD : d2 };
	wire[15:0] sdrQ;
	wire       sdrR = r2p;
	wire       sdrW = dioEn ? dioW : w2;

	sdram sdram
	(
		.clock  (clock  ),
		.ready  (ready  ),
		.rfsh   (rfsh   ),
		.a      (sdrA   ),
		.d      (sdrD   ),
		.q      (sdrQ   ),
		.rd     (sdrR   ),
		.wr     (sdrW   ),
		.dramCe (dramCe ),
		.dramCs (dramCs ),
		.dramRas(dramRas),
		.dramCas(dramCas),
		.dramWe (dramWe ),
		.dramDQM(dramDQM),
		.dramDQ (dramDQ ),
		.dramBA (dramBA ),
		.dramA  (dramA  )
	);
	assign dramCk = clock;

//--- zxp3 ----------------------------------------------------------------------------------------

	wire divmmc = !status[2];
	wire timing = status[5];

	wire reset = power && ready && F9 && !status[0] && !dioEn;
	wire nmi = F5 && !status[1];

	wire ear = tapeBusy ? tapeEar : ~tape;

	zxp3 zxp3
	(
		.divmmc (divmmc ),
		.timing (timing ),
		.clock  (clock  ),
		.ne7M0  (ne7M0  ),
		.pe7M0  (pe7M0  ),
		.ne3M5  (ne3M5  ),
		.pe3M5  (pe3M5  ),
		.reset  (reset  ),
		.rfsh   (rfsh   ),
		.nmi    (nmi    ),
		.a1     (a1     ),
		.q1     (q1     ),
		.w1     (w1     ),
		.a2     (a2     ),
		.d2     (d2     ),
		.q2     (q2     ),
		.r2     (r2     ),
		.w2     (w2     ),
		.r      (r      ),
		.g      (g      ),
		.b      (b      ),
		.i      (i      ),
		.hsync  (hsync  ),
		.vsync  (vsync  ),
		.ear    (ear    ),
		.midi   (midi   ),
		.left   (left   ),
		.right  (right  ),
		.col    (col    ),
		.row    (row    ),
		.joy1   (joy1   ),
		.joy2   (joy2   ),
		.mbtns  (mbtns  ),
		.xaxis  (xaxis  ),
		.yaxis  (yaxis  ),
		.fddCe  (fddCe  ),
		.fddRd  (fddRd  ),
		.fddWr  (fddWr  ),
		.fddA   (fddA   ),
		.fddD   (fddD   ),
		.fddQ   (fddQ   ),
		.fddMtr (fddMtr ),
		.sdcCs  (sdcCs  ),
		.sdcCk  (sdcCk  ),
		.sdcMosi(sdcMosi),
		.sdcMiso(sdcMiso)
	);

//-------------------------------------------------------------------------------------------------

	assign led = {2{ reset }};

	assign joyCk = mbjoyCk;
	assign joyLd = mbjoyLd;
	assign mbjoyQ = joyD;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
