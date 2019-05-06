classdef BateriaDinamica < BateriaEstatica
    properties
        r_sc
        r_int
        r_1
        r_2
        c_1
        c_2
        i_r1
        i_r2
    end
     
    methods(Static = true, Access = public)
        %% DYNAMIC
        
        function v_int = p_voltage_internal(bateria_est, phi, i, rsc, rint, r1, r2, t)
            e = bateria_est.battery_voltage_static(phi, i, t);
            if ( i > 0e0 )
                v_int = e - rint * i;
            else
                v_int = e - (rint + rsc) * i;
            end
            v_int;
        end
        
        function v_din = p_voltage_dynamic(bateria_est, phi, i, ir1, ir2, rsc, rint, r1, r2, t)
            v_int = BateriaDinamica.p_voltage_internal(bateria_est, phi, i, rsc, rint, r1, r2, t);
            v_din = v_int - ir1 * r1 - ir2 * r2;
        end
        
        function f = dynamic_model_diff(y, t, i_interp, rsc, rint, r1, r2, c1, c2, bateria_est, tp)
            f = zeros(3,1);
            phi = y(1);
            i12 = y(2);
            i22 = y(3);
            
            i = i_interp.eval(t);
            
            e = bateria_est.battery_voltage_static(phi, i, tp);
            %v_int = BateriaDinamica.p_voltage_internal(bateria_est, phi, i, rsc, rint, r1, r2, tp);

            f(1) = e * i;
            f(2) = (i - i12) / (r1 * c1);
            f(3) = (i - i22) / (r2 * c2);
        end
        
        function fer = minimize_dynamic_model(u, time, i_exp, v_exp, bateria_est, tp, do_plot)
            rsc = u(1);
            rint = u(2);
            r1 = u(3);
            r2 = u(4);
            c1 = u(5);
            c2 = u(6);
            
            t0 = time(1);
            i_interp = Interpolator(time, i_exp);
            i0 = i_interp.eval(t0);
            y0 = [0e0; i0; i0];
            f_diff = @(y,t) BateriaDinamica.dynamic_model_diff(y, t, i_interp, rsc, rint, r1, r2, c1, c2, bateria_est, tp);
            rk = RK4(f_diff, y0, t0);

            n = length(time);
            v_sim = ones(n,1) * v_exp(1);
            for k = 2:n
              dt = time(k) - time(k-1);
              rk = rk.next(dt);
              phi = rk.y(1);
              i12 = rk.y(2);
              i22 = rk.y(3);
              if ( or( abs(i12) > 10e0, abs(i22) > 1e2 ) )
                  %return;
              end
              i = i_interp.eval(time(k));
              v_sim(k) = BateriaDinamica.p_voltage_dynamic(bateria_est, phi, i, i12, i22, rsc, rint, r1, r2, tp);
            end
            
            fer = bateria_est.p_rmsd(v_exp, v_sim, ones(length(v_exp), 1));
            
            if ( do_plot )
              %% IMG OPTIONS
              set(groot,'defaultLineLineWidth',1.5);
              set(gcf,'PaperPositionMode','auto');
              set(gca,'FontSize',8);
              colormap('jet');
              s100 = [0, 0, 390, 390 * .75];
              s80 = s100 .* .8;
              s60 = s100 .* .6;
              s40 = s100 .* .4;
              s45 = s100 .* .45;
              resolucion = s80;
              fig = figure('Units', 'points', 'Position', resolucion);
              hold on;
              grid on;
              box on;
              hold on;
              title("Ajuste del modelo dinámico");
              xlabel("t [s]");
              ylabel("V [V]");
              plot(v_sim, "DisplayName", "Simulated");
              plot(v_exp, "DisplayName", "Experimental");
              legend();
              outname = "Figuras/DIN";
              %out = strcat(outname, ".fig");
              %savefig(fig, out);
              out = strcat(outname, ".eps");
              print(fig, out, '-depsc', '-r0');
              close(fig);
            end
        end
    end
  
    methods
    %% CONSTRUCTOR
      function obj = BateriaDinamica(bateria_est)
        %obj@BateriaEstatica(bateria_est.s, bateria_est.p); 
        obj.r_c = bateria_est.r_c;
        obj.r_d = bateria_est.r_d;
        obj.phi_max = bateria_est.phi_max;
        obj.coeficientes_descarga_tipo1 = bateria_est.coeficientes_descarga_tipo1;
        obj.coeficientes_descarga_tipo2 = bateria_est.coeficientes_descarga_tipo2;
        obj.coeficientes_descarga_tipo3 = bateria_est.coeficientes_descarga_tipo3;
        obj.coeficientes_carga_tipo1 = bateria_est.coeficientes_carga_tipo1;
        obj.coeficientes_carga_tipo2 = bateria_est.coeficientes_carga_tipo2;
        obj.coeficientes_carga_tipo3 = bateria_est.coeficientes_carga_tipo3;
      end
    end
%      
    methods
        %% STATIC
        function v_int = voltage_internal(obj, phi, i, t)
            if ( nargin == 3 )
                tt = 3;
            else
                tt = t;
            end
            if ( i > 0e0 )
                e = obj.battery_discharge_voltage(phi, i, tt);
            else
                e = obj.battery_charge_voltage(phi, -i, tt);
                e = e - i * obj.r_sc;
            end
            v_int = e - i * obj.r_int;
        end
        
    end
    
    methods
      %% DYNAMIC
      
      function v_din = voltage_dynamic(obj, phi, i, t)
          v_int = obj.voltage_internal(phi, i, t);
          v_din = v_int - obj.i_r1 * obj.r_1 - obj.i_r2 * obj.r_2;
      end

      function obj = adjust_dynamic(obj, archivo, t, do_print, do_plot)
        if ( nargin <= 3 )
          do_print = false;
          do_plot = false;
        elseif ( nargin == 4 )
          if ( do_print == [] )
            do_print = false;
          end
        else
          if ( do_print == [] )
            do_print = false;
          end
          if ( do_plot == [] )
            do_plot = false;
          end
        end
          a = load(archivo);
          tE = a(:,1);
          vE = a(:,2);
          iE = a(:,3);
          
          u0 = [+2.1e-2, +1.1e-2, +1.5e-2, +6.2e-3, +1.5e+3, +2.6e+3];
          
          if ( do_print )
            options = optimset('Display', 'iter', 'MaxFunEvals', 50);
          else
            options = optimset('MaxFunEvals', 50);
          end
          
          f = @(u) obj.minimize_dynamic_model(u, tE, iE, vE, obj, t, false);
          x = fminsearch(f,u0,options);
          if ( do_plot )
            f = @(u) obj.minimize_dynamic_model(u, tE, iE, vE, obj, t, true);
            f(x);
          end
          
          obj.r_sc = x(1);
          obj.r_int = x(2);
          obj.r_1 = x(3);
          obj.r_2 = x(4);
          obj.c_1 = x(5);
          obj.c_2 = x(6);
          
          if ( do_print )
            disp(strcat("R_SC = ", num2str(x(1))));
            disp(strcat("R_INT = ", num2str(x(2))));
            disp(strcat("R_1 = ", num2str(x(3))));
            disp(strcat("R_2 = ", num2str(x(4))));
            disp(strcat("C_1 = ", num2str(x(5))));
            disp(strcat("C_2 = ", num2str(x(6))));
          end
      end
    end
end