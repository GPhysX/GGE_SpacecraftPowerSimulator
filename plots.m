set(groot,'defaultLineLineWidth',1.0);
set(gcf,'PaperPositionMode','auto');
set(gca,'FontSize',8);
colormap('jet');
s100 = [0, 0, 390, 390 * .75];
s80 = s100 .* .8;
s60 = s100 .* .6;
s40 = s100 .* .4;
s45 = s100 .* .45;
resolucion = s80;
tt = vec_t / 90e0 / 60e0;
%% PLOT EQUIPOS
fig = figure('Units', 'points', 'Position', resolucion);  hold on;
grid on;
box on;
hold on;
xlim([0,15]);
xlabel("t/t_p [-]");
title("Intensidades de corriente de equipos");
plot(tt(plot_range,kk), vec_i_33v(plot_range,kk) , "DisplayName", "PL 3.3 V");
plot(tt(plot_range,kk), vec_i_5v(plot_range,kk)  , "DisplayName", "PL 5.0 V");
plot(tt(plot_range,kk), vec_i_m15v(plot_range,kk), "DisplayName", "PL -15 V");
plot(tt(plot_range,kk), vec_i_p15v(plot_range,kk), "DisplayName", "PL +15 V");
%plot(t(plot_range), vec_i_bus(plot_range) , "DisplayName", "PL BUS V");
legend();
outname = strcat(key, "_", plotnames{1});
out = strcat(outname, ".fig");
savefig(fig, out);
out = strcat(outname, ".eps");
print(fig, out, '-depsc', '-r0');

%% PLOT CONVERSORES
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
box on;
grid on;
xlim([0,15]);
xlabel("t/t_p [-]");
title("Intensidades de corriente de conversores");
plot(tt(plot_range,kk), vec_ic1i(plot_range,kk), "DisplayName","DC 3.3V IN");
plot(tt(plot_range,kk), vec_ic2i(plot_range,kk), "DisplayName","DC 5.0V IN");
plot(tt(plot_range,kk), vec_ic3i(plot_range,kk), "DisplayName","DC  15V IN");
%yyaxis right
plot(tt(plot_range,kk), vec_ic1o(plot_range,kk), "DisplayName","DC 3.3V OUT");
plot(tt(plot_range,kk), vec_ic2o(plot_range,kk), "DisplayName","DC 5.0V OUT");
plot(tt(plot_range,kk), vec_ic3o(plot_range,kk), "DisplayName","DC  15V OUT");
legend();
outname = strcat(key, "_", plotnames{2});
%out = strcat(outname, ".fig");
%savefig(fig, out);
out = strcat(outname, ".eps")
print(fig, out, '-depsc', '-r0');

% figure();
% hold on;
% grid on;
% title("Conversor DC a 3.3V de salida");
% plot(t(plot_range), vec_ic1i(plot_range), "DisplayName","I_IN");
% plot(t(plot_range), vec_ic1o(plot_range), "DisplayName","I_OUT");
% legend();
% 
% figure();
% hold on;
% grid on;
% title("Conversor DC a 5.0V de salida");
% plot(t(plot_range), vec_ic2i(plot_range), "DisplayName","I_IN");
% plot(t(plot_range), vec_ic2o(plot_range), "DisplayName","I_OUT");
% legend();
% 
% figure();
% hold on;
% grid on;
% title("Conversor DC a 15V de salida");
% plot(t(plot_range), vec_ic3i(plot_range), "DisplayName","I_IN");
% plot(t(plot_range), vec_ic3o(plot_range), "DisplayName","I_OUT");
% legend();

%% PLOT BATERIA
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
box on;
grid on;
xlim([0,15]);
xlabel("t/t_p [-]");
title("Intensidades de corriente y tensión de batería");
plot(tt(plot_range,kk), vec_i_c(plot_range,kk), "DisplayName", "I");
%plot(t(plot_range), vec_e_p(plot_range), "DisplayName", "V");
yyaxis right
plot(tt(plot_range,kk), phi(plot_range,kk) / bateria.phi_max, "DisplayName", "DoC");
legend();
outname = strcat(key, "_", plotnames{3});
%out = strcat(outname, ".fig");
%savefig(fig, out);
out = strcat(outname, ".eps")
print(fig, out, '-depsc', '-r0');

%% PLOT PS BATERIA BUS CDC15V
fig = figure('Units', 'points', 'Position', resolucion);
hold on;
box on;
grid on;
xlim([0,15]);
xlabel("t/t_p [-]");
title(["Intensidades de corriente de", "elementos principales"]);
plot(tt(plot_range,kk), vec_i_ps(plot_range,kk) , "DisplayName", "I PANEL");
plot(tt(plot_range,kk), vec_i_c(plot_range,kk)  , "DisplayName", "I BATERIA");
plot(tt(plot_range,kk), vec_i_bus(plot_range,kk), "DisplayName", "I BUS");
plot(tt(plot_range,kk), vec_ic3i(plot_range,kk), "DisplayName", "I CONVERSOR");
yyaxis right
%plot(t(plot_range), vec_e_p(plot_range), "DisplayName", "V");
plot(vec_t(plot_range,kk), phi(plot_range,kk) / bateria.phi_max, "DisplayName", "DoC");
legend();

outname = strcat(key, "_", plotnames{4});
%out = strcat(outname, ".fig");
%savefig(fig, out);
out = strcat(outname, ".eps")
print(fig, out, '-depsc', '-r0');