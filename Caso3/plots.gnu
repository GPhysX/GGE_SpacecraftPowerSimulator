#!/usr/bin/gnuplot
set terminal epslatex standalone size 9.6cm,7.2cm font ",8" header \
   "\\newcommand{\\ft}[0]{\\footnotesize}"

# T
set output 'GT.tex'
set title "\\textbf{Perfil de temperatura por orbita}"
set xlabel "$\\nu$ [$^\\circ$]"
set ylabel "$T$ [$^\\circ$C]"
set xrange[0:360]
set xtics(0,60,120,180,240,300,360)
set grid
set box
plot 'T.dat' u 1:2 w l lw 3 notitle


# FV
set output 'GFV.tex'
set title "\\textbf{Irradiancia sobre los paneles}\n\\textbf{solares por periodo}"
set xlabel "$t/P$ [-]"
set ylabel "$E/E_{ref}$ [-]"
set xrange[0:1]
set xtics(0,0.2,0.4,0.6,0.8,1)
set grid
set box
set key box opaque
plot 'FV.dat' u 1:2 w l lw 3 title "\\ft $X-$", \
'' u 1:3 w l lw 3 title "\\ft $Y-$", \
'' u 1:4 w l lw 3 title "\\ft $Z-$", \
'' u 1:5 w l lw 3 title "\\ft $Z+$"


#IBT
set output 'GIBT.tex'
set title "\\textbf{Intensidad de corriente}\n\\textbf{de elementos principales}"
set xlabel "$t$ [h]"
set ylabel "$I$ [A]"
set xrange[0:24]
set xtics(0,3,6,9,12,15,18,21,24)
set grid
set box
set key box opaque left top
plot 'IBT.dat' u 1:2 w l lw 7 title "\\ft EQUIPO", \
'' u 1:3 w l lw 4 title "\\ft PANEL", \
'' u 1:4 w l lw 4 title "\\ft BATER\\'IA"
set output 'GIBT2.tex'
set xrange[9:13]
set xtics(9,10,11,12,13)
replot


#IEQ
set output 'GIEQ.tex'
set title "\\textbf{Intensidad de corriente}\n\\textbf{de equipos}"
set xlabel "$t$ [h]"
set ylabel "$I$ [A]"
set xrange[0:24]
set xtics(0,3,6,9,12,15,18,21,24)
set grid
set box
set key box opaque left top Left
plot 'IEQ.dat' u 1:2 w l lw 5 title "\\ft EQ $3,3$ V", \
'' u 1:3 w l lw 5 title "\\ft EQ  $5,0$ V", \
'' u 1:4 w l lw 5 title "\\ft EQ $+15$ V", \
'' u 1:5 w l lw 5 title "\\ft EQ $-15$ V", \
'' u 1:6 w l lw 5 lc rgb '#d95319' title "\\ft EQ BUS"
set output 'GIEQ2.tex'
set xrange[9:13]
set xtics(9,10,11,12,13)
replot

#ICNV
set output 'GICNV.tex'
set title "\\textbf{Intensidad de corriente}\n\\textbf{de conversores}"
set xlabel "$t$ [h]"
set ylabel "$I$ [A]"
set xrange[0:24]
set xtics(0,3,6,9,12,15,18,21,24)
set grid
set box
set key box opaque left center Left
plot 'ICNV.dat' u 1:2 w l lw 5 title "\\ft CNV $3,3$ V IN", \
'' u 1:3 w l lw 5 title "\\ft CNV $3,3$ V OUT", \
'' u 1:4 w l lw 5 title "\\ft CNV $5,0$ V IN", \
'' u 1:5 w l lw 5 title "\\ft CNV $5,0$ V OUT", \
'' u 1:6 w l lw 5 lc rgb '#d95319' title "\\ft CNV $\\pm15$ V IN", \
'' u 1:7 w l lw 5 title "\\ft CNV $\\pm15$ V OUT"
set output 'GICNV2.tex'
set xrange[9:13]
set xtics(9,10,11,12,13)
replot


#DOD
set output 'GDOD.tex'
set title "\\textbf{Profundidad de descarga}"
set xlabel "$t$ [h]"
set ylabel "$DoD$ [\\%]"
set xrange[0:24]
set xtics(0,3,6,9,12,15,18,21,24)
set grid
set box
unset key
plot 'DOD.dat' u 1:2 w l lw 5 notitle
set output 'GDOD2.tex'
set xrange[9:13]
set xtics(9,10,11,12,13)
replot

#PWR
set output 'GPWR.tex'
set title "\\textbf{Potencia de elementos principales}"
set xlabel "$t$ [h]"
set ylabel "$P$ [W]"
set xrange[0:24]
set xtics(0,3,6,9,12,15,18,21,24)
set grid
set box
set key box opaque left top

plot 'PWR.dat' u 1:2 w l lw 7 title "\\ft EQUIPO", \
'' u 1:3 w l lw 4 title "\\ft PANEL", \
'' u 1:4 w l lw 4 title "\\ft BATER\\'IA"
set output 'GPWR2.tex'
set xrange[9:13]
set xtics(9,10,11,12,13)
replot

#DIN
set output 'GDIN.tex'
set title "\\textbf{Comparaci\\'on de los modelos}"
set xlabel "$t$ [s]"
set ylabel "$V$ [V]"
set xrange[0:1800]
set xtics(0,300,600,900,1200,1500,1800)
set grid
set box
set key box opaque right top

plot 'DIN.dat' u 1:2 w l lw 3 title "\\ft EST\\'ATICO", '' u 1:3 w l lw 3 title "\\ft DIN\\'AMICO", '' u 1:4 w l lw 3 title "\\ft EXPERIMENTAL"

