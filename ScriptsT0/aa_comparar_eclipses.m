%% CLEARS AND FLAGS
clear
clc
set(0,'DefaultFigureVisible','off');

%% INITS
alphas = [0e0, -22.5e0];
M = length(alphas);
N = 1000;
phis = linspace(0e0, 360e0, N);
eclipses_m = zeros(N, 2);
eclipses_g = zeros(N, 2);
delta_phi = 360e0 / N;
tituloss = [ ...
    "Factor de eclipse para Orbita Helios\'incrona de 12:00H.", ...
    "Factor de eclipse para Orbita Helios\'incrona de 10:30H." ; ...
    "Error para Orbita Helios\'incrona de 12:00H.", ...
    "Error para Orbita Helios\'incrona de 10:30H." ...
];
outputss = [ ...
    "outs/EclipsesLN1200", ...
    "outs/EclipsesLN1030" ; ...
    "outs/ErrorEclipsesLN1200", ...
    "outs/ErrorEclipsesLN1030" ...
];
archivos = ["data/EclipsesLN1200.txt", "data/EclipsesLN1030.txt"];
inicios = [4, 2];
finales = [1003, 1001];

%% ORBIT DATA
sma = 6378e0 + 500e0;
ecc = 0e0;
inc = 97.402e0;
aop = 0e0;
ta = 0e0;
%n_sol = [1d0, 0e0, 0e0];
epsilon = -23.03;
n_sol = [cosd(epsilon), 0e0, sind(epsilon)];

%% COMPUTE & PLOT
for k = 1:1:M
    %% CC + FLAGS
    raan = alphas(k);
    archivo = archivos(k);
    titulos = tituloss(:,k);
    outputs = outputss(:,k);
    inicio = inicios(k);
    fin = finales(k);
    
    %% SATELITE + ORBITA
    satelite = Satelite("GGE-02");
    satelite = satelite.inicializarOrbitaTerrestre(sma, ecc, inc, raan, aop, ta);
    
    %% COMPUTE
    for i = 1:1:N
        eclipses_m(i,k) = satelite.factorEclipse(n_sol);
        satelite = satelite.aumentarAnomaliaVerdadera(delta_phi);
    end
    
    %% GMAT DATA
    [nu_deg,fe] = aaf_importarEclipses(archivo, inicio, fin);
    eclipses_g(:,k) = fe;
    clear fe;
    
    %% PLOT ECLIPSE
    figure('Renderer', 'painters', 'Position', [10 10 900 300])
    sgtitle(titulos(1), "Interpreter", "latex")
    plot( ...
        phis  , eclipses_m(:,k), "r--", ...
        nu_deg, eclipses_g(:,k), "b-." ...
    );
    legend("Matlab", "GMAT");
    xlim([0e0, 360e0]);
    ylim([-1e-2, 1e0+1e-2]);
    xticks(0:30:360);
    yticks(-1:1:1);
    ylabel("$F_v$", "Interpreter", "latex");
    xlabel("$\nu\ [\deg]$", "Interpreter", "latex");
    saveas(gcf, outputs(1), 'epsc');
    
    %% PLOT ERR ECLIPSE
    figure('Renderer', 'painters', 'Position', [10 10 900 300])
    sgtitle(titulos(2), "Interpreter", "latex")
    df = eclipses_m(:,k) - eclipses_g(:,k);
    plot( ...
        phis, df ...
    );
    xlim([0e0, 360e0]);
    ylim([min(df)-1e-4, max(df)+1e-4]);
    xticks(0:30:360);
    yticks(-1:1:1);
    ylabel("Err$\left(F_v\right)$", "Interpreter", "latex");
    xlabel("$\nu\ [\deg]$", "Interpreter", "latex");
    saveas(gcf, outputs(2), 'epsc');
end