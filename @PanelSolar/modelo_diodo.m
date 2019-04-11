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
## @deftypefn {Function File} {@var{retval} =} f_diodo (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-18

function f = modelo_diodo (obj, cur, v, t, e)
  a = parametros_diodo(obj, t, e);
  f1 = cur;
  f2 = a.i_pv - a.i_0 * (exp((v + cur * a.r_s)/a.a/a.v_t)) - (v + cur * a.r_s) / a.r_sh;
  f = f1 - f2;
endfunction
