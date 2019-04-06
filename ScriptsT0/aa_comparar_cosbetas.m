%% CLEARS AND FLAGS
clear
clc
set(0,'DefaultFigureVisible','off');

%% INITS
alphas = [0e0, -22.5e0];
M = length(alphas);
N = 1000;
phis = linspace(0e0, 360e0, N);
cosenos_m = zeros(N, 6, M);
cosenos_g = zeros(N, 6, M);
delta_phi = 360e0 / N;
conversor_ejes_matlab2gmat = [2, 1, 5, 6, 3, 4];
subtitulos = ["Panel X-", "Panel X+", "Panel Y-", "Panel Y+", "Panel Z-", "Panel Z+"];
tituloss = [ ...
    "$\cos\beta$ para Orbita Helios\'incrona de 12:00H.", ...
    "$\cos\beta$ para Orbita Helios\'incrona de 10:30H." ; ...
    "Error para Orbita Helios\'incrona de 12:00H.", ...
    "Error para Orbita Helios\'incrona de 10:30H." ...
];
outputss = [ ...
    "outs/CosenosLN1200", ...
    "outs/CosenosLN1030" ; ...
    "outs/ErrorCosenosLN1200", ...
    "outs/ErrorCosenosLN1030" ...
];
archivos = ["data/CosenosLN1200.txt", "data/CosenosLN1030.txt"];
inicios = [4, 2];
finales = [1003, 1001];

%% ORBIT DATA
sma = 6378e0 + 500e0;
ecc = 0e0;
inc = 97.402e0;
aop = 0e0;
ta = 0e0;
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
        for j = 1:1:6
            cosenos_m(i,j,k) = satelite.cosenoPanel(n_sol, j);
        end
        satelite = satelite.aumentarAnomaliaVerdadera(delta_phi);
    end
    
    %% GMAT DATA
    [nu_deg,cbxm,cbxp,cbym,cbyp,cbzm,cbzp] = aaf_importarCosenos(archivo, inicio, fin);
    cosenos_g(:,:,k) = [cbxm,cbxp,cbym,cbyp,cbzm,cbzp];
    clear cbxm cbxp cbym cbyp cbzm cbzp;
    
    %% PLOT COSBETA
    figure();
    sgtitle(titulos(1), "Interpreter", "latex")
    for i = 1:1:6
        subtitulo = subtitulos(i);
        subplot(3,2,i);
        plot( ...
            phis, cosenos_m(:,conversor_ejes_matlab2gmat(i),k), "r--", ...
            nu_deg, cosenos_g(:,i,k), "b-." ...
        );
        title(subtitulo, "Interpreter", "latex");
        legend("Matlab", "GMAT");
        xlim([0e0, 360e0]);
        ylim([-1e-1, 1e0]);
        xticks(0:90:360);
        xlabel("$\nu\ [\deg]$", "Interpreter", "latex");
    end
    saveas(gcf, outputs(1), 'epsc');
    
    %% PLOT ERR COSBETA
    figure();
    sgtitle(titulos(2), "Interpreter", "latex")
    for i = 1:1:6
        subtitulo = subtitulos(i);
        subplot(3,2,i);
        df = cosenos_m(:,conversor_ejes_matlab2gmat(i),k) - cosenos_g(:,i,k);
        plot( ...
            phis, df ...
        );
        title(subtitulo, "Interpreter", "latex");
        xlim([0e0, 360e0]);
        ylim([min(df)-1e-4, max(df)+1e-4]);
        xticks(0:90:360);
        xlabel("$\nu\ [\deg]$", "Interpreter", "latex");
    end
    saveas(gcf, outputs(2), 'epsc');
    
end