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
## @deftypefn {Function File} {@var{retval} =} plot_curva (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-20

function [f] = plot_curva (x, y, l, titulo, filename)
close all
graphics_toolkit gnuplot;
f = figure();
plot(x, y, l);
grid on;
xlim([min(x), max(x)]);
ylim([min(y), max(y)]);
xlabel("V [V]","interpreter", "latex");
ylabel("I [A]","interpreter", "latex");
title(titulo,"interpreter", "latex");

print -depslatexstandalone f

## process generated files with pdflatex
system ("latex f.tex");
## dvi to ps
system ("dvips f.dvi");
## ps to eps
system ("ps2eps f.ps");
## rename
system (["mv f.eps ", filename, ".eps"]);
## delete
system ("rm f.tex f.dvi f.ps");
endfunction
