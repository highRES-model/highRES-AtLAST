******************************************
* highres hydrogen module
******************************************


$ONEPS
$ONEMPTY

* hydrogen setup

* read in storage sets/data
set El      Electrolizers;
set H2T     Storage tanks; 
set FC      Fuel Cells; 

parameter eff_electrolyzer(El)                   Fractional electrolyzer efficiency;
parameter HHV_h2                                 Higher heat value of hydrogen (MWh per kg);
parameter eff_tank(H2T)                          Fractional efficiency of hydrogen tank;
parameter h2_store_min(H2T)                      Fractional minimum level of hydrogen tank;
parameter h2_store_max(H2T)                      Fractional maximum level of hydrogen tank;
parameter eff_fuel_cell(FC)                      Fractional fuel cell efficiency;
parameter LHV_h2                                 Lower heat value of hydrogen (MWh per kg);
parameter max_nom_pcap_electrolyzer(El)          Maximum Electrolyzer nominal power (MW);
parameter max_nom_pcap_fuel_cell(FC)             Maximum Fuel cell nominal capacity (MW);
parameter electrolyzer_capex%model_yr%(El)       Capital cost of the electrolyzer (kUSD per MW);
parameter electrolyzer_fom(El)                   Fixed O&M costs of the electrolyzer (kUSD per MW) 2%;
parameter electrolyzer_varom(El)                 Variable O&M costs of the electrolyzer (kUSD per MW per year)
parameter h2_storage_capex%model_yr%(H2T)        Capital cost of the hydrogen tank (kUSD per kg);
parameter h2_storage_fom(H2T)                    Fixed O&M costs of the hydrogen tank (USD per kg) 2%;
parameter fuel_cell_capex%model_yr%(FC)          Capital cost of the fuel cell (kUSD per MW);
parameter fuel_cell_fom(FC)                      Fixed O&M costs of the fuel cell (kUSD per MW) 1.8%;
parameter fuel_cell_varom(FC)                    Variable O&M costs of the fuel cell (kUSD per MW per year)
parameter electrolyzer_exist_pcap_z(z,El,lt)     existing electrolyzer capacity for each zone (MW);
parameter electrolyzer_lim_pcap_z(z,El,lt)       Maximum electrolyzer capacity for each zone (MW);
parameter h2_storage_exist_pcap_z(z,H2T,lt)      Existing H2 storage capacity for each zone (MW);
parameter h2_storage_lim_pcap_z(z,H2T,lt)        Maximum H2 storage capacity for each zone (kg);
parameter fuel_cell_exist_pcap_z(z,FC,lt)        Existing fuel cell capacity for each zone (MW);
parameter fuel_cell_lim_pcap_z(z,FC,lt)          Maximum fuel cell capacity for each zone (MW);
parameter import_hour_z(h,z)                     Hours in which "Import" can be used for each zone (hours);

*************** Extra parameters for annualizing ***************
parameter CRF_elect(El) Capital recovery factor for electrolyzer;
parameter PLT_elect(El) Project lifetime (year) for electrolyzer;

parameter CRF_h2stor(H2T) Capital recovery factor for h2 storage tank;
parameter PLT_h2stor(H2T) Project lifetime (year) for h2 storage tank;

parameter CRF_fuelcell(FC) Capital recovery factor for fuel cell;
parameter PLT_fuelcell(FC) Project lifetime (year) for fuel cell;
****************************************************************

$INCLUDE data_inputs/%psys_scen%_h2.dd

parameter electrolyzer_capex(El) annualised power capex for the electrolyzer (kUSD per MW);
parameter h2_storage_capex(H2T) annualised power capex for the H2 storage (kUSD per kg);
parameter fuel_cell_capex(FC) annualised power capex for the fuel cell (kUSD per MW);

electrolyzer_capex(El) = electrolyzer_capex%model_yr%(El);
h2_storage_capex(H2T) = h2_storage_capex%model_yr%(H2T);
fuel_cell_capex(FC) = fuel_cell_capex%model_yr%(FC);

*************** Annualizing capital cost ***********************

CRF_elect(El) = IR/(1-(1+IR)**(-PLT_elect(El)));
electrolyzer_capex(El) = electrolyzer_capex(El)*CRF_elect(El);

CRF_h2stor(H2T) = IR/(1-(1+IR)**(-PLT_h2stor(H2T)));
h2_storage_capex(H2T) = h2_storage_capex(H2T)*CRF_h2stor(H2T);

CRF_fuelcell(FC) = IR/(1-(1+IR)**(-PLT_fuelcell(FC)));
fuel_cell_capex(FC) = fuel_cell_capex(FC)*CRF_fuelcell(FC);

