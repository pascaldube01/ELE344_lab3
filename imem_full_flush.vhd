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

  CONSTANT TAILLE_ROM : positive := 59;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);

  CONSTANT Rom : romtype := (
    0  => x"20030001",
    1  => x"00000020",
    2  => x"00000020",
    3  => x"00032820",
    4  => x"00000020",
    5  => x"00000020",
    6  => x"00a33822",
    7  => x"00000020",
    8  => x"00000020",
    9  => x"20640004",
    10  => x"00000020",
    11  => x"00000020",
    12  => x"00641024",
    13  => x"00000020",
    14  => x"00000020",
    15  => x"00472825",
    16  => x"00000020",
    17  => x"00000020",
    18  => x"10e30011",
    19  => x"00000020",
    20  => x"00000020",
    21  => x"0085102a",
    22  => x"00000020",
    23  => x"00000020",
    24  => x"ac841fd7",
    25  => x"00000020",
    26  => x"00000020",
    27  => x"8ca21fdb",
    28  => x"00000020",
    29  => x"00000020",
    30  => x"2047fffc",
    31  => x"00000020",
    32  => x"00000020",
    33  => x"08000012",
    34  => x"00000020",
    35  => x"00000020",
    36  => x"00e2202a",
    37  => x"00000020",
    38  => x"00000020",
    39  => x"00e31024",
    40  => x"00000020",
    41  => x"00000020",
    42  => x"8c471fdb",
    43  => x"00000020",
    44  => x"00000020",
    45  => x"ac452003",
    46  => x"00000020",
    47  => x"00000020",
    48  => x"10a70005",
    49  => x"00000020",
    50  => x"00000020",
    51  => x"00a33825",
    52  => x"00000020",
    53  => x"00000020",
    54  => x"8ce42003",
    55  => x"00000020",
    56  => x"00000020",
    57  => x"08000000",
    58  => x"00000020",
    59  => x"00000020");
BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

