classdef OrbitaTerrestre < Orbita
    %OrbitaTerrestre Orbita centrada en la Tierra
    
    properties
        constante_solar = 1366;  % W/m**2
    end
    
    %% INSTANCE METHODS
    methods
        %% CONSTRUCTOR
        function obj = OrbitaTerrestre(sma, ecc, inc, raan, aop, ta)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj = Orbita(3.986e5, 6378e0, sma, ecc, inc, raan, aop, ta, 0.1, 0.6, 288.0);
        end
    end
end

