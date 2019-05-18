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
% @deftypefn {Function File} {@var{retval} =} f_i_kh (@var{input1}, @var{input2})
%
% @seealso{}
% @end deftypefn

% Author: imanol <imanol@debian>
% Created: 2019-03-18

function cur = corriente_tension_KarmalkarHaneefa(obj, r, t, e)
  f_ceros(v) = modelo_KarmalkarHaneefa(obj, v/r, v, t, e);
  v = fsolve(f_ceros, obj.v_oc);
  cur = v/r;
endfunction
