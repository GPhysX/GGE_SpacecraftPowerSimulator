function [pwr, pbus, i3, i5, ip15, im15, icnvs] = simulacion_potencia(nu, periodo, cnvs, caso)
%simulacion_potencia Perfil de consumos del sstelite
%   nu: Anomalia Verdadera [deg]
%   periodo: periodo orbital [s]

%nus_obs = 60:120:360;
%nus_trs = 0:120:360;
icnvs = zeros(6,1);
aa = 24e0*3600e0/periodo;
nus_obs = linspace(60,aa*360e0,3);
nus_trs = linspace( 0,aa*360e0,3);
t_ventana = 10e0 * 60e0;
dnu = 5e-1 * 360e0 * t_ventana / periodo;
pwr_obs = 15e0;
pwr_trs = 22e0;
pwr_bus = 5e0;
pwr_15p = 5e-1;
pwr_15m = 2e-1;
pwr_5 = 1e0;
pwr_3 = 2e0;

v_out_1 = 3.3;
i_out_1 = pwr_3 / v_out_1;
i3 = i_out_1;
v_inp_1 = 15e0;
i_inp_1 = cnvs{1}.corriente_entrada(i_out_1);
p_inp_1 = v_inp_1 * i_inp_1;
icnvs(1:2) = [i_inp_1, i_out_1];

v_out_2 = 5e0;
i_out_2 = pwr_5 / v_out_2;
i5 = i_out_2;
v_inp_2 = 15e0;
i_inp_2 = cnvs{2}.corriente_entrada(i_out_2);
p_inp_2 = v_inp_2 * i_inp_2;
icnvs(3:4) = [i_inp_2, i_out_2];

im15 = pwr_15m / -15e0;
ip15 = pwr_15p / +15e0;
p_out_3 = p_inp_1 + p_inp_2 + pwr_15p + pwr_15m;
i_out_3 = p_out_3 / 15e0;
p_inp_3 = p_out_3 / cnvs{3}.rendimiento(p_out_3 / 15e0);
i_inp_3 = p_inp_3;
icnvs(5:6) = [i_inp_3, i_out_3];

%pwr_base = pwr_3 + pwr_5 + pwr_15m + pwr_15p + pwr_bus;
pwr_base = p_inp_3 + pwr_bus;
pwr = pwr_base * ones(size(nu));

i = 1;
for nu_i = nu
  if caso == 1
    temp = mod(nu_i, 360);
    if(temp > 131 && temp < 243)
      temp = p_inp_2 + pwr_15p;
      temp = temp / cnvs{3}.rendimiento(temp / 15e0);
      pwr(i) = pwr_bus + temp;
      i3 = 0e0;
      im15 = 0e0;
    end
  end
  pbus = pwr_bus;
  if ( any( abs( nus_obs - nu_i ) < dnu ) )
    pwr(i) = pwr(i) + pwr_obs;
    pbus = pwr_bus + pwr_obs;
  end
  if ( any( abs( nus_trs - nu_i ) < dnu ) )
    pwr(i) = pwr(i) + pwr_trs;
    pbus = pwr_bus + pwr_trs;
  end
  i = i + 1;
end
end

