function [potencia_c_max, potencia_c_media, potencia_t_max, potencia_t_media] = aaf_dibujarPotencias(nus, potencias_c, potencias_t, titulo, output)
%aaf_dibujarPotencias Hace un plot de las potencias

%% Potencias
potencia_c_max = max(potencias_c);
potencia_c_media = mean(potencias_c);
potencia_t_max = max(potencias_t);
potencia_t_media = mean(potencias_t);

%% Limites de los gráficos
xmin = min(nus);
xmax = max(nus);
ymin = 0e0;
ymax = max(potencia_c_max, potencia_t_max);
ymax = ceil(ymax/10)*10 + 1e-3; % Ymax Potencia de 10

%% Plots
figure();
sgtitle(titulo, "Interpreter", "latex")
subplot(2,1,1);
plot( ...
    nus, potencias_c, "b-", ...
    nus, ones(1, length(nus)) * potencia_c_max, "r-.", ...
    nus, ones(1, length(nus)) * potencia_c_media, "g--" ...
);
title("Instrumentos en $X+$ apuntando a C\'enit.", "Interpreter", "latex");
xlim([xmin, xmax]);
ylim([ymin, ymax]);
xticks(0:30:360);
yticks(0:10:ymax);
L = legend("$P$", "$P_{max}$", "$\overline{P}$");
set(L,'Interpreter','latex')

subplot(2,1,2);
plot( ...
    nus, potencias_t, "b-", ...
    nus, ones(1, length(nus)) * potencia_t_max, "r-.", ...
    nus, ones(1, length(nus)) * potencia_t_media, "g--" ...
);
title("Instrumentos en $X+$ apuntando a Tierra.", "Interpreter", "latex");
xlim([0e0, 360e0]);
ylim([-1e0, ymax]);
xticks(0:30:360);
yticks(0:10:ymax);
L = legend("$P$", "$P_{max}$", "$\overline{P}$");
set(L,'Interpreter','latex')

%% Guardar
saveas(gcf, output, 'epsc');
end

