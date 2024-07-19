# Exemple simple de fichier .do
#
# Fonction: Genere toutes les combinaisons d'entr�e
#           sur les ports a, b et c
#
# Auteur: Yves Blaqui�re
#
# ----------------------------------------------------
# 1) Cr�er la librarie work
vlib work

# 2) Compiler les fichiers avec VHDL 1993
vcom -93 -work work controlleur.vhd
vcom -93 -work work controlleur_tb.vhd

# 3) D�marrer la simulation avec le design
vsim work.controlleur_tb(controlleur_test) -gui -do "add wave -unsigned -r *;run 500000;wave zoom full"