****************************************************************

set electrolyzer_lim(El,z);
set h2_storage_lim(H2T,z);
set fuel_cell_lim(FC,z);
electrolyzer_lim(El,z) = YES$(((sum(lt,electrolyzer_lim_pcap_z(z,El,lt))+sum(lt,electrolyzer_exist_pcap_z(z,El,lt)))>0.));
h2_storage_lim(H2T,z) = YES$(((sum(lt,h2_storage_lim_pcap_z(z,H2T,lt))+sum(lt,h2_storage_exist_pcap_z(z,H2T,lt)))>0.));
fuel_cell_lim(FC,z) = YES$(((sum(lt,fuel_cell_lim_pcap_z(z,FC,lt))+sum(lt,fuel_cell_exist_pcap_z(z,FC,lt)))>0.));

Positive variables
var_P_el(h,z,El) Electrolyzer electrical consumption (MW)
var_mass_h2(h,z,El,H2T) Mass flow of hydrogen (kg per hr)
var_h2_level(h,z,H2T) Hydrogen tank level (kg)
var_fuel_cell_h2(h,z,H2T,FC) Fuel cell hydrogen consumption (kg per hr)
var_P_fuel_cell(h,z,FC) Output power of the fuel cell (MW)

var_new_electrolyzer_pcap_z(z,El) New electrolyzer capacity in a zone (MW)
var_new_electrolyzer_pcap(El) New electrolyzer capacity (MW)
var_exist_electrolyzer_pcap_z(z,El) Existing electrolyzer capacity in a zone (MW)
var_exist_electrolyzer_pcap(El) Existing electrolyzer capacity (MW)
var_tot_electrolyzer_pcap_z(z,El) Total electrolyzer capacity in a zone (MW)
var_tot_electrolyzer_pcap(El) Total electrolyzer capacity (MW)

var_new_h2_storage_pcap_z(z,H2T) New H2 storage capacity in a zone (kg)
var_new_h2_storage_pcap(H2T) Total new H2 storage capacity (kg)
var_exist_h2_storage_pcap_z(z,H2T) Existing H2 storage capacity in a zone (kg)
var_exist_h2_storage_pcap(H2T) Total existing H2 storage capacity (kg)
var_tot_h2_storage_pcap_z(z,H2T) H2 storage capacity in a zone (kg)
var_tot_h2_storage_pcap(H2T) Total H2 storage capacity (kg)

var_new_fuel_cell_pcap_z(z,FC) New fuel cell capacity in a zone (MW)
var_new_fuel_cell_pcap(FC) Total new fuel cell capacity (MW)
var_exist_fuel_cell_pcap_z(z,FC) Existing fuel cell capacity in a zone (MW)
var_exist_fuel_cell_pcap(FC) Total existing fuel cell capacity (MW)
var_tot_fuel_cell_pcap_z(z,FC) Fuel cell capacity in a zone (MW)
var_tot_fuel_cell_pcap(FC) Total fuel cell capacity (MW)
;

Equations
eq_electrilyzer
eq_electrolyzer_pcap
eq_electrolyzer_max_pcap
eq_electrolyzer_import_lim

eq_h2_storage
eq_h2_storage_mincap
eq_h2_storage_maxcap

eq_fuel_cell
eq_fuel_cell_pcap
eq_fuel_cell_max_pcap

eq_new_electrolyzer_pcap
eq_exist_electrolyzer_pcap
eq_tot_electrolyzer_pcap_z
eq_tot_electrolyzer_pcap

eq_new_h2_storage_pcap
eq_exist_h2_storage_pcap
eq_tot_h2_storage_pcap_z
eq_tot_h2_storage_pcap

eq_new_fuel_cell_pcap
eq_exist_fuel_cell_pcap
eq_tot_fuel_cell_pcap_z
eq_tot_fuel_cell_pcap

;


**** Electrilyzer genetarion ****

* existing Electrolyzer power capacity
var_exist_electrolyzer_pcap_z.UP(z,El)$(electrolyzer_exist_pcap_z(z,El,"UP")) = electrolyzer_exist_pcap_z(z,El,"UP");
var_exist_electrolyzer_pcap_z.L(z,El)$(electrolyzer_exist_pcap_z(z,El,"UP")) = electrolyzer_exist_pcap_z(z,El,"UP");
var_exist_electrolyzer_pcap_z.FX(z,El)$(electrolyzer_exist_pcap_z(z,El,"FX")) = electrolyzer_exist_pcap_z(z,El,"FX");

