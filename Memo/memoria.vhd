library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
-- Camino de datos del MIPS Multiciclo
-- Autores:
--	Diaz María Emilia
--	Rojas Villegas Andrés Sebastián
--	Torres Marcelo Alejandro

entity memoria is
port( 
	CLK 	: in STD_LOGIC;
	WE      : in STD_LOGIC;
	Adr	: in STD_LOGIC_VECTOR(31 downto 0);
	WD      : in STD_LOGIC_VECTOR(31 downto 0);
	RD      : out STD_LOGIC_VECTOR(31 downto 0));
end memoria;


architecture behave of memoria is
	type ramtype is array (5 downto 0) of STD_LOGIC_VECTOR (31 downto 0);
	signal registers: ramtype;

begin
	process( CLK ) begin
		if rising_edge(CLK) and WE = '1' then
            			registers( Adr(7 downto 2) ) <= WD;
        	end if;
    	end process;
    
    	process( Adr, registers ) begin  
        
	case Adr(7 downto 2) is
		when "000000" => RD <= X"20030000"; --00000000 		    addi r3,zero,0		        r3 <- 0
		when "000001" => RD <= X"20040007"; --00000004 		    addi r4,zero,7 			r4 <- 7			
		when "000010" => RD <= X"20050005"; --00000008 		    addi r5,zero,5			r5 <- 2
		when "000011" => RD <= X"10A00003"; --0000000C 	loop:	    beq  r5,zero,mostrar(0000001C)      if(r5 == 0) goto(mostrar)
		when "000100" => RD <= X"00641820"; --00000010 		    add  r3,r3,r4,func 			else r3 <- r3 + r4
		when "000101" => RD <= X"20A5FFFF"; --00000014 		    addi r5,r5,-1			r5 <- r5 - 1
		when "000110" => RD <= X"08000003"; --00000018 	goto loop:  j    0000000C			goto(loop)
		when "000111" => RD <= X"AC0300AC"; --0000001C	mostrar:    sw   r3,mem(00000020)		return r3
		when others => RD <= registers(adr(7 downto 2));
	end case;

	end process;
end;