function f = ecuaciones_sistema(y,t,cdc33,cdc5,cdc15,ipps,ipbus,ipp15v,ipm15v,ipp5v,ipp33v,bateria)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
f = zeros(3,1);
phi = y(1);
ir1 = y(2);
ir2 = y(3);

bateria.i_r1 = ir1;
bateria.i_r2 = ir2;

global i_c e_p
%global p_33 p_5 p_p15 p_m15 p_bus p_ps
%global switchs
%global conversor_3_3v conversor_5v conversor_15v

p_33 = ipp33v.eval(t);
p_5 = ipp5v.eval(t);
p_m15 = ipm15v.eval(t);
p_p15 = ipp15v.eval(t);
p_bus = ipbus.eval(t);
p_ps = ipps.eval(t);

p_inp_3 = cdc33.corriente_entrada(p_33 / 3.3) * 15e0;

p_inp_2 = cdc5.corriente_entrada(p_5 / 5.0) * 15e0;

p_out_1 = p_p15 + p_m15 + p_inp_2 + p_inp_3;
p_inp_1 = cdc15.corriente_entrada(p_out_1 / 15.0) * 22.5;

p_sys = p_bus + p_inp_1;
p_t = p_ps - p_sys;

if ( p_ps > 1e-3)
    % Paneles Solares funcionando.
    if ( phi < 0e0 )
        % Bateria cargada, desconectarla.
        p_t = 0e0;
    end
end

if ( and( p_t > 0e0, p_t < 1e0) )
    %Charge at 1W, assume no charge at all.
    p_t = 0e0;
end

p_t;

if ( abs(p_t) < 1e-3 )
    i_c = 0e0;
    e_p = 0e0;
elseif ( p_t > 0e0 )
    %% Charge
    ff = @(x) p_t / -x - bateria.voltage_dynamic(phi, x, 3);
    i_c = fzero(ff, -2e0);
    if (i_c < -1e1)
        ;
    end
    %fff = @(x) abs(p_t + x * bateria.voltage_dynamic(phi, x, 3));
    %[i_c, fer] = fmincon(fff, [-20e0],[],[],[],[],[-5e2],[0e0]);
    e_p = bateria.voltage_dynamic(phi, i_c, 3);
    p_t / i_c;
else
    %% Discharge
    ff = @(x) p_t / -x - bateria.voltage_dynamic(phi, x, 3);
    i_c = fzero(ff, 2e0);
    %fff = @(x) abs(p_t + x * bateria.voltage_dynamic(phi, x, 3));
    %i_c = fminsearch(fff, [2e0]);
    e_p = bateria.voltage_dynamic(phi, i_c, 3);
    p_t / i_c;
    if (i_c > 3e0)
        ;
    end
end

f(1) = i_c * bateria.battery_voltage_static(phi, i_c, 3);
f(2) = (i_c - ir1) / (bateria.r_1 * bateria.c_1);
f(3) = (i_c - ir2) / (bateria.r_2 * bateria.c_2);

