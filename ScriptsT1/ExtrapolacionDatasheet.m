%% Borrado de variables
close all
clear
clc

sc_datos_datasheet

filename = "data.dat";
[v_exp, i_exp] = fc_datos_experimentales (filename);
[v_oc_panel, i_sc_panel, n, m] = fc_dimensionado_panel (filename)





