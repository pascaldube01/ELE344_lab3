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



--------------- signaux pour le pipelilne ----------
SIGNAL IF_PCNextBr          : std_logic_vector(31 DOWNTO 0);
SIGNAL IF_PCNext            : std_logic_vector(31 DOWNTO 0);
SIGNAL IF_PC                : std_logic_vector(31 DOWNTO 0);
SIGNAL IF_PCPlus4           : std_logic_vector(31 DOWNTO 0);
SIGNAL IF_ID_PCPlus4        : std_logic_vector(31 DOWNTO 0);
SIGNAL IF_ID_Instruction    : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_PCJump            : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_SignImm           : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_rs                : std_logic_vector(4 DOWNTO 0);
SIGNAL ID_rt                : std_logic_vector(4 DOWNTO 0);
SIGNAL ID_rd                : std_logic_vector(4 DOWNTO 0);
SIGNAL ID_rd1               : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_rd2               : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_Jump              : std_logic;
SIGNAL ID_MemtoReg          : std_logic;
SIGNAL ID_MemWrite          : std_logic;
SIGNAL ID_MemRead           : std_logic;
SIGNAL ID_Branch            : std_logic;
SIGNAL ID_AluSrc            : std_logic;
SIGNAL ID_RegDst            : std_logic;
SIGNAL ID_RegWrite          : std_logic;
SIGNAL ID_AluControl        : std_logic_vector(4 DOWNTO 0);
SIGNAL EX_PCBranch          : std_logic;
SIGNAL EX_PCSrc             : std_logic;
SIGNAL EX_SignImmSh         : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_ForwardA          : std_logic_vector(1 DOWNTO 0);
SIGNAL EX_ForwardB          : std_logic_vector(1 DOWNTO 0);
SIGNAL EX_preSrcB           : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_SrcB              : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_SrcA              : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_AluResult         : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_Zero              : std_logic;
SIGNAL ID_EX_AluSrc         : std_logic;
SIGNAL ID_EX_RegDst         : std_logic;
SIGNAL ID_EX_AluControl     : std_logic;
SIGNAL EX_WriteReg          : std_logic_vector(4 DOWNTO 0); 
SIGNAL ID_EX_rt             : std_logic_vector(4 DOWNTO 0);
SIGNAL ID_EX_rs             : std_logic_vector(4 DOWNTO 0); 
SIGNAL ID_EX_rd1            : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_EX_Branch         : std_logic;
SIGNAL EX_cout              : std_logic;
SIGNAL ID_EX_MemWrite       : std_logic;
SIGNAL ID_EX_MemRead        : std_logic;
SIGNAL ID_EX_RegWrite       : std_logic;
SIGNAL ID_EX_MemtoReg       : std_logic;
SIGNAL ID_EX_SignImm        : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_EX_rd             : std_logic_vector(4 DOWNTO 0);
SIGNAL ID_EX_rd2            : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_EX_PCPlus4        : std_logic_vector(31 DOWNTO 0);
SIGNAL ID_EX_instruction    : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_MEM_AluResult     : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_MEM_MemWrite      : std_logic;
SIGNAL EX_MEM_MemRead       : std_logic;
SIGNAL EX_MEM_MemtoReg      : std_logic;
SIGNAL EX_MEM_RegWrite      : std_logic;
SIGNAL EX_MEM_preSrcB       : std_logic_vector(31 DOWNTO 0);
SIGNAL EX_MEM_WriteReg      : std_logic_vector(4 DOWNTO 0); 
SIGNAL EX_MEM_instruction   : std_logic_vector(31 DOWNTO 0);
SIGNAL WB_Result            : std_logic_vector(31 DOWNTO 0);
SIGNAL MEM_WB_WriteReg      : std_logic_vector(4 DOWNTO 0);
SIGNAL MEM_WB_MemtoReg      : std_logic;
SIGNAL MEM_WB_RegWrite      : std_logic;
SIGNAL MEM_WB_AluResult     : std_logic_vector(31 DOWNTO 0);
SIGNAL MEM_WB_readdata      : std_logic_vector(31 DOWNTO 0);
SIGNAL MEM_WB_instruction   : std_logic_vector(31 DOWNTO 0);

begin










----------unite d'envoi-----------
--sortie A

sortieA : process(EX_MEM_RegWrite, EX_MEM_WriteReg, ID_EX_rs, MEM_WB_RegWrite, MEM_WB_WriteReg)
begin
	if ((EX_MEM_RegWrite = '1') and (EX_MEM_WriteReg /= "00000") and (EX_MEM_WriteReg = ID_EX_rs)) then
		EX_ForwardA <= "1X";
	elsif ((MEM_WB_RegWrite = '1') and (MEM_WB_WriteReg /= "00000") and (MEM_WB_WriteReg = ID_EX_rs)) then
		EX_ForwardA <= "01";
	else 
		EX_ForwardA <= "00";
	end if;
end process;


--sortie B
sortieB : process(EX_MEM_RegWrite, EX_MEM_WriteReg, ID_EX_rt, MEM_WB_RegWrite, MEM_WB_WriteReg)
begin
	if (EX_MEM_RegWrite = '1' and (EX_MEM_WriteReg /="00000") and (EX_MEM_WriteReg = ID_EX_rt)) then
		EX_ForwardB <= "1X";
	elsif (MEM_WB_RegWrite = '1' and (MEM_WB_WriteReg /= "00000")and (MEM_WB_WriteReg = ID_EX_rt)) then
		EX_ForwardB <= "01";
	else 
		EX_ForwardB <= "00";
	end if;
end process;


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
