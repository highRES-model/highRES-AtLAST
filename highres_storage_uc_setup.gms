*******************
* UC code for storage - pretty much mirrors the generator UC code and only provides linear units
*******************

store_unitsize(s)=store_unitsize(s)/MWtoGW;
store_maxramp(s)=store_maxramp(s)/MWtoGW;
store_startupcost(s)=store_startupcost(s)/MWtoGW;


set map_minup_store(h,s,h)
    map_mindown_store(h,s,h);

set store_quick(s);

store_quick("H2-Salt-CCGT")=no;
store_quick("H2-Salt-OCGT")=yes;

parameter store_max_res_uc(s,service_type);


*store_maxramp("H2-Salt-CCGT")=78/MWtoGW;

* compute maximum power ramp in MW for each tech for in each reserve window

store_max_res_uc(s,"reserve")$(store_uc_lin(s))=store_maxramp(s)*res_time;
store_max_res_uc(s,"f_response")$(store_uc_lin(s))=store_maxramp(s)*f_res_time;


map_minup_store(h,s,h_alias+(ord(h)-store_minup(s)))$[hh_minup(h_alias) and ord (h_alias)<store_minup(s)] = yes;
map_mindown_store(h,s,h_alias+(ord(h)-store_mindown(s)))$[hh_mindown(h_alias) and ord (h_alias)<store_mindown(s)] = yes;


Positive variables
var_store_tot_n_units_lin(z,s)           total number of units (linear)
var_store_new_n_units_lin(z,s)           number of new units (linear)
var_store_exist_n_units_lin(z,s)         number of existing units (linear)
var_store_up_units_lin(h,z,s)            units starting up by tech zone and hour (linear)
var_store_down_units_lin(h,z,s)          units shutdown by tech zone and hour (linear)
var_store_com_units_lin(h,z,s)           units committed by tech zone and hour (linear)
;

Equations
eq_uc_store_tot_units_lin
eq_uc_store_units_lin
eq_uc_store_unit_state_lin
eq_uc_store_cap_lin
eq_uc_store_exist_cap_lin
eq_uc_store_gen_max_lin
eq_uc_store_gen_min_lin
eq_uc_store_gen_minup_lin
eq_uc_store_gen_mindown_lin

eq_uc_store_max_reserve_lin
eq_uc_store_max_response_lin
;


eq_uc_store_tot_units_lin(z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) .. var_store_tot_n_units_lin(z,s) =E= var_store_exist_n_units_lin(z,s)+var_store_new_n_units_lin(z,s);

eq_uc_store_cap_lin(z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) .. var_new_store_pcap_z(z,s) =E= var_store_new_n_units_lin(z,s)*store_unitsize(s);

eq_uc_store_exist_cap_lin(z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) .. var_exist_store_pcap_z(z,s) =E= var_store_exist_n_units_lin(z,s)*store_unitsize(s);




eq_uc_store_units_lin(h,z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) .. var_store_com_units_lin(h,z,s) =L= var_store_tot_n_units_lin(z,s);

eq_uc_store_unit_state_lin(h,z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) ..  var_store_com_units_lin(h,z,s) =E= var_store_com_units_lin(h-1,z,s)+var_store_up_units_lin(h,z,s)-var_store_down_units_lin(h,z,s);

eq_uc_store_gen_max_lin(h,z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) .. var_store_com_units_lin(h,z,s)*store_unitsize(s)*store_af(s) =G=

var_store_gen(h,z,s)+ var_store_res(h,z,s) + var_store_f_res(h,z,s)
;

eq_uc_store_gen_min_lin(h,z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s)) .. var_store_gen(h,z,s) =G= var_store_com_units_lin(h,z,s)*store_mingen(s)*store_unitsize(s);





eq_uc_store_gen_minup_lin(h,z,s)$(s_lim(z,s) and store_uc_lin(s) and (store_minup(s) > 1) and (ord(h) > 1) and uc_z(z)) .. sum(map_minup_store(h,s,h_alias),var_store_up_units_lin(h_alias,z,s)) =L= var_store_com_units_lin(h,z,s);

eq_uc_store_gen_mindown_lin(h,z,s)$(s_lim(z,s) and store_uc_lin(s) and (store_mindown(s) > 1) and (ord(h) > 1) and uc_z(z)) .. sum(map_mindown_store(h,s,h_alias),var_store_down_units_lin(h_alias,z,s)) =L= var_store_tot_n_units_lin(z,s)-var_store_com_units_lin(h,z,s);


eq_uc_store_max_reserve_lin(h,z,s)$(s_lim(z,s) and store_uc_lin(s) and uc_z(z)) .. var_store_res(h,z,s) =L= var_store_com_units_lin(h,z,s)*store_unitsize(s)*store_af(s)*store_max_res_uc(s,"reserve");

eq_uc_store_max_response_lin(h,z,s)$(s_lim(z,s) and store_uc_lin(s) and uc_z(z)) .. var_store_f_res(h,z,s) =L= var_store_com_units_lin(h,z,s)*store_max_res_uc(s,"f_response")*store_af(s);



equation eq_uc_store_reserve_quickstart;
variables var_store_res_quick(h,z,s);

eq_uc_store_reserve_quickstart(h,z,s)$(s_lim(z,s) and uc_z(z) and store_uc_lin(s) and store_quick(s)) .. (var_store_tot_n_units_lin(z,s)-var_store_com_units_lin(h,z,s))*store_unitsize(s)*store_af(s) =G= var_store_res_quick(h,z,s);
