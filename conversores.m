close all
clc
plots = true;

%% Conversor 5V
a = load("data/conversor_5V.dat", "-ascii");
vec_v_in = a(:,1);
vec_i_in = a(:,2);
vec_p_in = a(:,3);
vec_v_out = a(:,4);
vec_i_out = a(:,5);
vec_p_out = a(:,6);
vec_eta = a(:,8);

v_in = vec_v_in(1);
v_out = vec_v_out(1);

conversor_5v = ConversorDC(v_in, v_out);
conversor_5v = conversor_5v.ajuste(vec_i_out, vec_eta);

if ( plots )
  figure();
  hold on;
  plot(vec_i_in, vec_i_in, 'DisplayName', 'Experimental');
  plot(vec_i_in, conversor_5v.corriente_entrada(vec_i_out), 'DisplayName', 'Simulado');
  legend();
end

%% Conversor 15V
a = load("data/conversor_15V.dat", "-ascii");
vec_v_in = a(:,1);
vec_i_in = a(:,3);
vec_p_in = a(:,2);
vec_v_out = a(:,4);
vec_i_out = a(:,5);
vec_p_out = a(:,6);
vec_eta = a(:,7);

v_in = vec_v_in(1);
v_out = vec_v_out(1);

conversor_15v = ConversorDC(v_in, v_out);
conversor_15v = conversor_15v.ajuste(vec_i_out, vec_eta);

if ( plots )
  figure();
  hold on;
  plot(vec_i_in, vec_i_in, 'DisplayName', 'Experimental');
  plot(vec_i_in, conversor_15v.corriente_entrada(vec_i_out), 'DisplayName', 'Simulado');
  legend();
end

%% Conversor 3_3V
a = load("data/conversor_3.3V.dat", "-ascii");
vec_v_in = a(:,1);
vec_i_in = a(:,2);
vec_p_in = a(:,3);
vec_v_out = a(:,4);
vec_i_out = a(:,5);
vec_p_out = a(:,6);
vec_eta = a(:,8);

v_in = vec_v_in(1);
v_out = vec_v_out(1);

conversor_3_3v = ConversorDC(v_in, v_out);
conversor_3_3v = conversor_3_3v.ajuste(vec_i_out, vec_eta);

if ( plots )
  figure();
  hold on;
  plot(vec_i_in, vec_i_in, 'DisplayName', 'Experimental');
  plot(vec_i_in, conversor_3_3v.corriente_entrada(vec_i_out), 'DisplayName', 'Simulado');
  legend();
end