var_exist_electrolyzer_pcap_z.FX(z,El)$(not var_exist_electrolyzer_pcap_z.l(z,El)) = 0.0;

* Limits on power capacity of a place
var_tot_electrolyzer_pcap_z.UP(z,El)$(electrolyzer_lim_pcap_z(z,El,'UP'))=electrolyzer_lim_pcap_z(z,El,'UP');
var_tot_electrolyzer_pcap_z.LO(z,El)$(electrolyzer_lim_pcap_z(z,El,'LO'))=electrolyzer_lim_pcap_z(z,El,'LO');
var_tot_electrolyzer_pcap_z.FX(z,El)$(electrolyzer_lim_pcap_z(z,El,'FX'))=electrolyzer_lim_pcap_z(z,El,'FX');

* Power capacity balance equations
eq_new_electrolyzer_pcap(El) .. sum(z,var_new_electrolyzer_pcap_z(z,El)) =E= var_new_electrolyzer_pcap(El);
eq_exist_electrolyzer_pcap(El) .. sum(z,var_exist_electrolyzer_pcap_z(z,El)) =E= var_exist_electrolyzer_pcap(El);
eq_tot_electrolyzer_pcap_z(z,El) .. var_new_electrolyzer_pcap_z(z,El) + var_exist_electrolyzer_pcap_z(z,el) =E= var_tot_electrolyzer_pcap_z(z,El);
eq_tot_electrolyzer_pcap(El) .. sum(z,var_tot_electrolyzer_pcap_z(z,El)) =E= var_tot_electrolyzer_pcap(El);

* Power balance equation
eq_electrilyzer(h,electrolyzer_lim(El,z)) .. eff_electrolyzer(El)*var_P_el(h,z,El) =E= sum(h2_storage_lim(H2T,z),var_mass_h2(h,z,El,H2T))*HHV_h2;

* Capacity limit
eq_electrolyzer_pcap(h,electrolyzer_lim(El,z)) .. var_P_el(h,z,El) =L= var_tot_electrolyzer_pcap_z(z,El)*derating_h2;
eq_electrolyzer_max_pcap(h,electrolyzer_lim(El,z)) .. var_new_electrolyzer_pcap_z(z,El) =L= max_nom_pcap_electrolyzer(El);

* Constraining the use of H2 imports
eq_electrolyzer_import_lim(h,electrolyzer_lim("Import",z)) .. var_P_el(h,z,"Import") =L= import_hour_z(h,z);

**** Hydrogen storage ****

* existing H2 storage capacity
var_exist_h2_storage_pcap_z.UP(z,H2T)$(h2_storage_exist_pcap_z(z,H2T,"UP")) = h2_storage_exist_pcap_z(z,H2T,"UP");
var_exist_h2_storage_pcap_z.L(z,H2T)$(h2_storage_exist_pcap_z(z,H2T,"UP")) = h2_storage_exist_pcap_z(z,H2T,"UP");
var_exist_h2_storage_pcap_z.FX(z,H2T)$(h2_storage_exist_pcap_z(z,H2T,"FX")) = h2_storage_exist_pcap_z(z,H2T,"FX");

var_exist_h2_storage_pcap_z.FX(z,H2T)$(not var_exist_h2_storage_pcap_z.l(z,H2T)) = 0.0;

* Limits on power capacity of a zone
var_tot_h2_storage_pcap_z.UP(z,H2T)$(h2_storage_lim_pcap_z(z,H2T,'UP'))=h2_storage_lim_pcap_z(z,H2T,'UP');
var_tot_h2_storage_pcap_z.LO(z,H2T)$(h2_storage_lim_pcap_z(z,H2T,'LO'))=h2_storage_lim_pcap_z(z,H2T,'LO');
var_tot_h2_storage_pcap_z.FX(z,H2T)$(h2_storage_lim_pcap_z(z,H2T,'FX'))=h2_storage_lim_pcap_z(z,H2T,'FX');

* Power capacity balance equations
eq_new_h2_storage_pcap(H2T) .. sum(z,var_new_h2_storage_pcap_z(z,H2T)) =E= var_new_h2_storage_pcap(H2T);
eq_exist_h2_storage_pcap(H2T) .. sum(z,var_exist_h2_storage_pcap_z(z,H2T)) =E= var_exist_h2_storage_pcap(H2T);
eq_tot_h2_storage_pcap_z(z,H2T) .. var_new_h2_storage_pcap_z(z,H2T) + var_exist_h2_storage_pcap_z(z,H2T) =E= var_tot_h2_storage_pcap_z(z,H2T);
eq_tot_h2_storage_pcap(H2T) .. sum(z,var_tot_h2_storage_pcap_z(z,H2T)) =E= var_tot_h2_storage_pcap(H2T);

