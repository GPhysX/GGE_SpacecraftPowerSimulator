classdef ConversorDC
    %CONVERSORDC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        a
        b
        c
        v_in
        v_out
    end
    
    methods
        function obj = ConversorDC(v_in, v_out)
            %CONVERSORDC Construct an instance of this class
            %   Detailed explanation goes here
            obj.name = "ConversorDC";
            obj.v_in = v_in;
            obj.v_out = v_out;
        end
        
%         function eta = rendimiento(obj, i_in)
%             eta = obj.a * ( 1e0 - exp(-obj.c * i_in));
%         end
        function eta = rendimiento(obj, i_out)
            eta = obj.a * ( 1e0 - obj.b * exp(-obj.c * i_out));
        end
        
%         function i_out = corriente_salida(obj, i_in)
%             i_out = obj.rendimiento(i_in) .* obj.v_in .* i_in / obj.v_out;
%         end
        
%         function i_out = corriente_salida(obj, i_in)
%           i_out = obj.rendimiento(i_in) .* obj.v_in .* i_in / obj.v_out;
%         end
        
        function i_in = corriente_entrada(obj, i_out)
          i_in = 1e0 ./ obj.rendimiento(i_out) .* obj.v_out .* i_out / obj.v_in;
        end
        
%         function i_in = corriente_entrada(obj, i_out)
%             N_MAX = 100;
%             i_in = 1e-2;
%             j = 0;
%             err = 1e8;
%             while ( and( j < N_MAX, err > 1e-4 ) )
%                 eta = obj.rendimiento(i_in);
%                 if ( eta > 1e-3 )
%                     i2 = obj.v_out / obj.v_in * i_out / eta;
%                 else
%                     i2 = eta / obj.c;
%                 end
%                 err = abs ( i2 - i_in );
%                 i_in = i2;
%             end
%         end
        
        function obj = ajuste(obj, i_out_exp, eta_exp)
            f_eta = @(u) u(1) * ( 1e0 - u(2) * exp( - u(3) * i_out_exp));
            f_ajuste = @(u) sqrt(sum((eta_exp - f_eta(u)).^2e0)/length(eta_exp));
            
            u0 = [eta_exp(end), 1e-3, 1e0];
            u = fminsearch(f_ajuste, u0);
            
            obj.a = u(1);
            obj.b = u(2);
            obj.c = u(3);
            
            %figure();
            %hold on;
            %plot(i_in_exp, eta_exp, 'DisplayName', 'Experimental');
            %plot(i_in_exp, obj.rendimiento(i_in_exp), 'DisplayName', 'Simulado');
        end

    end
end

