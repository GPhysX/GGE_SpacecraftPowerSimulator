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
      do_print = true;
      %% IMG OPTIONS
      do_plot = true;
      set(groot,'defaultLineLineWidth',1.5);
      set(gcf,'PaperPositionMode','auto');
      set(gca,'FontSize',8);
      colormap('jet');
      s100 = [0, 0, 390, 390 * .75];
      s80 = s100 .* .8;
      %s60 = s100 .* .6;
      %s40 = s100 .* .4;
      %s45 = s100 .* .45;
      resolucion = s80;
      
      %% INIT
      bateria = BateriaEstatica();
      
      %% ADJUST & PLOT
        
      for tp = 1:3
        
        bateria = bateria.adjust_discharge("data/ensayos_modulo_3s1p_descarga.dat", tp, do_print);
        bateria = bateria.adjust_charge("data/ensayos_modulo_3s1p_carga.dat", tp, do_print);
        
        if ( do_plot )
          %% PLOT DISCHARGE

          tabla = bateria.datos_carga_a_vector("data/ensayos_modulo_3s1p_descarga.dat", 0, 0);
          phi2 = tabla(:,4) + bateria.r_d * tabla(:,5);
          phi = linspace(0e0, max(phi2), 20);
          v_vec = tabla(:,3);

          fig = figure('Units', 'points', 'Position', resolucion);  hold on;
          grid on;
          box on;
          hold on;
          xlabel("\phi [C \cdot V]");
          ylabel("V^d [V]");
          scatter(phi2,v_vec,".");
          if ( tp == 1 )
            title(["Ajuste del modelo de descarga", "tipo I"]);
          elseif ( tp == 2 )
            title(["Ajuste del modelo de descarga", "tipo II"]);
          else
            title(["Ajuste del modelo de descarga", "tipo III"]);
          end
          plot(phi, bateria.discharge_voltage(phi, 5e0, tp), "r-x");
          plot(phi, bateria.discharge_voltage(phi, 2.5e0, tp), "r-+");
          plot(phi, bateria.discharge_voltage(phi, 1.5e0, tp), "rd-");
          legends = ["Experimental", "I = 5,0 A", "I = 2,5 A", "I = 1,5 A"];
          legend(legends);
          outname = strcat("Figuras/ED", num2str(tp));
          %out = strcat(outname, ".fig");
          %savefig(fig, out);
          out = strcat(outname, ".eps");
          print(fig, out, '-depsc', '-r0');

          %% PLOT CHARGE

          tabla = bateria.datos_carga_a_vector("data/ensayos_modulo_3s1p_carga.dat", 10, 10);
          phi2 = bateria.phi_max - tabla(:,4) + bateria.r_c * tabla(:,5);
          phi = linspace(0e0, bateria.phi_max, 20);
          v_vec = tabla(:,3);

          fig = figure('Units', 'points', 'Position', resolucion);  hold on;
          grid on;
          box on;
          hold on;
          xlabel("\phi [C \cdot V]");
          ylabel("V^c [V]");
          scatter(phi2,v_vec,".");
          if ( tp == 1 )
            title(["Ajuste del modelo de carga", "tipo I"]);
          elseif ( tp == 2 )
            title(["Ajuste del modelo de carga", "tipo II"]);
          else
            title(["Ajuste del modelo de carga", "tipo III"]);
          end
          plot(phi, bateria.charge_voltage(phi, 5e0, tp), "r-x");
          plot(phi, bateria.charge_voltage(phi, 2.5e0, tp), "r-+");
          plot(phi, bateria.charge_voltage(phi, 1.5e0, tp), "rd-");
          legends = ["Experimental", "I = 5,0 A", "I = 2,5 A", "I = 1,5 A"];
          legend(legends);
          outname = strcat("Figuras/EC", num2str(tp));
          %out = strcat(outname, ".fig");
          %savefig(fig, out);
          out = strcat(outname, ".eps");
          print(fig, out, '-depsc', '-r0');
        end
      end

      %% DYNAMIC
      bateria = BateriaDinamica(bateria);
      bateria = bateria.adjust_dynamic("data/medidas_bateria.dat", 3, do_print, do_plot);
      bateria = ModuloBaterias(1,1,bateria);
    end
  end
  
  methods(Static = false)
    function obj = Examples ()
      obj.name = "Examples";
    end
  end
end
