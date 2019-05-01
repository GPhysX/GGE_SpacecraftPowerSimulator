classdef BateriaEstatica
    properties
        phi_max
        r_c
        r_d
        coeficientes_descarga_tipo1
        coeficientes_descarga_tipo2
        coeficientes_descarga_tipo3
        coeficientes_carga_tipo1
        coeficientes_carga_tipo2
        coeficientes_carga_tipo3
    end
    
    methods(Static = true)
        function [phi1, phi2] = get_phies (t, i, v)
            n = length(t);
            dts = t(2:n) - t(1:(n-1));
            integrando_phi1 = v .* i;
            integrando_phi2 = i .^ 2e0;
            trap_phi1 = 5e-1 * (integrando_phi1(2:n) + integrando_phi1(1:(n-1))) .* dts;
            trap_phi2 = 5e-1 * (integrando_phi2(2:n) + integrando_phi2(1:(n-1))) .* dts;
            
            phi1 = zeros(n,1);
            phi2 = zeros(n,1);
            for j = 1:(n-1)
              phi1(j+1) = phi1(j) + trap_phi1(j);
              phi2(j+1) = phi2(j) + trap_phi2(j);
            end
        end
    end
    
    methods(Static = true, Access = public)
      %% DISCHARGE
      function e_d = p_battery_discharge_voltage_type1(phi, ~, e_d_coefs)
        e_d = e_d_coefs(1) + e_d_coefs(2) * phi;
      end
      
      function e_d = p_battery_discharge_voltage_type2(phi, ~, e_d_coefs)
        e_d = e_d_coefs(1) + e_d_coefs(2) * phi;
        e_d = e_d + e_d_coefs(3) * exp ( e_d_coefs(4) * phi );
      end
      
      function e_d = p_battery_discharge_voltage_type3(phi, i, e_d_coefs)
        e_d = e_d_coefs(1) + e_d_coefs(2) * phi;
        e_2 = e_d_coefs(3) + e_d_coefs(4) * i + e_d_coefs(5) * i .^ 2e0;
        e_3 = e_d_coefs(6) + e_d_coefs(7) * i;
        e_d = e_d + e_2 .* exp ( e_3 .* phi );
      end
      
      function e_d = p_battery_discharge_voltage(phi, i, e_d_coefs, t)
        if ( t == 1 )
          e_d = Bateria.p_battery_discharge_voltage_type1(phi, i, e_d_coefs);
        elseif ( t == 2 )
          e_d = Bateria.p_battery_discharge_voltage_type2(phi, i, e_d_coefs);
        else
          e_d = Bateria.p_battery_discharge_voltage_type3(phi, i, e_d_coefs);
        end
      end
      
      function v_d = p_discharge_voltage(phi, i, e_d_coefs, r_d, t)
        if ( t == 1 )
          e_d = Bateria.p_battery_discharge_voltage_type1(phi, i, e_d_coefs);
        elseif ( t == 2 )
          e_d = Bateria.p_battery_discharge_voltage_type2(phi, i, e_d_coefs);
        else
          e_d = Bateria.p_battery_discharge_voltage_type3(phi, i, e_d_coefs);
        end
        v_d = e_d - r_d .* i;
      end
      
      function fer = p_rmsd_discharge_voltage (weigth, v, i, phi1, phi2, e_d_coefs, r_d, t)
      %disp(nargin)
      %fflush(stdout);
        phi = phi1 + r_d * phi2;
        v2 = Bateria.p_discharge_voltage(phi, i, e_d_coefs, r_d, t);
        fer = Bateria.p_rmsd(v2, v, weigth);
      end
      
    end
    
    methods(Static = true, Access = public)
      %% CHARGE
      function e_c = p_battery_charge_voltage_type1(phi, ~, e_c_coefs)
        e_c = e_c_coefs(1) - e_c_coefs(2) * phi;
      end
      
      function e_c = p_battery_charge_voltage_type2(phi, ~, e_c_coefs)
        e_c = e_c_coefs(1) - e_c_coefs(2) * phi;
        e_c = e_c - e_c_coefs(3) * exp ( e_c_coefs(4) * phi );
      end
      
      function e_c = p_battery_charge_voltage_type3(phi, i, e_c_coefs)
        e_c = e_c_coefs(1) - e_c_coefs(2) * phi;
        e_2 = e_c_coefs(3);
        e_3 = e_c_coefs(4) + e_c_coefs(5) * i;
        e_c = e_c - e_2 * exp ( e_3 .* phi );
      end
      
      function e_c = p_battery_charge_voltage(phi, i, e_c_coefs, t)
        if ( t == 1 )
          e_c = Bateria.p_battery_charge_voltage_type1(phi, i, e_c_coefs);
        elseif ( t == 2 )
          e_c = Bateria.p_battery_charge_voltage_type2(phi, i, e_c_coefs);
        else
          e_c = Bateria.p_battery_charge_voltage_type3(phi, i, e_c_coefs);
        end
      end
      
      function v_c = p_charge_voltage(phi, i, e_c_coefs, r_c, t)
        if ( t == 1 )
          e_c = Bateria.p_battery_charge_voltage_type1(phi, i, e_c_coefs);
        elseif ( t == 2 )
          e_c = Bateria.p_battery_charge_voltage_type2(phi, i, e_c_coefs);
        else
          e_c = Bateria.p_battery_charge_voltage_type3(phi, i, e_c_coefs);
        end
        v_c = e_c + r_c .* i;
      end
      
      function fer = p_rmsd_charge_voltage (weigth, v, i, phi1, phi2, e_c_coefs, r_c, phi0, t)
        phi = phi0 - phi1 + r_c * phi2;
        v2 = Bateria.p_charge_voltage(phi, i, e_c_coefs, r_c, t);
        fer = Bateria.p_rmsd(v2, v, weigth);
      end
      
    end
    
    methods(Static = true, Access = public)
      %% AUX
      function rmsd = p_rmsd(v_exp, v_sim, w)
        % _rmsd RMSD function with weights.
        %  v_exp: Experimental  data.
        %  v_sim: Simulated / Calculated data.
        %  w: Weigth of each data.
        rmsd = norm((v_sim - v_exp) .* w) / sqrt(sum(w));
      end
      
      function table = datos_carga_a_vector(archivo, head_trim, tail_trim)
          a = load(archivo, "-ascii");
          
          %% Size of table
          %n = size(a(:,1));
          m = size(a, 2) / 3;
          
          %% Extract vectors
          ts = a(:,1:3:end);
          is = a(:,2:3:end);
          vs = a(:,3:3:end);
          
          %%
          l = 0;
          v_vec = [];
          i_vec = [];
          phi1_vec = [];
          phi2_vec = [];
          t_vec = [];
          pesos_vec = [];
          
          for j = 1:m
              tmp_t = t_vec;
              tmp_i = i_vec;
              tmp_v = v_vec;
              tmp_p1 = phi1_vec;
              tmp_p2 = phi2_vec;
              tmp_w = pesos_vec;
              
              i_max = max(is(:,j));
              subindxs = abs(is(:,j) - i_max) < 1e-3;
              n_i = sum(subindxs) - head_trim - tail_trim;
              l = l + n_i;
              
              t2 = ts(subindxs, j);
              i2 = is(subindxs, j);
              v2 = vs(subindxs, j);
              
              t2 = t2((head_trim+1):(end-tail_trim));
              i2 = i2((head_trim+1):(end-tail_trim));
              v2 = v2((head_trim+1):(end-tail_trim));
              w2 = ones(length(t2),1) * n_i;
              %% WARNING
              w2(round(90e-2 * length(t2)):length(t2)) = n_i * 1e-4;
              w2(round(40e-2 * length(t2)):round(60e-2 * length(t2))) = n_i * 1e-2;
              w2(round(40e-2 * length(t2)):round(60e-2 * length(t2))) = n_i * 1e-2;
              
              [p12, p22] = Bateria().get_phies (t2, i2, v2);
              
              t_vec = zeros(l,1);
              i_vec = zeros(l,1);
              v_vec = zeros(l,1);
              phi1_vec = zeros(l,1);
              phi2_vec = zeros(l,1);
              pesos_vec = zeros(l,1);
              
              t_vec(1:l,1) = [tmp_t; t2];
              i_vec(1:l,1) = [tmp_i; i2];
              v_vec(1:l,1) = [tmp_v; v2];
              phi1_vec(1:l,1) = [tmp_p1; p12];
              phi2_vec(1:l,1) = [tmp_p2; p22];
              pesos_vec(1:l,1) = [tmp_w; w2];
          end
          figure();
          plot(pesos_vec);
          pesos_vec = 1e0 ./ pesos_vec;
          figure();
          plot(pesos_vec);
          %pesos_vec = pesos_vec / norm(pesos_vec);
          table = [t_vec, i_vec, v_vec, phi1_vec, phi2_vec, pesos_vec];
              
      end
    end
    
    methods
    %% CONSTRUCTOR
      function obj = BateriaEstatica()
        obj.r_c = 0e0;
        obj.r_d = 0e0;
        obj.coeficientes_descarga_tipo1 = zeros(1,2);
        obj.coeficientes_descarga_tipo2 = zeros(1,4);
        obj.coeficientes_descarga_tipo3 = zeros(1,7);
      end
    end
    
    methods
      %% DISCHARGE  
      function e_d = battery_discharge_voltage(obj, phi, i, t)
        if (nargin == 4)
            tt = t;
        else
            tt = 3;
        end       
        if ( tt == 1 )
            e_d_coefs = obj.coeficientes_descarga_tipo1;
        elseif ( tt == 2 )
            e_d_coefs = obj.coeficientes_descarga_tipo2;
        else
            e_d_coefs = obj.coeficientes_descarga_tipo3;
        end
        e_d = obj.p_battery_discharge_voltage(phi, i, e_d_coefs, tt);
      end
      
      function v_d = discharge_voltage(obj, phi, i, t)
        e_d = obj.battery_discharge_voltage(phi, i, t);
        v_d = e_d - i * obj.r_d;
      end
      
      function obj = adjust_discharge(obj, archivo, t)
          a = Bateria().datos_carga_a_vector(archivo, 3, 3);
          %t_vec = a(:,1);
          i_vec = a(:,2);
          v_vec = a(:,3);
          phi1_vec = a(:,4);
          phi2_vec = a(:,5);
          pesos = a(:,6);
          
          figure()
          plot(pesos);
          
          ff = @(u) obj.p_rmsd_discharge_voltage(pesos, v_vec, i_vec, phi1_vec, phi2_vec, u, u(end), t);
          
          if ( t == 1 )
            lb = [0e0, -1e0, 0e0];
            ub = [25e0, 0e0, 1e2];
            u0 = [12e0, -1e-3, 1e0];
          elseif ( t == 2 )
            obj = obj.adjust_discharge(archivo, 1);
            lb = [0e0, -1e0, -1e0, -0e0, 0e0];
            ub = [1e2,  0e0,  0e0, 1e0, 1e2];
            u0 = [obj.coeficientes_descarga_tipo1(1)*.8, obj.coeficientes_descarga_tipo1(2), -1e-15, 1e-3, obj.r_d];
          else
            obj = obj.adjust_discharge(archivo, 2);
            lb = [ 0e0, -1e0,    -1e-1,     -1e-1,     -1e-1,      0e0,     -1e-1,  0e0];
            ub = [ 1e2, -0e0,    -0e-0,       0e0,       0e0,     1e-1,       0e0,  1e1];
            u0 = [obj.coeficientes_descarga_tipo2(1), obj.coeficientes_descarga_tipo2(2), -1e-8, -1e-8, -1e-8, 1e-3, -1e-8, obj.r_d];
          end
          %[u, fer] = fmincon(ff, u0,[],[],[],[],lb,ub);
          options = optimset("Display", "iter", "Tolx", 1e-6, "Tolfun", 1e-6);
          [u, fer] = fminsearch(ff, u0, options);
          
          %disp(fer);
          
          %phis = obj.phi_max - phi1_vec + u(3)*phi2_vec;
          %scatter(phis, u(1) + u(2) * phis + u(3) .* i_vec );
          
          if ( t == 1 )
            obj.coeficientes_descarga_tipo1 = u(1:2);
            obj.r_d = u(3);
          elseif ( t == 2 )
            obj.coeficientes_descarga_tipo2 = u(1:4);
            obj.r_d = u(5);
          else
            obj.coeficientes_descarga_tipo3 = u(1:7);
            obj.r_d = u(8);
          end
          
          phis = phi1_vec + obj.r_d * phi2_vec;
          obj.phi_max = max(phis);
      end
      
      function obj = ajuste_coeficientes_descarga(obj, archivo, tipo, u0)
          if ( nargin == 2 )
              u0 = zeros(1,3);
              tipo = 1;
          end
          cabeza = 3;
          cola = 3;
          t_ref = 1e0;
          a = load(archivo, "-ascii");
          n = size(a,1);
          m = size(a,2) / 3;
          pesos = ones(m,1);

          ts = a(:,1:3:end);
          is = a(:,2:3:end);
          vs = a(:,3:3:end);
          phi1 = zeros(n, m);
          phi2 = zeros(n, m);
          for j = 1:m
              [phi1(:,j), phi2(:,j)] = Bateria.get_phies(ts(:,j), is(:,j), vs(:,j));
          end

          n_f = 0;
          for j = 1:m
              n_i = sum(ts(:,j) > t_ref) - cola - cabeza;
              n_f = n_f + n_i;
              pesos(j) = n_i;
          end
          pesos = 1e0 ./ pesos;
          pesos = pesos / norm(pesos);

          v_vec = zeros(n_f,1);
          i_vec = zeros(n_f,1);
          phi1_vec = zeros(n_f,1);
          phi2_vec = zeros(n_f,1);
          t_vec = zeros(n_f,1);
          pesos_vec = zeros(n_f,1);

          n_t = 0;
          for j = 1:m
              n_p = n_t;
              subidxs = ts(:,j) > t_ref;
              k = 0;
              kk = length(subidxs);
              while ( k < cola )
                  if (subidxs(kk) == 1)
                      subidxs(kk) = 0;
                      k = k + 1;
                  end
                  kk = kk - 1;
              end
              k = 0;
              kk = 1;
              while ( k < cabeza )
                  if (subidxs(kk) == 1)
                      subidxs(kk) = 0;
                      k = k + 1;
                  end
                  kk = kk + 1;
              end

              n_i = sum(ts(:,j) > t_ref) - cabeza - cola;
              n_t = n_t + n_i;

              v_vec((n_p+1):n_t)    = vs(subidxs,j);
              i_vec((n_p+1):n_t)    = is(subidxs,j);
              phi1_vec((n_p+1):n_t) = phi1(subidxs,j);
              phi2_vec((n_p+1):n_t) = phi2(subidxs,j);
              t_vec((n_p+1):n_t)    = ts(subidxs,j);
              pesos_vec((n_p+1):n_t) = pesos(j) ;%* (1e0+0*5*sin(pi/2e0*linspace(-1e0, 0e0, n_t - n_p)) .^ 20 +3*sin(pi/2e0*linspace(0e0, 1e0, n_t - n_p)) .^ 20);
              %pesos_vec((n_t-5):n_t) = 0e0;
          end
          
          n = length(pesos_vec);
          p_max = ceil(n / 50e0);
          %p_max = 10;
          l = 6;
          p_vec = linspace(p_max, 1, l);

          for k = 1:l
              p = round(p_vec(k));
              if ( p == 0 ); p = 1; end
              range = 1:p:n;

              if (tipo == 3)
                  ajuste = @(u) Bateria().modelo_estatico_descarga_tipo3(pesos_vec(range), v_vec(range), i_vec(range), phi1_vec(range), phi2_vec(range), u(1), u(2), u(3), u(4), u(5), u(6), u(7), u(8));
                  lb = [ 0e0, -1e0,    -1e-1,     -1e-1,     -1e-1,      0e0,     -1e-1,  0e0];
                  ub = [ 1e2, -0e0,    -0e-0,       0e0,       0e0,     1e-1,       0e0,  1e1];
                  uu0 = [12e0, -1e-3, -1e-8, -1e-8, -1e-8, 1e-3, -1e-8, 1e0];
              elseif (tipo == 2)
                  ajuste = @(u) Bateria().modelo_estatico_descarga_tipo2(pesos_vec(range), v_vec(range), i_vec(range), phi1_vec(range), phi2_vec(range), u(1), u(2), u(3), u(4), u(5));
                  lb = [0e0, -1e0, -1e0, -0e0, 0e0];
                  ub = [1e2,  0e0,  0e0, 1e0, 1e2];
                  uu0 = [12e0, -1e-3, -1e-15, 1e-3, 1e0];
              else
                  ajuste = @(u) Bateria().modelo_estatico_descarga_tipo1(pesos_vec(range), v_vec(range), i_vec(range), phi1_vec(range), phi2_vec(range), u(1), u(2), u(3));
                  lb = [0e0, -1e0, 0e0];
                  ub = [25e0, 0e0, 1e2];
                  uu0 = [12e0, -1e-3, 1e0];
              end

              if(nargin > 3)
                  if(length(u0) > 1)
                      uu0 = u0;
                  end
              end

              if ( k > 1 )
                  uu0 = u;
              end

              %options = optimoptions('fmincon', 'Display','iter', 'Algorithm', 'interior-point',  'OptimalityTolerance', 1e-14, 'StepTolerance', 1e-14);
              %[u, fer] = fmincon(ajuste, uu0, [], [], [], [], lb, ub, [], options);
              options = optimoptions('patternsearch', 'MaxIterations',  1e5, 'MaxFunctionEvaluations', 1e5, 'MeshTolerance', 1e-14, 'StepTolerance', 1e-7);
              disp(['p = ', num2str(p), ', type = ', num2str(tipo)]);
              [u, fer] = patternsearch(ajuste, uu0, [], [], [], [], lb, ub, [], options);
              disp(fer);
          end

          if ( tipo == 3 )
              obj.coeficientes_descarga_tipo3 = u(1:7);
              obj.r_d = u(8);
          elseif ( tipo == 2 )
              obj.coeficientes_descarga_tipo2 = u(1:4);
              obj.r_d = u(5);
          else
              obj.coeficientes_descarga_tipo1 = u(1:2);
              obj.r_d = u(3);
          end

          obj.phi_max = max(phi1_vec + obj.r_d * phi2_vec);
      end
      
      function obj = ajuste_coeficientes_descarga_tipo1(obj, archivo, u0)
          if (nargin > 2)
              obj = obj.ajuste_coeficientes_descarga(archivo, 1, u0);
          else
              obj = obj.ajuste_coeficientes_descarga(archivo);
          end
      end
      
      function obj = ajuste_coeficientes_descarga_tipo2(obj, archivo, u0)
          nargin
          if (nargin > 2)
              obj = obj.ajuste_coeficientes_descarga(archivo, 2, u0);
          else
              obj = obj.ajuste_coeficientes_descarga_tipo1(archivo, 1);
              coefs = obj.coeficientes_descarga_tipo1;
              u0 = [coefs(1), coefs(2), -1e-10, 1e-3, obj.r_d];
              obj = obj.ajuste_coeficientes_descarga(archivo, 2, u0);
          end
      end
      
      function obj = ajuste_coeficientes_descarga_tipo3(obj, archivo, u0)
          nargin
          if (nargin > 2)
              obj = obj.ajuste_coeficientes_descarga(archivo, 3, u0);
          else
              %bateria = Bateria();
              obj = obj.ajuste_coeficientes_descarga_tipo2(archivo);
              coefs = obj.coeficientes_descarga_tipo2;
              u0 = [coefs(1), coefs(2), coefs(3)/3e0, coefs(3)/15e0, coefs(3)/75e0, coefs(4)/2e0, coefs(4)/10e0, obj.r_d];
              %u0 = [12e0, -1e-2, -5e-9, -1e-8, -1e-8, 1e-6, -1e-6, obj.r_d];
              obj = obj.ajuste_coeficientes_descarga(archivo, 3, u0);
          end
      end
    end
    
    methods
      %% CHARGE
     
      function e_c = battery_charge_voltage(obj, phi, i, t)
        if (nargin == 4)
            tt = t;
        else
            tt = 3;
        end       
        if ( tt == 1 )
            e_c_coefs = obj.coeficientes_carga_tipo1;
        elseif ( tt == 2 )
            e_c_coefs = obj.coeficientes_carga_tipo2;
        else
            e_c_coefs = obj.coeficientes_carga_tipo3;
        end
        e_c = obj.p_battery_charge_voltage(phi, i, e_c_coefs, tt);
      end
      
      function v_c = charge_voltage(obj, phi, i, t)
          e_c = obj.battery_charge_voltage(phi, i, t);
          v_c = e_c + i * obj.r_c;
      end
      
      function obj = adjust_charge(obj, archivo, t)
          a = Bateria().datos_carga_a_vector(archivo, 3, 3);
          %t_vec = a(:,1);
          i_vec = a(:,2);
          v_vec = a(:,3);
          phi1_vec = a(:,4);
          phi2_vec = a(:,5);
          pesos = a(:,6);
                    
          ff = @(u) obj.p_rmsd_charge_voltage(pesos, v_vec, i_vec, phi1_vec, phi2_vec, u, u(end), obj.phi_max, t);
          
          if ( t == 1 )
            lb = [0e0, 0e0, 0e0];
            ub = [1e3, 1e0, 1e3];
            u0 = [0e0, 1e0, 0e0];
          elseif ( t == 2 )
            obj = obj.adjust_charge(archivo, 1);
            lb = [0e0, 0e0, 0e0, -1e2, 0e0];
            ub = [1e3, 1e0, 1e0,  1e2, 1e3];
            u0 = [obj.coeficientes_carga_tipo1, 1e-8, 1e-4, obj.r_c];
          else
            obj = obj.adjust_charge(archivo, 2);
            lb = [0e0, 0e0, 0e0, -1e2, -1e2, 0e0];
            ub = [1e3, 1e0, 1e0,  1e2,  1e2, 1e3];
            u0 = [obj.coeficientes_carga_tipo2(1:3), obj.coeficientes_carga_tipo2(4)/2e0, obj.coeficientes_carga_tipo2(4)/1e1, obj.r_c];
          end
          
          [u, fer] = fmincon(ff, u0,[],[],[],[],lb,ub);
          
          disp(fer);
          
          %phis = obj.phi_max - phi1_vec + u(3)*phi2_vec;
          %scatter(phis, u(1) + u(2) * phis + u(3) .* i_vec );
          
          if ( t == 1 )
            obj.coeficientes_carga_tipo1 = u(1:2);
            obj.r_c = u(3);
          elseif ( t == 2 )
            obj.coeficientes_carga_tipo2 = u(1:4);
            obj.r_c = u(5);
          else
            obj.coeficientes_carga_tipo3 = u(1:5);
            obj.r_c = u(6);
          end
      end
      
    end
    
    methods
        %% STATIC
        
        function v_est = voltage_static(obj, phi, i, t)
            if ( nargin == 3 )
                tt = 3;
            else
                tt = t;
            end
            if ( i > 0e0 )
                %v_est = obj.discharge_voltage(phi, i, tt);
                e_d = obj.battery_discharge_voltage(phi, i, tt);
                v_est = e_d - i * obj.r_d;
            else
                e_c = obj.battery_charge_voltage(phi, -i, tt);
                v_est = e_c - i * obj.r_c;
            end
        end
        
        function e = battery_voltage_static(obj, phi, i, t)
            if ( nargin == 3 )
                tt = 3;
            else
                tt = t;
            end
            if ( i > 0e0 )
                %v_est = obj.discharge_voltage(phi, i, tt);
                e = obj.battery_discharge_voltage(phi, i, tt);
            else
                e = obj.battery_charge_voltage(phi, -i, tt);
            end
        end
        
    end
    
    methods
      %% DYNAMIC

      function v_estatico = modelo_estatico(obj, phi, i, r_1, r_2)
          if sign(i) > 0e0
              e_d = obj.voltaje_pila_descarga(phi, i);
              r = obj.r_d - r_1 - r_2;
              v_estatico = e_d - r * i;
          else
              e_c = obj.voltaje_pila_carga(phi, abs(i));
              r = obj.r_c - r_1 - r_2;
              v_estatico = e_c + r * i;
          end
      end
    end
end