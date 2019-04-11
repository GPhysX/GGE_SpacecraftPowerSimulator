close all
clear
clc

%% Importar datos
filename = "data.dat";
sc_datos_datasheet;
[v_exp, i_exp] = fc_datos_experimentales (filename);
[v_oc_panel, i_sc_panel, n, m] = fc_dimensionado_panel (filename);

% Punto de potencia maxima
[_, i] = max(v_exp .* i_exp);
v_mp_panel = v_exp(i);
i_mp_panel = i_exp(i);

% Karmalcar
[v_oc_panel, i_sc_panel, gamma, m] = f_karmalkar_analitico( ...
    n = n, ...
    t = 28e0 + 273.15, ...
    v_oc = v_oc_panel, ...
    i_sc = i_sc_panel, ...
    v_mp = v_mp_panel, ...
    i_mp = i_mp_panel ...
);
disp(["gamma = ", num2str(gamma,5)]);
disp(["m = ", num2str(m,5)]);
valor_rmsd = norm(i_exp - f_i_kh (v_exp, v_oc_panel, i_sc_panel, gamma, m));
disp(["Error RMSD del ajuste analitico: ", num2str(valor_rmsd)]);


%% Grafico
%% Comparacion de resultados
f_i = @(v) f_i_kh (v, v_oc_panel, i_sc_panel, gamma, m);
plot_curva(v_exp, f_i(v_exp), "b-", "Ajuste de la curva I-V de Karmalkar y Haneefa", "R21");


a = [v_exp; f_i(v_exp)]';
save "D21.dat" a;