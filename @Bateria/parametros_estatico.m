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
## @deftypefn {Function File} {@var{retval} =} parametros_estatico (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-26

function a = parametros_estatico (obj)
  a.ec00 = 1e0;
  a.ec10 = 1e0;
  a.ec20 = 1e0;
  a.ec30 = 1e0;
  a.ec31 = 1e0;
  
  a.ed00 = 1e0;
  a.ed10 = 1e0;
  a.ed20 = 1e0;
  a.ed21 = 1e0;
  a.ed22 = 1e0;
  a.ed30 = 1e0;
  a.ed31 = 1e0;
endfunction
