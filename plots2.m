close all

set(groot,'defaultLineLineWidth',1);
set(gcf,'PaperPositionMode','auto');
set(gca,'FontSize',8);
colormap('jet');
s100 = [0, 0, 390, 390 * .75];
s80 = s100 .* .8;
s60 = s100 .* .6;
s40 = s100 .* .4;
s45 = s100 .* .45;
resolucion = s80;

plot_range = 2:length(vec_t(:,1));
p = 90 * 60;

%% PLOT DOD

fig = figure('Units', 'points', 'Position', resolucion);
hold on;
grid on;
box on;
hold on;
xlabel("t/t_P [-]");
ylabel("DoD [%]");
xlim([0,15]);
xticks(0:2.5:15);
title("Simulación de la profundidad de descarga");
%rigths = [3,4];
for kk = s:s
%   if ( any (rigths == kk) )
%     yyaxis right
%   else
%     yyaxis left
%   end
  plot(vec_t(plot_range,kk) / p, 1e2 * dod(plot_range,kk));
end
%legends = ["C. constante", "Trans. datos", "Exp. 1", "Exp. 2", "Exp. 3"];%, "Completo"];
%legend(legends);
outname = "Figuras/DOD";
%out = strcat(outname, ".fig");
%savefig(fig, out);
out = strcat(outname, ".eps");
print(fig, out, '-depsc', '-r0');

%% PLOT IBAT
for kk = s:s
  fig = figure('Units', 'points', 'Position', s80);
  hold on;
  grid on;
  box on;
  hold on;
  xlabel("t/t_P [-]");
  ylabel("I [A]");
  title("Intensidades de corriente y tensión de batería");
  xticks(0:2.5:15);
  %title(["Simulación de la corriente", "y tensión de la batería"]);
  % %rigths = [3,4];
  % for kk = 1:5
  % %   if ( any (rigths == kk) )
  % %     yyaxis right
  % %   else
  % %     yyaxis left
  % %   end
  %   plot(vec_t(plot_range,kk) / p, 1e2 * dod(plot_range,kk));
  % end
  %legend("C. constante", "Trans. datos", "Exp. 1", "Exp. 2", "Exp. 3");
  plot(vec_t(plot_range,kk) / p, vec_i_c(plot_range,kk));
  yyaxis right
  ylabel("V [V]");
  plot(vec_t(plot_range,kk) / p, vec_e_p(plot_range,kk));
  outname = strcat("Figuras/BAT", num2str(kk,1));
  %out = strcat(outname, ".fig");
  %savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');
end


%% PLOT PS BUS CONV
for kk = s:s
  fig = figure('Units', 'points', 'Position', s80);
  hold on;
  grid on;
  box on;
  hold on;
  xlabel("t/t_P [-]");
  ylabel("I [A]");
  title(["Intensidades de corriente de", "elementos principales"]);
  xticks(0:2.5:15);
  plot(vec_t(plot_range,kk) / p, vec_i_ps(plot_range,kk));
  plot(vec_t(plot_range,kk) / p, vec_i_bus(plot_range,kk));
  plot(vec_t(plot_range,kk) / p, vec_ic3i(plot_range,kk));
  legend("Panel", "BUS", "CONV.");
%   yyaxis right
%   ylabel("V [V]");
%   plot(vec_t(plot_range,kk) / p, vec_e_p(plot_range,kk));
  outname = strcat("Figuras/MAIN", num2str(kk,1));
  %out = strcat(outname, ".fig");
  %savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');
end

close all