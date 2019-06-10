%clear all
close all
clc

options = optimoptions("fsolve", "Display", "none");

trabajo = 4;
caso = 0;
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
  if caso == 2
    bateria.p = 1;
  else
    bateria.p = 2;
  end
  satelite.bateria = bateria;
  dt = 40e0;
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
  iqs = zeros(n,4);
  ics = zeros(n,6);
  pbus = zeros(n,1);
  
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
    [pwr_i, pbuss, i3, i5, ip15, im15, icnvs] = simulacion_potencia(ta, periodo, cnvs, caso);
    iqs(i,:) = [i3, i5, ip15, im15];
    pwr(i) = pwr_i;
    pbus(i) = pbuss;
    
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
    f_solve = @(u) simulacion_sistema(u(1), u(2), u(3), temp, es, pwr_i, phi_i, satelite, caso);
    u = fsolve(f_solve, [12e0, 1e0, 1e0], options);
    v_i = u(1);
    ips_i = u(2);
    ibt_i = u(3);
    
    v_s(i) = v_i;
    ips(i) = ips_i;
    ibt(i) = ibt_i;
    
    pps(i) = v_i * ips_i;
    pbt(i) = v_i * ibt_i;
    
    icnvs(5) = icnvs(5) / bateria.voltage_dynamic(phi_i, ibt_i, 3);
    ics(i,:) = icnvs;
    
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
  
  impx = ips + ibt;
  ibus = pbus ./ bateria.voltage_dynamic(phi, ibt, 3);

