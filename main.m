clear all
close all
clc

ejemplo = Examples();
%ejemplo.ex_curvaiv_panelsolar();
close all;
%ejemplo.ex_orbita_sunsync();
close all;
bateria = ejemplo.ex_bateria_ajuste();

fv = @(phi) bateria.coeficientes_carga_tipo1(1) + bateria.coeficientes_carga_tipo1(2) * phi + bateria.r_c * 5e0;
phis = linspace(bateria.phi_max, 0e0, 1000);
