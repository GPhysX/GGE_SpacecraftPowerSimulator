function satelite = aaf_configuracionPanelesLN1200(satelite)
%aaf_configuracionPanelesLN1030 Coloca los paneles de la orbita 12:00.

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
panel_XM = panel_12UD.add(panel_6U);
panel_XP = panel_12UD.add(panel_3U);
panel_YM = panel_VC;
panel_YP = panel_VC;
panel_ZM = panel_VC;
panel_ZP = panel_VC;

%% Colocacion de paneles
satelite = satelite.ponerPanel(panel_XM, 1);
satelite = satelite.ponerPanel(panel_XP, 2);
satelite = satelite.ponerPanel(panel_YM, 3);
satelite = satelite.ponerPanel(panel_YP, 4);
satelite = satelite.ponerPanel(panel_ZM, 5);
satelite = satelite.ponerPanel(panel_ZP, 6);
end

