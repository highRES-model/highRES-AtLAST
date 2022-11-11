******************************************
* highres CSP module
******************************************

$ONEPS
$ONEMPTY


* CSP setup

* read in storage sets/data
set CSP;

parameter vre_CSP_gen(h,CSP,r) Capacity factors - DNI and DHI depending on the technology;

parameter SF_cap2area(CSP) Capacity to area factor (MW per km2);
parameter SF_area(CSP,z,r) Available area r in zone z (km2);

parameter TES_eff_in(CSP) TES fractional charge efficiency;
parameter TES_eff_out(CSP) TES fractional discharge efficiency;
parameter TES_loss_per_hr(CSP) Thermal energy loss per hour in TES;
parameter TES_max(CSP) Fractional maximum thermal storage level for TES;
parameter TES_min(CSP) Fractional minimum thermal storage level for TES;
parameter TES_p_to_e(CSP) thermal power to energy ratio;

parameter PB_eff(CSP) PB fractional efficiency;
parameter PB_mingen(CSP) Fractional minimum energy generation for PB;
parameter PB_af(CSP) Availability factor for the PB;
parameter PB_ramp_up(CSP) Ramp-up limit for PB (MW);
parameter PB_ramp_down(CSP) Ramp-down limit for PB (MW);

parameter TES_t_capex%model_yr%(CSP) Thermal capital cost for the TES (kUSD per MW);
parameter TES_e_capex%model_yr%(CSP) Energy capital cost for the TES (kUSD per MWh);
parameter PB_capex%model_yr%(CSP) Capital cost for the PB (kUSD per MW);
parameter SF_capex%model_yr%(CSP) Capital cost for the SF (kUSD per MW);
parameter Dt Time step (hour);

parameter CSP_varom(CSP) Variable cost for CSP (kUSD per MWh);
parameter CSP_fom(CSP) Operation & maintenance cost for CSP (kUSD per MW per year);

parameter SF_exist_cap_r(CSP,z,r) Existing SF power capacity by region of a zone (MW);
parameter SF_exist_pcap_z(z,CSP,lt) Existing SF power capacity by zone (MW);
parameter SF_lim_pcap_z(z,CSP,lt) power SF capacity limit by zone (MW);
parameter TES_exist_pcap_z(z,CSP,lt) Existing TES power capacity by zone (MW);
parameter TES_lim_pcap_z(z,CSP,lt) TES power capacity limit by zone (MW);
parameter TES_exist_ecap_z(z,CSP,lt) TES energy capacity by zone (MWh);
parameter TES_lim_ecap_z(z,CSP,lt) TES energy capacity limit by zone (MWh);
parameter PB_exist_pcap_z(z,CSP,lt) Existing PB power capacity by region of a zone (MW);
parameter PB_lim_pcap_z(z,CSP,lt) PB power capacity limit by zone (MW);

*************** Extra parameters for annualized capex ***************
parameter CRF_SF(CSP) Capital recovery factor for solar field block;
parameter PLT_SF(CSP) Project lifetime (year) for solar field block;

parameter CRF_TES(CSP) Capital recovery factor for thermal storage;
parameter PLT_TES(CSP) Project lifetime (year) for thermal storage;

parameter CRF_PB(CSP) Capital recovery factor for power block;
parameter PLT_PB(CSP) Project lifetime (year) for power block;

* Extra testing
parameter CRF_CSP(CSP) Capital recovery factor for CSP;
parameter PLT_CSP(CSP) Project lifetime (year) for CSP;
****************************************************************

$INCLUDE data_inputs/%psys_scen%_csp.dd

vre_CSP_gen /
$INCLUDE data_inputs/cf_csp_2020.dd
/;

parameter SF_capex(CSP) annualised power capex for SF (USDk per MW);
parameter TES_t_capex(CSP) annualised power capex for TES (USDk per MW);
parameter TES_e_capex(CSP) annualised energy capex for TES (USDk per MWh);
parameter PB_capex(CSP) annualised power capex for PB (USDk per MW);

SF_capex(CSP) = SF_capex%model_yr%(CSP);
TES_t_capex(CSP) = TES_t_capex%model_yr%(CSP);
TES_e_capex(CSP) = TES_e_capex%model_yr%(CSP);
PB_capex(CSP) = PB_capex%model_yr%(CSP);


$INCLUDE data_inputs/CSP_areas_2022.dd

