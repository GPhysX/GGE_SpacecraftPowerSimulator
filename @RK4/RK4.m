classdef RK4
    %RK4 Runge-Kutta 4
    
    properties
        f
        y
        t
        iter
    end
    
    methods
        function obj = RK4(f, y0, t0)
            %RK4 Constructor
            %   f: funcion f(y,t)
            %   y0: Vector Estado  en instante inicial
            %   t0: Instante inicial
            s = size(y0);
            if ( s(1) == 1 )
                % Change to column-vector.
                obj.y = y0';
            else
                obj.y = y0;
            end
            obj.f = f;
            obj.t = t0;
            obj.iter = 0;
        end
        
        function obj = next(obj,dt)
            %next Calcula el Vector Estado en el instante t + dt.
            %   obj: objeto Runge-Kutta 4.
            %   dt: incremento de tiempo hasta el siguiente paso.
            k1 = obj.f(obj.y, obj.t);
            k2 = obj.f(obj.y + dt / 2e0 * k1, obj.t + dt / 2e0);
            k3 = obj.f(obj.y + dt / 2e0 * k2, obj.t + dt / 2e0);
            k4 = obj.f(obj.y + dt * k3, obj.t + dt);
            obj.y = obj.y + dt / 6e0 * (k1 + 2e0 * k2 + 2e0 * k3 + k4);
            obj.y;
            obj.t = obj.t + dt;
            obj.iter = obj.iter + 1;
        end
    end
end

