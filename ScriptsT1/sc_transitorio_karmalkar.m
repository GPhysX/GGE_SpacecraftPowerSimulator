close all
clear
clc

%% Importar datos
filename = "data.dat";
resis = 37.2;
sc_datos_datasheet;
[v_exp, i_exp] = fc_datos_experimentales (filename);
[v_oc_panel, i_sc_panel, n, m] = fc_dimensionado_panel (filename);


%% Transitorio de potencia.
M = 1000;
omega = 52e-3;  % rad/s
resis = 37.2;   % Ohm
t0 = 15.0;        % s
t_frio = -2e1;  % C
t_cal = 8e1;    % C
t_ref = 28e0;   % C
[_, i] = max(v_exp .* i_exp);
v_mp_panel = v_exp(i);
i_mp_panel = i_exp(i);
i_mp_raw = i_mp_panel;
v_mp_raw = v_mp_panel;
i_sc_raw = i_sc_panel;
v_oc_raw = v_oc_panel;

%% Funciones en funcion del tiempo
temp = @(t) f_temperatura(omega * t , omega, t0, t_frio, t_cal);
cos_dir = @(t) f_incidencia(omega * t);
v_oc = @(t) v_oc_raw + n * dvoc_dtemp * (temp(t) - 28e0);
i_sc = @(t) i_sc_raw + m * disc_dtemp * (temp(t) - 28e0);
v_mp = @(t) v_mp_raw + n * dvmp_dtemp * (temp(t) - 28e0);
i_mp = @(t) i_mp_raw + m * dimp_dtemp * (temp(t) - 28e0);

%% Inicializadores
thetas = linspace(0e0, pi, M);
time = thetas / omega;
vs = zeros(M,1);
is = zeros(M,1);

a = [time; temp(time)]';
save "Tx.dat" a;

a = [time; cos_dir(time)]';
save "Cx.dat" a;

%% Bucle
i = 0;
for t = time;
  i += 1;
  theta_i = thetas(i);
  temp_i = temp(t) + 273.15;
  v_oc_i = v_oc(t);
  v_mp_i = v_mp(t);
  i_mp_i = i_mp(t);
  cos_dir_i = cos_dir(t);
  i_sc_i = i_sc(t) * cos_dir_i;
  i_mp_i = i_mp(t) * cos_dir_i;
  
  if cos_dir_i <= 1e-4
    v = 0e0;
    cur = 0e0;
  else
    [v_oc_i, i_sc_i, gamma_i, m_i] = f_karmalkar_analitico (n, temp_i, v_oc_i, i_sc_i, v_mp_i, i_mp_i);
    ff_zero = @(v) v / resis - f_i_kh (v, v_oc_i, i_sc_i, gamma_i, m_i);
    %v = fsolve(ff_zero, v_oc_i);
    v = fzero(ff_zero, [0e0, v_oc_i]);
    cur = f_i_kh (v, v_oc_i, i_sc_i, gamma_i, m_i);
    gamma_i;
    
  end;

  is(i) = cur;
  vs(i) = v;
end;

figure();
plot(thetas, is);

a = [time; is']';
save "ti_KH.dat" a;

figure();
plot(vs, is);
figure();
plot(time, vs .* is);

a = [time; vs']';
save "tv_KH.dat" a;

a = [time; (is.*vs)']';
save "tp_KH.dat" a;

%gnuplot_curves(vs, is, "Curva I-V en simulaci\\'on", {"$V$ [V]", "$I$ [A]"}, {"NONE"});


gnuplot_curves_2(time', vs, is, "Corriente y tensi\\\\'on producida por el panel solar en simulaci\\\\'on", {"$t$ [s]", "$V$ [V]", "$I$ [A]"}, {"Corriente", "Tensi\\\\'on"}, "KH");