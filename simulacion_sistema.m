function f = simulacion_sistema(v, i_ps, i_bat, temp, es, pwr, phi, satelite)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
f = zeros(3, 1);
ips = zeros(6, 1);
ips(1) = 0e0;%satelite.paneles.XM.corriente_d1r2(v, temp, es(1));
ips(2) = satelite.paneles.YM.corriente_d1r2(v, temp, es(2));
ips(3) = satelite.paneles.ZM.corriente_d1r2(v, temp, es(3));
ips(4) = 0e0;%satelite.paneles.XP.corriente_d1r2(v, temp, es(4));
ips(5) = satelite.paneles.YP.corriente_d1r2(v, temp, es(5));
ips(6) = satelite.paneles.ZP.corriente_d1r2(v, temp, es(6));

ips(ips < 0e0) = 0e0;

pwr_ps = v * sum(ips);
pwr_bt = v * i_bat;
f(1) = i_ps - sum(ips);
f(2) = v - satelite.bateria.voltage_dynamic(phi, i_bat, 3);
f(3) = pwr - pwr_bt - pwr_ps;
if ( phi < 0e0 )
  if (pwr_ps > pwr)
    f(1) = i_ps - sum(ips);
    f(2) = i_bat;
    f(3) = pwr - pwr_ps;
  end
end

end

