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
% ## @deftypefn {Function File} {@var{retval} =} Examples (@var{input1}, @var{input2})
% ##
% ## @seealso{}
% ## @end deftypefn
% 
% ## Author: imanol <imanol@debian>
% ## Created: 2019-03-26

classdef Examples
  properties
    name
  end
  
  methods(Static = true)
    function [v,i] = ex_curvaiv_panelsolar ()
      gnu = Gnuplots();
      ps = PanelSolar( ...
          7, ...
          1, ...
          2667e-3, ...
          506.0e-3, ... 
          2371e-3, ...
          487.0e-3, ...
          -6.0e-0, ...
          0.32e-0, ...
          -6.1e-0, ...
          0.28e-0, ...
          300e0, ...
          1367e0 ...
      );

      v = linspace(0e0, 7 * 2667e-3, 100);
      i = corriente_KarmalkarHaneefa(ps, v, 300e0, 1367e0);
      gnuplot_curves(gnu, v', i', "Curvas \\\\textit{I-V}", "iv", {"$V$ [V]", "$I$ [A]"});
    end
    
    function [xs, ys, zs] = ex_orbita_sunsync ()
      Orb = @(ta) Orbita(3.986e5, 6378e0, 42e3, 5e-1, 98.4, 45e0, 30e0, ta, 0.1, 0.6, 288.0);
      %orbita = Orb(35e0);
      %n_sol = [1e0, 0e0, 0e0];
      period = 2e0 * pi * sqrt(42e3 ^ 3e0 / 3.986e5);
      time = linspace(0e0, period, 100);
      xs = zeros(100,1);
      ys = zeros(100,1);
      zs = zeros(100,1);
      
      i = 0;
      for t = time
        i = i + 1;
        ta_i = 35e0 + t * 360e0 / period;
        %Orbita(3.986e5, 6378e0, sma, ecc, inc, raan, aop, ta, 0.1, 0.6, 288.0);
        orbita = Orb(ta_i);
        xx_i = orbita.ejes_inerciales.x_b;
        xs(i) = xx_i(1);
        ys(i) = xx_i(2);
        zs(i) = xx_i(3);
      end
      plot3(xs, ys, zs);
    end
    
    function [bateria] = ex_bateria_ajuste ()
        bateria = BateriaEstatica();
        bateria = bateria.adjust_discharge("data/ensayos_modulo_3s1p_descarga.dat", 3);
        bateria = bateria.adjust_charge("data/ensayos_modulo_3s1p_carga.dat", 3);
        bateria = BateriaDinamica(bateria);
        bateria = bateria.adjust_dynamic("data/medidas_bateria.dat", 3);
        
        tabla = bateria.datos_carga_a_vector("data/ensayos_modulo_3s1p_descarga.dat", 10, 10);
        phi2 = tabla(:,4) + bateria.r_d * tabla(:,5);
        phi = linspace(0e0, max(phi2), 20);
        v_vec = tabla(:,3);
        figure();
        hold on;
        grid on;
        plot(phi, bateria.discharge_voltage(phi, 5e0, 3), "r-x");
        plot(phi, bateria.discharge_voltage(phi, 2.5e0, 3), "r-+");
        plot(phi, bateria.discharge_voltage(phi, 1.5e0, 3), "rd-");
        plot(phi2,v_vec);
        legend();
        
        tabla = bateria.datos_carga_a_vector("data/ensayos_modulo_3s1p_carga.dat", 10, 10);
        phi2 = bateria.phi_max - tabla(:,4) + bateria.r_c * tabla(:,5);
        phi = linspace(0e0, bateria.phi_max, 20);
        v_vec = tabla(:,3);
        figure();
        hold on;
        grid on;
        plot(phi, bateria.charge_voltage(phi, 5e0, 3), "r-x");
        plot(phi, bateria.charge_voltage(phi, 2.5e0, 3), "r-+");
        plot(phi, bateria.charge_voltage(phi, 1.5e0, 3), "rd-");
        plot(phi2,v_vec);
        legend();
    end
  end
  
  methods(Static = false)
    function obj = Examples ()
      obj.name = "Examples";
    end
  end
end
