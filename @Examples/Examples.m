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
      %Orb = @(ta) Orbita(3.986e5, 6378e0, 42e3, 5e-1, 98.4, 45e0, 30e0, ta, 0.1, 0.6, 288.0);
      ecc = 0e0;
      inc = 98e0;
      raan = 30e0;
      aop = 0e0;
      Orb = @(ta) Orbita(3.986e5, 6378e0, 42e3, ecc, inc, raan, aop, ta, 0.1, 0.6, 288.0);
      %orbita = Orb(35e0);
      %n_sol = [1e0, 0e0, 0e0];
      period = 2e0 * pi * sqrt(42e3 ^ 3e0 / 3.986e5);
      time = linspace(0e0, period*.8, 100);
      xs = zeros(100,1);
      ys = zeros(100,1);
      zs = zeros(100,1);
      
      i = 0;
      for t = time
        i = i + 1;
        ta_i = 0e0 + t * 360e0 / period;
        %Orbita(3.986e5, 6378e0, sma, ecc, inc, raan, aop, ta, 0.1, 0.6, 288.0);
        orbita = Orb(ta_i);
        xx_i = orbita.ejes_inerciales.x_b;
        xs(i) = xx_i(1);
        ys(i) = xx_i(2);
        zs(i) = xx_i(3);
      end
      %plot3(xs, ys, zs);
    end
    
    function [bateria] = ex_bateria_ajuste (do_plot)
      do_print = true;
      %% IMG OPTIONS
      %do_plot = true;
      %set(groot,'defaultLineLineWidth',1.5);
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
      
      file_charge = "data/ensayos_modulo_3s1p_carga.dat";
      file_discharge = "data/ensayos_modulo_3s1p_descarga.dat";
        
      for tp = 1:3
        
        bateria = bateria.adjust_discharge(file_discharge, tp, do_print);
        bateria = bateria.adjust_charge(file_charge, tp, do_print);
        
        if ( do_plot )
          %% PLOT DISCHARGE
          %aa = load(file_discharge);

          fig = figure('Units', 'points', 'Position', resolucion);  hold on;
          grid on;
          box on;
          hold on;
          xlabel("\phi");
          ylabel("V^d [V]");
          %cs = {"m","g","b"};
          css = {"b--","m--","g--"};
          ies = [5e0, 25e-1, 15e-1];
          tabla = bateria.datos_carga_a_vector(file_discharge, 10, 10);
          phi2 = tabla(:,4) + bateria.r_d * tabla(:,5);
          phi = linspace(0e0, bateria.phi_max, length(phi2));
          v_vec = tabla(:,3);
          scatter(phi2,v_vec,".");
          aa = zeros(length(phi),8);
          aa(:,1:2) = [phi2,v_vec];
          for iii = 1:3
            plot(phi, bateria.discharge_voltage(phi, ies(iii), tp), css{iii});
            aa(:,2*iii+1:2*(iii+1)) = [phi', bateria.discharge_voltage(phi, ies(iii), tp)'];
          end
          save(strcat("ED", num2str(tp), ".dat"), 'aa', '-ASCII');
          if ( tp == 1 )
            title(["Ajuste del modelo de descarga", "tipo I"]);
          elseif ( tp == 2 )
            title(["Ajuste del modelo de descarga", "tipo II"]);
          else
            title(["Ajuste del modelo de descarga", "tipo III"]);
          end
          legends = ["Experimental", "I = 5,0 A", "I = 2,5 A", "I = 1,5 A"];
          legend(legends);
          outname = strcat("Figuras/ED", num2str(tp));
          out = strcat(outname, ".eps");
          print(fig, out, '-depsc', '-r0');
          close(fig);

          %% PLOT CHARGE

          tabla = bateria.datos_carga_a_vector("data/ensayos_modulo_3s1p_carga.dat", 10, 10);
          phi2 = bateria.phi_max - tabla(:,4) + bateria.r_c * tabla(:,5);
          phi = linspace(0e0, bateria.phi_max, length(phi2));
          v_vec = tabla(:,3);
          aa = zeros(length(phi),8);
          aa(:,1:2) = [phi2,v_vec];

          fig = figure('Units', 'points', 'Position', resolucion);  hold on;
          grid on;
          box on;
          hold on;
          xlabel("\phi");
          ylabel("V^c [V]");
          scatter(phi2,v_vec,".");
          if ( tp == 1 )
            title(["Ajuste del modelo de carga", "tipo I"]);
          elseif ( tp == 2 )
            title(["Ajuste del modelo de carga", "tipo II"]);
          else
            title(["Ajuste del modelo de carga", "tipo III"]);
          end
