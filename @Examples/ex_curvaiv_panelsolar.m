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
## @deftypefn {Function File} {@var{retval} =} ex_curvaiv_panelsolar (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-26

function [v,i] = ex_curvaiv_panelsolar (obj)
  gnu = Gnuplots();
  ps = PanelSolar( ...
      7, ...
      1, ...
      2667e-3, ...
      506.0e-3, ... 
      2371e-3, ...
      487.0e-3, ...
      -6.0e-0, ...
      0.32e-0, ...
      -6.1e-0, ...
      0.28e-0, ...
      300e0, ...
      1367e0 ...
  );

  v = linspace(0e0, 7 * 2667e-3, 100);
  i = corriente_KarmalkarHaneefa(ps, v, 300e0, 1367e0);
  gnuplot_curves(gnu, v', i', "Curvas \\\\textit{I-V}", "iv", {"$V$ [V]", "$I$ [A]"});
endfunction
