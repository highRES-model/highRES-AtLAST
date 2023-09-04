$ONEPS
$ONEMPTY

Sets

lt / UP, LO, FX /


r regions /
$BATINCLUDE data_inputs/%vre_restrict%_regions.dd
/

z zones /
$BATINCLUDE data_inputs/zones.dd
/
;

*$INCLUDE %weather_yr%_temporal.dd
$INCLUDE data_inputs/%model_yr%_temporal.dd


alias(h,h_alias);

alias(z,z_alias) ;


* these sets have to be read in here, they can't be read in at the same time as
* parameter definitions

set g;
set non_vre(g);
set vre(g);
set trans;
set trans_links(z,z_alias,trans);

parameter gen_capex(g)                          annualised power capex (USDk per MW);
parameter gen_capex%model_yr%(g)                annualised (or non annualised) power capex (USDk per MW);
parameter gen_varom(g)                          variable O&M (USDk per MWh);
parameter gen_fom(g)                            fixed O&M (USDk per MW per yr);
parameter gen_fuelcost(g)                       fuel cost (kUSD per MWh);
parameter gen_mingen(g)                         Fractional minimum generation per technology;
parameter gen_emisfac(g)                        Emission factor per technology (ton CO2 per MWh);
parameter gen_maxramp(g)                        Max ramp for each generation technology (MW per min);
parameter gen_af(g)                             fractional availability factor;
parameter gen_peakaf(g)                         fractional peak availability factor?;
parameter gen_cap2area(g)                       Capacity to area factor (MW per km2);
parameter gen_lim_pcap_z(z,g,lt)                New power capacity limit by zone (MW);
parameter gen_lim_ecap_z(z,g,lt)                New energy capacity limit by zone (MWh);
parameter gen_exist_pcap_z(z,g,lt)              Existing power capacity limit by zone (MW);
parameter gen_exist_ecap_z(z,g,lt)              Existing energy capacity limit by zone (MWh);
parameter gen_fx_natcap(g);

parameter gen_unitsize(non_vre);
parameter gen_startupcost(non_vre);
parameter gen_minup(non_vre);
parameter gen_mindown(non_vre);
parameter gen_inertia(non_vre);

parameter trans_links_cap(z,z_alias,trans)      Transmission line capacity (MW);
parameter trans_links_dist(z,z_alias,trans)     Transmission line distance (km);
parameter trans_loss(trans)                     Transmission line losses (fraction per 100km);
parameter trans_varom(trans)                    Variable O&M (kUSD per MWh);
parameter trans_line_capex(trans)               Annualised (or non annualised) capex (kUSD per MW per 100km);
parameter trans_sub_capex(trans)                Annualised (or non annualised) capex (kUSD per MW per 100km);

parameter area(vre,z,r)                         available area for renewable technologies (km2);
parameter vre_gen(h,vre,r)                      capacity factor per renewable technology in a region of a zone;

parameter demand(z,h)                           Electricity demand by zone per hour (MWh);

*************** Extra parameters for annualizing ***************
parameter CRF_g(g) Capital recovery factor;
parameter CRF_trans(trans) Capital recovery factor for transmission line;
parameter PLT_g(g) Project lifetime (year);
parameter CRF_transformer Capital recovery factor for transformer;
parameter PLT_trans(trans) Project lifetime (year) for transmission line;
parameter PLT_transformer Project lifetime (year) for transformer;
****************************************************************

scalar co2_budget;


$INCLUDE data_inputs/%psys_scen%_gen.dd
$INCLUDE data_inputs/trans.dd
*$INCLUDE ../data_inputs/%esys_scen%_co2_budget.dd

* need to switch between agg and not for areas currently

*$INCLUDE vre_areas_%weather_yr%_%vre_restrict%.dd
$INCLUDE data_inputs/PV_areas_2022.dd
*$BATINCLUDE vre_%weather_yr%_agg_new_%area_scen%.dd
$INCLUDE data_inputs/%esys_scen%_demand_%dem_yr%.dd

*$gdxin vre_%weather_yr%_%vre_restrict%.gdx
*$load vre_gen
Parameter
vre_gen(h,vre,r) /
$INCLUDE data_inputs/cf_pv_%weather_yr%.dd
/;



gen_capex(g)=gen_capex%model_yr%(g);
gen_fuelcost(g)=gen_fuelcost%model_yr%(g);

*************** Annualizing capital cost ***********************

CRF_g(g) = IR/(1-(1+IR)**(-PLT_g(g)));
CRF_trans(trans) = IR/(1-(1+IR)**(-PLT_trans(trans)));
CRF_transformer = IR/(1-(1+IR)**(-PLT_transformer));

gen_capex(g) = gen_capex(g)*CRF_g(g);
trans_line_capex(trans) = trans_line_capex(trans)*CRF_trans(trans);
transformer_capex = transformer_capex*CRF_transformer;


* Special case for PV
set y_i /1*4/;
parameter y_repl(y_i) /
1 5,
2 10,
3 15,
4 20/;
gen_capex('PV') = 0.08*gen_capex%model_yr%('PV')*sum(y_i,IR/(1-(1+IR)**(-y_repl(y_i)))) +
                    gen_capex%model_yr%('PV')*IR/(1-(1+IR)**(-25));
    

****************************************************************


parameter exist_vre_cap_r(vre,z,r);

*$BATINCLUDE vre_per_zone_2016.dd
