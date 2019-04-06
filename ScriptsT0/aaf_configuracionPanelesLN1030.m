function satelite = aaf_configuracionPanelesLN1030(satelite)
%aaf_configuracionPanelesLN1030 Coloca los paneles de la orbita 10:30.

% Estructura con todos los paneles disponibles
paneles = aaf_PanelesSolaresDisponibles();

%% Panel Vacio (Sin panel solar)
panel_VC = PanelSolar();

%% Panel de las caras estrechas (Z+-). 4 X paneles de 1U
panel_1U = paneles.ENDUROSATXY1U; 
panel_4U = panel_1U.multiply(4);

%% Paneles de las caras alargadas (X+-, y+-)
panel_3U = paneles.ENDUROSATXY3U;
panel_6U = paneles.DHV6U;
panel_9U = panel_3U.multiply(3);
panel_12U = panel_3U.multiply(4);
panel_12UD = paneles.DHV;%.multiply(2);
panel_24U = paneles.DHVS;
panel_24UD = paneles.DHV.multiply(2);

%% Eleccion de paneles
panel_XM = panel_12U;
panel_XP = panel_6U;
panel_YM = panel_4U;
panel_YP = panel_4U;
panel_ZM = panel_6U;
panel_ZP = panel_6U;

%% Colocacion de paneles
satelite = satelite.ponerPanel(panel_XM, 1);
satelite = satelite.ponerPanel(panel_XP, 2);
satelite = satelite.ponerPanel(panel_YM, 3);
satelite = satelite.ponerPanel(panel_YP, 4);
satelite = satelite.ponerPanel(panel_ZM, 5);
satelite = satelite.ponerPanel(panel_ZP, 6);
end

