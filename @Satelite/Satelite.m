classdef Satelite
    %Satelite: objeto satelite. Contiene
    
    properties
        nombre
        orbita
        actitud
        paneles
        orientacion_paneles
        bateria
        nombre_orientaciones = ["XM", "XP", "YM", "YP", "ZM", "ZP"];
    end
    
    methods
        %% CONSTRUCTOR
        function obj = Satelite(nombre)
            %Satelite Objeto satelite.
            if(nargin == 1)
                obj.nombre = nombre;
            else
                obj.nombre = 'Satelite';
            end
            panel_vacio = [];%PanelSolar();
            obj.paneles = struct(...
                "XM", panel_vacio, ...
                "XP", panel_vacio, ...
                "YM", panel_vacio, ...
                "YP", panel_vacio, ...
                "ZM", panel_vacio, ...
                "ZP", panel_vacio ...
            );
            obj.orientacion_paneles = struct(...
                "XM", [-1e0, 0e0, 0e0], ...
                "XP", [+1e0, 0e0, 0e0], ...
                "YM", [+0e0,-1e0, 0e0], ...
                "YP", [+0e0,+1e0, 0e0], ...
                "ZM", [+0e0, 0e0,-1e0], ...
                "ZP", [+0e0, 0e0,+1e0] ...
            );
            obj.actitud = Actitud();
        end
        
        %% GETERS
        function orbita = getOrbita(obj)
            %getOrbita devuelve la orbita.
            orbita = obj.orbita;
        end
        
        %% SETTERS
        function obj = ponerPanel(obj, panel, i)
            if(i > 0 && i <= 6)
                obj.paneles.(obj.nombre_orientaciones(i)) = panel;
            else
                disp('Aviso: indice de panel incorrecto.');
            end
        end
        
        %% ACTITUD
        function obj = rotar(obj, theta, eje)
            %rotar Rotar el satelite alrededor de un eje.
            
            q = Actitud.cuaternionRotacionI(theta, eje);
            act = obj.actitud;
            act = act.rotacionPorCuaternion(q);
            obj.actitud = act;
        end
        %% ORBITAS
        function obj = inicializarOrbitaTerrestre(obj, sma, ecc, inc, raan, aop, ta)
            %inicializarOrbita inicializa la orbita y ajusta la actitud.
            obj.orbita = OrbitaTerrestre(sma, ecc, inc, raan, aop, ta);
        end
        
        function obj = cambiarAnomaliaVerdadera(obj, ta)
            %cambiarAnomaliaVerdadera cambia el valor de la anomalia y ajusta la actitud.
            obj = obj.inicializarOrbitaTerrestre( ...
                obj.orbita.sma, ...
                obj.orbita.ecc, ...
                obj.orbita.inc, ...
                obj.orbita.raan, ...
                obj.orbita.aop, ...
                ta);
        end
        
        function obj = cambiarRAAN(obj, raan)
            %cambiarRAAN cambia el valor del RAAN y ajusta la actitud.
            obj = obj.inicializarOrbitaTerrestre( ...
                obj.orbita.sma, ...
                obj.orbita.ecc, ...
                obj.orbita.inc, ...
                raan, ...
                obj.orbita.aop, ...
                obj.orbita.ta);
        end
        
        function obj = aumentarAnomaliaVerdadera(obj, delta_ta)
            %aumentarAnomaliaVerdadera aumenta el valor de la anomalia y ajusta la actitud.
            obj = obj.inicializarOrbitaTerrestre( ...
                obj.orbita.sma, ...
                obj.orbita.ecc, ...
                obj.orbita.inc, ...
                obj.orbita.raan, ...
                obj.orbita.aop, ...
                obj.orbita.ta + delta_ta);
        end
        
        function obj = aumentarRAAN(obj, delta_raan)
            %aumentarRAAN aumenta el valor de la anomalia y ajusta la actitud.
            obj = obj.inicializarOrbitaTerrestre( ...
                obj.orbita.sma, ...
                obj.orbita.ecc, ...
                obj.orbita.inc, ...
                obj.orbita.raan + delta_raan, ...
                obj.orbita.aop, ...
                obj.orbita.ta);
        end
        
        function n_i = normalInercialPanel(obj, i)
            n_b = obj.orientacion_paneles.(obj.nombre_orientaciones(i));
            R_b2o = [obj.actitud.x_b; obj.actitud.y_b; obj.actitud.z_b];
            R_o2i = [obj.orbita.ejes_inerciales.x_b; obj.orbita.ejes_inerciales.y_b; obj.orbita.ejes_inerciales.z_b];
            
            n_o = n_b * R_b2o;
            n_i = n_o * R_o2i;
        end
        
        %% POTENCIA
        function cos_beta = cosenoPanel(obj, n_sol_i, i)
            % Datos del panel
            n_i = obj.normalInercialPanel(i);
            cos_beta = dot(n_i, n_sol_i);
            if(cos_beta < cosd(85e0)); cos_beta = 0e0; end
        end
        
        function factor_eclipse = factorEclipse(obj, n_sol_i)
            factor_eclipse = 1e0 - obj.orbita.hayEclipse(n_sol_i);
        end
        
        function potencia = potenciaPanel(obj, n_sol_i, i)
            potencia = 0e0;
            if(i > 0 && i <= 6)
            else
                disp("Aviso: indice de panel incorrecto.");
                return;
            end
            % Datos satelite
            un_i = -obj.orbita.ejes_inerciales.x_b;
            
            % Datos del panel
            panel = obj.paneles.(obj.nombre_orientaciones(i));
            area_efectiva = panel.area_efectiva;
            eficiencia = panel.eficiencia;
            n_i = obj.normalInercialPanel(i);
            cos_beta = obj.cosenoPanel(n_sol_i, i);
            
            % Datos de la orbita
            K = obj.orbita.constante_solar;
            factor_eclipse = obj.factorEclipse(n_sol_i);
            
            % Datos del planeta
            albedo = obj.orbita.albedo;
            e = obj.orbita.emisividad;
            T = obj.orbita.temperatura;
            factor_tierra = dot(un_i, n_i);
            if(factor_tierra < 0e0); factor_tierra = 0e0; end
            factor_albedo = factor_tierra * factor_eclipse;
            
            
            irradiancia_sol = K * cos_beta * factor_eclipse;
            irradiancia_albedo = K * albedo * factor_albedo;
            irradiancia_planeta = e * 5.67e-8 * T^4e0 * factor_tierra * 0e0;
            
            irradiancia = irradiancia_sol + irradiancia_planeta + irradiancia_albedo;
            potencia = eficiencia * area_efectiva * irradiancia;
        end
        
        function potencia = potenciaPaneles(obj, n_sol_i)
            potencia = 0e0;
            for i = 1:1:6
                potencia = potencia + obj.potenciaPanel(n_sol_i, i);
            end
        end
    end
end

