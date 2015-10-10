LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY Control IS
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

		State		: out Std_Logic_Vector(3 downto 0)

);
END Control;

ARCHITECTURE comportamiento OF Control IS

	COMPONENT ctrl_fsm
	port (
		Clk		: in Std_Logic;
		Reset		: in Std_Logic;
		Opcode		: in Std_Logic_Vector(5 downto 0);
		IorD		: out Std_Logic;
		IRWrite		: out Std_Logic;
		RegDst		: out Std_Logic;
		MemtoReg	: out Std_Logic;
		RegWrite	: out Std_Logic;
		ALUSrcA		: out Std_Logic;
		ALUSrcB		: out Std_Logic_Vector(1 downto 0);
		ALUOp		: out Std_Logic_Vector(1 downto 0);
		PCSrc		: out Std_Logic_Vector(1 downto 0);
		PCWrite		: out Std_Logic;
		Branch		: out Std_Logic;		
		MemWrite	: out Std_Logic;
		State		: out Std_Logic_Vector(3 downto 0));
	END COMPONENT;

	COMPONENT ctrl_aludec
	PORT( 
	  Funct			: IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
	  ALUOp			: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
	  ALUControl		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
	END COMPONENT;
	
Signal t_ALUOp	: std_logic_vector(1 DOWNTO 0);

BEGIN
Ctrl_ppal	: ctrl_fsm PORT MAP(clk,Reset,OpCode,IorD,IRWrite,RegDst,MemtoReg,RegWrite,ALUSrcA,
				ALUSrcB,t_ALUOp,PCSrc,PCWrite,Branch,MemWrite,State);
ctrl_alu	: ctrl_aludec PORT MAP(Func, t_ALUOp,ALUControl);

END comportamiento;