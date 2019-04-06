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
## @deftypefn {Function File} {@var{retval} =} f_temperatura (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-18

function t = f_temperatura (t, omega, tiempo_delay, t_frio, t_caliente)
  ## Parametros
  omega = 52e-3;                         % rad / s
  tiempo_delay = 15e0;                   % s
  t_frio_c = -20e0;                      % C
  t_caliente_c = 80e0;                   % C
  t_frio = t_frio_c + 273.15e0;          % K
  t_caliente = t_caliente_c + 273.15e0;  % K
  
  ## Variable
  theta = rem(omega * t, 2e0 * pi);
  
  ## Parametros del modelo
  mu = pi/2e0 + omega * tiempo_delay;
  phi1 = mu - pi;
  c1 = pi / (mu);
  b1 = (t_frio - t_caliente) / 2e0;
  a1 = (t_frio + t_caliente) / 2e0;
  
  phi2 = - pi;
  b2 = (t_caliente - t_frio) / 2e0;
  a2 = (t_frio + t_caliente) / 2e0;
  c2 = pi / (pi - omega * tiempo_delay);
  
  ## Asignaciones
  t = a1 + b1 * cos(theta * c1);
  t(theta > mu) = a2 + b2 * cos(c2 * (theta(theta > mu) - mu));
  t(theta > pi) = t_frio;
endfunction
