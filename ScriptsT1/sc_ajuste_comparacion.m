sc_ajuste_analitico

f_analitico = f_i;
%clear -x f_analitico;

sc_ajuste_numerico
f_numerico = f_i_ajuste_numerico;

a = [v_exp; f_analitico(v_exp) - i_exp; f_numerico(v_exp) - i_exp]';
%a = [v_exp; (f_analitico(v_exp)./i_exp - 1e0) * 100e0; (f_numerico(v_exp)./i_exp - 1e0) * 100e0]';

save "Err.dat" a;

N = length(v_exp);
M = 60;
subs = 1:(uint8(N/M)):N;
graphics_toolkit gnuplot;

%figure();
plot(v_exp(subs), i_exp(subs),  "m-", ...
  v_exp(subs), f_analitico(v_exp(subs)), "r.--", ...
  v_exp(subs), f_numerico(v_exp(subs)), "b.-." ...
);
xlim([min(v_exp), max(v_exp)]);
ylim([0e0, max(i_exp)]);
legend(["Experimental"; "Analitico"; "Numerico"]);
grid on;
title("Comparacion de ajustes de la curva de Karmalkar y Haneefa y los datos experimentales.");

figure();
plot(v_exp, f_analitico(v_exp) - i_exp,"b-.", ...
  v_exp, f_numerico(v_exp) - i_exp,  "r--" ...
);
legend(["Analitico"; "Numerico"]);
xlim([min(v_exp), max(v_exp)]);
grid on;
title("Comparacion de ajustes de la curva de Karmalkar y Haneefa y los datos experimentales.");