*************** Annualized capital cost ***********************

CRF_SF(CSP) = IR/(1-(1+IR)**(-PLT_SF(CSP)));
SF_capex(CSP) = SF_capex(CSP)*CRF_SF(CSP);

CRF_TES(CSP) = IR/(1-(1+IR)**(-PLT_TES(CSP)));
TES_t_capex(CSP) = TES_t_capex(CSP)*CRF_TES(CSP);
TES_e_capex(CSP) = TES_e_capex(CSP)*CRF_TES(CSP);

CRF_PB(CSP) = IR/(1-(1+IR)**(-PLT_PB(CSP)));
PB_capex(CSP) = PB_capex(CSP)*CRF_PB(CSP);

****************************************************************

set SF_lim(CSP,z);
set TES_lim(CSP,z);
set PB_lim(CSP,z);
*TODO: check if the condition is ok
SF_lim(CSP,z) = YES$(sum(r,SF_exist_cap_r(CSP,z,r) + SF_area(CSP,z,r))>0.);
TES_lim(CSP,z) = YES$(((sum(lt,TES_lim_pcap_z(z,CSP,lt))+sum(lt,TES_exist_pcap_z(z,CSP,lt)))>0.));
PB_lim(CSP,z) = YES$(((sum(lt,PB_lim_pcap_z(z,CSP,lt))+sum(lt,PB_exist_pcap_z(z,CSP,lt)))>0.));

set SF_lim_r(CSP,z,r);
SF_lim_r(CSP,z,r) = (SF_exist_cap_r(CSP,z,r) + SF_area(CSP,z,r));


* Existing SF capacity aggregated to zones
SF_exist_pcap_z(z,CSP,"FX") = sum(r,SF_exist_cap_r(CSP,z,r));

* To be conservative, existing capacity is removed from new capacity limit
SF_area(CSP,z,r) = SF_area(CSP,z,r) - SF_exist_cap_r(CSP,z,r);
SF_area(CSP,z,r)$(SF_area(CSP,z,r)<0.) = 0.  ;


Equations
eq_new_SF_pcap
eq_exist_SF_pcap
eq_tot_SF_pcap_z
eq_tot_SF_pcap
eq_SF_gen_r
eq_SF_area_max
eq_SF_gen_z
eq_new_SF_pcap_z
eq_exist_SF_pcap_z
eq_SF_pcap_z(h,z,CSP)

eq_new_TES_pcap
eq_exist_TES_pcap
eq_tot_TES_pcap_z
eq_tot_TES_pcap

eq_new_TES_ecap
eq_exist_TES_ecap
eq_tot_TES_ecap_z
eq_tot_TES_ecap

eq_TES_balance
eq_CSP_TES_max
eq_CSP_TES_min
eq_CSP_TES_ecap_max

eq_CSP_PB_z
eq_gen_CSP_z
eq_PB_ramp_up
eq_PB_ramp_down

eq_new_PB_pcap
eq_exist_PB_pcap
eq_tot_PB_pcap_z
eq_tot_PB_pcap

eq_CSP_gen_max
eq_CSP_gen_min
;

Positive Variable
var_new_TES_pcap(CSP)
var_exist_TES_pcap(CSP)
var_new_TES_pcap_z(z,CSP)
var_exist_TES_pcap_z(z,CSP)
var_tot_TES_pcap_z(z,CSP)
var_tot_TES_pcap(CSP)

var_new_TES_ecap(CSP)
var_exist_TES_ecap(CSP)
var_new_TES_ecap_z(z,CSP)
var_exist_TES_ecap_z(z,CSP)
var_tot_TES_ecap_z(z,CSP)
var_tot_TES_ecap(CSP)

var_new_SF_pcap_z
var_exist_SF_pcap_z
var_new_SF_pcap
var_exist_SF_pcap
var_tot_SF_pcap_z
var_tot_SF_pcap
var_SF_curtail
var_new_SF_pcap_r(z,CSP,r)
var_exist_SF_pcap_r(z,CSP,r)

var_SF_thermal_z
var_SF_thermal_r
var_store_TES
var_thermal_store_in
var_thermal_store_out

var_PB_thermal_z

var_new_PB_pcap_z
var_exist_PB_pcap_z
var_new_PB_pcap
var_exist_PB_pcap
var_tot_PB_pcap_z
var_tot_PB_pcap

var_CSP_gen
;