%           plot(phi, bateria.charge_voltage(phi, 5e0, tp), "r-x");
%           plot(phi, bateria.charge_voltage(phi, 2.5e0, tp), "r-+");
%           plot(phi, bateria.charge_voltage(phi, 1.5e0, tp), "rd-");
          plot(phi, bateria.charge_voltage(phi, 5e0, tp), "b--");
          plot(phi, bateria.charge_voltage(phi, 2.5e0, tp), "m--");
          plot(phi, bateria.charge_voltage(phi, 1.5e0, tp), "g--");
          aa(:,3:4) = [phi', bateria.charge_voltage(phi, 5e0, tp)'];
          aa(:,5:6) = [phi', bateria.charge_voltage(phi, 2.5, tp)'];
          aa(:,7:8) = [phi', bateria.charge_voltage(phi, 1.5, tp)'];
          save(strcat("EC", num2str(tp), ".dat"), 'aa', '-ASCII');
          legends = ["Experimental", "I = 5,0 A", "I = 2,5 A", "I = 1,5 A"];
          legend(legends);
          outname = strcat("Figuras/EC", num2str(tp));
          %out = strcat(outname, ".fig");
          %savefig(fig, out);
          out = strcat(outname, ".eps");
          print(fig, out, '-depsc', '-r0');
          close(fig);
        end
      end

      %% DYNAMIC
      bateria = BateriaDinamica(bateria);
      bateria = bateria.adjust_dynamic("data/medidas_bateria.dat", 3, do_print, do_plot);
      bateria = ModuloBaterias(1,1,bateria);
      
      %% ERR DYNAMIC VS STATIC
      if ( do_plot )
        bateria.i_r1 = 0e0;
        bateria.i_r2 = 0e0;
        a = load("data/medidas_bateria.dat");
        t = a(:,1);
        v = a(:,2);
        i = a(:,3);
        phis = zeros(size(i));
        ir1s = zeros(size(i));
        ir2s = zeros(size(i));
        v_est = zeros(size(i));
        v_din = zeros(size(i));
        for idx = 1:(length(t)-1)
          t_i = t(idx);
          t_next = t(idx+1);
          dt = t_next - t_i;
          phi_i = phis(idx);
          ir1_i = ir1s(idx);
          ir2_i = ir2s(idx);
          i_i = i(idx);
          bateria.i_r1 = ir1_i;
          bateria.i_r2 = ir2_i;
          v_din(idx) = bateria.voltage_dynamic(phi_i, i_i, 3);
          v_est(idx) = bateria.voltage_static(phi_i, i_i, 3);
          
          v_din(idx+1) = v_din(idx);
          v_est(idx+1) = v_est(idx);
          
          phis(idx+1) = phi_i + dt * v_est(idx) * i_i;
          ir1s(idx+1) = ir1_i + dt * ((i_i - ir1_i) / (bateria.r_1 * bateria.c_1));
          ir2s(idx+1) = ir2_i + dt * ((i_i - ir2_i) / (bateria.r_2 * bateria.c_2));
        end
        fig = figure('Units', 'points', 'Position', resolucion);  hold on;
        grid on;
        box on;
        hold on;
        xlim([0, max(t)]);
        title("\textbf{Comparaci\'on de los modelos}", "Interpreter", "latex");
        xlabel("$t$ [s]", "Interpreter", "latex");
        ylabel("$V$ [V]", "Interpreter", "latex");
        plot(t, v_est, "b", "DisplayName", "EST\'ATICO");
        plot(t, v_din, "m", "DisplayName", "DIN\'AMICO");
        plot(t, v, "g", "DisplayName", "EXPERIMENTAL");
        legend('Interpreter', 'latex');
        print(fig, "Figuras/BATERR.eps", "-depsc", "-r0");
        close(fig);
        
        %aa = zeros(length(t), 4);
        aa = [t, v_est, v_din, v];
        fileID = fopen(strcat("Figuras/DIN.dat"),'w');
        fprintf(fileID,'#%1s\t%4s\t%4s\t%4s\n','t','vest','vdin','vexp');
        fprintf(fileID,'%18.14f\t%18.14f\t%18.14f\t%18.14ff\n',aa');
        fclose(fileID);
      end
    end
    
    function [panel_p, panel_g, panel_v] = ex_simulacion_panel ()
      %% PANEL
      %% Datos del datasheet
      s = 7;
      p = 3;
%       v_oc_cell = 2667e-3;
%       dvoc_dt_cell = -6e-3;
%       i_sc_cell = 506e-3;
%       disc_dt_cell = 0.32e-3;
%       v_mp_cell = 2371e-3;
%       i_mp_cell = 487e-3;
%       dvmp_dt_cell = -6.1e-3;
%       dimp_dt_cell = 0.28e-3;
      v_oc_cell = 2700e-3;
      dvoc_dt_cell = -6.2e-3;
      i_sc_cell = 520.2e-3;
      disc_dt_cell = 0.36e-3;
      v_mp_cell = 2411e-3;
      i_mp_cell = 504.4e-3;
      dvmp_dt_cell = -6.7e-3;
      dimp_dt_cell = 0.24e-3;
      t_ref = 300e0;
      e_ref = 1367e0;
      %% Panel Estandar
      panel_p = PanelSolar( ...
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
      panel_p.adjust(t_ref, e_ref);
      %% Panel Grande
      p = 4;
      panel_g = PanelSolar( ...
        s, ...
        4, ...
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
      panel_g.adjust(t_ref, e_ref);
      %% Panel Vacio
      panel_v = PanelSolar( ...
        s, ...
        p, ...
        v_oc_cell, ...
        1e-6, ... 
        v_mp_cell, ...
        1e-4, ...
        dvoc_dt_cell, ...
        0e0, ...
        dvmp_dt_cell, ...
        0e0, ...
        t_ref, ...
        e_ref);
      panel_v.adjust(t_ref, e_ref);
    end

    function cnvs = ex_simulacion_conversores (do_plots)
      filenames = {"data/conversor_3.3V2.dat", "data/conversor_5V2.dat", "data/conversor_15V2.dat"};
      fignames = {"Figuras/CDC33", "Figuras/CDC5", "Figuras/CDC15"};
      dispnames = {"3,3 V", "5 V", "$\pm$15 V"};
      cnvs = cell(1, length(filenames));
      colors = {"b", "m", "g"};
            
      if ( do_plots )
        %set(groot,'defaultLineLineWidth',1.0);
        set(gcf,'PaperPositionMode','auto');
        set(gca,'FontSize',8);
        colormap('jet');
        s100 = [0, 0, 390, 390 * .75];
        %s80 = s100 .* .8;
        s60 = s100 .* .6;
        %s40 = s100 .* .4;
        s45 = s100 .* .45;
        %resolucion = s80;
        fig_t = figure('Units', 'points', 'Position', s45);
        hold on;
        box on;
        grid on;
        ylabel("ERR($I_{IN}$)", "Interpreter", "latex");
        xlabel("$I_{OUT}$ [A]", "Interpreter", "latex");
        title("\textbf{Ajuste de conversores}", "Interpreter", "latex");
      end

      for i = 1:length(filenames)
        filename = filenames{i};
        a = load(filename, "-ascii");
        vec_v_in = a(:,1);
        vec_i_in = a(:,2);
        %vec_p_in = a(:,3);
        vec_v_out = a(:,4);
        vec_i_out = a(:,5);
        %vec_p_out = a(:,6);
        vec_eta = a(:,7);

        v_in = vec_v_in(1);
        v_out = vec_v_out(1);

        cnv_i = ConversorDC(v_in, v_out);
        cnv_i = cnv_i.ajuste(vec_i_out, vec_eta);
        cnvs{i} = cnv_i;
        
        if ( do_plots )
          figname = fignames{i};
          dispname = dispnames{i};
          fig = figure('Units', 'points', 'Position', s45);
          hold on;
          box on;
          grid on;
          ylabel("$I_{IN}$ [A]", "Interpreter", "latex");
          xlabel("$I_{OUT}$ [A]", "Interpreter", "latex");
          title(strcat("\textbf{Ajuste Conversor de ", dispname, "}"), "Interpreter", "latex");
          plot(vec_i_out, vec_i_in, 'm', 'DisplayName', 'EXPERIMENTAL');
          plot(vec_i_out, cnv_i.corriente_entrada(vec_i_out), 'g', 'DisplayName', 'SIMULADO');
          legend('Interpreter', 'latex');
          out = strcat(figname, ".eps");
          print(fig, out, '-depsc', '-r0');
          close(fig);
          
          aa = [vec_i_out, vec_eta*1e2, cnv_i.rendimiento(vec_i_out)*1e2];
          fileID = fopen(strcat(figname, '.dat'),'w');
          fprintf(fileID,'#%4s\t%3s\t%7s\n','iout','eta','eta_sim');
          fprintf(fileID,'%18.14f\t%18.14f\t%18.14f\n',aa');
          fclose(fileID);
          %% Rendimiento
          fig = figure('Units', 'points', 'Position', s60);
          hold on;
          box on;
          grid on;
          ylabel("$\eta$ [\%]", "Interpreter", "latex");
          xlabel("$I_{OUT}$ [A]", "Interpreter", "latex");
          ylim([0,1e2]);
          title(strcat("\textbf{Rendimiento conversor ", dispname, "}"), "Interpreter", "latex");
          plot(vec_i_out, vec_eta*1e2, 'b', 'DisplayName', 'Experimental');
          plot(vec_i_out, cnv_i.rendimiento(vec_i_out)*1e2, 'm--', 'DisplayName', 'Simulado');
          legend('Location', 'southeast', 'Interpreter', 'latex');
          out = strcat(figname, "_R.eps");
          print(fig, out, '-depsc', '-r0');
          close(fig);
          %% Fig Tot
          set(0,'CurrentFigure',fig_t);
          plot(vec_i_out, vec_i_in - cnv_i.corriente_entrada(vec_i_out), colors{i}, 'DisplayName', dispname);
        end
       end

      if ( do_plots )
        legend();
        outname = "Figuras/CDCERR";
        out = strcat(outname, ".eps");
        print(fig_t, out, '-depsc', '-r0');
        close(fig_t);
      end

    end

    function [orbita, periodo] = ex_simulacion_orbita (do_plots)
      mu_t = 3.986e5;
      rp_t = 6378e0;
      h = 500;
      sma = rp_t + h;
      ecc = 0e0;
      inc = acosd(-(sma/12352e0)^3.5);
      %inc = 97.4023;
      raan_0 = 45e0;
      aop = 0e0;
      ta_0 = 0e0;
      albedo = 0.30;
      eps = 0.6;
      t_p = 288e0;
      j2 = 1.0826e-3;
      delta_raan = -3e0 * pi * j2 * (6378e0 / sma) ^ 2e0 * cosd(inc) * 180e0 / pi;
      orbita = Orbita(mu_t, rp_t, sma, ecc, inc, raan_0, aop, ta_0, albedo, eps, t_p);
      periodo = 2e0 * pi * sqrt(sma ^ 3e0 / mu_t);
      
      if ( do_plots )
        set(gcf,'PaperPositionMode','auto');
        set(gca,'FontSize',8);
        s100 = [0, 0, 390, 390 * .75];
        s80 = s100 .* .8;
        fig = figure('Units', 'points', 'Position', s80);
        hold on;
        grid on;
        box on;
        n = 50;
        units = 'km';
        myscale = 6378;
        theta = (-n:2:n)/n*pi;
        phi = (-n:2:n)'/n*pi/2;
        cosphi = cos(phi); cosphi(1) = 0; cosphi(n+1) = 0;
        sintheta = sin(theta); sintheta(1) = 0; sintheta(n+1) = 0;

        x = myscale*cosphi*cos(theta);
        y = myscale*cosphi*sintheta;
        z = myscale*sin(phi)*ones(1,n+1);
        load('topo.mat','topo','topomap1');
        topo2 = [topo(:,181:360) topo(:,1:180)];
        props.FaceColor= 'texture';
        props.EdgeColor = 'none';
        props.FaceLighting = 'phong';
        props.Cdata = topo2;
        surface(x,y,z,props)
        colormap(topomap1);
        axis equal
        title("\textbf{Orbita del nanosat\'elite}", 'Interpreter', 'latex');
        xlabel(['X [' units ']'])
        ylabel(['Y [' units ']'])
        zlabel(['Z [' units ']'])
        view(127.5,30);
        
        nn = 1000;
        xs = zeros(nn, 3);
        time = linspace(0e0, periodo*1, nn);
        es_eclipse = false;
        for i = 1:nn
          t_i = time(i);
          ta_i = ta_0 + t_i * 360e0 / periodo;
          raan_i = raan_0 + delta_raan * t_i / periodo;
          omega_tierra = t_i * 360e0 / (24e0 * 3600e0);
          %Orbita(3.986e5, 6378e0, sma, ecc, inc, raan, aop, ta, 0.1, 0.6, 288.0);
          %orbita = orbita.cambiarTA(ta_i);
          orbita2 = Orbita(mu_t, rp_t, sma, ecc, inc, raan_i, 0e0, ta_i, albedo, eps, t_p);
          ei = orbita2.ejes_inerciales;
          el = ei.rotacionEje(-omega_tierra, 3);
          %el = ei;
          xx_i = el.x_b;
          xs(i, 1:3) = xx_i(:) * sma;
          if(orbita2.hayEclipse([1,0,0]) && not(es_eclipse))
            es_eclipse = true;
          elseif(not(orbita2.hayEclipse([1,0,0])) && es_eclipse)
            es_eclipse = false;
          end
        end
        plot3(xs(:,1), xs(:,2), xs(:,3), "r");
        print(fig, "Figuras/Orb.eps", '-depsc', '-r0');
        close(fig);
      end
    end
    
    function [panel_p, panel_g, panel_v, orbita, periodo, bateria, cnvs, satelite] = ex_simulacion (do_plots)
      [panel_p, panel_g, panel_v] = Examples.ex_simulacion_panel();
      [orbita, periodo] = Examples.ex_simulacion_orbita(do_plots);
      cnvs = Examples.ex_simulacion_conversores(do_plots);
      bateria = Examples.ex_bateria_ajuste(do_plots);
      satelite = Satelite("DeathStar");
      satelite.orbita = orbita;
      satelite = satelite.ponerPanel(panel_g, 1);
      satelite = satelite.ponerPanel(panel_g, 2);
      satelite = satelite.ponerPanel(panel_g, 3);
      satelite = satelite.ponerPanel(panel_p, 4);
      satelite = satelite.ponerPanel(panel_p, 5);
      satelite = satelite.ponerPanel(panel_p, 6);
    end
  end
  
  methods(Static = false)
    function obj = Examples ()
      obj.name = "Examples";
    end
  end
end
