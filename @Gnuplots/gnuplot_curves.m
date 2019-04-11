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

function [text] = gnuplot_curves (gnu, x, y, titulo, name, labels, legends)
N = size(x, 2);
if nargin == 6
  for i = 1:1:N
    legends{i} = "NONE";
  end;
end;
factor = 0.01384;
scale = 0.75;
f_w = 0.6;
w_t = 390e0;
w = f_w * w_t * factor;
h = w * scale;
filename = "temp.dat";
a = [x'; y']';
save "temp.dat" a;
text = "#!/usr/bin/gnuplot\n";
text = [text, "set terminal epslatex size ", num2str(w,5), "in,", num2str(h,5),"in linewidth 4 standalone\n"];
text = [text, "set output 'temp.tex'\n"];
text = [text, "set title \"", titulo, "\"\n"];
text = [text, "set xlabel \"", labels{1}, "\"\n"];
text = [text, "set ylabel \"", labels{2}, "\"\n"];
%text = [text, "set xrange[", num2str(min(x)), ":", num2str(max(x)), "]\n"];
%text = [text, "set yrange[", num2str(min(y)), ":", num2str(max(y)), "]\n"];
text = [text, "set grid\n"];
text = [text, "plot \\\n"];

for i = 1:1:N
  j = i + N;
  if strcmp(legends{i}, "NONE")
    dispname = "notitle";
  else
    dispname = ["title '", legends{i}, "'"];
  end;
  text = [text, "'", filename, "' u ", int2str(i), ":", int2str(j), " w l ", dispname, ",\\\n"];
end;
text = text(1:1:(end-3));
save "temp.gnu" text;

system("gnuplot temp.gnu");
system("latex temp.tex");
system("dvips temp.dvi");
system("ps2eps -f temp.ps");
system(["mv temp.eps ", name, ".eps"])
system("rm temp-inc.eps temp.aux temp.tex temp.log temp.dvi temp.ps temp.gnu temp.dat");

endfunction
