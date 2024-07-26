--========================= imem.vhd ============================
-- ELE-343 Conception des syst�mes ordin�s
-- HIVER 2017, Ecole de technologie sup�rieure
-- Auteur : Chakib Tadj, Vincent Trudel-Lapierre, Yves Blaqui�re
-- =============================================================
-- Description: imem        
-- =============================================================

LIBRARY ieee;
LIBRARY std;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY imem IS -- Memoire d'instructions
  PORT (adresse : IN  std_logic_vector(31 DOWNTO 0); -- Taille a modifier
                                                    -- selon le programme 
        data : OUT std_logic_vector(31 DOWNTO 0));
END;  -- imem;

ARCHITECTURE imem_arch OF imem IS

  CONSTANT TAILLE_ROM : positive := 19;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);

  CONSTANT Rom : romtype := (
    0  => x"20030001",
    1  => x"00032820",
    2  => x"00a33822",
    3  => x"20640004",
    4  => x"00641024",
    5  => x"00472825",
    6  => x"10e30005",
    7  => x"0085102a",
    8  => x"ac841fd7",
    9  => x"8ca21fdb",
    10 => x"2047fffc",
    11 => x"08000006",
    12 => x"00e2202a",
    13 => x"00e31024",
    14 => x"8c471fdb",
    15 => x"ac452003",
    16 => x"10a70001",
    17 => x"00a33825",
	18 => x"8ce42003",
    19 => x"08000000");
BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

