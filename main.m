%clear all
close all
clc

trabajo = 4;
ejemplo = Examples();

if ( trabajo == 1 )
  ejemplo.ex_orbita_sunsync();
  close all;
elseif ( trabajo == 2 )
  ejemplo.ex_curvaiv_panelsolar();
  close all;
elseif ( trabajo == 3 )
  bateria = ejemplo.ex_bateria_ajuste();
  close all
else
  n_sol_i = [1e0, 0e0, 0e0];
  omega = 0.01 * 180e0 / pi;
  %omega = 0e0;
  [panel, orbita, periodo, bateria, satelite] = ejemplo.ex_simulacion();
  bateria.s = 1;
  bateria.p = 2;
  satelite.bateria = bateria;
  n = 8000;
  t0 = 0e0;
  tf = 24e0 * 60e0 * 60e0;
  ts = linspace(t0, tf, n);
  dt = (tf - t0) / n;
  fxm = zeros(n,1);
  fym = zeros(n,1);
  fzm = zeros(n,1);
  fxp = zeros(n,1);
  fyp = zeros(n,1);
  fzp = zeros(n,1);
  tas = 360e0 * ts / periodo;
  phi = zeros(n,1);
  ir1 = zeros(n,1);
  ir2 = zeros(n,1);
  ips = zeros(n,1);
  ibt = zeros(n,1);
  v_s = zeros(n,1);
  pwr = zeros(n,1);
  pps = zeros(n,1);
  pbt = zeros(n,1);
  i = 1;
  for t = ts(1:(length(ts)-1))
    %% AJUSTES DE TIEMPO
    phi_i = phi(i);
    ir1_i = ir1(i);
    ir2_i = ir2(i);
    satelite.bateria.i_r1 = ir1_i;
    satelite.bateria.i_r2 = ir2_i;
    ta = 360e0 * t / periodo;
    satelite = satelite.cambiarAnomaliaVerdadera(ta);
    dtheta = omega * dt;
    satelite = satelite.rotar(theta, 1);
    temp = simulacion_temperatura(ta);
    pwr_i = simulacion_potencia(ta, periodo);
    pwr(i) = pwr_i;
    
    %% FACTORES DE VISTA
    fe = satelite.factorEclipse(n_sol_i);
    fxm_i = fe*satelite.cosenoPanel(n_sol_i, 3);
    fym_i = fe*satelite.cosenoPanel(n_sol_i, 5);
    fzm_i = fe*satelite.cosenoPanel(n_sol_i, 1);
    fxp_i = fe*satelite.cosenoPanel(n_sol_i, 4);
    fyp_i = fe*satelite.cosenoPanel(n_sol_i, 6);
    fzp_i = fe*satelite.cosenoPanel(n_sol_i, 2);
    
    %% IRRADIANCIA EN PANELES
    es = 1367 * ones(6, 1);
    es(1) = es(1) * fzm_i;
    es(2) = es(2) * fzp_i;
    es(3) = es(3) * fxm_i;
    es(4) = es(4) * fxp_i;
    es(5) = es(5) * fym_i;
    es(6) = es(6) * fzp_i;
    
    satelite.paneles.XM = satelite.paneles.XM.adjust(temp, es(1));
    satelite.paneles.YM = satelite.paneles.YM.adjust(temp, es(2));
    satelite.paneles.ZM = satelite.paneles.ZM.adjust(temp, es(3));
    satelite.paneles.XP = satelite.paneles.XP.adjust(temp, es(4));
    satelite.paneles.YP = satelite.paneles.YP.adjust(temp, es(5));
    satelite.paneles.ZP = satelite.paneles.ZP.adjust(temp, es(6));
    
    %% RESOLVER PROBLEMA
    f_solve = @(u) simulacion_sistema(u(1), u(2), u(3), temp, es, pwr_i, phi_i, satelite);
    options = optimoptions("fsolve", "Display", "none");
    u = fsolve(f_solve, [12e0, 1e0, 1e0], options);
    v_i = u(1);
    ips_i = u(2);
    ibt_i = u(3);
    
    v_s(i) = v_i;
    ips(i) = ips_i;
    ibt(i) = ibt_i;
    
    pps(i) = v_i * ips_i;
    pbt(i) = v_i * ibt_i;
    
    %% CALCULAR VALORES EN FUTURO
    i_bat_modulo = ibt_i / satelite.bateria.p;
    phi(i+1) = phi_i + dt * i_bat_modulo * satelite.bateria.voltage_static(phi_i, i_bat_modulo, 3);
    ir1(i+1) = ir1_i + dt * (i_bat_modulo - ir1_i) / (satelite.bateria.c_1 * satelite.bateria.r_1);
    ir2(i+1) = ir2_i + dt * (i_bat_modulo - ir2_i) / (satelite.bateria.c_2 * satelite.bateria.r_2);
    
    %% GUARDAR DATOS Y ASIGNAR VALORES FUTUROS
    fxm(i+1) = fxm_i;
    fym(i+1) = fym_i;
    fzm(i+1) = fzm_i;
    fxp(i+1) = fxp_i;
    fyp(i+1) = fyp_i;
    fzp(i+1) = fzp_i;
    i = i + 1;
    
    %% PORCENTAJE SIM.
    disp(strcat(num2str(1e2 * t / ts(length(ts)-1), 5), " %"));
  end
