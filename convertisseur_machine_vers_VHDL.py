import sys

machineCodeFichier = open(sys.argv[1], 'r')
VHDLFichier = open(sys.argv[2],"w+")
nbInstru = 0

while True:
	instru = machineCodeFichier.readline()
    
	#arret ici si fin du fichier
	if not instru:
		break
    
	VHDLFichier.write('    ')
	VHDLFichier.write(str(nbInstru))
	VHDLFichier.write('  => x"')
	VHDLFichier.write(instru.strip())
	VHDLFichier.write('",\n')
	nbInstru += 1


print("rappel: changer le dernier ',' pour ');'")
print("\n\n", nbInstru, " instructions")
machineCodeFichier.close()
VHDLFichier.close()
