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
## @deftypefn {Function File} {@var{retval} =} modelo_estatico (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-26

function [e_d, e_c] = modelo_estatico (obj, phi, cur)
  a = parametros_estatico(obj);
  
  e_d0 = a.ed00;
  e_d1 = a.ed10;
  e_d2 = dot([a.ed20; a.ed21; a.ed22], (cur * ones(3,1)).^(0:1:2));
  e_d3 = dot([a.ed30; a.ed31], (cur * ones(2,1)).^(0:1:1));
  
  e_d = e_d0 + e_d1 * phi + e_d2 * exp(e_d3 * phi);
  
  e_c0 = a.ec00;
  e_c1 = a.ec10;
  e_c2 = a.ec20;
  e_c3 = dot([a.ec30; a.ec31], (cur * ones(2,1)).^(0:1:1));
  
  e_c = e_c0 + e_c1 * phi + e_c2 * exp(e_c3 * phi);
endfunction
