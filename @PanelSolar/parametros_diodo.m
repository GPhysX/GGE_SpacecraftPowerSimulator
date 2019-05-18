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
% @deftypefn {Function File} {@var{retval} =} f_datos_circuito_diodo (@var{input1}, @var{input2})
%
% @seealso{}
% @end deftypefn

% Author: imanol <imanol@debian>
% Created: 2019-03-18

function parametros = parametros_diodo (obj, t, e)
  % Constantes
  k = 1.3806503e-23;   %Boltzmann [J/K]
  q = 1.60217646e-19;  %Electron charge [C]
  
  % Parametros del panel 
  n = obj.n;
  v_oc = obj.v_oc;
  i_sc = obj.i_sc;
  v_mp = obj.v_mp;
  i_mp = obj.i_mp;
  
  % Estimacion de 'a'
  alf = 1.2;
  
  % Voltaje termico
  v_t = n*k*t/q;
  
  % Coeficientes
  a_n = alf * v_t;
  a_d = i_mp;
  a = a_n ./ a_d;
  
  b_n = - v_mp .* (2e0*i_mp - i_sc);
  b_d =  v_mp .* i_sc + v_oc .* (i_mp - i_sc);
  b = b_n / b_d;
  
  c_1 = -(2e0*v_mp-v_oc)./(alf*v_t);
  c_2 = +(v_mp.*i_sc - v_oc .* i_sc) / (v_mp .* i_sc + v_oc .* (i_mp - i_sc));
  c = c_1 + c_2;
  
  d = (v_mp - v_oc) ./ (alf * v_t);
  
  % Parametros del cir. 1D/2R
  r_s = a .* (lambertw(-1,b.*exp(c)) - (c+d));
  
  r_sh_n = (v_mp - i_mp .* r_s) .* (v_mp - r_s .* (i_sc - i_mp) - alf .* v_t);
  r_sh_d = (v_mp - i_mp .* r_s) .* (i_sc - i_mp) - alf .* v_t .* i_mp;
  r_sh = r_sh_n / r_sh_d;
  
  i_0 = ((r_sh + r_s) .* i_sc - v_oc) / (r_sh .* exp(v_oc / alf / v_t));
  
  i_pv_ref = (1e0 + r_s / r_sh) .* i_sc;
  i_pv = i_pv_ref * e / obj.e_ref;
  
  % Devolver estructura
  parametros.i_pv = i_pv;
  parametros.i_0 = i_0;
  parametros.r_s = rs;
  parametros.a = alf;
  parametros.v_t = v_t;
  parametros.r_sh = r_sh;
endfunction
