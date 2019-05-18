classdef Orbita
    %Orbita: 
    
    properties
        mu_p
        r_p
        sma
        ecc
        inc
        raan
        aop
        ta
        albedo
        emisividad
        temperatura
        ejes_inerciales
    end
    
    methods
        function obj = Orbita(mu_p, r_p, sma, ecc, inc, raan, aop, ta, albedo, emisividad, temperatura)
            %Orbita constructor.
            %  mu_p: mu del planeta (km**3/s**2).
            %  r_p: radio del planeta (km).
            %  sma: semieje mayor (km).
            %  ecc: excentricidad.
            %  inc: inclinacion (deg).
            %  raan: RAAN (deg).
            %  aop: argumento del perigeo (deg).
            %  ta: anomalia verdadera (deg).
            %  albedo: albedo medio del planeta.
            %  emisividad: emisividad media del planeta.
            %  temperatura: temperatura media del planeta (K).
            
            obj.mu_p = mu_p;
            obj.r_p = r_p;
            obj.sma = sma;
            obj.ecc = ecc;
            obj.inc = inc;
            obj.raan = raan;
            obj.aop = aop;
            obj.ta = ta;
            
            precesion = raan;
            nutacion = inc;
            rotacion = aop + ta;
            actitud = Actitud();
            actitud = actitud.rotacionPorEuler(-precesion, -nutacion, -rotacion);
            obj.ejes_inerciales =  actitud;
            
            if(nargin >= 9)
                obj.albedo = albedo;
                obj.emisividad = emisividad;
                obj.temperatura = temperatura;
            else
                obj.albedo = 0e0;
                obj.emisividad = 0e0;
                obj.temperatura = 0e0;
            end
        end
        
        function f = hayEclipse(obj, n_sol_i)
            %hayEclipse 1 si hay eclipse, 0 si no hay eclipse.
            %  n_sol_i: vector unitario apuntando al Sol en Ejes
            %    Inerciales.
            f = 0e0;
            r_mag = obj.sma * (1e0 - obj.ecc^2e0) / (1e0 + obj.ecc * cosd(obj.ta));
            precesion = obj.raan;
            nutacion = obj.inc;
            rotacion = obj.aop + obj.ta;
            %u_r_i = Actitud().rotacionPorEuler(-precesion, -nutacion, -rotacion).x_b;
            
            q = Actitud.cuaternionRotacionEuler(precesion, nutacion, rotacion);
            
            u_r_i = Actitud().rotacionPorCuaternion(q).x_b;
            n = n_sol_i;
            
            r_i = r_mag * u_r_i;
            z_plano_sombra = dot(r_i, n);
            r_plano_sombra = norm(r_i - z_plano_sombra * n);
            
            
            
            if(z_plano_sombra < 0e0)
                if(r_plano_sombra <= obj.r_p)
                    f = 1e0;
                end
            end
        end
    end
end

