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
## @deftypefn {Function File} {@var{retval} =} f_karmalkar_analitico (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-18

function parametros = parametros_KarmalkarHaneefa (obj, t, e)
  [v_oc, i_sc, v_mp, i_mp] = puntos_caracteristicos (obj, t, e)
  
  alpha = v_mp / v_oc;
  beta = i_mp / i_sc;
  c = (1e0 - beta - alpha) / (2e0 * beta - 1e0);
  m = lambertw(-1, - alpha ^ (-1e0/c) * log(alpha) / c) / log(alpha) + 1e0 / c + 1e0;
  gamma = (2e0 * beta - 1e0) / (alpha ^ m * (m - 1e0));
  
  parametros.v_oc = v_oc;
  parametros.i_sc = i_sc;
  parametros.gamma = gamma;
  parametros.m = m; 
endfunction
