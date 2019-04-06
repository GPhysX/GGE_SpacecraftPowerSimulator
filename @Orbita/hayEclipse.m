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
## @deftypefn {Function File} {@var{retval} =} hayEclipse (@var{input1}, @var{input2})
##
## @seealso{}
## @end deftypefn

## Author: imanol <imanol@debian>
## Created: 2019-03-27

function f = hayEclipse(obj, n_sol_i)
    %hayEclipse 1 si hay eclipse, 0 si no hay eclipse.
    %  n_sol_i: vector unitario apuntando al Sol en Ejes
    %    Inerciales.
    f = 0e0;
    r_mag = obj.sma * (1e0 - obj.ecc^2e0) / (1e0 + obj.ecc * cosd(obj.ta));
    precesion = obj.raan;
    nutacion = obj.inc;
    rotacion = obj.aop + obj.ta;
    %u_r_i = Actitud().rotacionPorEuler(-precesion, -nutacion, -rotacion).x_b;
    
    q = Actitud.cuaternionRotacionEuler(precesion, nutacion, rotacion);
    
    u_r_i = Actitud().rotacionPorCuaternion(q).x_b;
    n = n_sol_i;
    
    r_i = r_mag * u_r_i;
    z_plano_sombra = dot(r_i, n);
    r_plano_sombra = norm(r_i - z_plano_sombra * n);
    
    
    
    if(z_plano_sombra < 0e0)
        if(r_plano_sombra <= obj.r_p)
            f = 1e0;
        end
    end
endfunction
