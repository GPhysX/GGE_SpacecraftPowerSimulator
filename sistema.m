close all
clc
%global conversor_3_3v conversor_5v conversor_15v
global i_c e_p
%a = load("data/consumos_constantes.dat", "-ascii");
%a = load("data/consumos_transmision_datos.dat", "-ascii");
%a = load("data/consumos_exp1.dat", "-ascii");
a = load("data/consumos_exp2.dat", "-ascii");
%a = load("data/consumos_exp3.dat", "-ascii");
%range = 1:80;
range = 1:length(a(:,1));
t = a(range,1);
p_ps    = Interpolator(t, a(range,2));
p_bus   = Interpolator(t, a(range,3));
p_p15v  = Interpolator(t, a(range,4));
p_m15v  = Interpolator(t, a(range,5));
p_p5v   = Interpolator(t, a(range,6));
p_p3_3v = Interpolator(t, a(range,7));



n = length(t);
phi0 = bateria.phi_max * 100e-2;
t0 = t(1);
u0 = [phi0;-1e0;-1e0];
phi = ones(n,1) * phi0;
vec_i_c = zeros(n,1);
vec_e_p = zeros(n,1);
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
end

figure();
%plot(t, phi / bateria.phi_max, t, p_ps.eval(t)/30e0);
%plot(t(vec_e_p > 1e0), vec_i_c(vec_e_p > 1e0));
plot(t, vec_i_c);

hold on;
plot(t, vec_e_p);
yyaxis right
plot(t, phi / bateria.phi_max);
%plot(t(vec_e_p > 1e0), vec_e_p(vec_e_p > 1e0));
