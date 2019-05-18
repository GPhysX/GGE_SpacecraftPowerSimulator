function t = simulacion_temperatura(nu)
%simulacion_temperatura simulacion de la temperatura del satelite
%   nu: anomalia verdadera (deg)
t_max = 273.15 + 50;
t_min = 273.15 - 10;
tm = 5e-1 * (t_max + t_min);
a = 5e-1 * abs(t_max - t_min);
nu_max = 130.9091;
nu_min = 247.2727;
nu2 = mod(nu, 360);

t = zeros(size(nu2));
i = 1;
for nu_i = nu2
  if ( nu_i > nu_max && nu_i < nu_min )
    t(i) = (tm + a * cos(pi*(nu_i - nu_max)/(nu_min - nu_max)));
  else
    t(i) = tm - a * cos(pi*mod(nu_i - nu_min, 360)/(360 - abs(nu_max - nu_min)));
  end
  i = i + 1;
end

