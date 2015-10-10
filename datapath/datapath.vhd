library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

-- Camino de datos del MIPS Multiciclo
-- Autores:
--	Diaz María Emilia
--	Rojas Villegas Andrés Sebastián
--	Torres Marcelo Alejandro


entity datapath is
	port( 	Clk, Reset:		in  STD_LOGIC;

		-- external mem pins
		ReadData:		in  STD_LOGIC_VECTOR(31 downto 0);
		WriteData : 		out STD_LOGIC_VECTOR(31 downto 0);
		MemAdr:			out STD_LOGIC_VECTOR(31 downto 0);
		
		-- control pins
		IorD : 			in  STD_LOGIC;
		IRWrite:		in  STD_LOGIC;
		InstrOp:		out STD_LOGIC_VECTOR(5 downto 0);
		InstrFunc:		out STD_LOGIC_VECTOR(5 downto 0);
		RegDst :		in  STD_LOGIC;
		MemtoReg:		in  STD_LOGIC;
		RegWrite : 		in  STD_LOGIC;
		ALUSrcA:		in  STD_LOGIC;
		ALUZero:		out STD_LOGIC;
		PCEn:			in  STD_LOGIC;
		PCSrc:			in  STD_LOGIC_VECTOR(1 downto 0);
		ALUControl:		in  STD_LOGIC_VECTOR(2 downto 0);
		ALUSrcB:		in  STD_LOGIC_VECTOR(1 downto 0));
end datapath;

architecture struct of datapath is

	component alu
		port( a, b     : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
			  ctrl     : in  STD_LOGIC_VECTOR( 2 DOWNTO 0);
			  res      : out STD_LOGIC_VECTOR(31 DOWNTO 0);
			  zero     : out STD_LOGIC);
	end component;
	
	component mux2
		port( d0, d1 : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
			  s      : in  STD_LOGIC;
			  y      : out STD_LOGIC_VECTOR(31 DOWNTO 0));
	end component;
	
	component mux2_5b
		port( d0, d1 : in  STD_LOGIC_VECTOR(4 DOWNTO 0);
			  s      : in  STD_LOGIC;
			  y      : out STD_LOGIC_VECTOR(4 DOWNTO 0));
	end component;
	
	component mux4
		port( d0, d1 : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
			  d2, d3 : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
			  s      : in  STD_LOGIC_VECTOR( 1 DOWNTO 0);
			  y      : out STD_LOGIC_VECTOR(31 DOWNTO 0));
	end component;
	
	component reg
		port( clk, rst:	in STD_LOGIC;
			  en: 		in STD_LOGIC;
			  d:		in STD_LOGIC_VECTOR(31 downto 0);
			  q:		out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	
	component regfile
		port( clk, we3      : in STD_LOGIC;
			  a1, a2, a3    : in STD_LOGIC_VECTOR(4 downto 0);
			  wd3           : in STD_LOGIC_VECTOR(31 downto 0);
			  rd1, rd2      : out STD_LOGIC_VECTOR(31 downto 0));
	end component;
	
	component signext
		port( a : in  STD_LOGIC_VECTOR(15 DOWNTO 0);
			  y : out STD_LOGIC_VECTOR(31 DOWNTO 0));
	end component;
	
	component sl2
		port( a : in  STD_LOGIC_VECTOR(31 DOWNTO 0);
			  y : out STD_LOGIC_VECTOR(31 DOWNTO 0));
	end component;

	component sl22
		port( a : in  STD_LOGIC_VECTOR(25 DOWNTO 0);
			  y : out STD_LOGIC_VECTOR(27 DOWNTO 0));
	end component;
	
	signal Instr, Data, RFD1, RFD2: STD_LOGIC_VECTOR(31 downto 0);
	signal RFWD, OpA, OpB, SignImm: STD_LOGIC_VECTOR(31 downto 0); 
	signal SignImmSh, SrcA, SrcB:	STD_LOGIC_VECTOR(31 downto 0);
	signal ALUResult, ALUOut:	STD_LOGIC_VECTOR(31 downto 0);
	signal PCNext, PC, PcJump:	STD_LOGIC_VECTOR(31 downto 0);
	signal RFWA: STD_LOGIC_VECTOR(4 downto 0);
	
begin
		
	-- program counter
	pcreg: reg port map(CLK, Reset, PCEn, PCNext, PC);
	pcmux: mux4 port map(ALUResult, ALUOut, PcJump,,PCSrc, PCNext);
	memadrmux: mux2 port map(PC, ALUOut, IorD, MemAdr);
	
	--para saltar
	shiftsalto: sl22 port map(Instr(25 downto 0), PcJump(27 downto 0));
	 PcJump(31 downto 28) <= PC(31 downto 28);
	
	-- Instr and Data registers
	instrreg: reg port map(CLK, Reset, IRWrite, ReadData, Instr);
	datareg: reg port map(CLK, Reset, '1', ReadData, Data);
	
	--reg file
	rfwamux: mux2_5b port map(Instr(20 downto 16), Instr(15 downto 11), RegDst, RFWA);
	rfwdmux: mux2 port map(ALUOut, Data, MemtoReg, RFWD);
	rf: regfile port map(CLK, RegWrite, Instr(25 downto 21), Instr(20 downto 16), RFWA, RFWD, RFD1, RFD2);
	rfrd1reg: reg port map(CLK, Reset, '1', RFD1, OpA);
	rfrd2reg: reg port map(CLK, Reset, '1', RFD2, OpB);
	
	-- alu
	signext2: signext port map(Instr(15 downto 0), SignImm);
	shift2: sl2 port map(SignImm, SignImmSh);
	srcamux: mux2 port map(PC, OpA, ALUSrcA, SrcA);
	srcbmux: mux4 port map(OpB, X"00000004", SignImm, SignImmSh, ALUSrcB,SrcB);
	alu2: alu port map(SrcA, SrcB, ALUControl, ALUResult, ALUZero);
	alureg: reg port map(CLK, Reset, '1', ALUResult, ALUOut);

	-- out signals
	
	
	InstrOp <= Instr(31 downto 26);
	InstrFunc <= Instr(5 downto 0);
	WriteData <= OpB;

end;