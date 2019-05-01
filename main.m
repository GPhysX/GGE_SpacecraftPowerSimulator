clear all
close all
clc

ejemplo = Examples();
%ejemplo.ex_curvaiv_panelsolar();
close all;
%ejemplo.ex_orbita_sunsync();
close all;
bateria = ejemplo.ex_bateria_ajuste();
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

