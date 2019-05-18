classdef PanelSolar
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    s
    p
    v_oc_cell % V
    i_sc_cell % A
    v_mp_cell % V
    i_mp_cell % A
    dvoc_dt_cell % V/K
    disc_dt_cell % I/K
    dvmp_dt_cell % V/K
    dimp_dt_cell % A/K
    t_ref % K
    e_ref % W m^-2
    v_oc
    i_sc
    v_mp
    i_mp
    gamma
    m
    param_d1r2
  end
  
  methods
    function obj = PanelSolar ( ...
        s, p, ...
        v_oc_cell, i_sc_cell, v_mp_cell, i_mp_cell, ...
        dvoc_dt_cell, disc_dt_cell, dvmp_dt_cell, dimp_dt_cell, ...
        t_ref, e_ref)
      %UNTITLED2 Construct an instance of this class
      %   Detailed explanation goes here
      obj.s = s;
      obj.p = p;
      obj.v_oc_cell = v_oc_cell;        % V
      obj.i_sc_cell =i_sc_cell;         % A
      obj.v_mp_cell = v_mp_cell;        % V
      obj.i_mp_cell = i_mp_cell;        % A
      obj.dvoc_dt_cell = dvoc_dt_cell;  % V/K
      obj.disc_dt_cell = disc_dt_cell;  % I/K
      obj.dvmp_dt_cell = dvmp_dt_cell;  % V/K
      obj.dimp_dt_cell = dimp_dt_cell;  % A/K
      obj.t_ref = t_ref;                % K
      obj.e_ref = e_ref;                % W m^-2
      obj.i_sc = i_sc_cell * p;         % A
      obj.v_oc = v_oc_cell * s;         % V
      obj.i_mp = i_mp_cell * p;         % A
      obj.v_mp = v_mp_cell * s;         % V
    end
  end
  
  methods(Static = true)
    function parametros = p_parametros_diodo (v_oc, i_sc, v_mp, i_mp, t, e, e_ref, s)
      % Constantes
      k = 1.3806503e-23;   %Boltzmann [J/K]
      q = 1.60217646e-19;  %Electron charge [C]

      % Estimacion de 'a'
      alf = 1.2;

      % Voltaje termico
      v_t = s*k*t/q;

      % Coeficientes
      a_n = alf * v_t;
      a_d = i_mp;
      a = a_n ./ a_d;

      b_n = - v_mp .* (2e0*i_mp - i_sc);
      b_d =  v_mp .* i_sc + v_oc .* (i_mp - i_sc);
      b = b_n / b_d;

      c_1 = -(2e0*v_mp-v_oc)./(alf*v_t);
      c_2 = +(v_mp.*i_sc - v_oc .* i_sc) / (v_mp .* i_sc + v_oc .* (i_mp - i_sc));
      c = c_1 + c_2;

      d = (v_mp - v_oc) ./ (alf * v_t);

      % Parametros del cir. 1D/2R
      r_s = a .* (lambertw(-1,b.*exp(c)) - (c+d));

      r_sh_n = (v_mp - i_mp .* r_s) .* (v_mp - r_s .* (i_sc - i_mp) - alf .* v_t);
      r_sh_d = (v_mp - i_mp .* r_s) .* (i_sc - i_mp) - alf .* v_t .* i_mp;
      r_sh = r_sh_n / r_sh_d;

      i_0 = ((r_sh + r_s) .* i_sc - v_oc) / (r_sh .* exp(v_oc / alf / v_t));

      i_pv_ref = (1e0 + r_s / r_sh) .* i_sc;
      i_pv = i_pv_ref * e / e_ref;

      % Devolver estructura
      parametros.i_pv = i_pv;
      parametros.i_0 = i_0;
      parametros.r_s = r_s;
      parametros.a = alf;
      parametros.v_t = v_t;
      parametros.r_sh = r_sh;
    end
    
    function cur_out = p_current_d1r2(v, v_oc, i_sc, v_mp, i_mp, t, e, e_ref, n)
      p = PanelSolar.p_parametros_diodo(v_oc, i_sc, v_mp, i_mp, t, e, e_ref, n);
      if ( v > v_oc )
        cur_out = 0e0;
      elseif (v < 0e0 )
        cur_out = 0e0;
      else
        f_cur = @(cur) real(p.i_pv - p.i_0 * (exp((v + cur * p.r_s)/p.a/p.v_t)) - (v + cur * p.r_s) / p.r_sh);
        f_cur(i_sc / 2e0);
        f_solve = @(x) abs(x - f_cur(x));
        options = optimoptions("fsolve", "Display", "none");
        cur_out = fsolve(f_solve, i_sc, options);
      end
    end
    
    function cur = p_corriente_KarmalkarHaneefa(v_oc, i_sc, gamma, m)
      %a = parametros_KarmalkarHaneefa(obj, t, e);
      %disp(a);
      v_adim = v / v_oc;
      c = [1e0; -(1e0 - gamma); -gamma];
      t = ones(3,1) * v_adim ;
      e = [0e0; 1e0; m];
      i_adim = sum(c .* (t .^ e), 1);
      cur = i_adim * i_sc;
    end
  end
  
  methods
    
    function cur = corriente_KarmalkarHaneefa(obj, v)
      %a = parametros_KarmalkarHaneefa(obj, t, e);
      disp(obj);
      v_adim = v / obj.v_oc;
      c = [1e0; -(1e0 - obj.gamma); -obj.gamma];
      t = ones(3,1) * v_adim ;
      e = [0e0; 1e0; obj.m];
      i_adim = sum(c .* (t .^ e), 1);
      cur = i_adim * obj.i_sc; 
    end
    
    function cur_out = corriente_d1r2(obj, v, t, e)
      cur_out = PanelSolar.p_current_d1r2(v, obj.v_oc, obj.i_sc, obj.v_mp, obj.i_mp, t, e, obj.e_ref, obj.s);
    end
    
    function obj = parametros_d1r2(obj, t, e)
      obj.v_oc = obj.s * (obj.v_oc_cell + obj.dvoc_dt_cell * (t - obj.t_ref));
      obj.v_mp = obj.s * (obj.v_mp_cell + obj.dvmp_dt_cell * (t - obj.t_ref));
      obj.i_sc = obj.p * (obj.i_sc_cell + obj.disc_dt_cell * (t - obj.t_ref));
      obj.i_mp = obj.p * (obj.i_mp_cell + obj.dimp_dt_cell * (t - obj.t_ref));
      obj.param_d1r2 = PanelSolar.p_parametros_diodo (obj.v_oc, obj.i_sc, obj.v_mp, obj.i_mp, t, e, obj.e_ref, obj.s);
    end

    function obj = adjust(obj, t, e)
      %data = importdata(filename, "\t", 1);
      %v_exp = data.data(:,1)';
      %i_exp = data.data(:,2)';
      
      obj = obj.parametros_d1r2(t, e);
            
%       v_oc_panel = max(v_exp);
%       i_sc_panel = max(i_exp);
%       obj.s = round(v_oc_panel / obj.v_oc_cell);
%       obj.p = round(i_sc_panel / obj.i_sc_cell);
%       %temp_exp = (v_oc_panel - obj.s * obj.v_oc_cell) / obj.dvoc_dtemp_cell + 28e0;
%       
%       i_kh = @(u) PanelSolar.p_corriente_KarmalkarHaneefa(v_exp, u(1), u(2), u(3), u(4));
%       f_rmsd = @(u) norm(i_exp - i_kh (v_exp, u(1), u(2), u(3), u(4)));
%       [u, valor_rmsd] = fminsearch(f_rmsd, [v_oc_panel, i_sc_panel, 1e0, 32e0]);
%       disp(["gamma: ",  num2str(u(3))]);
%       disp(["m: ",  num2str(u(4))]);
%       disp(["Error RMSD del ajuste numerico: ", num2str(valor_rmsd/sqrt(length(v_exp)))]);
    end
  end
end
