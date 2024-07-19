--================ alu.vhd =================================
-- ELE344 Conception et architecture de processeurs
-- été 2024, Ecole de technologie superieure
-- Pascal Dube
-- DUBP09289301
-- =============================================================
-- Description: 
--              Architecture RTL du UAL de N bits.
-- =============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use ieee.std_logic_misc.ALL;

ENTITY UAL IS
  GENERIC (N : integer := 32);
  PORT (ualControl : IN  std_logic_vector(3 DOWNTO 0);
        srcA, srcB : IN  std_logic_vector(N-1 DOWNTO 0);
        result     : OUT std_logic_vector(N-1 DOWNTO 0);
        cout, zero : OUT std_logic);
END UAL;

ARCHITECTURE rtl OF UAL IS
  SIGNAL operation                    : std_logic_vector(1 DOWNTO 0);
  SIGNAL op1, op2                     : std_logic;
  SIGNAL somme, srcAMux, srcBMux, res : std_logic_vector(N-1 DOWNTO 0);
  SIGNAL retenueSomme                 : unsigned(N DOWNTO 0);
BEGIN
  operation <= ualControl(1 DOWNTO 0);
  op1       <= ualControl(3);
  op2       <= ualControl(2);
  
  --inversion (si commande par ualControl) des entrees
  with op1 select
  srcAMux   <= 	srcA 		when '0',
  				not (srcA) 	when OTHERS;
  				
  with op2 select
  srcBMux   <=  srcB		when '0',
  				not (srcB) 	when OTHERS;

--somme des nombres (fait en dehors du mux principal car on en a aussi besoin pour SLT)
--addition des deux nombres et du carry in dans un integer, on fait aussi un resize pour pouvoir retenir le carry
retenueSomme <= resize(unsigned(srcAMux), srcAMux'length+1) + unsigned(srcBMux) + unsigned'("" & op2);
somme <= std_logic_vector(retenueSomme(N-1 DOWNTO 0)); --conversion en std_logic_vector (pour synthese)



 -- Multiplexeur 4-a-1 pour generer le signal res
with operation select
	res 	<=  srcAMux AND srcBMux when "00",							--AND
				srcAMux OR srcBMux when "01",							--OR
				somme when "10",										--ADD
				(0 => somme(N-1), others => '0') when OTHERS;			--SLT




  -- Assignation des sorties
  zero  <= not or_reduce(res);
  result <= res;
  COUT  <= retenueSomme(n);
END rtl;
