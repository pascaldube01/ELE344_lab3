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
        clock,Reset,
        
        MemtoReg,Branch,AluSrc,RegDst,
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
signal pcJump:std_logic_vector(31 DOWNTO 0);
signal signImmSh:std_logic_vector(31 DOWNTO 0);
signal pcBranch: std_logic_vector(31 DOWNTO 0);
signal pcSrc:std_logic;



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
SIGNAL EX_PCBranch          : std_logic_vector(31 DOWNTO 0);
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











-------------- autres parties du processeur ----------------
registre : ENTITY work.RegFile(RegFile_arch)--création de l'entité banc de registres
port map(
	clk=>clock,
	we=>RegWrite,
	ra1=>ID_rs,
	ra2=>ID_rt,
	wa=>MEM_WB_WriteReg,
	wd=>WB_Result,
	rd1=>ID_rd1,
	rd2=>ID_rd2
);

operation : ENTITY work.UAL(rtl)--création de l'entité ual
port map(
	ualControl=>AluControl,
	srcA=>ual_srcA, 
	srcB=>ual_srcB, 
	result=>ual_result,
	zero=>ual_zero	
);







----------unite d'envoi-----------
--sortie A

sortieA : process(EX_MEM_RegWrite, EX_MEM_WriteReg, ID_EX_rs, MEM_WB_RegWrite, MEM_WB_WriteReg)
begin
	if ((EX_MEM_RegWrite = '1') and (EX_MEM_WriteReg /= "00000") and (EX_MEM_WriteReg = ID_EX_rs)) then
		EX_ForwardA <= "10";
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
		EX_ForwardB <= "10";
	elsif (MEM_WB_RegWrite = '1' and (MEM_WB_WriteReg /= "00000")and (MEM_WB_WriteReg = ID_EX_rt)) then
		EX_ForwardB <= "01";
	else 
		EX_ForwardB <= "00";
	end if;
end process;












------------mux----------------------


----------mux du choix de l'arrivée de l'écriture de registre(de mémoire ou du résultat ual)
process(MemtoReg,ReadData,ual_result)
begin
	if MemtoReg ='1' then
		resultat<=ReadData;
	else
		resultat<=ual_result;
	end if;
end process;











--------etages de pipeline----------


----------------------------------------------------------------------
----------------------- IF --------------------------------------------
----------------------------------------------------------------------


--loqique du PC
IF_PCPlus4<=std_logic_vector(unsigned( IF_PC ) + 4); --incrementation de PC
ID_PCJump<=(IF_ID_PCPlus4(31 downto 28) & (IF_ID_Instruction(25 downto 0) & "00")); --addresse de saut
EX_pcSrc<=Branch AND  ual_zero; --selection de la source
EX_PCBranch<=std_logic_vector(unsigned( IF_PCPlus4 ) + unsigned(signImmSh));





------------mux du choix branch ou pc+4
process(EX_PCSrc,EX_PCBranch,IF_PCPlus4)
begin
	if EX_PCSrc ='1' then
		IF_PCNextBr <= EX_PCBranch;
	else
		IF_PCNextBr <= IF_PCPlus4;
	end if;
end process;
------------- mux du choix entre adresse pc de jump ou pc next branch
process(ID_Jump,ID_PCJump, IF_PCNextBr )
begin
	if Jump ='1' then
		IF_PCNext<=ID_PCJump;
	else
		IF_PCNext<=IF_PCNextBr ;
	end if;
end process;




----------------------------------------------------------------------
----------------------- ID --------------------------------------------
----------------------------------------------------------------------


--logique combinatoire

ID_rs <= IF_ID_Instruction(25 DOWNTO 21);
ID_rt <= IF_ID_Instruction(20 DOWNTO 16);
ID_rd <= IF_ID_Instruction(15 DOWNTO 11);

ID_SignImm<=std_logic_vector(resize(signed(IF_ID_Instruction(15 downto 0)), 32)); --extension de signe de valeur immediate



