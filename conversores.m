close all
clc
do_plots = true;

%%
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
if ( do_plots )
  fig_t = figure('Units', 'points', 'Position', s45);
  hold on;
  box on;
  grid on;
end

%% Conversor 5V
a = load("data/conversor_5V.dat", "-ascii");
vec_v_in = a(:,1);
vec_i_in = a(:,2);
vec_p_in = a(:,3);
vec_v_out = a(:,4);
vec_i_out = a(:,5);
vec_p_out = a(:,6);
vec_eta = a(:,8);

v_in = vec_v_in(1);
v_out = vec_v_out(1);

conversor_5v = ConversorDC(v_in, v_out);
conversor_5v = conversor_5v.ajuste(vec_i_out, vec_eta);

if ( do_plots )
  fig = figure('Units', 'points', 'Position', s45);
  hold on;
  box on;
  grid on;
  ylabel("I_{IN} [A]");
  xlabel("I_{OUT} [A]");
  plot(vec_i_out, vec_i_in, 'DisplayName', 'Experimental');
  plot(vec_i_out, conversor_5v.corriente_entrada(vec_i_out), 'DisplayName', 'Simulado');
  legend();
  outname = "Figuras/CDC5";
  %out = strcat(outname, ".fig");
  %savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');
  set(0,'CurrentFigure',fig_t);
  plot(vec_i_out, vec_i_in - conversor_5v.corriente_entrada(vec_i_out), 'DisplayName', '5.0 V');
end

%% Conversor 15V
a = load("data/conversor_15V.dat", "-ascii");
vec_v_in = a(:,1);
vec_i_in = a(:,3);
vec_p_in = a(:,2);
vec_v_out = a(:,4);
vec_i_out = a(:,5);
vec_p_out = a(:,6);
vec_eta = a(:,7);

v_in = vec_v_in(1);
v_out = vec_v_out(1);

conversor_15v = ConversorDC(v_in, v_out);
conversor_15v = conversor_15v.ajuste(vec_i_out, vec_eta);

if ( do_plots )
  fig = figure('Units', 'points', 'Position', s45);
  hold on;
  box on;
  grid on;
  ylabel("I_{IN} [A]");
  xlabel("I_{OUT} [A]");
  plot(vec_i_out, vec_i_in, 'DisplayName', 'Experimental');
  plot(vec_i_out, conversor_15v.corriente_entrada(vec_i_out), 'DisplayName', 'Simulado');
  legend();
  outname = "Figuras/CDC15";
  %out = strcat(outname, ".fig");
  %savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');
  set(0,'CurrentFigure',fig_t);
  plot(vec_i_out, vec_i_in - conversor_15v.corriente_entrada(vec_i_out), 'DisplayName', '15 V');
end

%% Conversor 3_3V
a = load("data/conversor_3.3V.dat", "-ascii");
vec_v_in = a(:,1);
vec_i_in = a(:,2);
vec_p_in = a(:,3);
vec_v_out = a(:,4);
vec_i_out = a(:,5);
vec_p_out = a(:,6);
vec_eta = a(:,8);

v_in = vec_v_in(1);
v_out = vec_v_out(1);

conversor_3_3v = ConversorDC(v_in, v_out);
conversor_3_3v = conversor_3_3v.ajuste(vec_i_out, vec_eta);

if ( do_plots )
  fig = figure('Units', 'points', 'Position', s45);
  hold on;
  box on;
  grid on;
  ylabel("I_{IN} [A]");
  xlabel("I_{OUT} [A]");
  plot(vec_i_out, vec_i_in, 'DisplayName', 'Experimental');
  plot(vec_i_out, conversor_3_3v.corriente_entrada(vec_i_out), 'DisplayName', 'Simulado');
  legend();
  outname = "Figuras/CDC33";
  %out = strcat(outname, ".fig");
  %savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');
  set(0,'CurrentFigure',fig_t);
  plot(vec_i_out, vec_i_in - conversor_3_3v.corriente_entrada(vec_i_out), 'DisplayName', '3.3 V');
  legend();
  ylabel("ERR(I_{IN})");
  xlabel("I_{OUT} [A]");
  outname = "Figuras/CDCERR";
  %out = strcat(outname, ".fig");
  %savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig_t, out, '-depsc', '-r0');
end
