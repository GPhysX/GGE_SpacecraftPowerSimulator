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
v_oc = @(t) (v_oc_raw + n * dvoc_dtemp * (temp(t) - 28e0));
i_sc = @(t) (i_sc_raw + m * disc_dtemp * (temp(t) - 28e0));
v_mp = @(t) (v_mp_raw + n * dvmp_dtemp * (temp(t) - 28e0));
i_mp = @(t) (i_mp_raw + m * dimp_dtemp * (temp(t) - 28e0));
%% Inicializadores
thetas = zeros(M,1);
thetas = linspace(0e0, pi, M);
time = thetas / omega;
vs = zeros(M,1);
is = zeros(M,1);

%% Bucle
i = 0;
for t = time
  i += 1;
  theta_i = thetas(i);
  temp_i = temp(t) + 273.15;
  v_oc_i = v_oc(t);
  i_sc_i = i_sc(t);
  v_mp_i = v_mp(t);
  i_mp_i = i_mp(t);
  cos_dir_i = cos_dir(t);
  [i_pv_ref, i_0, r_s, a, v_t, r_sh] = ...
      f_datos_circuito_diodo (n, temp_i, v_oc_i, i_sc_i, v_mp_i, i_mp_i);
  i_pv = i_pv_ref * cos_dir_i;
  if abs(imag(i_pv)) < 1e-20; i_pv = real(i_pv); end;
  if abs(imag(i_0)) < 1e-20; i_0 = real(i_0); end;
  if abs(imag(r_s)) < 1e-20; r_s = real(r_s); end;
  if abs(imag(r_sh)) < 1e-20; r_sh = real(r_sh); end;
  if abs(imag(v_t)) < 1e-20; v_t = real(v_t); end;
  ff_diodo = @(cur, v) f_diodo(cur, v, i_pv, i_0, a, v_t, r_s, r_sh);
  ff_zeros = @(v) v / resis - ff_diodo(v / resis, v);
  %v = fsolve(ff_zeros, v_oc_raw);
  v = fzero(ff_zeros, [-1e0, v_oc_raw]);
  is(i) = ff_diodo(v/resis, v);
  vs(i) = v;
end;

plot(time, is);


gnuplot_curves_2(time', vs, is, "Corriente y tensi\\\\'on producida por el panel solar en simulaci\\\\'on", {"$t$ [s]", "$V$ [V]", "$I$ [A]"}, {"Corriente", "Tensi\\\\'on"}, "Diodo");