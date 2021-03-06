function obj = aaf_PanelesSolaresDisponibles()
    panel_TDSP12U       = PanelSolar(12,28,  true, 8.4420e-2, 47.7e-2, 650e-3, inf);
    panel_ENDUROSATXY1U = PanelSolar(1,  2, false, 0.6030e-2, 29.5e-2,  48e-3, 1.50e3);
    panel_ENDUROSATXY3U = PanelSolar(3,  7, false, 2.1105e-2, 30.0e-2, 136e-3, 3.60e3);
    panel_DHV6U         = PanelSolar(6, 16,  true, 4.8810e-2, 30.0e-2, 300e-3, inf);
    panel_DHVSP         = PanelSolar(6, 28,  true, 9.7537e-2, 30.0e-2, 600e-3, 3.60e3);
    panel_DHVSSP        = PanelSolar(6, 28,  true,14.6310e-2, 30.0e-2, 900e-3, inf);
    panel_ISIS3U        = PanelSolar(3,  6, false, 1.6837e-2, 30.0e-2, 150e-3, 4.90e3);
    panel_ISIS6U        = PanelSolar(6, 15, false, 4.1484e-2, 30.0e-2, 300e-3, 8.45e3);
    panel_TEST3U = PanelSolar(3,  3, false, 100e-3^2e0, 1e+0, 0.15,   inf);
    
    obj = struct(...
        "ENDUROSATXY3U", panel_ENDUROSATXY3U, ...
        "ENDUROSATXY1U", panel_ENDUROSATXY1U, ...
        "TDSP12U", panel_TDSP12U, ...
        "ISIS3U", panel_ISIS3U, ...
        "ISIS6U", panel_ISIS6U, ...
        "TEST3U", panel_TEST3U, ...
        "DHV6U", panel_DHV6U, ...
        "DHV", panel_DHVSP, ...
        "DHVS", panel_DHVSSP ...
    );
    
end