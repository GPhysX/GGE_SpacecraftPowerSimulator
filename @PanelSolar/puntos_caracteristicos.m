% Copyright (C) 2019 imanol
% 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% -*- texinfo -*- 
% @deftypefn {Function File} {@var{retval} =} puntos_caracteristicos (@var{input1}, @var{input2})
%
% @seealso{}
% @end deftypefn

% Author: imanol <imanol@debian>
% Created: 2019-03-26

function [v_oc, i_sc, v_mp, i_mp] = puntos_caracteristicos (obj, t, e)
  v_oc = obj.n * (obj.v_oc_cell + obj.dvoc_dt_cell * (t - obj.t_ref));
  i_sc = obj.m * (obj.i_sc_cell + obj.disc_dt_cell * (t - obj.t_ref)) * e / obj.e_ref;
  v_mp = obj.n * (obj.v_mp_cell + obj.dvmp_dt_cell * (t - obj.t_ref));
  i_mp = obj.m * (obj.i_mp_cell + obj.dimp_dt_cell * (t - obj.t_ref)) * e / obj.e_ref;

endfunction
