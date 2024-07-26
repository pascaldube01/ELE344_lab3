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

  CONSTANT TAILLE_ROM : positive := 28;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);

  CONSTANT Rom : romtype := (
    0  => x"20030001",
    1  => x"00032820",
    2  => x"00a33822",
    3  => x"20640004",
    4  => x"00641024",
    5  => x"00472825",
    6  => x"10e30009",
    7  => x"00000020",
    8  => x"00000020",
    9  => x"0085102a",
    10  => x"ac841fd7",
    11  => x"8ca21fdb",
    12  => x"00000020",
    13  => x"2047fffc",
    14  => x"08000006",
    15  => x"00000020",
    16  => x"00e2202a",
    17  => x"00e31024",
    18  => x"8c471fdb",
    19  => x"00000020",
    20  => x"ac452003",
    21  => x"10a70003",
    22  => x"00000020",
    23  => x"00000020",
    24  => x"00a33825",
    25  => x"8ce42003",
    26  => x"08000000",
    27  => x"00000020",
    28  => x"00000020");
BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

