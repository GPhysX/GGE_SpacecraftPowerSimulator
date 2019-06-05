classdef Actitud
    %Actitud: Sistema de ejes body locales.
    
    properties
        x_b
        y_b
        z_b
    end
    
    %% STATIC METHODS
    methods(Static=true)
        function qi = cuaternionRotacionI(theta, i)
            c = cosd(theta/2e0);
            s = sind(theta/2e0);
            qi = [c, 0e0, 0e0, 0e0];
            qi(i + 1) = s;
        end
        function qx = cuaternionRotacionX(theta)
            qx = Actitud.cuaternionRotacionI(theta, 1);
        end
        function qy = cuaternionRotacionY(theta)
            qy = Actitud.cuaternionRotacionI(theta, 2);
        end
        function qz = cuaternionRotacionZ(theta)
            qz = Actitud.cuaternionRotacionI(theta, 3);
        end
        function q = cuaternionRotacionEuler(precesion, nutacion, rotacion)
            qp = Actitud.cuaternionRotacionZ(precesion);
            qn = Actitud.cuaternionRotacionX(nutacion);
            qr = Actitud.cuaternionRotacionZ(rotacion);
            %qr = quaternion(qr(1),qr(2),qr(3),qr(4));
            %qn = quaternion(qn(1),qn(2),qn(3),qn(4));
            %qp = quaternion(qp(1),qp(2),qp(3),qp(4));
            %q = qr * (qn * qp);
            q = Actitud.quat_mult(qr, Actitud.quat_mult(qn, qp));
        end
        function q3 = quat_mult(q1, q2)
          %r = 
          r = q1(1) * q2(1) - dot(q1(2:1:4), q2(2:1:4));
          %x = q1(2) * q2(1) + q1(3) * q2(4) - q1(4) * q2(3);
          x = q1(2) * q2(1) + q1(3) * q2(4) + q1(1) * q2(2) - q1(4) * q2(3);
          %y = q1(3) * q2(1) + q1(4) * q2(2) - q1(2) * q2(4);
          y = q1(3) * q2(1) + q1(4) * q2(2) + q1(1) * q2(3) - q1(2) * q2(4);
          %z = q1(4) * q2(1) + q1(2) * q2(3) - q1(3) * q2(2);
          z = q1(4) * q2(1) + q1(2) * q2(3) + q1(1) * q2(4) - q1(3) * q2(2);
          q3 = [r,x,y,z];
          %q3 = quatmultiply(q1, q2);
        end
        function q2 = quat_rota(q, v)
            qp = [q(1), -q(2), -q(3), -q(4)];
            q2 = Actitud().quat_mult(q, Actitud().quat_mult([0e0, v(1), v(2), v(3)],qp));
            q2 = [q2(2), q2(3), q2(4)];
        end
    end
    %% CLASS METHODS
    methods(Static=false)
        %% CONSTRUCTOR
        function obj = Actitud()
            %Actitud definir los ejes locales iniciales.
            obj.x_b = [1e0, 0e0, 0e0];
            obj.y_b = [0e0, 1e0, 0e0];
            obj.z_b = [0e0, 0e0, 1e0];
        end
        %% INSTANCE METHODS
        function obj = rotacionPorCuaternion(obj, q)
            %rotacionPorCuaternion Gira segun el quaternion q.
            %obj.x_b = quatrotate(q, obj.x_b);
            %obj.y_b = quatrotate(q, obj.y_b);
            %obj.z_b = quatrotate(q, obj.z_b);
            x_b_new = Actitud().quat_rota(q, obj.x_b);
            y_b_new = Actitud().quat_rota(q, obj.y_b);
            z_b_new = Actitud().quat_rota(q, obj.z_b);
            
            obj.x_b = x_b_new;
            obj.y_b = y_b_new;
            obj.z_b = z_b_new;
        end
        function obj = rotacionPorEuler(obj, precesion, nutacion, rotacion)
            %rotacionPorAngulosEuler Giro con angulos de Tait-Bryan
            q = Actitud.cuaternionRotacionEuler(precesion, nutacion, rotacion);
            obj = obj.rotacionPorCuaternion(q);
        end
        
        function obj = rotacionEje(obj, theta, eje)
          %rotacionEje Giro en grados sobre un eje principal.
          if eje == 1
            qi = Actitud.cuaternionRotacionI(theta, 1);
            obj = obj.rotacionPorCuaternion(qi);
          elseif eje == 2
            qi = Actitud.cuaternionRotacionI(theta, 2);
            obj = obj.rotacionPorCuaternion(qi);
          elseif eje == 3
            qi = Actitud.cuaternionRotacionI(theta, 3);
            obj = obj.rotacionPorCuaternion(qi);
          end
        end
    end
end

