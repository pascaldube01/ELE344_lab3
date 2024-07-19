--========================= regfile.vhd ===============================
-- ELE-344 Conception et architecture de processeurs
-- �cole de technologie superieure, Aut 2018
-- Auteur: Yves Blaquiere
-- ====================================================================
-- 1 cycle
-- ====================================================================
-- Description: Banc de registres realise avec une memoire comportant :
--              - Un port d'ecriture (we, wd, wa) synchrone
--              - 2 ports de lecture combinatoire (ra1, ra2, rd1, rd2)
-- ====================================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY RegFile IS  -- Fichier de registres a 3 ports (2 lecture, 1 ecriture)
  PORT (clk          : IN  std_logic;
        we           : IN  std_logic; -- Write enable (RegWrite)
        ra1, ra2, wa : IN  std_logic_vector(4 DOWNTO 0);  -- Adresses de lecture
        wd           : IN  std_logic_vector(31 DOWNTO 0);  -- Donnee d'ecriture
        rd1, rd2     : OUT std_logic_vector(31 DOWNTO 0));  -- Donnees de lecture
END;

ARCHITECTURE RegFile_arch OF RegFile IS
  TYPE RamType IS ARRAY (31 DOWNTO 0) OF std_logic_vector(31 DOWNTO 0) ;
  SIGNAL mem : RamType;
BEGIN
--Fichier de registres � trois ports
--    Deux ports de lecture, combinatoire
--    Un port d'�criture synchrone
  PROCESS (clk)
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF we = '1' THEN
        mem(to_integer(unsigned(wa))) <= wd;
      END IF;
    END IF;
  END PROCESS;

  PROCESS (ra1, ra2, mem)
  BEGIN
    IF (to_integer(unsigned((ra1))) = 0) THEN
      rd1 <= (OTHERS => '0'); 
    ELSE
      rd1 <= mem(to_integer(unsigned(ra1)));
    END IF;

    IF (to_integer(unsigned((ra2))) = 0) THEN
      rd2 <= (OTHERS => '0'); 
    ELSE
      rd2 <= mem(to_integer(unsigned(ra2)));
    END IF;
  END PROCESS;
END RegFile_arch;
