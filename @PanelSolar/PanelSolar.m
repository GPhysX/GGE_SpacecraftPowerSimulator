function obj = PanelSolar ( ...
    n, m, ...
    v_oc_cell, i_sc_cell, v_mp_cell, i_mp_cell, ...
    dvoc_dt_cell, disc_dt_cell, dvmp_dt_cell, dimp_dt_cell, ...
    t_ref, e_ref ...
)
  obj.n = n;
  obj.m = m;
  obj.v_oc_cell = v_oc_cell;        % V
  obj.i_sc_cell =i_sc_cell;         % A
  obj.v_mp_cell = v_mp_cell;        % V
  obj.i_mp_cell = i_mp_cell;        % A
  obj.dvoc_dt_cell = dvoc_dt_cell;  % V/K
  obj.disc_dt_cell = disc_dt_cell;  % I/K
  obj.dvmp_dt_cell = dvmp_dt_cell;  % V/K
  obj.dimp_dt_cell = dimp_dt_cell;  % A/K
  obj.t_ref = t_ref;                % K
  obj.e_ref = e_ref;                % W m^-2
  obj = class (obj, "PanelSolar");
end
