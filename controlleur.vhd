--========================= controlleur.vhd ============================
-- ELE-344 Conception et architecture de processeurs
-- ÉTÉ 2024, Ecole de technologie superieure
-- Auteur : pascal dubé et raphaêl tazbaz
-- Date:2024-07-12
-- =============================================================
-- Description: controlleur
--						contient le décodeur principal des instruction
--						et le décodeur des opérations de l'ual
-- =============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_misc.ALL;


ENTITY controlleur IS
  PORT (	--entres et sorties telles que specifiees dans l'enonce
        OP 			: in std_logic_vector(5 DOWNTO 0);
		Funct 		: in std_logic_vector(5 DOWNTO 0);
		regWrite	: out std_logic;
        regDst		: out std_logic;
		ALUSrc		: out std_logic;
        branch		: out std_logic;
        memRead		: out std_logic;
        memWrite	: out std_logic;
        memToReg	: out std_logic;
        jump		: out std_logic;
		ALUControl	: out std_logic_vector (3 DOWNTO 0));
END controlleur;


architecture control of controlleur IS
--signal interne qui relier le decodeur principal a alucon
	SIGNAL aluOP : std_logic_vector (1 DOWNTO 0);

begin

	--decodeur principal
	principal : process (OP)
		begin

			if (OP = "100011") THEN 	--LW
				regWrite <= '1';
				regDst <= '0';
				ALUSrc <= '1';
				branch <= '0';
				memRead <= '1';
				memWrite <= '0';
				memToReg <= '1';
				aluOP <= "00";
				jump <= '0';
			elsif (OP = "101011") THEN --SW
				regWrite <= '0';
				regDst <= '-';
				ALUSrc <= '1';
				branch <= '0';
				memRead <= '0';
				memWrite <= '1';
				memToReg <= '-';
				aluOP <= "00";
				jump <= '0';
			elsif (OP = "000100") THEN --BEQ
				regWrite <= '0';
				regDst <= '-';
				ALUSrc <= '0';
				branch <= '1';
				memRead <= '0';
				memWrite <= '0';
				memToReg <= '-';
				aluOP <= "01";
				jump <= '0';
			elsif (OP = "001000") THEN --ADDI
				regWrite <= '1';
				regDst <= '0';
				ALUSrc <= '1';
				branch <= '0';
				memRead <= '0';
				memWrite <= '0';
				memToReg <= '0';
				aluOP <= "00";
				jump <= '0';
			elsif (OP = "000010") THEN --J
				regWrite <= '0';
				regDst <= '-';
				ALUSrc <= '-';
				branch <= '-';
				memRead <= '0';
				memWrite <= '0';
				memToReg <= '-';
				aluOP <= "--";
				jump <= '1';
			else	 					-- intruction type R
				regWrite <= '1';
				regDst <='1';
				ALUSrc <= '0';
				branch <= '0';
				memRead <= '0';
				memWrite <= '0';
				memToReg <= '0';
				aluOP <= "10";
				jump <= '0';
			end	if;			
	end process principal;

	--decodeur de l'ALU
	alucon : process (aluOP, Funct)
		begin
			if	(aluOP = "00") then		--add
				aluControl <= "0010";
			elsif (aluOP = "01") then	--sub
				aluControl <= "0110";
			else						--instruction type R, verifier le champ Funct	
				if(Funct = "100000") then 		--add
						aluControl <= "0010";
					elsif (Funct = "100010") then 	--sub
						aluControl <= "0110";
					elsif (Funct = "100100") then	--and
						aluControl <= "0000";
					elsif (Funct = "100101") then	--or
						aluControl <= "0001";
					else							--slt
						aluControl <= "0111";
				end if;
				
			end if;
	end process alucon;
	
end control;