set hfirst(h),hlast(h);
hfirst(h) = yes$(ord(h) eq 1) ;
hlast(h) = yes$(card(h));

**** For solar generation ****

* existing SF capacity
var_exist_SF_pcap_z.UP(z,CSP)$(SF_exist_pcap_z(z,CSP,"UP")) = SF_exist_pcap_z(z,CSP,"UP");
var_exist_SF_pcap_z.LO(z,CSP)$(SF_exist_pcap_z(z,CSP,"LO")) = SF_exist_pcap_z(z,CSP,"LO");
var_exist_SF_pcap_z.FX(z,CSP)$(SF_exist_pcap_z(z,CSP,"FX")) = SF_exist_pcap_z(z,CSP,"FX");

var_exist_SF_pcap_z.FX(z,CSP)$(not var_exist_SF_pcap_z.l(z,CSP)) = 0.0;

* Limits on power capacity of a zone
var_tot_SF_pcap_z.UP(z,CSP)$(SF_lim_pcap_z(z,CSP,'UP')) = SF_lim_pcap_z(z,CSP,'UP');
var_tot_SF_pcap_z.LO(z,CSP)$(SF_lim_pcap_z(z,CSP,'LO')) = SF_lim_pcap_z(z,CSP,'LO');
var_tot_SF_pcap_z.FX(z,CSP)$(SF_lim_pcap_z(z,CSP,'FX')) = SF_lim_pcap_z(z,CSP,'FX');

* power capacity balance equations
eq_new_SF_pcap(CSP) .. sum(z,var_new_SF_pcap_z(z,CSP)) =E= var_new_SF_pcap(CSP);
eq_exist_SF_pcap(CSP) .. sum(z,var_exist_SF_pcap_z(z,CSP)) =E= var_exist_SF_pcap(CSP);
eq_tot_SF_pcap_z(z,CSP) .. var_new_SF_pcap_z(z,CSP) + var_exist_SF_pcap_z(z,CSP) =E= var_tot_SF_pcap_z(z,CSP);
eq_tot_SF_pcap(CSP) .. sum(z,var_tot_SF_pcap_z(z,CSP)) =E= var_tot_SF_pcap(CSP);

* Balance in Solar Field (SF) block - Thermal energy from irradiation data in regional level
eq_SF_gen_r(h,SF_lim_r(CSP,z,r)) .. var_SF_thermal_r(h,z,CSP,r) =E= vre_CSP_gen(h,CSP,r)*(var_new_SF_pcap_r(z,CSP,r)*derating_CSP + var_exist_SF_pcap_r(z,CSP,r)*derating_CSP) - var_SF_curtail(h,z,CSP,r);

* SF gen at regional level aggregated to zonal level
eq_SF_gen_z(h,z,CSP) .. var_SF_thermal_z(h,z,CSP) =E= sum(SF_lim_r(CSP,z,r),var_SF_thermal_r(h,z,CSP,r));

* SF capacity across all regions in a zone must be equal to capacity in that zone
eq_new_SF_pcap_z(z,CSP) .. sum(SF_lim_r(CSP,z,r),var_new_SF_pcap_r(z,CSP,r)) =E= var_new_SF_pcap_z(z,CSP);
eq_exist_SF_pcap_z(z,CSP) .. sum(SF_lim_r(CSP,z,r),var_exist_SF_pcap_r(z,CSP,r)) =E= var_exist_SF_pcap_z(z,CSP);

* Limits on Solar Field block in regional level
eq_SF_area_max(SF_lim_r(CSP,z,r)) .. var_new_SF_pcap_r(z,CSP,r) =L= SF_area(CSP,z,r)*SF_cap2area(CSP);

* Limit on Solar Field block in zonal level
eq_SF_pcap_z(h,z,CSP) .. var_SF_thermal_z(h,z,CSP) =L= var_tot_SF_pcap_z(z,CSP);

**** For storage ****

* existing TES power capacity
var_exist_TES_pcap_z.UP(z,CSP)$(TES_exist_pcap_z(z,CSP,"UP")) = TES_exist_pcap_z(z,CSP,"UP");
var_exist_TES_pcap_z.LO(z,CSP)$(TES_exist_pcap_z(z,CSP,"LO")) = TES_exist_pcap_z(z,CSP,"LO");
var_exist_TES_pcap_z.FX(z,CSP)$(TES_exist_pcap_z(z,CSP,"FX")) = TES_exist_pcap_z(z,CSP,"FX");