%   nu_pre_eclipse = 0e0;
%   nu_pos_eclipse = 0e0;
%   eclipse = false;
%   for i = 1:(n-1)
%     dta = tas(i+1) - tas(i);
%     dt = periodo / n;
%     t = i * dt;
%     satelite = satelite.aumentarAnomaliaVerdadera(dta);
%     theta = - omega * dt;
%     satelite = satelite.rotar(theta, 1);
%     fe = satelite.factorEclipse(n_sol_i);
%     fxm(i+1) = fe*satelite.cosenoPanel(n_sol_i, 3);
%     fym(i+1) = fe*satelite.cosenoPanel(n_sol_i, 5);
%     fzm(i+1) = fe*satelite.cosenoPanel(n_sol_i, 1);
%     fxp(i+1) = fe*satelite.cosenoPanel(n_sol_i, 4);
%     fyp(i+1) = fe*satelite.cosenoPanel(n_sol_i, 6);
%     fzp(i+1) = fe*satelite.cosenoPanel(n_sol_i, 2);
%     if ( fe == 0 && ~eclipse )
%       nu_pre_eclipse = tas(i+1);
%       eclipse = true;
%     end
%     if ( fe == 1 && eclipse )
%       nu_pos_eclipse = tas(i+1);
%       eclipse = false;
%     end
%  end

%% GRAFICAS
%% FV
fig = figure();
hold on;
grid on;
box on;
title("Irradiancia sobre los paneles solares");
xlabel("TA [deg]");
ylabel("E/E_{ref} [-]");
plot(tas, fxm, "rx--", "DisplayName", "Fxm");
plot(tas, fym, "bd--", "DisplayName", "Fym");
plot(tas, fzm, "g+--", "DisplayName", "Fzm");
plot(tas, fxp, "rx-", "DisplayName", "Fxp");
plot(tas, fyp, "bd-", "DisplayName", "Fyp");
plot(tas, fzp, "g+-", "DisplayName", "Fzp");
legend();
%% IBT
fig = figure();
grid on;
box on;
title("Intensidad de la bateria");
xlabel("TA [deg]");
ylabel("I [A]");
plot(tas, ibt);

%% DOD
fig = figure();
grid on;
box on;
title("Profundidad de descarga");
xlabel("TA [deg]");
ylabel("DoD [%]");
plot(tas, phi / satelite.bateria.phi_max * 100);

%% PWR
fig = figure();
hold on;
grid on;
box on;
title("Potencia");
xlabel("TA [deg]");
ylabel("P [W]");
plot(tas, pwr, "DisplayName", "EQUIPOS");
plot(tas, pps, "DisplayName", "PANEL");
plot(tas, pbt, "DisplayName", "BATERIA");
legend();

%% END
end
% bateria.r_1 = bateria.r_d / 3e0;
% bateria.r_2 = bateria.r_d / 3e0;
% bateria.c_1 = bateria.r_d / 1e-3;
% bateria.c_2 = bateria.r_d / 1e-3;
% bateria.r_int = bateria.r_d / 3e0;
% 
% a = load("data/medidas_bateria.dat");
% tE = a(:,1);
% vE = a(:,2);
% iE = a(:,3);
% 
% fv = @(phi) bateria.coeficientes_carga_tipo1(1) + bateria.coeficientes_carga_tipo1(2) * phi + bateria.r_c * 5e0;
% phis = linspace(bateria.phi_max, 0e0, 1000);
% 


%bat = struct(bateria);

