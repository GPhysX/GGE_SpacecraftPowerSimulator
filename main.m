%clear all
close all
clc

options = optimoptions("fsolve", "Display", "none");

trabajo = 4;
ejemplo = Examples();

if ( trabajo == 1 )
  ejemplo.ex_orbita_sunsync();
  %close all;
elseif ( trabajo == 2 )
  ejemplo.ex_curvaiv_panelsolar();
  close all;
elseif ( trabajo == 3 )
  bateria = ejemplo.ex_bateria_ajuste();
  close all
else
  n_sol_i = [1e0, 0e0, 0e0];
  omega = 0.01 * 180e0 / pi;
  j2 = 1.08263e-3;
  %omega = 0e0;
  if not(exist('panel_p', 'var') & exist('panel_g', 'var') & exist('panel_v', 'var') & exist('orbita', 'var') & exist('periodo', 'var') & exist('bateria', 'var') & exist('satelite', 'var') & exist('cnvs', 'var'))
    [panel_p, panel_g, panel_v, orbita, periodo, bateria, cnvs, satelite] = ejemplo.ex_simulacion(true);
  end
  bateria.s = 1;
  bateria.p = 4;
  satelite.bateria = bateria;
  dt = 20e0;
  t0 = 0e0;
  tf = 24e0 * 60e0 * 60e0;
  %tf = 90 * 6e1 * 2;
  n = int64((tf-t0)/dt);%8000;
  ts = linspace(t0, tf, n);
  %dt = (tf - t0) / n;
  tas = 360e0 * ts / periodo;
  
  fxm = zeros(n,1);
  fym = zeros(n,1);
  fzm = zeros(n,1);
  fxp = zeros(n,1);
  fyp = zeros(n,1);
  fzp = zeros(n,1);
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
    delta_omega = -3e0 * pi * j2 * (6378e0 * satelite.orbita.ecc/ satelite.orbita.sma / (1e0 / satelite.orbita.ecc - satelite.orbita.ecc)) ^ 2e0 * cosd(satelite.orbita.inc);
    satelite = satelite.cambiarAnomaliaVerdadera(ta);
    satelite = satelite.aumentarRAAN(delta_omega);
    dtheta = omega * dt;
    satelite = satelite.rotar(dtheta, 1);
    temp = simulacion_temperatura(ta);
    pwr_i = simulacion_potencia(ta, periodo, cnvs);
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
    es(6) = es(6) * fyp_i;
    
    %satelite.paneles.XM = satelite.paneles.XM.adjust(temp, es(1));
    satelite.paneles.YM = satelite.paneles.YM.adjust(temp, es(2));
    satelite.paneles.ZM = satelite.paneles.ZM.adjust(temp, es(3));
    %satelite.paneles.XP = satelite.paneles.XP.adjust(temp, es(4));
    satelite.paneles.YP = satelite.paneles.YP.adjust(temp, es(5));
    satelite.paneles.ZP = satelite.paneles.ZP.adjust(temp, es(6));
    
    %% RESOLVER PROBLEMA
    f_solve = @(u) simulacion_sistema(u(1), u(2), u(3), temp, es, pwr_i, phi_i, satelite);
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

%% GRAFICAS
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
%% FV
fig = figure('Units', 'points', 'Position', resolucion);
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
print(fig, 'Figuras/FV.eps', '-depsc', '-r0');

%% IBT
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title("Intensidad de la bateria");
xlabel("TA [deg]");
ylabel("I [A]");
plot(tas, ibt);
print(fig, 'Figuras/IBT.eps', '-depsc', '-r0');

%% DOD
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title("Profundidad de descarga");
xlabel("TA [deg]");
ylabel("DoD [%]");
plot(tas, phi / satelite.bateria.phi_max * 100);
print(fig, 'Figuras/DOD.eps', '-depsc', '-r0');

%% PWR
fig = figure('Units', 'points', 'Position', resolucion);
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
print(fig, 'Figuras/PWR.eps', '-depsc', '-r0');

%% END
end
