classdef ModuloBaterias < BateriaDinamica
  %MODULOBATERIAS Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    s
    p
  end
  
  methods(Static = true, Access = private)
    function bat_din = to_bateriadinamica(obj)
      bat_din = BateriaDinamica(obj);
      bat_din.r_sc = obj.r_sc;
      bat_din.r_int = obj.r_int;
      bat_din.r_1 = obj.r_1;
      bat_din.r_2 = obj.r_2;
      bat_din.c_1 = obj.c_1;
      bat_din.c_2 = obj.c_2;
      bat_din.i_r1 = obj.i_r1;
      bat_din.i_r2 = obj.i_r2;
    end
  end
  
  methods
    function obj = ModuloBaterias(s,p,bateria_din)
      obj@BateriaDinamica(bateria_din);
      obj.s = s;
      obj.p = p;
      obj.r_sc = bateria_din.r_sc;
      obj.r_int = bateria_din.r_int;
      obj.r_1 = bateria_din.r_1;
      obj.r_2 = bateria_din.r_2;
      obj.c_1 = bateria_din.c_1;
      obj.c_2 = bateria_din.c_2;
      obj.i_r1 = 0e0;
      obj.i_r2 = 0e0;
%       obj.r_c = bateria_din.r_c;
%       obj.r_d = bateria_din.r_d;
%       obj.phi_max = bateria_din.phi_max;
%       obj.coeficientes_descarga_tipo1 = bateria_din.coeficientes_descarga_tipo1;
%       obj.coeficientes_descarga_tipo2 = bateria_din.coeficientes_descarga_tipo2;
%       obj.coeficientes_descarga_tipo3 = bateria_din.coeficientes_descarga_tipo3;
%       obj.coeficientes_carga_tipo1 = bateria_din.coeficientes_carga_tipo1;
%       obj.coeficientes_carga_tipo2 = bateria_din.coeficientes_carga_tipo2;
%       obj.coeficientes_carga_tipo3 = bateria_din.coeficientes_carga_tipo3;
    end
    
    function v_int = voltage_internal(obj, phi, i, t)
      bat_din = ModuloBaterias.to_bateriadinamica(obj);
      v_int = obj.s * voltage_internal(bat_din, phi, i / obj.p, t);
    end
    
    function v_din = voltage_dynamic(obj, phi, i, t)
      bat_din = BateriaDinamica(obj);
      bat_din.r_sc = obj.r_sc;
      bat_din.r_int = obj.r_int;
      bat_din.r_1 = obj.r_1;
      bat_din.r_2 = obj.r_2;
      bat_din.c_1 = obj.c_1;
      bat_din.c_2 = obj.c_2;
      bat_din.i_r1 = obj.i_r1;
      bat_din.i_r2 = obj.i_r2;
      v_din = obj.s * voltage_dynamic(bat_din, phi, i / obj.p, t);
    end
  end
end