* Energy balance equations
set hfirst(h),hlast(h);
hfirst(h) = yes$(ord(h) eq 1) ;
hlast(h) = yes$(ord(h) eq card(h));
*eq_h2_storage(h,h2_lim(h2,z)) .. var_h2_level(h,z,h2) =E= var_h2_level(h-1,z,h2) + var_mass_h2(h,z,h2) - var_fuel_cell_h2(h,z,h2)/eff_tank(h2);
* Connecting the last hour with the first hour
eq_h2_storage(h,h2_storage_lim(H2T,z)) .. var_h2_level(h,z,H2T) =E= var_h2_level(h--1,z,H2T) + (sum(electrolyzer_lim(El,z),var_mass_h2(h,z,El,H2T)) - sum(fuel_cell_lim(FC,z),var_fuel_cell_h2(h,z,H2T,FC))/eff_tank(H2T))*1;
* the number 1 at the end indicates the time step (1 hour) to obtain consistant units (kg)

* Storage level limits
eq_h2_storage_mincap(h,h2_storage_lim(H2T,z)) .. var_tot_h2_storage_pcap_z(z,H2T)*h2_store_min(H2T) =L= var_h2_level(h,z,H2T);
eq_h2_storage_maxcap(h,h2_storage_lim(H2T,z)) .. var_tot_h2_storage_pcap_z(z,H2T)*h2_store_max(H2T)*derating_h2 =G= var_h2_level(h,z,H2T);


**** Fuel cell generation ****

* existing Fuel cell capacity
var_exist_fuel_cell_pcap_z.UP(z,FC)$(fuel_cell_exist_pcap_z(z,FC,"UP")) = fuel_cell_exist_pcap_z(z,FC,"UP");
var_exist_fuel_cell_pcap_z.L(z,FC)$(fuel_cell_exist_pcap_z(z,FC,"UP")) = fuel_cell_exist_pcap_z(z,FC,"UP");
var_exist_fuel_cell_pcap_z.FX(z,FC)$(fuel_cell_exist_pcap_z(z,FC,"FX")) = fuel_cell_exist_pcap_z(z,FC,"FX");

var_exist_fuel_cell_pcap_z.FX(z,FC)$(not var_exist_fuel_cell_pcap_z.l(z,FC)) = 0.0;

* Limits o power capacity of a place
var_tot_fuel_cell_pcap_z.UP(z,FC)$(fuel_cell_lim_pcap_z(z,FC,'UP'))=fuel_cell_lim_pcap_z(z,FC,'UP');
var_tot_fuel_cell_pcap_z.LO(z,FC)$(fuel_cell_lim_pcap_z(z,FC,'LO'))=fuel_cell_lim_pcap_z(z,FC,'LO');
var_tot_fuel_cell_pcap_z.FX(z,FC)$(fuel_cell_lim_pcap_z(z,FC,'FX'))=fuel_cell_lim_pcap_z(z,FC,'FX');

* Power capacity balance equations
eq_new_fuel_cell_pcap(FC) .. sum(z, var_new_fuel_cell_pcap_z(z,FC)) =E= var_new_fuel_cell_pcap(FC);
eq_exist_fuel_cell_pcap(FC) .. sum(z,var_exist_fuel_cell_pcap_z(z,FC)) =E= var_exist_fuel_cell_pcap(FC);
eq_tot_fuel_cell_pcap_z(z,FC) .. var_new_fuel_cell_pcap_z(z,FC) + var_exist_fuel_cell_pcap_z(z,FC) =E= var_tot_fuel_cell_pcap_z(z,FC);
eq_tot_fuel_cell_pcap(FC) .. sum(z,var_tot_fuel_cell_pcap_z(z,FC)) =E= var_tot_fuel_cell_pcap(FC);

* Power balance equation
eq_fuel_cell(h,fuel_cell_lim(FC,z)) .. eff_fuel_cell(FC)*sum(h2_storage_lim(H2T,z),var_fuel_cell_h2(h,z,H2T,FC))*LHV_h2 =E= var_P_fuel_cell(h,z,FC);

* Capacity limits
eq_fuel_cell_pcap(h,fuel_cell_lim(FC,z)) .. var_P_fuel_cell(h,z,FC) =L= var_tot_fuel_cell_pcap_z(z,FC)*derating_h2;
eq_fuel_cell_max_pcap(h,fuel_cell_lim(FC,z)) .. var_new_fuel_cell_pcap_z(z,FC) =L= max_nom_pcap_fuel_cell(FC);