var_exist_TES_pcap_z.FX(z,CSP)$(not var_exist_TES_pcap_z.l(z,CSP)) = 0.0;

* existing TES energy capacity
var_exist_TES_ecap_z.UP(z,CSP)$(TES_exist_ecap_z(z,CSP,"UP")) = TES_exist_ecap_z(z,CSP,"UP");
var_exist_TES_ecap_z.LO(z,CSP)$(TES_exist_ecap_z(z,CSP,"LO")) = TES_exist_ecap_z(z,CSP,"LO");
var_exist_TES_ecap_z.FX(z,CSP)$(TES_exist_ecap_z(z,CSP,"FX")) = TES_exist_ecap_z(z,CSP,"FX");

var_exist_TES_ecap_z.FX(z,CSP)$(not var_exist_TES_ecap_z.l(z,CSP)) = 0.0;

* Limits on power capacity of a place
var_tot_TES_pcap_z.UP(z,CSP)$(TES_lim_pcap_z(z,CSP,'UP')) = TES_lim_pcap_z(z,CSP,'UP');
var_tot_TES_pcap_z.LO(z,CSP)$(TES_lim_pcap_z(z,CSP,'LO')) = TES_lim_pcap_z(z,CSP,'LO');
var_tot_TES_pcap_z.FX(z,CSP)$(TES_lim_pcap_z(z,CSP,'FX')) = TES_lim_pcap_z(z,CSP,'FX');

* Limits on energy capacity of a place
var_tot_TES_ecap_z.UP(z,CSP)$(TES_lim_ecap_z(z,CSP,'UP')) = TES_lim_ecap_z(z,CSP,'UP');
var_tot_TES_ecap_z.LO(z,CSP)$(TES_lim_ecap_z(z,CSP,'LO')) = TES_lim_ecap_z(z,CSP,'LO');
var_tot_TES_ecap_z.FX(z,CSP)$(TES_lim_ecap_z(z,CSP,'FX')) = TES_lim_ecap_z(z,CSP,'FX');

* power capacity balance equations
eq_new_TES_pcap(CSP) .. sum(TES_lim(CSP,z),var_new_TES_pcap_z(z,CSP)) =E= var_new_TES_pcap(CSP);
eq_exist_TES_pcap(CSP) .. sum(TES_lim(CSP,z),var_exist_TES_pcap_z(z,CSP)) =E= var_exist_TES_pcap(CSP);
eq_tot_TES_pcap_z(z,CSP) .. var_new_TES_pcap_z(z,CSP) + var_exist_TES_pcap_z(z,CSP) =E= var_tot_TES_pcap_z(z,CSP);
eq_tot_TES_pcap(CSP) .. sum(z,var_tot_TES_pcap_z(z,CSP)) =E= var_tot_TES_pcap(CSP);

* energy capacity balance equations
eq_new_TES_ecap(CSP) .. sum(TES_lim(CSP,z),var_new_TES_ecap_z(z,CSP)) =E= var_new_TES_ecap(CSP);
eq_exist_TES_ecap(CSP) .. sum(TES_lim(CSP,z),var_exist_TES_ecap_z(z,CSP)) =E= var_exist_TES_ecap(CSP);
eq_tot_TES_ecap_z(z,CSP) .. var_new_TES_ecap_z(z,CSP) + var_exist_TES_ecap_z(z,CSP) =E= var_tot_TES_ecap_z(z,CSP);
eq_tot_TES_ecap(CSP) .. sum(z,var_tot_TES_ecap_z(z,CSP)) =E= var_tot_TES_ecap(CSP);

* Balance in Thermal Storage block
*eq_TES_balance(h,TES_lim(CSP,z)) ..
*var_store_TES(h,z,CSP) =E= var_store_TES(h-1,z,CSP)*(1-TES_loss_per_hr(CSP)) + (var_thermal_store_in(h,z,CSP)*TES_eff_in(CSP)
*    - var_thermal_store_out(h,z,CSP)/TES_eff_out(CSP))*Dt;
* Connecting the last hour with the first hour
eq_TES_balance(h,TES_lim(CSP,z)) ..
var_store_TES(h,z,CSP) =E= var_store_TES(h--1,z,CSP)*(1-TES_loss_per_hr(CSP)) + (var_thermal_store_in(h,z,CSP)*TES_eff_in(CSP)
    - var_thermal_store_out(h,z,CSP)/TES_eff_out(CSP))*Dt;

