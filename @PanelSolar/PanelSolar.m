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
## @deftypefn {Function File} {@var{retval} =} PanelSolar (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-26

function obj = PanelSolar ( ...
    n, m, ...
    v_oc_cell, i_sc_cell, v_mp_cell, i_mp_cell, ...
    dvoc_dt_cell, disc_dt_cell, dvmp_dt_cell, dimp_dt_cell, ...
    t_ref, e_ref ...
)
  obj.n = n;
  obj.m = m;
  obj.v_oc_cell = v_oc_cell;        % V
  obj.i_sc_cell =i_sc_cell;         % A
  obj.v_mp_cell = v_mp_cell;        % V
  obj.i_mp_cell = i_mp_cell;        % A
  obj.dvoc_dt_cell = dvoc_dt_cell;  % V/K
  obj.disc_dt_cell = disc_dt_cell;  % I/K
  obj.dvmp_dt_cell = dvmp_dt_cell;  % V/K
  obj.dimp_dt_cell = dimp_dt_cell;  % A/K
  obj.t_ref = t_ref;                % K
  obj.e_ref = e_ref;                % W m^-2
  obj
  obj = class (obj, "PanelSolar");
endfunction