--registre de transfer IF_ID
process(clock)
begin
	if rising_edge(clock) then 
	IF_ID_PCPlus4 <= IF_PCPlus4;
	IF_ID_Instruction <=Instruction;
	end if;
end process;




-- mise des signaux en entree vers leurs signaux interne respectifs
--vers IF
ID_Jump <= Jump;
--vers EX
ID_Branch <= Branch;
ID_AluSrc <= AluSrc;
ID_AluControl <= AluControl
ID_RegDst <= regDst;
--vers MEM
ID_MemWrite <= MemWriteIn;
ID_MemRead <= MemReadIn;
--vers WB
ID_MemtoReg <= MemtoReg;
ID_RegWrite <= regWrite;





----------------------------------------------------------------------
----------------------- EX --------------------------------------------
----------------------------------------------------------------------



--registre de transfer ID_EX
process(clock)
begin
	if rising_edge(clock) then 
		--vers EX
		ID_EX_Branch <= ID_Branch;
		ID_EX_AluSrc <=ID_AluSrc;
		ID_EX_aluControl <= ID_AluControl;
		ID_EX_RegDst <=ID_RegDst;
		--vers MEM
		ID_EX_memWrite <= ID_MemWrite;
		ID_EX <= memRead <= ID_MemRead;
		--vers WB
		ID_EX_memToReg <= ID_MemtoReg;
		ID_EX_RegWrite <= ID_RegWrite;
	end if;
end process;




--------mux forwardA ----------
process(EX_forwardA, WB_Result, ID_EX_rd1, EX_MEM_AluResult)
	if(EX_forwardA = "10") then
		EX_SrcA <= EX_MEM_AluResult;
	elsif(EX_forwardA = "01") then
		EX_SrcA <= WB_Result;
	elsif(EX_forwardA = "00") then
		EX_SrcA <= ID_EX_rd1;
	end if;
end process;



--------mux forwardB ----------
process(EX_forwardB, WB_Result, ID_EX_rd2, EX_MEM_AluResult)
	if(EX_forwardB = "10") then
		EX_preSrcB <= EX_MEM_AluResult;
	elsif(EX_forwardB = "01") then
		EX_preSrcB <= WB_Result;
	elsif(EX_forwardB = "00") then
		EX_preSrcB <= ID_EX_rd1;
	end if;
end process;






--------mux forwardB ----------

--------mux srcB -------------
process(ID_EX_AluSrc,ID_EX_SignImm, EX_preSrcB)
begin
	if AluSrc ='1' then
		ual_srcB<=ID_EX_SignImm;
	else
		ual_srcB<=EX_preSrcB;
	end if;
end process;

-------- mux writeREg
process(ID_EX_RegDst, ID_EX_rt, ID_EX_rd )
begin
	if RegDst ='1' then
		EX_WriteReg<=ID_EX_rt;
	else
		EX_WriteReg<=ID_EX_rd;
	end if;
end process;







----------------------------------------------------------------------
----------------------- MEM --------------------------------------------
----------------------------------------------------------------------
--registre de transfer EX_MEM
process(clock)
begin
	if rising_edge(clock) then 
	end if;
end process;

----------------------------------------------------------------------
----------------------- WB --------------------------------------------
----------------------------------------------------------------------
--registre de transfer MEM_WB
process(clock)
begin
	if rising_edge(clock) then 
	end if;
end process;






-------------bascule D d'entrée du compteur pc
process(clock,reset)
begin
	if reset = '1' then
		IF_PC <=(others => '0');  
	elsif rising_edge(clock) then
		IF_PC<=IF_PCNext;  
	end if;
end process;





--signaux vers d'autres parties du CPU (sorties)
MemReadOut<=MemReadIn;
MemWriteOut<=MemWriteIn;
pc<= "00" & IF_PC(31 downto 2);
AluResult<=ual_result;
WriteData<=reg_rd2;

end architecture;
