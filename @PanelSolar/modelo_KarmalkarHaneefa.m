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
## @deftypefn {Function File} {@var{retval} =} f_i_kh (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-18

function f = modelo_KarmalkarHaneefa (obj, cur, v, t, e)
  a = parametros_KarmalkarHaneefa(obj, t, e);
  v_adim = v / a.v_oc;
  cur_adim = cur / a.i_sc;
  
  c = [1e0; -(1e0 - a.gamma); -a.gamma];
  t = ones(3,1) * v_adim ;
  e = [0e0; 1e0; a.m];
  
  f1 = cur_adim;
  f2 = sum(c .* (t .^ e), 1);
  f = f1 - f2;

endfunction
