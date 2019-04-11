%%% PROBAR CON PANELES ORIENTADOS A 45DEG, 135DEG
%% CLEAR & FLAGS
clear
clc
set(0,'DefaultFigureVisible','off');

%% INITS
N = 1000;
phis = linspace(0e0, 360e0, N);
delta_phi = 360e0 / N;
potencias_xp_tierra = zeros(1, N);
potencias_xp_cenit = zeros(1, N);

alphas = [0e0, -22.5e0];

titulos = [ ...
    "Potencia durante orbita helios\'incrona de 12:00.", ...
    "Potencia durante orbita helios\'incrona de 10:30." ...
];
outputs = [ ...
    "outs/PotenciaLN1200", ...
    "outs/PotenciaLN1030" ...
];

n_sol = [1e0, 0e0, 0e0];
r_p = 6378e0;
h = 500e0;
sma = r_p + h;
ecc = 0e0;
inc = 97.402e0;
aop = 0e0;
ta = 0e0;

for k = 1:1:2
    titulo = titulos(k);
    output = outputs(k);
    alpha = alphas(k);
    
    raan = alpha;

    %% Inicializar Satelite
    satelite = Satelite("GGE-02");
    satelite = satelite.inicializarOrbitaTerrestre(sma, ecc, inc, raan, aop, ta);
    if( k == 1)
        satelite = aaf_configuracionPanelesLN1200(satelite);
    else
        satelite = aaf_configuracionPanelesLN1030(satelite);
    end

    %% Calcular potencias
    for i = 1:1:N
        potencias_xp_cenit(i) = satelite.potenciaPaneles(n_sol);
        satelite = satelite.aumentarAnomaliaVerdadera(delta_phi);
    end
    potencia_max_cenit = max(potencias_xp_cenit);
    potencia_media_cenit = sum(potencias_xp_cenit) / N;

    satelite = satelite.rotar(180e0, 2);

    for i = 1:1:N
        potencias_xp_tierra(i) = satelite.potenciaPaneles(n_sol);
        satelite = satelite.aumentarAnomaliaVerdadera(delta_phi);
    end
    potencia_max_tierra = max(potencias_xp_tierra);
    potencia_media_tierra = sum(potencias_xp_tierra) / N;

    %% Plotear
    [potencia_c_max, potencia_c_media, potencia_t_max, potencia_t_media] = aaf_dibujarPotencias(phis, potencias_xp_cenit, potencias_xp_tierra, titulo, output);
end