#ED1
set output 'GED1.tex'
set title "\\textbf{Ajuste del modelo de descarga tipo I}"
set xlabel "$\\phi$"
set ylabel "$V^d$ [V]"
#set format x "%2.0e"
set xrange[0:150000]
set xtics(0,50000,100000,150000)
set grid
set box
set key box opaque right top
plot 'ED1.dat' u 1:2 pointinterval 20 pt 2 ps 0.5 title "\\ft Experimental", \
'' u 3:4 w l lw 3 title "\\ft $I$=5,0 A", \
'' u 5:6 w l lw 3 title "\\ft $I$=2,5 A", \
'' u 7:8 w l lw 3 title "\\ft $I$=1,5 A"
#ED2
set output 'GED2.tex'
set title "\\textbf{Ajuste del modelo de descarga tipo II}"
set xlabel "$\\phi$"
set ylabel "$V^d$ [V]"
#set format x "%2.0e"
set xrange[0:150000]
set xtics(0,50000,100000,150000)
set grid
set box
set key box opaque right top
plot 'ED2.dat' u 1:2 pointinterval 20 pt 2 ps 0.5 title "\\ft Experimental", \
'' u 3:4 w l lw 3 title "\\ft $I$=5,0 A", \
'' u 5:6 w l lw 3 title "\\ft $I$=2,5 A", \
'' u 7:8 w l lw 3 title "\\ft $I$=1,5 A"
#ED3
set output 'GED3.tex'
set title "\\textbf{Ajuste del modelo de descarga tipo III}"
set xlabel "$\\phi$"
set ylabel "$V^d$ [V]"
#set format x "%2.0e"
set xrange[0:150000]
set xtics(0,50000,100000,150000)
set grid
set box
set key box opaque right top
plot 'ED3.dat' u 1:2 pointinterval 20 pt 2 ps 0.5 title "\\ft Experimental", \
'' u 3:4 w l lw 3 title "\\ft $I$=5,0 A", \
'' u 5:6 w l lw 3 title "\\ft $I$=2,5 A", \
'' u 7:8 w l lw 3 title "\\ft $I$=1,5 A"
#EC1
set output 'GEC1.tex'
set title "\\textbf{Ajuste del modelo de carga tipo I}"
set xlabel "$\\phi$"
set ylabel "$V^c$ [V]"
#set format x "%2.0e"
set xrange[0:150000]
set xtics(0,50000,100000,150000)
set grid
set box
set key box opaque right top
plot 'EC1.dat' u 1:2 pt 2 ps 0.5 title "\\ft Experimental", \
'' u 3:4 w l lw 3 title "\\ft $I$=5,0 A", \
'' u 5:6 w l lw 3 title "\\ft $I$=2,5 A", \
'' u 7:8 w l lw 3 title "\\ft $I$=1,5 A"
#EC2
set output 'GEC2.tex'
set title "\\textbf{Ajuste del modelo de carga tipo II}"
set xlabel "$\\phi$"
set ylabel "$V^c$ [V]"
#set format x "%2.0e"
set xrange[0:150000]
set xtics(0,50000,100000,150000)
set grid
set box
set key box opaque right top
plot 'EC2.dat' u 1:2 pt 2 ps 0.5 title "\\ft Experimental", \
'' u 3:4 w l lw 3 title "\\ft $I$=5,0 A", \
'' u 5:6 w l lw 3 title "\\ft $I$=2,5 A", \
'' u 7:8 w l lw 3 title "\\ft $I$=1,5 A"
#EC3
set output 'GEC3.tex'
set title "\\textbf{Ajuste del modelo de carga tipo III}"
set xlabel "$\\phi$"
set ylabel "$V^c$ [V]"
#set format x "%2.0e"
set xrange[0:150000]
set xtics(0,50000,100000,150000)
set grid
set box
set key box opaque right top
plot 'EC3.dat' u 1:2 pt 2 ps 0.5 title "\\ft Experimental", \
'' u 3:4 w l lw 3 title "\\ft $I$=5,0 A", \
'' u 5:6 w l lw 3 title "\\ft $I$=2,5 A", \
'' u 7:8 w l lw 3 title "\\ft $I$=1,5 A"

#CNV3
set output 'GCDC33.tex'
set title "\\textbf{Rendimiento conversor 3,3 V}"
set xlabel "$I_{OUT} [A]$"
set ylabel "$\\eta$ [\\%]"
#set format x "%2.0e"
set xrange[0:2.5]
set yrange[0:100]
set xtics(0,0.5,1,1.5,2,2.5)
set grid
set box
set key box opaque right top
plot 'CDC33.dat' u 1:2 w l lw 3 title "\\ft Experimental", \
'' u 1:3 w l lw 3 title "\\ft Simulado"


#CNV5
set output 'GCDC5.tex'
set title "\\textbf{Rendimiento conversor 5 V}"
set xlabel "$I_{OUT} [A]$"
set ylabel "$\\eta$ [\\%]"
#set format x "%2.0e"
set yrange[0:100]
set xrange[0:3]
set xtics(0,1,2,2)
set grid
set box
set key box opaque right top
plot 'CDC5.dat' u 1:2 w l lw 3 title "\\ft Experimental", \
'' u 1:3 w l lw 3 title "\\ft Simulado"
#CNV15
set output 'GCDC15.tex'
set title "\\textbf{Rendimiento conversor $\\pm$15 V}"
set xlabel "$I_{OUT} [A]$"
set ylabel "$\\eta$ [\\%]"
#set format x "%2.0e"
set xrange[0:2]
set yrange[0:100]
set xtics(0,0.5,1,1.5,2,2.5)
set grid
set box
set key box opaque right top
plot 'CDC15.dat' u 1:2 w l lw 3 title "\\ft Experimental", \
'' u 1:3 w l lw 3 title "\\ft Simulado"