%% GRAFICAS
set(groot,'defaultLineLineWidth',0.8);
set(gcf,'PaperPositionMode','auto');
set(gca,'FontSize',8);
colormap('jet');
s100 = [0, 0, 390, 390 * .75];
s80 = s100 .* .8;
s60 = s100 .* .6;
%s40 = s100 .* .4;
%s45 = s100 .* .45;
resolucion = s80;
tli = 3.5e4;
tls = tli + 2*periodo;
[v_mins, i_mins] = find(ts <= tli);
[v_maxs, i_maxs] = find(ts >= tls);
i_min = max(i_mins);
i_max = min(i_maxs);
ts = ts / 3600e0;
tli = tli / 3600e0;
tls = tls / 3600e0;
%% T
fig = figure('Units', 'points', 'Position', s60);
hold on;
grid on;
box on;
nues = linspace(0,360,1000);
xlim([0,360]);
xticks(0:60:360);
title("\textbf{Perfil de temperatura por periodo}",'Interpreter','latex');
xlabel("$\nu$ [$^{\circ}$]",'Interpreter','latex');
ylabel("$T$ [$^{\circ}$C]",'Interpreter','latex');
plot(nues, simulacion_temperatura(nues)-273.15);
fileID = fopen('T.dat','w');
fprintf(fileID,'#%6s\t%12s\n','nu','T');
fprintf(fileID,'%18.14f\t%18.14f\n',[nues', simulacion_temperatura(nues)'-273.15]');
fclose(fileID);
print(fig, 'Figuras/T.eps', '-depsc', '-r0');
%% FV
%fig = figure('Units', 'points', 'Position', resolucion);
fig = figure('Units', 'points', 'Position', s80);
hold on;
grid on;
box on;
title(["\textbf{Irradiancia sobre los paneles}","\textbf{solares por periodo}"], "Interpreter", "latex");
xlabel("$t/P$ [-]", "Interpreter", "latex");
ylabel("$E/E_{ref}$ [-]", "Interpreter", "latex");
xlim([round(min(ts)),round(max(ts))]);
xticks(round(min(ts)):4:round(max(ts)));
plot(ts(2:end)/periodo*3600, fxm(2:end), "m", "DisplayName", "Fxm");
plot(ts(2:end)/periodo*3600, fym(2:end), "g", "DisplayName", "Fym");
plot(ts(2:end)/periodo*3600, fzm(2:end), "b", "DisplayName", "Fzm");
%plot(ts, fxp, "m--", "DisplayName", "Fxp");
%plot(ts, fyp, "g--", "DisplayName", "Fyp");
plot(ts(2:end)/periodo*3600, fzp(2:end), "b--", "DisplayName", "Fzp");
legend(["$X-$","$Y-$","$Z-$","$Z+$"], "Interpreter", "latex",'NumColumns',2);
print(fig, 'Figuras/FV.eps', '-depsc', '-r0');
%xlim([floor(min(tli)),ceil(max(tls))]);
xlim([0,1]);
%xticks(floor(min(tli)):1:ceil(max(tls)));
xticks(0:0.2:1);
print(fig, 'Figuras/FV2.eps', '-depsc', '-r0');

aa = [ts(2:end)'/periodo*3600, fxm(2:end), fym(2:end), fzm(2:end), fzp(2:end)];
fileID = fopen('FV.dat','w');
fprintf(fileID,'#%1s\t%3s\t%3s\t%3s\t%3s\n','t','fxm','fym','fzm','fzp');
fprintf(fileID,'%14.10f\t%14.10f\t%14.10f\t%14.10f\t%14.10f\n',aa');
fclose(fileID);

%% IBT
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title(["\textbf{Intensidad de corriente}", "\textbf{de elementos principales}"], "Interpreter", "latex");
xlabel("$t$ [h]", "Interpreter", "latex");
ylabel("$I$ [A]", "Interpreter", "latex");
xlim([round(min(ts)),round(max(ts))]);
xticks(round(min(ts)):4:round(max(ts)));
plot(ts, impx, "b", "Linewidth", 1.4, "DisplayName", "EQUIPO");
plot(ts, ips, "m", "DisplayName", "PANEL");
plot(ts, ibt, "g", "DisplayName", "BATER\'IA");
legend('Location', 'northwest', 'Interpreter', 'latex');
print(fig, 'Figuras/IBT.eps', '-depsc', '-r0');
xlim([floor(min(tli)),ceil(max(tls))]);
xticks(floor(min(tli)):1:ceil(max(tls)));
print(fig, 'Figuras/IBT2.eps', '-depsc', '-r0');

aa = [ts', impx, ips, ibt];
fileID = fopen('IBT.dat','w');
fprintf(fileID,'#%1s\t%4s\t%3s\t%4s\t\n','t','impx','ips','ibat');
fprintf(fileID,'%18.14f\t%18.14f\t%18.14f\t%18.14f\n',aa');
fclose(fileID);

%% IEQ
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title("\textbf{Intensidad de corriente de equipos}", "Interpreter", "latex");
xlabel("$t$ [h]", "Interpreter", "latex");
ylabel("$I$ [A]", "Interpreter", "latex");
xlim([round(min(ts)),round(max(ts))]);
xticks(round(min(ts)):4:round(max(ts)));
plot(ts, iqs(:,1), "b", "Displayname", "EQ $3,3$ V");
plot(ts, iqs(:,2), "m", "Displayname", "EQ $5$ V");
plot(ts, iqs(:,3), "g", "Displayname", "EQ $+15$ V");
plot(ts, iqs(:,4), 'Color', [0,0,0.5], "Displayname", "EQ $-15$ V");
plot(ts, ibus, 'Color', [0.5,0,0.5], "Displayname", "EQ BUS");
legend('Location', 'northwest', 'Interpreter', 'latex');
print(fig, 'Figuras/IEQ.eps', '-depsc', '-r0');
xlim([floor(min(tli)),ceil(max(tls))]);
xticks(floor(min(tli)):1:ceil(max(tls)));
print(fig, 'Figuras/IEQ2.eps', '-depsc', '-r0');

aa = [ts', iqs, ibus];
fileID = fopen('IEQ.dat','w');
fprintf(fileID,'#%1s\t%2s\t%2s\t%4s\t%4s\t%4s\n','t','i3','i5','i+15','i-15','ibus');
fprintf(fileID,'%18.14f\t%18.14f\t%18.14f\t%18.14f\t%18.14f\t%18.14f\n',aa');
fclose(fileID);

%% ICNVS
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title("\textbf{Intensidad de corriente de conversores}", "Interpreter", "latex");
xlabel("$t$ [h]", "Interpreter", "latex");
ylabel("$I$ [A]", "Interpreter", "latex");
xlim([round(min(ts)),round(max(ts))]);
xticks(round(min(ts)):4:round(max(ts)));
plot(ts, ics(:,1), "b"  , "Displayname", "CNV $3,3$ V IN");
plot(ts, ics(:,2), "b--", "Displayname", "CNV $3,3$ V OUT");
plot(ts, ics(:,3), "m"  , "Displayname", "CNV $5,0$ V IN");
plot(ts, ics(:,4), "m--", "Displayname", "CNV $5,0$ V OUT");
plot(ts, ics(:,5), "g"  , "Displayname", "CNV $\pm 15$ V IN");
plot(ts, ics(:,6), "g--", "Displayname", "CNV $\pm 15$ V OUT");
legend('Location', 'northwest', 'Interpreter', 'latex');
print(fig, 'Figuras/ICNV.eps', '-depsc', '-r0');
xlim([floor(min(tli)),ceil(max(tls))]);
xticks(floor(min(tli)):1:ceil(max(tls)));
print(fig, 'Figuras/ICNV2.eps', '-depsc', '-r0');

aa = [ts', ics];
fileID = fopen('ICNV.dat','w');
fprintf(fileID,'#%1s\t%2s\t%4s\t%4s\t%4s\t%4s\t%4s\n','t','i33i','i33o','i50i','i50o','i15i','i15o');
fprintf(fileID,'%18.14f\t%18.14f\t%18.14f\t%18.14f\t%18.14f\t%18.14f\t%18.14f\n',aa');
fclose(fileID);

%% DOD
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title("\textbf{Profundidad de descarga}", "Interpreter", "latex");
xlabel("$t$ [h]", "Interpreter", "latex");
ylabel("$DoD$ [\%]", "Interpreter", "latex");
xlim([round(min(ts)),round(max(ts))]);
xticks(round(min(ts)):4:round(max(ts)));
plot(ts, phi / satelite.bateria.phi_max * 100, "b");
print(fig, 'Figuras/DOD.eps', '-depsc', '-r0');
xlim([floor(min(tli)),ceil(max(tls))]);
xticks(floor(min(tli)):1:ceil(max(tls)));
print(fig, 'Figuras/DOD2.eps', '-depsc', '-r0');

aa = [ts', phi / satelite.bateria.phi_max * 100];
fileID = fopen('DOD.dat','w');
fprintf(fileID,'#%1s\t%2s\t%3s\n','t','dod');
fprintf(fileID,'%18.14f\t%18.14f\n',aa');
fclose(fileID);

%% PWR
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
title("\textbf{Potencia}", "Interpreter", "latex");
xlabel("$t$ [h]", "Interpreter", "latex");
ylabel("$P$ [W]", "Interpreter", "latex");
xlim([round(min(ts)),round(max(ts))]);
xticks(round(min(ts)):4:round(max(ts)));
plot(ts, pwr, "b", "Linewidth", 1.4, "DisplayName", "EQUIPOS");
plot(ts, pps, "m", "DisplayName", "PANEL");
plot(ts, pbt, "g", "DisplayName", "BATERIA");
legend('Location', 'northwest', 'Interpreter', 'latex');
print(fig, 'Figuras/PWR.eps', '-depsc', '-r0');
xlim([floor(min(tli)),ceil(max(tls))]);
xticks(floor(min(tli)):1:ceil(max(tls)));
print(fig, 'Figuras/PWR2.eps', '-depsc', '-r0');

aa = [ts', pwr, pps, pbt];
fileID = fopen('PWR.dat','w');
fprintf(fileID,'#%1s\t%3s\t%3s\t%3s\n','t','pwr','pps','pbt');
fprintf(fileID,'%18.14f\t%18.14f\t%18.14f\t%18.14f\n',aa');
fclose(fileID);

%% Galgas Equipos
tab = cell(5,4);
tab{1,1} = "EQ 3,3 V";
tab{2,1} = "EQ 5,0 V";
tab{3,1} = "EQ $+15$ V";
tab{4,1} = "EQ $-15$ V";
tab{5,1} = "EQ BUS";

tab{1,2} = max(iqs(:,1));
tab{2,2} = max(iqs(:,2));
tab{3,2} = max(iqs(:,3));
tab{4,2} = max(-iqs(:,4));
tab{5,2} = max(ibus);

[n_cs, ~, D_cs, ~] = galga([tab{:,2}]);
tab{4,2} = -tab{4,2};
tab{1,3} = n_cs(1);
tab{2,3} = n_cs(2);
tab{3,3} = n_cs(3);
tab{4,3} = n_cs(4);
tab{5,3} = n_cs(5);

tab{1,4} = D_cs(1);
tab{2,4} = D_cs(2);
tab{3,4} = D_cs(3);
tab{4,4} = D_cs(4);
tab{5,4} = D_cs(5);

%text = "";
fileid = fopen("galgas_equipos.txt", 'w');
for ii = 1:5
  fprintf(fileid, "%s\t", tab{ii,1});
  for jj = 2:4
    %text = strcat(text, num2str(tab{ii,jj}), char(9));
    fprintf(fileid, "%8.4f\t", tab{ii,jj});
  end
  %text = strcat(text, newline);
  fprintf(fileid, "\n");
end
fclose(fileid);

%% Galgas Elm
tab = cell(3,4);
tab{1,1} = "EQUIPOS";
tab{2,1} = "PANEL";
tab{3,1} = "BATERÍA";

tab{1,2} = max(impx);
tab{2,2} = max(ips);
tab{3,2} = max(ibt);

[n_cs, ~, D_cs, ~] = galga([tab{:,2}]);
tab{1,3} = n_cs(1);
tab{2,3} = n_cs(2);
tab{3,3} = n_cs(3);

tab{1,4} = D_cs(1);
tab{2,4} = D_cs(2);
tab{3,4} = D_cs(3);

fileid = fopen("galgas_elm.txt", 'w');
for ii = 1:3
  fprintf(fileid, "%s\t", tab{ii,1});
  for jj = 2:4
    %text = strcat(text, num2str(tab{ii,jj}), char(9));
    fprintf(fileid, "%8.4f\t", tab{ii,jj});
  end
  %text = strcat(text, newline);
  fprintf(fileid, "\n");
end
fclose(fileid);

%% Galgas Cnvs
tab = cell(6,4);
tab{1,1} = "CNV 3,3 V IN";
tab{2,1} = "CNV 3,3 V OUT";
tab{3,1} = "CNV 5,0 V IN";
tab{4,1} = "CNV 5,0 V OUT";
tab{5,1} = "CNV $\pm15$ V IN";
tab{6,1} = "CNV $\pm15$ V OUT";

tab{1,2} = max(ics(:,1));
tab{2,2} = max(ics(:,2));
tab{3,2} = max(ics(:,3));
tab{4,2} = max(ics(:,4));
tab{5,2} = max(ics(:,5));
tab{6,2} = max(ics(:,6));

[n_cs, n_as, D_cs, D_as] = galga([tab{:,2}]);
tab{1,3} = n_cs(1);
tab{2,3} = n_cs(2);
tab{3,3} = n_cs(3);
tab{4,3} = n_cs(4);
tab{5,3} = n_cs(5);
tab{6,3} = n_cs(6);

tab{1,4} = D_cs(1);
tab{2,4} = D_cs(2);
tab{3,4} = D_cs(3);
tab{4,4} = D_cs(4);
tab{5,4} = D_cs(5);
tab{6,4} = D_cs(6);

%text = "";
fileid = fopen("galgas_convs.txt", 'w');
for ii = 1:6
  fprintf(fileid, "%s\t", tab{ii,1});
  for jj = 2:4
    %text = strcat(text, num2str(tab{ii,jj}), char(9));
    fprintf(fileid, "%8.4f\t", tab{ii,jj});
  end
  %text = strcat(text, newline);
  fprintf(fileid, "\n");
end
fclose(fileid);
%% END
close all
end
