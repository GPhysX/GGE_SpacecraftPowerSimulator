close all
clc
conversores
%global conversor_3_3v conversor_5v conversor_15v
global i_5 i_33 i_p15 i_m15 i_bus i_ps i_c e_p
global ic1i ic2i ic3i ic1o ic2o ic3o

set(groot,'defaultLineLineWidth',1.5);
set(gcf,'PaperPositionMode','auto');
set(gca,'FontSize',8);
colormap('jet');
s100 = [0, 0, 390, 390 * .75];
s80 = s100 .* .8;
s60 = s100 .* .6;
s40 = s100 .* .4;
s45 = s100 .* .45;
resolucion = s45;

filenames = {"data/consumos_constantes.dat", "data/consumos_transmision_datos.dat", "data/consumos_exp1.dat", "data/consumos_exp2.dat", "data/consumos_exp3.dat"};
keys = {"CC", "TX","E1","E2","E3"};
plotnames = {"EQ", "CDC", "BAT","MAIN"};

for kk = 5:5
  filename = filenames{kk};
  key = keys{kk};

  a = load(filename, "-ascii");

  %range = 1:80;
  range = 1:length(a(:,1));
  plot_range = 2:length(a(:,1));
  t = a(range,1);
  p_ps    = Interpolator(t, a(range,2));
  p_bus   = Interpolator(t, a(range,3));
  p_p15v  = Interpolator(t, a(range,4));
  p_m15v  = Interpolator(t, a(range,5));
  p_p5v   = Interpolator(t, a(range,6));
  p_p3_3v = Interpolator(t, a(range,7));



  n = length(t);
  phi0 = bateria.phi_max * 60e-2;
  t0 = t(1);
  u0 = [phi0;-1e0;-1e0];
  phi = ones(n,1) * phi0;
  vec_i_c = zeros(n,1);
  vec_e_p = zeros(n,1);
  vec_i_5v = zeros(n,1);
  vec_i_33v = zeros(n,1);
  vec_i_p15v = zeros(n,1);
  vec_i_m15v = zeros(n,1);
  vec_i_bus = zeros(n,1);
  vec_i_ps = zeros(n,1);
  vec_ic1i = zeros(n,1);
  vec_ic2i = zeros(n,1);
  vec_ic3i = zeros(n,1);
  vec_ic1o = zeros(n,1);
  vec_ic2o = zeros(n,1);
  vec_ic3o = zeros(n,1);
  f = @(y,t) ecuaciones_sistema(y,t,conversor_3_3v,conversor_5v,conversor_15v,p_ps,p_bus,p_p15v,p_m15v,p_p5v,p_p3_3v,bateria);
  integrador = RK4(f, u0, t0);

  %global switchs
  %switchs = 1;

  for k = 2:n
      dt = t(k) - t(k-1);
      integrador = integrador.next(dt);
      phi(k) = integrador.y(1);
      vec_i_c(k) = i_c;
      vec_e_p(k) = e_p;
      vec_i_5v(k) = i_5;
      vec_i_33v(k) = i_33;
      vec_i_p15v(k) = i_p15;
      vec_i_m15v(k) = i_m15;
      vec_i_bus(k) = i_bus;
      vec_i_ps(k) = i_ps;
      vec_ic1i(k) = ic1i;
      vec_ic1o(k) = ic1o;
      vec_ic2i(k) = ic2i;
      vec_ic2o(k) = ic2o;
      vec_ic3i(k) = ic3i;
      vec_ic3o(k) = ic3o;
  end
  t = t / 36e2;
  %% PLOT EQUIPOS
  fig = figure('Units', 'points', 'Position', resolucion);  hold on;
  grid on;
  box on;
  hold on;
  xlabel("t [h]");
  plot(t(plot_range), vec_i_33v(plot_range) , "DisplayName", "PL 3.3 V");
  plot(t(plot_range), vec_i_5v(plot_range)  , "DisplayName", "PL 5.0 V");
  plot(t(plot_range), vec_i_m15v(plot_range), "DisplayName", "PL -15 V");
  plot(t(plot_range), vec_i_p15v(plot_range), "DisplayName", "PL +15 V");
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
  xlabel("t [h]");
  plot(t, vec_ic1i, "DisplayName","DC 3.3V IN");
  plot(t, vec_ic2i, "DisplayName","DC 5.0V IN");
  plot(t, vec_ic3i, "DisplayName","DC  15V IN");
  %yyaxis right
  plot(t, vec_ic1o, "DisplayName","DC 3.3V OUT");
  plot(t, vec_ic2o, "DisplayName","DC 5.0V OUT");
  plot(t, vec_ic3o, "DisplayName","DC  15V OUT");
  legend();
  outname = strcat(key, "_", plotnames{2});
  out = strcat(outname, ".fig");
  savefig(fig, out);
  out = strcat(outname, ".eps");
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
  xlabel("t [h]");
  plot(t(plot_range), vec_i_c(plot_range), "DisplayName", "I");
  %plot(t(plot_range), vec_e_p(plot_range), "DisplayName", "V");
  yyaxis right
  plot(t(plot_range), phi(plot_range) / bateria.phi_max, "DisplayName", "DoC");
  legend();
  outname = strcat(key, "_", plotnames{3});
  out = strcat(outname, ".fig");
  savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');

  %% PLOT PS BATERIA BUS CDC15V
  fig = figure('Units', 'points', 'Position', resolucion);
  hold on;
  box on;
  grid on;
  xlabel("t [h]");
  plot(t(plot_range), vec_i_ps(plot_range) , "DisplayName", "I PANEL");
  plot(t(plot_range), vec_i_c(plot_range)  , "DisplayName", "I BATERIA");
  plot(t(plot_range), vec_i_bus(plot_range), "DisplayName", "I BUS");
  plot(t(plot_range), vec_ic3i(plot_range), "DisplayName", "I CONVERSOR");
  yyaxis right
  %plot(t(plot_range), vec_e_p(plot_range), "DisplayName", "V");
  plot(t(plot_range), phi(plot_range) / bateria.phi_max, "DisplayName", "DoC");
  legend();
  
  outname = strcat(key, "_", plotnames{4});
  out = strcat(outname, ".fig");
  savefig(fig, out);
  out = strcat(outname, ".eps");
  print(fig, out, '-depsc', '-r0');
  
  close all;
end
