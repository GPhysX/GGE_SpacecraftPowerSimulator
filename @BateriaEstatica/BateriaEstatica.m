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
          e_d = BateriaEstatica.p_battery_discharge_voltage_type1(phi, i, e_d_coefs);
        elseif ( t == 2 )
          e_d = BateriaEstatica.p_battery_discharge_voltage_type2(phi, i, e_d_coefs);
        else
          e_d = BateriaEstatica.p_battery_discharge_voltage_type3(phi, i, e_d_coefs);
        end
      end
      
      function v_d = p_discharge_voltage(phi, i, e_d_coefs, r_d, t)
        if ( t == 1 )
          e_d = BateriaEstatica.p_battery_discharge_voltage_type1(phi, i, e_d_coefs);
        elseif ( t == 2 )
          e_d = BateriaEstatica.p_battery_discharge_voltage_type2(phi, i, e_d_coefs);
        else
          e_d = BateriaEstatica.p_battery_discharge_voltage_type3(phi, i, e_d_coefs);
        end
        v_d = e_d - r_d .* i;
      end
      
      function fer = p_rmsd_discharge_voltage (weigth, v, i, phi1, phi2, e_d_coefs, r_d, t)
      %disp(nargin)
      %fflush(stdout);
        phi = phi1 + r_d * phi2;
        v2 = BateriaEstatica.p_discharge_voltage(phi, i, e_d_coefs, r_d, t);
        fer = BateriaEstatica.p_rmsd(v2, v, weigth);
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
          e_c = BateriaEstatica.p_battery_charge_voltage_type1(phi, i, e_c_coefs);
        elseif ( t == 2 )
          e_c = BateriaEstatica.p_battery_charge_voltage_type2(phi, i, e_c_coefs);
        else
          e_c = BateriaEstatica.p_battery_charge_voltage_type3(phi, i, e_c_coefs);
        end
      end
      
      function v_c = p_charge_voltage(phi, i, e_c_coefs, r_c, t)
        if ( t == 1 )
          e_c = BateriaEstatica.p_battery_charge_voltage_type1(phi, i, e_c_coefs);
        elseif ( t == 2 )
          e_c = BateriaEstatica.p_battery_charge_voltage_type2(phi, i, e_c_coefs);
        else
          e_c = BateriaEstatica.p_battery_charge_voltage_type3(phi, i, e_c_coefs);
        end
        v_c = e_c + r_c .* i;
      end
      
      function fer = p_rmsd_charge_voltage (weigth, v, i, phi1, phi2, e_c_coefs, r_c, phi0, t)
        phi = phi0 - phi1 + r_c * phi2;
        v2 = BateriaEstatica.p_charge_voltage(phi, i, e_c_coefs, r_c, t);
        fer = BateriaEstatica.p_rmsd(v2, v, weigth);
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
            w2(round(40e-2 * length(t2)):round(60e-2 * length(t2))) = n_i * 1e0;
            w2(1:round(5e-2 * length(t2))) = n_i * 1e-4;

            [p12, p22] = BateriaEstatica().get_phies (t2, i2, v2);

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
          %figure();
          %plot(pesos_vec);
          pesos_vec = 1e0 ./ pesos_vec;
          %figure();
          %plot(pesos_vec);
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
      
      function obj = adjust_discharge(obj, archivo, t, do_print)
        if ( nargin == 3 )
          do_print = false;
        elseif ( nargin == 4 )
          if ( do_print == [] )
            do_print = false;
          end
        end
        
        a = BateriaEstatica().datos_carga_a_vector(archivo, 3, 3);
        %t_vec = a(:,1);
        i_vec = a(:,2);
        v_vec = a(:,3);
        phi1_vec = a(:,4);
        phi2_vec = a(:,5);
        pesos = a(:,6);

        ff = @(u) obj.p_rmsd_discharge_voltage( ...
          pesos, v_vec, i_vec, phi1_vec, phi2_vec, u, u(end), t);

        if ( t == 1 )
          %lb = [0e0, -1e0, 0e0];
          %ub = [25e0, 0e0, 1e2];
          u0 = [12e0, -1e-5, 1e-2];
        elseif ( t == 2 )
          obj = obj.adjust_discharge(archivo, 1);
          %lb = [0e0, -1e0, -1e0, -0e0, 0e0];
          %ub = [1e2,  0e0,  0e0, 1e0, 1e2];
          u0 = [ ...
            obj.coeficientes_descarga_tipo1(1)*.8, ...
            obj.coeficientes_descarga_tipo1(2), ...
            -1e-15, ...
            1e-3, ...
            obj.r_d];
        else
          obj = obj.adjust_discharge(archivo, 2);
          %lb = [ 0e0, -1e0,    -1e-1,     -1e-1,     -1e-1,      0e0,     -1e-1,  0e0];
          %ub = [ 1e2, -0e0,    -0e-0,       0e0,       0e0,     1e-1,       0e0,  1e1];
          u0 = [ ...
            obj.coeficientes_descarga_tipo2(1), ...
            obj.coeficientes_descarga_tipo2(2), ...
            -1e-8, ...
            -1e-8, ...
            -1e-8, ...
            +1e-3, ...
            -1e-8, ...
            obj.r_d];
        end
        %[u, fer] = fmincon(ff, u0,[],[],[],[],lb,ub);
        if ( do_print )
          options = optimset("Display", "iter", "Tolx", 1e-8, "Tolfun", 1e-8);
        else
          options = optimset("Tolx", 1e-8, "Tolfun", 1e-8);
        end
        u = fminsearch(ff, u0, options);

        if ( t == 1 )
          obj.coeficientes_descarga_tipo1 = u(1:2);
          obj.r_d = u(3);
          if ( do_print )
            disp(strcat("E_0^d = ", num2str(u(1))));
            disp(strcat("E_1^d = ", num2str(u(2))));
            disp(strcat("R_d = ", num2str(u(3))));
          end
        elseif ( t == 2 )
          obj.coeficientes_descarga_tipo2 = u(1:4);
          obj.r_d = u(5);
          if ( do_print )
            disp(strcat("E_0^d = ", num2str(u(1))));
            disp(strcat("E_1^d = ", num2str(u(2))));
            disp(strcat("E_{2}^d = ", num2str(u(3))));
            disp(strcat("E_{3}^d = ", num2str(u(4))));
            disp(strcat("R_d = ", num2str(u(5))));
          end
        else
          obj.coeficientes_descarga_tipo3 = u(1:7);
          obj.r_d = u(8);
          if ( do_print )
            disp(strcat("E_0^d = ", num2str(u(1))));
            disp(strcat("E_1^d = ", num2str(u(2))));
            disp(strcat("E_{20}^d = ", num2str(u(3))));
            disp(strcat("E_{21}^d = ", num2str(u(4))));
            disp(strcat("E_{22}^d = ", num2str(u(5))));
            disp(strcat("E_{30}^d = ", num2str(u(6))));
            disp(strcat("E_{31}^d = ", num2str(u(7))));
            disp(strcat("R_d = ", num2str(u(8))));
          end
        end

        phis = phi1_vec + obj.r_d * phi2_vec;
        obj.phi_max = max(phis);
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

    function obj = adjust_charge(obj, archivo, t, do_print)
      if ( nargin == 3 )
        do_print = false;
      elseif ( nargin == 4 )
        if ( do_print == [] )
          do_print = false;
        end
      end
      
      a = BateriaEstatica().datos_carga_a_vector(archivo, 0, 0);
      %t_vec = a(:,1);
      i_vec = a(:,2);
      v_vec = a(:,3);
      phi1_vec = a(:,4);
      phi2_vec = a(:,5);
      pesos = a(:,6);

      ff = @(u) obj.p_rmsd_charge_voltage( ...
        pesos, v_vec, i_vec, phi1_vec, phi2_vec, u, u(end), obj.phi_max, t);

      if ( t == 1 )
        %lb = [0e0, 0e0, 0e0];
        %ub = [1e3, 1e0, 1e3];
        u0 = [12e0, 1e-5, 1e-2];
      elseif ( t == 2 )
        obj = obj.adjust_charge(archivo, 1);
        %lb = [0e0, 0e0, 0e0, -1e2, 0e0];
        %ub = [1e3, 1e0, 1e0,  1e2, 1e3];
        u0 = [obj.coeficientes_carga_tipo1, 1e-14, 1e-3, obj.r_c];
      else
        obj = obj.adjust_charge(archivo, 2);
        %lb = [0e0, 0e0, 0e0, -1e2, -1e2, 0e0];
        %ub = [1e3, 1e0, 1e0,  1e2,  1e2, 1e3];
        u0 = [ ...
          obj.coeficientes_carga_tipo2(1:3), ...
          obj.coeficientes_carga_tipo2(4)/2e0, ...
          obj.coeficientes_carga_tipo2(4)/1e1, ...
          obj.r_c];
      end
      %[u, fer] = fmincon(ff, u0,[],[],[],[],lb,ub);
      if ( do_print )
        options = optimset("Display", "iter", "Tolx", 1e-6, "Tolfun", 1e-6);
      else
        options = optimset("Tolx", 1e-6, "Tolfun", 1e-6);
      end
      u = fminsearch(ff, u0, options);          

      if ( t == 1 )
        obj.coeficientes_carga_tipo1 = u(1:2);
        obj.r_c = u(3);
        if ( do_print )
          disp(strcat("E_0^c = ", num2str(u(1))));
          disp(strcat("E_1^c = ", num2str(u(2))));
          disp(strcat("R_c = ", num2str(u(3))));
        end
      elseif ( t == 2 )
        obj.coeficientes_carga_tipo2 = u(1:4);
        obj.r_c = u(5);
        if ( do_print )
          disp(strcat("E_0^c = ", num2str(u(1))));
          disp(strcat("E_1^c = ", num2str(u(2))));
          disp(strcat("E_2^c = ", num2str(u(3))));
          disp(strcat("E_3^c = ", num2str(u(4))));
          disp(strcat("R_c = ", num2str(u(5))));
        end
      else
        obj.coeficientes_carga_tipo3 = u(1:5);
        obj.r_c = u(6);
        if ( do_print )
          disp(strcat("E_0^c = ", num2str(u(1))));
          disp(strcat("E_1^c = ", num2str(u(2))));
          disp(strcat("E_2^c = ", num2str(u(3))));
          disp(strcat("E_{30}^c = ", num2str(u(4))));
          disp(strcat("E_{31}^c = ", num2str(u(5))));
          disp(strcat("R_c = ", num2str(u(6))));
        end
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