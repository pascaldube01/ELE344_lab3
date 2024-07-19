--========================= datapath.vhd ============================
-- ELE-344 Conception et architecture de processeurs
-- ÉTÉ 2024, Ecole de technologie sup�rieure
-- Auteur : pascal dubé et raphaêl tazbaz
-- Date:2024-07-12
-- =============================================================
-- Description: datapath
--              chemin des données à l'intérieur du mips.
--					 comprenant l'ual et le banc de registres
-- =============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_misc.ALL;

library work;
use work.all;


entity datapath is
    port(
        clock,Reset,MemtoReg,Branch,AluSrc,RegDst,
		  RegWrite,Jump,MemReadIn,MemWriteIn: in std_logic;
        AluControl : in std_logic_vector(3 downto 0);
        
        Instruction,ReadData : in std_logic_vector(31 downto 0);
		  
        MemReadOut,MemWriteOut : out std_logic;
      
        PC,AluResult,WriteData : out std_logic_vector(31 downto 0)
    );
end entity;

architecture datapath_Arc of datapath is
-------------------- signaux internes de l'ual
signal  ual_srcA :   std_logic_vector(31 DOWNTO 0);
signal  ual_srcB :   std_logic_vector(31 DOWNTO 0);
signal  ual_result:  std_logic_vector(31 DOWNTO 0);
signal  ual_zero :   std_logic;
------------ signaux internes autour du banc de registrer
signal reg_wa:std_logic_vector(4 DOWNTO 0);--writeAdress
signal resultat:std_logic_vector(31 DOWNTO 0);
signal reg_rd2:std_logic_vector(31 DOWNTO 0);--read data 2
-------------- signaux internes  pour le jump et branch
signal signImm:std_logic_vector(31 DOWNTO 0);
signal pcPlus4:std_logic_vector(31 DOWNTO 0);
signal pcJump:std_logic_vector(31 DOWNTO 0);
signal signImmSh:std_logic_vector(31 DOWNTO 0);
signal pcBranch: std_logic_vector(31 DOWNTO 0);
signal pcSrc:std_logic;
signal pcNextBr:std_logic_vector(31 DOWNTO 0);
signal pcNext:std_logic_vector(31 DOWNTO 0);
signal signal_pc:std_logic_vector(31 downto 0);

begin

registre : ENTITY work.RegFile(RegFile_arch)--création de l'entité banc de registres
port map(
	clk=>clock,
	we=>RegWrite,
	ra1=>Instruction(25 downto 21),
	ra2=>Instruction(20 downto 16),
	wa=>reg_wa,
	wd=>resultat,
	rd1=>ual_srcA,
	rd2=>reg_rd2
);

operation : ENTITY work.UAL(rtl)--création de l'entité ual
port map(
	ualControl=>AluControl,
	srcA=>ual_srcA, 
	srcB=>ual_srcB, 
	result=>ual_result,
	zero=>ual_zero	
);
-------- mux du choix du registre cible
process(RegDst,instruction)
begin
	if RegDst ='1' then
		reg_wa<=Instruction(15 downto 11);
	else
		reg_wa<=Instruction(20 downto 16);
	end if;
end process;
--------mux du choix entre mode registre ou immédiat
process(AluSrc,signImm,reg_rd2)
begin
	if AluSrc ='1' then
		ual_srcB<=signImm;
	else
		ual_srcB<=reg_rd2;
	end if;
end process;
----------mux du choix de l'arrivée de l'écriture de registre(de mémoire ou du résultat ual)
process(MemtoReg,ReadData,ual_result)
begin
	if MemtoReg ='1' then
		resultat<=ReadData;
	else
		resultat<=ual_result;
	end if;
end process;
------------mux du choix branch ou pc+4
process(pcSrc,pcBranch,pcPlus4)
begin
	if pcSrc ='1' then
		pcNextBr<=pcBranch;
	else
		pcNextBr<=pcPlus4;
	end if;
end process;
------------- mux du choix entre adresse pc de jump ou pc next branch
process(Jump,pcJump, pcNExtBr)
begin
	if Jump ='1' then
		pcNext<=pcJump;
	else
		pcNext<=pcNextBr;
	end if;
end process;
-------------bascule D d'entrée du compteur pc
process(clock,reset)
begin
	if reset = '1' then
		signal_pc <=(others => '0');  
	elsif rising_edge(clock) then
		signal_pc<=pcNext;  
	end if;
end process;




signImm<=std_logic_vector(resize(signed(instruction(15 downto 0)), 32)); --extension de signe de valeur immediate

------------- opérations combinatoire pour le PC
pcSrc<=Branch AND  ual_zero; --selection de la source
pcPlus4<=std_logic_vector(unsigned( signal_pc ) + 4); --incrementation de PC
pcBranch<=std_logic_vector(unsigned( pcPlus4 ) + unsigned(signImmSh)); --addresse de branchement
pcJump<=(pcPlus4(31 downto 28) & (instruction(25 downto 0) & "00")); --addresse de saut
signImmSh<=std_logic_vector(resize(unsigned(signImm), 30)) &"00"; --offset de l'addresse (pour branchement)




--signaux vers d'autres parties du CPU (sorties)
MemReadOut<=MemReadIn;
MemWriteOut<=MemWriteIn;
pc<= "00" & signal_pc(31 downto 2);
AluResult<=ual_result;
WriteData<=reg_rd2;

end architecture;
