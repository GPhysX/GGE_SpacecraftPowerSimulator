GT.tex GFV.tex GIBT.tex GIBT2.tex GIEQ.tex GIEQ2.tex GICNV.tex GICNV2.tex GDOD.tex GDOD2.tex GPWR.tex GPWR2.tex GDIN.tex: plots.gnu T.dat FV.dat PWR.dat IEQ.dat ICNV.dat IBT.dat DOD.dat ED1.dat ED2.dat ED3.dat EC1.dat EC2.dat EC3.dat DIN.dat
	gnuplot plots.gnu
#	x=$(find . -name "*.tex")
#	for i = $x; do
#		ii="${i::-4}"
#		latex "$ii".tex
#		dvips "$ii".dvi
#		ps2eps "$ii".ps
#	done
#
%.dvi: %.tex
	latex $<
%.ps: %.dvi
	dvips $<
%.eps: %.ps
	ps2eps -f $<
clean:
	rm -rf *.dvi *.ps *.tex *-inc.eps *.aux *.log

