classdef Bateria
    properties
        r_c
        r_d
        coeficientes_descarga_tipo1
        coeficientes_descarga_tipo2
        coeficientes_descarga_tipo3
        coefs_e_d_t3
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

    end
    
    methods
        function obj = Bateria()
            obj.r_c = 0e0;
            obj.r_d = 0e0;
            obj.coeficientes_descarga_tipo1 = zeros(1,2);
            obj.coeficientes_descarga_tipo2 = zeros(1,4);
            obj.coeficientes_descarga_tipo3 = zeros(1,7);
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
    end
end