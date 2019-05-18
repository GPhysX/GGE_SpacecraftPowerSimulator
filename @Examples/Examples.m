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
    
    function [panel] = ex_simulacion_panel ()
      %% PANEL
      %% Datos del datasheet
      s = 7;
      p = 2;
      v_oc_cell = 2667e-3;
      dvoc_dt_cell = -6e-3;
      i_sc_cell = 506e-3;
      disc_dt_cell = 0.32e-3;
      v_mp_cell = 2371e-3;
      i_mp_cell = 487e-3;
      dvmp_dt_cell = -6.1e-3;
      dimp_dt_cell = 0.28e-3;
      t_ref = 300e0;
      e_ref = 1367e0;
      %% Panel
      panel = PanelSolar( ...
        s, ...
        p, ...
        v_oc_cell, ...
        i_sc_cell, ... 
        v_mp_cell, ...
        i_mp_cell, ...
        dvoc_dt_cell, ...
        disc_dt_cell, ...
        dvmp_dt_cell, ...
        dimp_dt_cell, ...
        t_ref, ...
        e_ref);
      panel.adjust(t_ref, e_ref);
    end
    
    function [orbita, periodo] = ex_simulacion_orbita ()
      mu_t = 3.986e5;
      rp_t = 6378e0;
      h = 500;
      sma = rp_t + h;
      ecc = 0e0;
      inc = 98.4;
      raan = 45e0;
      aop = 0e0;
      ta_0 = 0e0;
      albedo = 0.30;
      eps = 0.6;
      t_p = 288e0;
      orbita = Orbita(mu_t, rp_t, sma, ecc, inc, raan, aop, ta_0, albedo, eps, t_p);
      periodo = 2e0 * pi * sqrt(sma ^ 3e0 / mu_t);
    end
    
    function [panel, orbita, periodo, bateria, satelite] = ex_simulacion ()
      panel = Examples.ex_simulacion_panel();
      [orbita, periodo] = Examples.ex_simulacion_orbita();
      bateria = Examples.ex_bateria_ajuste();
      satelite = Satelite("DeathStar");
      satelite.orbita = orbita;
      satelite = satelite.ponerPanel(panel, 1);
      satelite = satelite.ponerPanel(panel, 2);
      satelite = satelite.ponerPanel(panel, 3);
      satelite = satelite.ponerPanel(panel, 4);
      satelite = satelite.ponerPanel(panel, 5);
      satelite = satelite.ponerPanel(panel, 6);
      
    end
  end
  
  methods(Static = false)
    function obj = Examples ()
      obj.name = "Examples";
    end
  end
end
