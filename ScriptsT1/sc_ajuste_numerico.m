close all
%clear
clc

%% Importar datos
filename = "data.dat";
sc_datos_datasheet;
[v_exp, i_exp] = fc_datos_experimentales (filename);
[v_oc_panel, i_sc_panel, n, m] = fc_dimensionado_panel (filename);

%% ajuste de la curva con funciones 'intrinsecas'.
f_rmsd = @(u) norm(i_exp - f_i_kh (v_exp, u(1), u(2), u(3), u(4)));
[u, valor_rmsd] = fminsearch(f_rmsd, [v_oc_panel, i_sc_panel, 1e0, 32e0]);
disp(["gamma: ",  num2str(u(3))]);
disp(["m: ",  num2str(u(4))]);
disp(["Error RMSD del ajuste numerico: ", num2str(valor_rmsd/sqrt(length(v_exp)))]);

%% Comparacion de resultados
f_i_ajuste_numerico = @(v) f_i_kh (v, u(1), u(2), u(3), u(4));
plot_curva(v_exp, f_i_ajuste_numerico(v_exp), "b-","Curva I-V de Karmalkar y Haneefa", "R22");

a = [v_exp; f_i_ajuste_numerico(v_exp)]';
save "D22.dat" a;