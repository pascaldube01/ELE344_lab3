--========================= controlleur.vhd ============================
-- ELE-344 Conception et architecture de processeurs
-- ÉTÉ 2024, Ecole de technologie superieure
-- Auteur : pascal dubé et raphaêl tazbaz
-- Date:2024-07-12
-- =============================================================
-- Description: controlleur test bench
--						test pour controlleur.vhd
-- =============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_misc.ALL;

ENTITY controlleur_tb IS
end controlleur_tb;


architecture controlleur_test of controlleur_tb is
		--signaux in/out du controlleur
        SIGNAL OP 			: std_logic_vector(5 DOWNTO 0);
		SIGNAL Funct 		: std_logic_vector(5 DOWNTO 0);
        SIGNAL regDst		: std_logic;
        SIGNAL jump			: std_logic;
        SIGNAL branch		: std_logic;
        SIGNAL memRead		: std_logic;
        SIGNAL memToReg		: std_logic;
        SIGNAL memWrite		: std_logic;
		SIGNAL ALUSrc		: std_logic;
		SIGNAL regWrite		: std_logic;
		SIGNAL ALUControl	: std_logic_vector (3 DOWNTO 0);

		signal instruction 	: string(1 TO 4);
		CONSTANT PERIODE : time := 20 ns;



BEGIN
	--instanciation du controlleur et port mappings
	CONTROLLEUR : ENTITY work.controlleur(control)
	PORT MAP (OP, Funct, regWrite, regDst, ALUSrc, branch, memRead, memWrite, memToReg, jump, aluControl);
	
	
	
--signaux de debug pour modelsim
    PROCESS(OP, Funct)
    BEGIN
      CASE OP IS
        WHEN  "100011"  => instruction <= "LW  "; --instruction I
        WHEN  "101011"  => instruction <= "SW  ";
        WHEN  "000100"  => instruction <= "BEQ ";
        WHEN  "001000"  => instruction <= "ADDI";
        WHEN  "000010"  => instruction <= "J   ";
        WHEN OTHERS => 							-- instruction R
        	case Funct is
        		WHEN "100000" => instruction <= "ADD ";
        		WHEN "100010" => instruction <= "SUB ";
        		WHEN "100100" => instruction <= "AND ";
        		WHEN "100101" => instruction <= "OR  ";
        		WHEN "101010" => instruction <= "SLT ";
        		WHEN OTHERS => instruction <= "----";	-- erreure
        	end case;
      END CASE;
    END PROCESS;

  
	
	
	
	
	
	
	
	--on teste chacune des instructions
	test : process
	begin
		--instruction type I
		Funct <= "000000"; --func est seulement utile sur les instructions R

		OP <= "100011"; -- LW
		wait for (PERIODE);
		
		OP <= "101011"; -- SW
		wait for (PERIODE);
		
		OP <= "000100"; -- BEQ
		wait for (PERIODE);

		OP <= "001000"; -- ADDI
		wait for (PERIODE);
		
		OP <= "000010"; -- J;
		wait for (PERIODE);



		--instructions type R
		op <= "000000";		--les instructions type R ont toutes un opcode de 0

		Funct <= "100000";	--ADD
		wait for (PERIODE);

		Funct <= "100010";	--SUB
		wait for (PERIODE);

		Funct <= "100100";	--AND
		wait for (PERIODE);

		Funct <= "100101";	--OR
		wait for (PERIODE);

		Funct <= "101010";	--SLT 
		wait for (PERIODE);
		
	
		
	end process test;
end controlleur_test;

