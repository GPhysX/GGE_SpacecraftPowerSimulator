close all
clc
conversores
do_plots = true;

global i_5 i_33 i_p15 i_m15 i_bus i_ps i_c e_p
global ic1i ic2i ic3i ic1o ic2o ic3o
global p_bat

%filenames = {"data/consumos_cc.dat", "data/consumos_tx.dat", "data/consumos_e1.dat", "data/consumos_e2.dat", "data/consumos_e3.dat"};
filenames = {"data/consumos_cc.dat", "data/consumos_transmision_datos.dat", "data/consumos_exp1.dat", "data/consumos_exp2.dat", "data/consumos_exp3.dat", "data/consumos_t.dat"};
keys = {"Figuras/CC", "Figuras/TX","Figuras/E1","Figuras/E2","Figuras/E3","Figuras/CT"};
plotnames = {"EQ", "CDC", "BAT","MAIN"};

a = load(filenames{1}, "-ascii");
t = a(:,1);

n = length(t);
s = length(filenames);

phi_0 = bateria.phi_max * 0e-2;
ir1_0 = -1e0;
ir2_0 = -1e0;
t0 = t(1);
u0 = [phi_0;ir1_0;ir2_0];
phi = ones(n,5) * phi_0;
vec_t = zeros(n,s);
vec_i_c = zeros(n,s);
vec_e_p = zeros(n,s);
vec_i_5v = zeros(n,s);
vec_i_33v = zeros(n,s);
vec_i_p15v = zeros(n,s);
vec_i_m15v = zeros(n,s);
vec_i_bus = zeros(n,s);
vec_i_ps = zeros(n,s);
vec_ic1i = zeros(n,s);
vec_ic2i = zeros(n,s);
vec_ic3i = zeros(n,s);
vec_ic1o = zeros(n,s);
vec_ic2o = zeros(n,s);
vec_ic3o = zeros(n,s);
vec_pbat = zeros(n,s);

i_equipos = zeros(n,s,5);
i_conv_in = zeros(n,s,3);
i_conv_out = zeros(n,s,3);
dod = zeros(n,s);

for kk = s:s
  filename = filenames{kk};
  key = keys{kk};

  a = load(filename, "-ascii");

  %range = 1:80;
  range = 1:length(a(:,1));
  plot_range = 2:length(a(:,1));
  t = a(range,1);
  vec_t(:,kk) = t;
  p_ps    = Interpolator(t, a(range,2));
  p_bus   = Interpolator(t, a(range,3));
  p_p15v  = Interpolator(t, a(range,4));
  p_m15v  = Interpolator(t, a(range,5));
  p_p5v   = Interpolator(t, a(range,6));
  p_p3_3v = Interpolator(t, a(range,7));

  t0 = t(1);
  f = @(y,t) ecuaciones_sistema(y,t,conversor_3_3v,conversor_5v,conversor_15v,p_ps,p_bus,p_p15v,p_m15v,p_p5v,p_p3_3v,bateria);
  integrador = RK4(f, u0, t0);

  for k = 2:n
      dt = t(k) - t(k-1);
      integrador = integrador.next(dt);
      phi(k,kk) = integrador.y(1);
      dod(k,kk) = integrador.y(1) / bateria.phi_max;
      vec_i_c(k,kk) = i_c;
      vec_e_p(k,kk) = e_p;
      vec_i_5v(k,kk) = i_5;
      vec_i_33v(k,kk) = i_33;
      vec_i_p15v(k,kk) = i_p15;
      vec_i_m15v(k,kk) = i_m15;
      vec_i_bus(k,kk) = i_bus;
      vec_i_ps(k,kk) = i_ps;
      vec_ic1i(k,kk) = ic1i;
      vec_ic1o(k,kk) = ic1o;
      vec_ic2i(k,kk) = ic2i;
      vec_ic2o(k,kk) = ic2o;
      vec_ic3i(k,kk) = ic3i;
      vec_ic3o(k,kk) = ic3o;
      vec_pbat(k,kk) = p_bat;
      
      i_equipos(k,kk,:) = [i_m15, i_33, i_5, i_p15, i_bus];
      i_conv_in(k,kk,:) = [ic1i, ic2i, ic3i];
      i_conv_out(k,kk,:) = [ic1o, ic2o, ic3o];
  end
  t = t / 36e2;
  
  if ( do_plots )
    plots;
  end
  
  close all;
end

figure();
plot(vec_t(plot_range,:), phi(plot_range,:) / bateria.phi_max);
