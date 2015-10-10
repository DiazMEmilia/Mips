LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_arith.ALL;

-- Camino de datos del MIPS Multiciclo
-- Autores:
--	Diaz María Emilia
--	Rojas Villegas Andrés Sebastián
--	Torres Marcelo Alejandro

ENTITY mips IS
PORT(
	CLOCK	: IN STD_LOGIC;
	CLOCK2  : IN STD_LOGIC;
	Reset	: IN STD_LOGIC;
----------------------------------------------------------------
	xRD	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	xWD	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	xAdr	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
	xMemWrite: OUT STD_LOGIC;
----------------------------------------------------------------
	xIorD, IRWrite:		out  STD_LOGIC;
	xInstrOp, xInstrFunc:	out STD_LOGIC_VECTOR(5 downto 0);
	xRegDst, xMemtoReg:	out  STD_LOGIC;
	xRegWrite, xALUSrcA:	out  STD_LOGIC;
	xALUZero:		out STD_LOGIC;
	xPCSrc:			out  STD_LOGIC_VECTOR(1 downto 0);
	xPCEn:			out  STD_LOGIC;
	xALUControl:		out  STD_LOGIC_VECTOR(2 downto 0);
	xALUSrcB:		out  STD_LOGIC_VECTOR(1 downto 0);
	Estado  : 		OUT STD_LOGIC_VECTOR (3 DOWNTO 0));
END mips;


architecture estructura OF mips IS

	COMPONENT datapath
	PORT( 
		Clk, Reset:		in  STD_LOGIC;
		-- pins a memoria externa
		ReadData:		in  STD_LOGIC_VECTOR(31 downto 0);
		WriteData:		out STD_LOGIC_VECTOR(31 downto 0);
		MemAdr:			out STD_LOGIC_VECTOR(31 downto 0);
		
		-- pins de control
		IorD, IRWrite:		in  STD_LOGIC;
		InstrOp, InstrFunc:	out STD_LOGIC_VECTOR(5 downto 0);
		RegDst, MemtoReg:	in  STD_LOGIC;
		RegWrite, ALUSrcA:	in  STD_LOGIC;
		ALUZero:		out STD_LOGIC;
		PCSrc:			in  STD_LOGIC_VECTOR(1 downto 0);
		PCEn:			in  STD_LOGIC;
		ALUControl:		in  STD_LOGIC_VECTOR(2 downto 0);
		ALUSrcB:		in  STD_LOGIC_VECTOR(1 downto 0));
	END COMPONENT;

	COMPONENT control
	PORT(
		Clk		: in Std_Logic;
		Reset		: in Std_Logic;
		OpCode		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		Func		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		ALUControl	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		
--Seleccion de Mux (Control Principal FSM)
		
		MemtoReg	: out Std_Logic;
		RegDst		: out Std_Logic;
		IorD		: out Std_Logic;
		PCSrc		: out Std_Logic_Vector(1 downto 0);
		ALUSrcB		: out Std_Logic_Vector(1 downto 0);
		ALUSrcA		: out Std_Logic;

--Habilitador de Registros (Control Principal FSM)

		IRWrite		: out Std_Logic;
		MemWrite	: out Std_Logic;
		PCWrite		: out Std_Logic;
		Branch		: out Std_Logic;
		RegWrite	: out Std_Logic;

		State		: out Std_Logic_Vector(3 downto 0));
	END COMPONENT;

	COMPONENT memoria
	PORT( 
		CLK, WE      	: in STD_LOGIC;
	  	Adr		: in STD_LOGIC_VECTOR(31 downto 0);
	  	WD           	: in STD_LOGIC_VECTOR(31 downto 0);
	  	RD      	: out STD_LOGIC_VECTOR(31 downto 0));
	END COMPONENT;

	COMPONENT and2
	PORT(
	  i0	: IN STD_LOGIC;
	  i1	: IN STD_LOGIC;
	  q	: OUT STD_LOGIC);
	end component;
	
	Component or2 
	PORT(
	  i0	: IN STD_LOGIC;
	  i1	: IN STD_LOGIC;
	  q	: OUT STD_LOGIC);
	end component;
	
	SIGNAL SPCEn,SIorD,SIRWrite,SRegDst,SMemtoReg,SRegWrite,SALUSrcA : STD_LOGIC;
	SIGNAL SPCWrite,SBranch,SALUZero,temp1,WEmemo:	STD_LOGIC;
	SIGNAL SALUSrcB,SALUOp,SPCSrcMux : STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL RDmemo,WDmemo,Adrmemo : STD_LOGIC_VECTOR (31 DOWNTO 0);
	--SIGNAL SState : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL SInstrFunc,SInstrOp :  STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL SALUControl : STD_LOGIC_VECTOR (2 DOWNTO 0);
	

BEGIN

--SPCEn <= (SPCWrite OR (SBranch AND SALUZero));
compOr		: or2 port map(SPCWrite,temp1, SPCEn);

compAnd		: and2 port map(SBranch,SALUZero,temp1);		

dp_completo	: datapath port map(CLOCK,Reset,RDmemo,WDmemo,Adrmemo,SIorD,SIRWrite,SInstrOp,SInstrFunc,SRegDst,SMemtoReg,
			SRegWrite,SALUSrcA,SALUZero,SPCSrcMux,SPCEn,SALUControl,SALUSrcB);

control_ppal 	: control port map(CLOCK2,Reset,SInstrOp,SInstrFunc,SALUControl,SMemtoReg,SRegDst,SIorD,
			SPCSrcMux,SALUSrcB,SALUSrcA,SIRWrite,WEmemo,SPCWrite,SBranch,SRegWrite,Estado);

memo		: memoria port map(CLOCK,WEmemo,Adrmemo,WDmemo,RDmemo);

xIorD 		<= SIorD; 
IRWrite		<= SIRWrite;	
xInstrOp 	<= SInstrOp;
xInstrFunc 	<= SInstrFunc;	
xRegDst		<= SRegDst;
xMemtoReg	<= SMemtoReg;	
xRegWrite	<= SRegWrite; 
xALUSrcA	<= SALUSrcA;	
xALUZero	<= SALUZero;		
xPCSrc		<= SPCSrcMux;
xPCEn		<= SPCEn;
xALUControl	<= SALUControl;		
xALUSrcB	<= SALUSrcB;
xRD		<= RDmemo;
xWD		<= WDmemo;
xAdr		<= Adrmemo;
xMemWrite	<= WEmemo;
	
END;
