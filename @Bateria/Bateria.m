classdef Bateria
    properties
        phi_max
        r_c
        r_d
        r_int
        r_1
        r_2
        c_1
        c_2
        coeficientes_descarga_tipo1
        coeficientes_descarga_tipo2
        coeficientes_descarga_tipo3
        coeficientes_carga_tipo1
        coeficientes_carga_tipo2
        coeficientes_carga_tipo3
        coefs_e_c
    end
    
    methods(Static = true)
        function [phi1, phi2] = get_phies (t, i, v)
            n = length(t);
            dts = t(2:n) - t(1:(n-1));
            integrando_phi1 = v .* i;
            integrando_phi2 = i .^ 2e0;
            trap_phi1 = 5e-1 * (integrando_phi1(2:n) + integrando_phi1(1:(n-1))) .* dts;
            trap_phi2 = 5e-1 * (integrando_phi2(2:n) + integrando_phi2(1:(n-1))) .* dts;
            
            phi1 = zeros(n,1);
            phi2 = zeros(n,1);
            for j = 1:(n-1)
              phi1(j+1) = phi1(j) + trap_phi1(j);
              phi2(j+1) = phi2(j) + trap_phi2(j);
            end
        end
        
        function fer = modelo_estatico_descarga_tipo1 (pesos, v, i, phi1, phi2, e0, e1, r_d)
            f_ed = @(phi) e0 + e1 * phi;
            phi = phi1 + r_d * phi2;
            ed = f_ed(phi);
            v2 = ed - r_d .* i;
            fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
        end
        
        function fer = modelo_estatico_descarga_tipo2 (pesos, v, i, phi1, phi2, e0, e1, e2, e3, r_d)
            f_ed = @(phi) e0 + e1 * phi + e2 * exp(e3 * phi);
            phi = phi1 + r_d * phi2;
            ed = f_ed(phi);
            v2 = ed - r_d .* i;
            fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
        end
        
        function fer = modelo_estatico_descarga_tipo3 (pesos, v, i, phi1, phi2, e0, e1, e20, e21, e22, e30, e31, r_d)
            f_ed = @(phi) e0 + e1 * phi + (e20 + e21 * i + e22 * i .^ 2e0) .* exp((e30 + e31 * i) .* phi);
            phi = phi1 + r_d * phi2;
            ed = f_ed(phi);
            v2 = ed - r_d .* i;
            fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
        end
        
        function fer = modelo_estatico_carga_tipo1 (pesos, v, i, phi1, phi2, e0, e1, r_c, phi0)
            f_ed = @(phi) e0 - e1 * phi;
            phi = phi0 - phi1 + r_c * phi2;
            ed = f_ed(phi);
            v2 = ed + r_c .* i;
            fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
        end
        
        function fer = modelo_estatico_carga_tipo2 (pesos, v, i, phi1, phi2, e0, e1, e2, e3, r_c, phi0)
            f_ed = @(phi) e0 - e1 * phi - e2 * exp(e3 * phi);
            phi = phi0 - phi1 + r_c * phi2;
            ed = f_ed(phi);
            v2 = ed + r_c .* i;
            fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
        end
        
        function fer = modelo_estatico_carga_tipo3 (pesos, v, i, phi1, phi2, e0, e1, e2, e30, e31, r_c, phi0)
            f_ed = @(phi) e0 - e1 * phi - e2 * exp((e30 + e31 * i) .* phi);
            phi = phi0 - phi1 + r_c * phi2;
            ed = f_ed(phi);
            v2 = ed + r_c .* i;
            fer = norm((v2 - v) .* pesos) / sqrt(sum(pesos));
        end
        
        function table = datos_carga_a_vector(archivo, head_trim, tail_trim)
            a = load(archivo, "-ascii");
            
            %% Size of table
            %n = size(a(:,1));
            m = size(a, 2) / 3;
            
            %% Extract vectors
            ts = a(:,1:3:end);
            is = a(:,2:3:end);
            vs = a(:,3:3:end);
            
            %%
            l = 0;
            v_vec = [];
            i_vec = [];
            phi1_vec = [];
            phi2_vec = [];
            t_vec = [];
            pesos_vec = [];
            
            for j = 1:m
                tmp_t = t_vec;
                tmp_i = i_vec;
                tmp_v = v_vec;
                tmp_p1 = phi1_vec;
                tmp_p2 = phi2_vec;
                tmp_w = pesos_vec;
                
                i_max = max(is(:,j));
                subindxs = abs(is(:,j) - i_max) < 1e-3;
                n_i = sum(subindxs) - head_trim - tail_trim;
                l = l + n_i;
                
                t2 = ts(subindxs, j);
                i2 = is(subindxs, j);
                v2 = vs(subindxs, j);
                
                t2 = t2((head_trim+1):(end-tail_trim));
                i2 = i2((head_trim+1):(end-tail_trim));
                v2 = v2((head_trim+1):(end-tail_trim));
                w2 = ones(length(t2),1) * n_i;
                
                [p12, p22] = Bateria().get_phies (t2, i2, v2);
                
                t_vec = zeros(l,1);
                i_vec = zeros(l,1);
                v_vec = zeros(l,1);
                phi1_vec = zeros(l,1);
                phi2_vec = zeros(l,1);
                pesos_vec = zeros(l,1);
                
                t_vec(1:l,1) = [tmp_t; t2];
                i_vec(1:l,1) = [tmp_i; i2];
                v_vec(1:l,1) = [tmp_v; v2];
                phi1_vec(1:l,1) = [tmp_p1; p12];
                phi2_vec(1:l,1) = [tmp_p2; p22];
                pesos_vec(1:l,1) = [tmp_w; w2];
            end
            
            pesos_vec = 1e0 ./ pesos_vec;
            pesos_vec = pesos_vec / norm(pesos_vec);
            table = [t_vec, i_vec, v_vec, phi1_vec, phi2_vec, pesos_vec];
                
        end
    end
    
    methods
        function obj = Bateria()
            obj.r_c = 0e0;
            obj.r_d = 0e0;
            obj.coeficientes_descarga_tipo1 = zeros(1,2);
            obj.coeficientes_descarga_tipo2 = zeros(1,4);
            obj.coeficientes_descarga_tipo3 = zeros(1,7);
        end
        
        function e_d = voltaje_pila_descarga(obj, phi, i)
            c_e_d = obj.coeficientes_descarga_tipo3;
            e0 = c_e_d(1);
            e1 = c_e_d(2);
            e2 = dot(c_e_d(3:5), [i .^ 0e0, i .^ 1e0, i .^ 2e0]);
            e3 = dot(c_e_d(6:7), [i .^ 0e0, i .^ 1e0]);
            e_d = e0 + e1 * phi + e2 .* exp(e3 .* phi);
        end
        
        function e_c = voltaje_pila_carga(obj, phi, i)
            c_e_c = obj.coeficientes_carga_tipo3;
            e0 = c_e_c(1);
            e1 = c_e_c(2);
            e2 = c_e_c(3);
            e3 = dot(c_e_d(4:5), [i .^ 0e0, i .^ 1e0]);
            e_c = e0 - e1 * phi - e2 .* exp(e3 .* phi);
        end
        
        function obj = ajuste_coeficientes_descarga(obj, archivo, tipo, u0)
            if ( nargin == 2 )
                u0 = zeros(1,3);
                tipo = 1;
            end
            cabeza = 3;
            cola = 3;
            t_ref = 1e0;
            a = load(archivo, "-ascii");
            n = size(a,1);
            m = size(a,2) / 3;
            pesos = ones(m,1);

            ts = a(:,1:3:end);
            is = a(:,2:3:end);
            vs = a(:,3:3:end);
            phi1 = zeros(n, m);
            phi2 = zeros(n, m);
            for j = 1:m
                [phi1(:,j), phi2(:,j)] = Bateria.get_phies(ts(:,j), is(:,j), vs(:,j));
            end

            n_f = 0;
            for j = 1:m
                n_i = sum(ts(:,j) > t_ref) - cola - cabeza;
                n_f = n_f + n_i;
                pesos(j) = n_i;
            end
            pesos = 1e0 ./ pesos;
            pesos = pesos / norm(pesos);

            v_vec = zeros(n_f,1);
            i_vec = zeros(n_f,1);
            phi1_vec = zeros(n_f,1);
            phi2_vec = zeros(n_f,1);
            t_vec = zeros(n_f,1);
            pesos_vec = zeros(n_f,1);

            n_t = 0;
            for j = 1:m
                n_p = n_t;
                subidxs = ts(:,j) > t_ref;
                k = 0;
                kk = length(subidxs);
                while ( k < cola )
                    if (subidxs(kk) == 1)
                        subidxs(kk) = 0;
                        k = k + 1;
                    end
                    kk = kk - 1;
                end
                k = 0;
                kk = 1;
                while ( k < cabeza )
                    if (subidxs(kk) == 1)
                        subidxs(kk) = 0;
                        k = k + 1;
                    end
                    kk = kk + 1;
                end

                n_i = sum(ts(:,j) > t_ref) - cabeza - cola;
                n_t = n_t + n_i;

                v_vec((n_p+1):n_t)    = vs(subidxs,j);
                i_vec((n_p+1):n_t)    = is(subidxs,j);
                phi1_vec((n_p+1):n_t) = phi1(subidxs,j);
                phi2_vec((n_p+1):n_t) = phi2(subidxs,j);
                t_vec((n_p+1):n_t)    = ts(subidxs,j);
                pesos_vec((n_p+1):n_t) = pesos(j);
                %pesos_vec((n_t-5):n_t) = 0e0;
                
                if (tipo == 3)
                    ajuste = @(u) Bateria().modelo_estatico_descarga_tipo3(pesos_vec, v_vec, i_vec, phi1_vec, phi2_vec, u(1), u(2), u(3), u(4), u(5), u(6), u(7), u(8));
                    lb = [ 0e0, -1e0,    -1e-1,     -1e-1,     -1e-1,      0e0,     -1e-1,  0e0];
                    ub = [25e0,-1e-5,      0e0,       0e0,       0e0,     1e-1,       0e0,  1e1];
                    uu0 = [12e0, -1e-3, -1e-8, -1e-8, -1e-8, 1e-3, -1e-8, 1e0];
                elseif (tipo == 2)
                    ajuste = @(u) Bateria().modelo_estatico_descarga_tipo2(pesos_vec, v_vec, i_vec, phi1_vec, phi2_vec, u(1), u(2), u(3), u(4), u(5));
                    lb = [0e0, -1e0, -1e0, 0e0, 0e0];
                    ub = [25e0, 0e0,  0e0, 1e2, 1e2];
                    uu0 = [12e0, -1e-3, -1e-3, 1e-8, 1e0];
                else
                    ajuste = @(u) Bateria().modelo_estatico_descarga_tipo1(pesos_vec, v_vec, i_vec, phi1_vec, phi2_vec, u(1), u(2), u(3));
                    lb = [0e0, -1e0, 0e0];
                    ub = [25e0, 0e0, 1e2];
                    uu0 = [12e0, -1e-3, 1e0];
                end
                
                if(nargin > 3)
                    if(length(u0) > 1)
                        uu0 = u0;
                    end
                end

                [u, fer] = fmincon(ajuste, uu0, [], [], [], [], lb, ub);%, [], options);
                disp(fer);
                
                if ( tipo == 3 )
                    obj.coeficientes_descarga_tipo3 = u(1:7);
                    obj.r_d = u(8);
                elseif ( tipo == 2 )
                    obj.coeficientes_descarga_tipo2 = u(1:4);
                    obj.r_d = u(5);
                else
                    obj.coeficientes_descarga_tipo1 = u(1:2);
                    obj.r_d = u(3);
                end
                
                obj.phi_max = max(phi1_vec + obj.r_d * phi2_vec);
            end
        end
        
        function obj = ajuste_coeficientes_descarga_tipo1(obj, archivo, u0)
            if (nargin > 2)
                obj = obj.ajuste_coeficientes_descarga(archivo, 1, u0);
            else
                obj = obj.ajuste_coeficientes_descarga(archivo);
            end
        end
        
        function obj = ajuste_coeficientes_descarga_tipo2(obj, archivo, u0)
            nargin
            if (nargin > 2)
                obj = obj.ajuste_coeficientes_descarga(archivo, 2, u0);
            else
                bateria = Bateria();
                bateria = bateria.ajuste_coeficientes_descarga_tipo1(archivo, 1);
                coefs = bateria.coeficientes_descarga_tipo1;
                u0 = [coefs(1), coefs(2), -1e-7, 1e-8, bateria.r_d];
                obj = obj.ajuste_coeficientes_descarga(archivo, 2, u0);
            end
        end
        
        function obj = ajuste_coeficientes_descarga_tipo3(obj, archivo, u0)
            if (nargin > 2)
                obj = obj.ajuste_coeficientes_descarga(archivo, 3, u0);
            else
                bateria = Bateria();
                bateria = bateria.ajuste_coeficientes_descarga_tipo2(archivo);
                coefs = bateria.coeficientes_descarga_tipo2;
                u0 = [coefs(1), coefs(2), coefs(3)/3e0, coefs(3)/15e0, coefs(3)/75e0, coefs(4)/2e0, coefs(4)/10e0, bateria.r_d];
                obj = obj.ajuste_coeficientes_descarga(archivo, 3, u0);
            end
        end
        
        function obj = ajuste_coeficiente_carga_tipo1(obj, archivo)
            a = Bateria().datos_carga_a_vector(archivo, 3, 3);
            %t_vec = a(:,1);
            i_vec = a(:,2);
            v_vec = a(:,3);
            phi1_vec = a(:,4);
            phi2_vec = a(:,5);
            pesos = a(:,6);
                        
            ff = @(u) obj.modelo_estatico_carga_tipo1(pesos, v_vec, i_vec, phi1_vec, phi2_vec, u(1), u(2), u(3), obj.phi_max);
            lb = [0e0, 0e0, 0e0];
            ub = [1e3, 1e0, 1e3];
            [u, fer] = fmincon(ff, [0e0, 1e0, 0e0],[],[],[],[],lb,ub);
            
            disp(fer);
            
            phis = obj.phi_max - phi1_vec + u(3)*phi2_vec;
            scatter(phis, u(1) + u(2) * phis + u(3) .* i_vec );
            
            obj.r_c = u(3);
            obj.coeficientes_carga_tipo1 = u(1:2);
        end
        
        function obj = ajuste_coeficiente_carga_tipo2(obj, archivo)
            a = Bateria().datos_carga_a_vector(archivo, 3, 3);
            %t_vec = a(:,1);
            i_vec = a(:,2);
            v_vec = a(:,3);
            phi1_vec = a(:,4);
            phi2_vec = a(:,5);
            pesos = a(:,6);
            
            obj = obj.ajuste_coeficiente_carga_tipo1(archivo);
            u0 = [obj.coeficientes_carga_tipo1, 1e-8, 1e-4, obj.r_c];
                        
            ff = @(u) obj.modelo_estatico_carga_tipo2(pesos, v_vec, i_vec, phi1_vec, phi2_vec, u(1), u(2), u(3), u(4), u(5), obj.phi_max);
            lb = [0e0, 0e0, 0e0, -1e2, 0e0];
            ub = [1e3, 1e0, 1e0,  1e2, 1e3];
            [u, fer] = fmincon(ff, u0,[],[],[],[],lb,ub);
            
            disp(fer);
            
            obj.r_c = u(5);
            obj.coeficientes_carga_tipo2 = u(1:4);
        end
        
        function obj = ajuste_coeficiente_carga_tipo3(obj, archivo)
            a = Bateria().datos_carga_a_vector(archivo, 3, 3);
            %t_vec = a(:,1);
            i_vec = a(:,2);
            v_vec = a(:,3);
            phi1_vec = a(:,4);
            phi2_vec = a(:,5);
            pesos = a(:,6);
            
            obj = obj.ajuste_coeficiente_carga_tipo2(archivo);
            u0 = [obj.coeficientes_carga_tipo2(1:3), obj.coeficientes_carga_tipo2(4)/2e0, obj.coeficientes_carga_tipo2(4)/1e1, obj.r_c];
                        
            ff = @(u) obj.modelo_estatico_carga_tipo3(pesos, v_vec, i_vec, phi1_vec, phi2_vec, u(1), u(2), u(3), u(4), u(5), u(6), obj.phi_max);
            lb = [0e0, 0e0, 0e0, -1e2, -1e2, 0e0];
            ub = [1e3, 1e0, 1e0,  1e2,  1e2, 1e3];
            [u, fer] = fmincon(ff, u0,[],[],[],[],lb,ub);
            
            disp(fer);
            
            obj.r_c = u(6);
            obj.coeficientes_carga_tipo3 = u(1:5);
        end
        
        function fer = modelo_dinamico(obj, t, i, v, r_1, r_2, c_1, c_2)
            phi0 = 0e0;
            [phi1, phi2] = obj.get_phies (t, i, v);
            e_d = obj.voltaje_pila_descarga(phi0 + phi1 * obj.r_d + phi2, i);
            e_c = obj.voltaje_pila_carga(phi0 - phi1 * obj.r_c + phi2, i);
            de = e_c - e_d;
            dr = obj.r_c - obj.r_d;
            v_estatico = e_d + (1e0 - sign(i)) / 2e0 * (de - dr * i) - (obj.r_d - r_1 -r_2) * i;
            
            f_i = @(j) i(j); 
            dv1_dt = @(y, j) (r_1 * f_i(j) - y) / (r_1 * c_1);
            n = length(t);
            v1s = zeros(n, 1);
            v2s = zeros(n, 1);
            
            for j = 1:n
                v1s(j+1) = v1s(j) + (t(j+1)-t(j)) * (r_1 * i(j) - v1s(j)) / (r_1 * c_1);
                v2s(j+1) = v2s(j) + (t(j+1)-t(j)) * (r_2 * i(j) - v2s(j)) / (r_2 * c_2);
            end
            
            v_dinamico = v_estatico - v1s - v2s;
        end
    end
end