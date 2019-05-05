classdef Interpolator
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x
        y
        n
        f
    end
    
    methods
        function obj = Interpolator(x,y)
            %UNTITLED7 Construct an instance of this class
            %   Detailed explanation goes here
            obj.x = x;
            obj.y = y;
            obj.n = length(x);
            %obj.f = griddedInterpolant(x,y);
        end
        
        function y_i = eval(obj, x_i)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if ( length(x_i) == 1)
              [row,~,~] = find(obj.x <= x_i);
              i_1 = max(row);
              i_2 = i_1 + 1;
              if ( i_2 > obj.n )
                  y_i = obj.y(end);
                  return
              end
              x_1 = obj.x(i_1);
              x_2 = obj.x(i_2);
              y_1 = obj.y(i_1);
              y_2 = obj.y(i_2);
              y_i = y_1 + (y_2 - y_1) / (x_2 - x_1) * (x_i - x_1);
            else
              y_i = zeros(size(x_i));
              for kk = 1:length(x_i)
                y_i(kk) = obj.eval(x_i(kk));
              end
            end
        end
    end
end

