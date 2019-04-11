classdef Entorno
    properties
        name
    end
    
    methods
        function env = Entorno ()
            env.name = "Entorno";
        end
    end
    
    methods(Static = true)
        function t = temperatura (t)%, omega, tiempo_delay, t_frio, t_caliente)
            %% Parametros
            omega = 52e-3;                         % rad / s
            tiempo_delay = 15e0;                   % s
            t_frio_c = -20e0;                      % C
            t_caliente_c = 80e0;                   % C
            t_frio = t_frio_c + 273.15e0;          % K
            t_caliente = t_caliente_c + 273.15e0;  % K

            %% Variable
            theta = rem(omega * t, 2e0 * pi);

            %% Parametros del modelo
            mu = pi/2e0 + omega * tiempo_delay;
            %phi1 = mu - pi;
            c1 = pi / (mu);
            b1 = (t_frio - t_caliente) / 2e0;
            a1 = (t_frio + t_caliente) / 2e0;

            %phi2 = - pi;
            b2 = (t_caliente - t_frio) / 2e0;
            a2 = (t_frio + t_caliente) / 2e0;
            c2 = pi / (pi - omega * tiempo_delay);

            %% Asignaciones
            t = a1 + b1 * cos(theta * c1);
            t(theta > mu) = a2 + b2 * cos(c2 * (theta(theta > mu) - mu));
            t(theta > pi) = t_frio;
        end
    end
end
