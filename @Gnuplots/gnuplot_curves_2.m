## Copyright (C) 2019 imanol
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{retval} =} gnuplot_curves (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-22

function [text] = gnuplot_curves_2 (x, y, y2, titulo, labels, legends, name)
N = size(x, 2);
P = length(labels);
filename = "temp.dat";
a = [x'; y';y2']';
save "temp.dat" a;
text = "#!/usr/bin/gnuplot\n";
text = [text, "set terminal epslatex standalone\n"];
text = [text, "set output 'temp.tex'\n"];
text = [text, "set title \"", titulo, "\"\n"];
text = [text, "set xlabel \"", labels{1}, "\"\n"];
text = [text, "set ylabel \"", labels{2}, "\"\n"];
if P == 3
  text = [text, "set y2label \"", labels{3}, "\"\n"];
end;
text = [text, "set y2tics\n"];
text = [text, "set xrange[", num2str(min(x),5), ":", num2str(max(x),5), "]\n"];
text = [text, "set yrange[", num2str(min(y),5), ":", num2str(max(y),5), "]\n"];
text = [text, "set y2range[", num2str(min(y2),5), ":", num2str(max(y2),5), "]\n"];
text = [text, "set grid\n"];
text = [text, "plot \\\n"];


if strcmp(legends{1}, "NONE")
  dispnamey = "notitle";
else
  dispnamey = ["title \"", legends{1}, "\""];
end;

if strcmp(legends{2}, "NONE")
  dispnamey2 = "notitle";
else
  dispnamey2 = ["title \"", legends{2}, "\""];
end;
  

text = [text, "'", filename, "' u 1:2 w l ", dispnamey, ",\\\n"]
text = [text, "'", filename, "' u 1:3 w l axes x1y2 ", dispnamey2, "\n"]

save "temp.gnu" text;

system("gnuplot temp.gnu");
system("latex temp.tex");
system("dvips temp.dvi");
system("ps2eps -f temp.ps");
system(["mv temp.eps ", name, ".eps"]);
system("rm temp.tex temp.dvi temp.ps temp.gnu temp.dat");

endfunction
