function pwr = simulacion_potencia(nu, periodo)
%simulacion_potencia Perfil de consumos del sstelite
%   nu: Anomalia Verdadera [deg]
%   periodo: periodo orbital [s]

%nus_obs = 60:120:360;
%nus_trs = 0:120:360;
nus_obs = linspace(60,15*360e0,10);
nus_trs = linspace( 0,15*360e0,8);
t_ventana = 10e0 * 60e0;
dnu = 5e-1 * 360e0 * t_ventana / periodo;
pwr_obs = 15e0;
pwr_trs = 22e0;
pwr_bus = 5e0;
pwr_15p = 5e-1;
pwr_15m = 2e-1;
pwr_5 = 1e0;
pwr_3 = 2e0;

pwr_base = pwr_3 + pwr_5 + pwr_15m + pwr_15p + pwr_bus;
pwr = pwr_base * ones(size(nu));

i = 1;
for nu_i = nu
  if ( any( abs( nus_obs - nu_i ) < dnu ) )
    pwr(i) = pwr(i) + pwr_obs;
  end
  if ( any( abs( nus_trs - nu_i ) < dnu ) )
    pwr(i) = pwr(i) + pwr_trs;
  end
  i = i + 1;
end
end