* Limits on thermal storage
eq_CSP_TES_max(h,z,CSP)$(TES_lim(CSP,z)) .. var_store_TES(h,z,CSP) =L= var_tot_TES_ecap_z(z,CSP)*TES_max(CSP)*derating_CSP;
eq_CSP_TES_min(h,z,CSP)$(TES_lim(CSP,z)) .. var_store_TES(h,z,CSP) =G= var_tot_TES_ecap_z(z,CSP)*TES_min(CSP)*derating_CSP;

eq_CSP_TES_ecap_max(z,CSP)$(TES_lim(CSP,z)) .. var_new_TES_ecap_z(z,CSP) =E= var_new_TES_pcap_z(z,CSP)*TES_p_to_e(CSP);


**** For electricity generation ****

* existing PB capacity
var_exist_PB_pcap_z.UP(z,CSP)$(PB_exist_pcap_z(z,CSP,"UP")) = PB_exist_pcap_z(z,CSP,"UP");
var_exist_PB_pcap_z.LO(z,CSP)$(PB_exist_pcap_z(z,CSP,"LO")) = PB_exist_pcap_z(z,CSP,"LO");
var_exist_PB_pcap_z.FX(z,CSP)$(PB_exist_pcap_z(z,CSP,"FX")) = PB_exist_pcap_z(z,CSP,"FX");

var_exist_PB_pcap_z.FX(z,CSP)$(not var_exist_PB_pcap_z.l(z,CSP)) = 0.0;

* Limits on power capacity of a place
var_tot_PB_pcap_z.UP(z,CSP)$(PB_lim_pcap_z(z,CSP,'UP')) = PB_lim_pcap_z(z,CSP,'UP');
var_tot_PB_pcap_z.LO(z,CSP)$(PB_lim_pcap_z(z,CSP,'LO')) = PB_lim_pcap_z(z,CSP,'LO');
var_tot_PB_pcap_z.FX(z,CSP)$(PB_lim_pcap_z(z,CSP,'FX')) = PB_lim_pcap_z(z,CSP,'FX');

* power capacity balance equations
eq_new_PB_pcap(CSP) .. sum(PB_lim(CSP,z), var_new_PB_pcap_z(z,CSP)) =E= var_new_PB_pcap(CSP);
eq_exist_PB_pcap(CSP) .. sum(PB_lim(CSP,z),var_exist_PB_pcap_z(z,CSP)) =E= var_exist_PB_pcap(CSP);
eq_tot_PB_pcap_z(z,CSP) .. var_new_PB_pcap_z(z,CSP) + var_exist_PB_pcap_z(z,CSP) =E= var_tot_PB_pcap_z(z,CSP);
eq_tot_PB_pcap(CSP) .. sum(z,var_tot_PB_pcap_z(z,CSP)) =E= var_tot_PB_pcap(CSP);

* Balance in Power block
eq_CSP_PB_z(h,PB_lim(CSP,z)) .. var_SF_thermal_z(h,z,CSP) =E= var_PB_thermal_z(h,z,CSP) + var_thermal_store_in(h,z,CSP) - var_thermal_store_out(h,z,CSP);
eq_gen_CSP_z(h,PB_lim(CSP,z)) .. var_CSP_gen(h,z,CSP) =E= var_PB_thermal_z(h,z,CSP)*PB_eff(CSP)*Dt;

* Limits on electricity generation of PB
eq_CSP_gen_max(PB_lim(CSP,z),h) .. var_CSP_gen(h,z,CSP) =L= var_tot_PB_pcap_z(z,CSP)*PB_af(CSP)*derating_CSP;
eq_CSP_gen_min(PB_lim(CSP,z),h) .. var_CSP_gen(h,z,CSP) =G= var_tot_PB_pcap_z(z,CSP)*PB_mingen(CSP)*derating_CSP;

* ramp equation for power block generation
eq_PB_ramp_up(h,z,CSP) .. var_CSP_gen(h,z,CSP) - var_CSP_gen(h-1,z,CSP) =L= PB_ramp_up(CSP);
eq_PB_ramp_down(h,z,CSP) .. var_CSP_gen(h,z,CSP) - var_CSP_gen(h-1,z,CSP) =L= PB_ramp_down(CSP);
