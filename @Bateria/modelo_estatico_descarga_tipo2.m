% ## Copyright (C) 2019 imanol
% ## 
% ## This program is free software; you can redistribute it and/or modify it
% ## under the terms of the GNU General Public License as published by
% ## the Free Software Foundation; either version 3 of the License, or
% ## (at your option) any later version.
% ## 
% ## This program is distributed in the hope that it will be useful,
% ## but WITHOUT ANY WARRANTY; without even the implied warranty of
% ## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% ## GNU General Public License for more details.
% ## 
% ## You should have received a copy of the GNU General Public License
% ## along with this program.  If not, see <http://www.gnu.org/licenses/>.
% 
% ## -*- texinfo -*- 
% ## @deftypefn {Function File} {@var{retval} =} modelo_estatico_tipo1 (@var{input1}, @var{input2})
% ##
% ## @seealso{}
% ## @end deftypefn
% 
% ## Author: imanol <imanol@debian>
% ## Created: 2019-04-05

function fer = modelo_estatico_descarga_tipo2 (pesos, v, i, phi1, phi2, e0, e1, e2, e3, rd)
  f_ed = @(phi) e0 + e1 * phi + e2 * exp(e3 * phi);
  phi = phi1 + rd * phi2;
  ed = f_ed(phi);
  v2 = ed - rd .* i;
  fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
end
