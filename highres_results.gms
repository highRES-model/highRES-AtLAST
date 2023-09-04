


$ontext
*********** UK results ***********

parameter o_trans_net_flow(h,z,z_alias);

o_trans_net_flow(h,z,z_alias)=sum((trans_links(z,z_alias,trans))$(uk_z(z) and not_uk_z_alias(z_alias)),var_trans_flow.l(h,z,z_alias,trans)*(1-(trans_links_dist_bidir(z,z_alias,trans)*trans_loss(trans))))

-sum(trans_links(z,z_alias,trans)$(uk_z(z) and not_uk_z_alias(z_alias)),var_trans_flow.l(h,z_alias,z,trans));

parameter o_eprice_delta_uk_z(h,z,z_alias);
parameter o_eprice_delta_z_uk(h,z_alias,z);

o_eprice_delta_uk_z(h,z,z_alias)$(uk_z(z) and not_uk_z_alias(z_alias) and sum(trans,trans_links(z,z_alias,trans)))=eq_elc_balance.m(h,z)-eq_elc_balance.m(h,z_alias);
o_eprice_delta_z_uk(h,z_alias,z)=-o_eprice_delta_uk_z(h,z,z_alias);

parameter o_trans_crent_uk_z(h,z,z_alias);
parameter o_trans_crent_z_uk(h,z_alias,z);

o_trans_crent_uk_z(h,z,z_alias)$(uk_z(z) and not_uk_z_alias(z_alias) and o_trans_net_flow(h,z,z_alias) < 0)=o_trans_net_flow(h,z,z_alias)*o_eprice_delta_z_uk(h,z_alias,z);
o_trans_crent_z_uk(h,z_alias,z)$(uk_z(z) and not_uk_z_alias(z_alias) and o_trans_net_flow(h,z,z_alias) > 0)=o_trans_net_flow(h,z,z_alias)*o_eprice_delta_z_uk(h,z_alias,z);

parameter o_uk_z_trade_capex;

o_uk_z_trade_capex(z,z_alias)=(sum(trans_links(z,z_alias,trans)$(uk_z(z) and not_uk_z_alias(z_alias)),var_trans_pcap.l(z,z_alias,trans)*trans_links_dist(z,z_alias,trans)*trans_line_capex(trans))
+sum(trans_links(z,z_alias,trans)$(uk_z(z) and not_uk_z_alias(z_alias)),var_trans_pcap.l(z,z_alias,trans)*trans_sub_capex(trans)*2));

parameter o_uk_share_trade_capex;

o_uk_share_trade_capex(z,z_alias)=o_uk_z_trade_capex(z,z_alias)*(sum(h,o_trans_crent_uk_z(h,z,z_alias))/(sum(h,o_trans_crent_uk_z(h,z,z_alias))+sum(h,o_trans_crent_z_uk(h,z_alias,z))));



scalar o_uk_sys_cost;

scalar o_uk_gen_var_cost;
$IF "%UC%" == ON scalar o_uk_gen_start_cost;
scalar o_uk_gen_capex_cost;
scalar o_uk_gen_fom_cost;
scalar o_uk_store_var_cost;
$IF "%store_uc%" == ON scalar o_uk_store_start_cost;
scalar o_uk_store_capex_cost;
scalar o_uk_store_fom_cost;
scalar o_uk_trade_cost;
scalar o_uk_trade_crent_cost;
scalar o_uk_trade_capex_cost;
scalar o_uk_trade_capex_cost1;
scalar o_uk_trade_fom_cost;
scalar o_uk_trans_capex_cost;
scalar o_uk_trans_fom_cost;

o_uk_gen_var_cost=sum(z$uk_z(z),costs_gen_varom.l(z));
$IF "%UC%" == ON o_uk_gen_start_cost=sum(z$uk_z(z),costs_gen_start.l(z));
o_uk_gen_capex_cost=sum(z$uk_z(z),costs_gen_capex.l(z));
o_uk_gen_fom_cost=sum(z$uk_z(z),costs_gen_fom.l(z));


$ifThen "%storage%" == ON

o_uk_store_var_cost=sum(z$uk_z(z),costs_store_varom.l(z));
o_uk_store_capex_cost=sum(z$uk_z(z),costs_store_capex.l(z));
o_uk_store_fom_cost=sum(z$uk_z(z),costs_store_fom.l(z));
$IF "%store_uc%" == ON o_uk_store_start_cost=sum(z$uk_z(z),costs_store_start.l(z));

$endIf

o_uk_trade_cost=sum((h,z)$(uk_z(z)),sum(z_alias,o_trans_net_flow(h,z,z_alias))*eq_elc_balance.m(h,z));

o_uk_trade_crent_cost=sum((h,z,z_alias),o_trans_crent_uk_z(h,z,z_alias));




o_uk_trade_capex_cost1=(sum(trans_links(z,z_alias,trans)$(uk_z(z) and not_uk_z_alias(z_alias)),var_trans_pcap.l(z,z_alias,trans)*trans_links_dist(z,z_alias,trans)*trans_line_capex(trans))

+sum(trans_links(z,z_alias,trans)$(uk_z(z) and not_uk_z_alias(z_alias)),var_trans_pcap.l(z,z_alias,trans)*trans_sub_capex(trans)*2))*

* costs weighted based on congestion rents

(sum((h,z,z_alias),o_trans_crent_uk_z(h,z,z_alias))/(sum((h,z,z_alias),o_trans_crent_uk_z(h,z,z_alias))+sum((h,z,z_alias),o_trans_crent_z_uk(h,z_alias,z))));

o_uk_trade_capex_cost=sum((z,z_alias),o_uk_share_trade_capex(z,z_alias));

o_uk_trade_fom_cost=o_uk_trade_capex_cost*0.02;

o_uk_trans_capex_cost=sum(uk_z(z),costs_trans_capex.l(z))-sum((z,z_alias),o_uk_z_trade_capex(z,z_alias));

o_uk_trans_fom_cost=o_uk_trans_capex_cost*0.02;


o_uk_sys_cost=
o_uk_gen_var_cost
$IF "%UC%" == ON +o_uk_gen_start_cost
+o_uk_gen_capex_cost
+o_uk_gen_fom_cost
+o_uk_store_var_cost
$IF "%store_uc%" == ON +o_uk_store_start_cost
+o_uk_store_capex_cost
+o_uk_store_fom_cost
+o_uk_trade_cost
+o_uk_trade_crent_cost
+o_uk_trade_capex_cost
+o_uk_trade_fom_cost
+o_uk_trans_capex_cost
+o_uk_trans_fom_cost;




parameter o_gen_uk(h,g);
parameter o_store_gen_uk(h,s);
parameter o_emissions_uk(yr);
parameter o_co2_intensity_uk(yr);

o_gen_uk(h,g)=sum(uk_z(z),var_gen.l(h,z,g));
o_store_gen_uk(h,s)=sum(uk_z(z),var_store_gen.L(h,z,s));

o_emissions_uk(yr)=sum((gen_lim(z,non_vre),h)$(hr2yr_map(yr,h) and uk_z(z)),var_gen.l(h,z,non_vre)*gen_emisfac(non_vre));
o_co2_intensity_uk(yr)=o_emissions_uk(yr)*1E3/sum((h,g),o_gen_uk(h,g));



parameter o_trans_net_flow_z(trans,z,z_alias);

*set not_uk_z_alias(z_alias);
*not_uk_z_alias(z_alias)=not (uk_z(z_alias));


o_trans_net_flow_z(trans,z,z_alias)=

* *(1-(trans_links_dist_bidir(z,z_alias,trans)*trans_loss(trans))))

sum(h,var_trans_flow.l(h,z,z_alias,trans))*(1-(trans_links_dist_bidir(z,z_alias,trans)*trans_loss(trans)))

-sum(h,var_trans_flow.l(h,z_alias,z,trans));

*parameter o_trans_test(z);

*o_trans_test(z)$(not_uk(z))=sum((trans,not_uk_z_alias(z_alias)),o_trans_net_flow_z(trans,z,z_alias));



set
z_imp / EU, IRL/
uk / UK /
z_map2(z_imp,z_alias) /
EU.(FRA,NDK,DEU,BNL)
IRL.IRL
/
z_map1(uk,z)
/
UK.UK1*UK9
/
;

parameter o_trans_net_import_uk(h,uk,z_imp);

o_trans_net_import_uk(h,uk,z_imp)=sum((z_map1(uk,z),z_map2(z_imp,z_alias),trans),var_trans_flow.l(h,z,z_alias,trans)*(1-(trans_links_dist_bidir(z,z_alias,trans)*trans_loss(trans))))-sum((z_map1(uk,z),z_map2(z_imp,z_alias),trans),var_trans_flow.l(h,z_alias,z,trans));



***********************************************

* Diagnostics

parameter co2_intensity_uk(yr);
*parameter co2_intensity(yr);

co2_intensity_uk(yr)=sum((gen_lim(z,non_vre),h)$(hr2yr_map(yr,h) and uk_z(z)),var_gen.l(h,z,non_vre)*gen_emisfac(non_vre))*1E3/
                         sum((gen_lim(z,g),h)$(hr2yr_map(yr,h) and uk_z(z)),var_gen.l(h,z,g));



*execute_unload "%outname%"

$ifThen "%UC%" == ON

parameter o_gen_f_provision(h,non_vre);
parameter o_store_f_provision(h,s);
parameter o_gen_res_provision(h,non_vre);
parameter o_store_res_provision(h,s);
parameter o_gen_quick_res_provision(h,non_vre);

o_gen_f_provision(h,non_vre)=sum(z$(gen_lim(z,non_vre) and gen_max_res(non_vre,"f_response") > 0. and uc_z(z)),var_f_res.l(h,z,non_vre));
o_store_f_provision(h,s)=sum(s_lim(z,s)$(store_max_freq(s) > 0. and uc_z(z)),var_store_f_res.l(h,z,s));
o_gen_res_provision(h,non_vre)=sum(z$(gen_lim(z,non_vre) and gen_max_res(non_vre,"reserve") > 0. and uc_z(z)),var_res.l(h,z,non_vre));
o_gen_quick_res_provision(h,non_vre)=sum(z$(gen_lim(z,non_vre) and gen_quick(non_vre) and uc_z(z)),var_res_quick.l(h,z,non_vre));
o_store_res_provision(h,s)=sum(s_lim(z,s)$(store_max_res(s) > 0. and uc_z(z)),var_store_res.l(h,z,s));

$endIf

$offtext

***************
*Costs
***************

*Variable Costs
parameter o_variableC;
o_variableC=
sum((gen_lim(z,non_vre),h),var_gen.L(h,z,non_vre)*gen_varom(non_vre))
+sum((vre_lim(vre,z,r),h),var_vre_gen_r.L(h,z,vre,r)*gen_varom(vre))
+sum((trans_links(z,z_alias,trans),h),var_trans_flow.l(h,z,z_alias,trans)*trans_varom(trans))


Parameter o_nonVREVarC;
o_nonVREVarC=sum((gen_lim(z,non_vre),h),var_gen.L(h,z,non_vre)*gen_varom(non_vre))

parameter o_VREVarC ;
o_VREVarC=sum((vre_lim(vre,z,r),h),var_vre_gen_r.L(h,z,vre,r)*gen_varom(vre))

parameter o_transVarC;
o_transVarC=sum((trans_links(z,z_alias,trans),h),var_trans_flow.L(h,z,z_alias,trans)*trans_varom(trans))


* Annualised fixed costs
parameter o_capitalC;
o_capitalC=sum(non_vre,var_new_pcap.L(non_vre)*gen_capex(non_vre))
+sum(vre,var_new_pcap.L(vre)*gen_capex(vre))
+sum(trans_links(z,z_alias,trans),var_trans_pcap.l(z,z_alias,trans)*trans_links_dist(z,z_alias,trans)*trans_line_capex(trans))
+sum(trans_links(z,z_alias,trans),var_trans_pcap.l(z,z_alias,trans)*trans_sub_capex(trans)*2)
+sum(g,var_tot_pcap.l(g)*gen_fom(g))
*+sum(g,var_exist_pcap.l(g)*gen_fom(g))

parameter o_nonVRECapC;
o_nonVRECapC=sum(non_vre,var_new_pcap.L(non_vre)*gen_capex(non_vre))
+sum(non_vre,var_tot_pcap.l(non_vre)*gen_fom(non_vre))
*+sum(non_vre,var_exist_pcap.l(non_vre)*gen_fom(non_vre))

parameter o_VRECapC;
o_VRECapC= sum(vre,var_new_pcap.L(vre)*gen_capex(vre))
+sum(vre,var_tot_pcap.l(vre)*gen_fom(vre))
*+sum(vre,var_exist_pcap.l(vre)*gen_fom(vre))

parameter o_transCapc;
o_transCapc=sum(trans_links(z,z_alias,trans),var_trans_pcap.l(z,z_alias,trans)*trans_links_dist(z,z_alias,trans)*trans_line_capex(trans))
+sum(trans_links(z,z_alias,trans),var_trans_pcap.l(z,z_alias,trans)*trans_sub_capex(trans)*2)

$ifThen "%storage%" == ON

* store costs

*Variable store costs
parameter o_variablestoreC;
o_variablestoreC=sum((s_lim(z,s),h),var_store_gen.L(h,z,s)*store_varom(s))

*Capital store Costs
parameter o_capitalstoreC;
o_capitalstoreC=sum(s,var_new_store_pcap.L(s)*store_pcapex(s)+var_new_store_ecap.L(s)*store_ecapex(s))
+sum(s,var_tot_store_pcap.L(s)*store_fom(s))
*+sum(s,var_exist_store_pcap.L(s)*store_fom(s))

*Total Capital Costs
parameter o_capitalC_tot;
o_capitalC_tot=o_capitalstoreC+o_capitalC

*Total Variable Costs
parameter o_variableC_tot;
o_variableC_tot=o_variablestoreC+o_variableC

$endIf

$ifThen "%hydrogen%" == "ON"
* hydrogen costs

*Capital electrolizer cost
parameter o_capH2ElecC;
o_capH2ElecC = sum(El, var_new_electrolyzer_pcap.L(El)*electrolyzer_capex(El))
+sum(El, var_tot_electrolyzer_pcap.L(El)*electrolyzer_fom(El))
*Capital hydrogen storage cost
parameter o_capH2storC;
o_capH2storC = sum(H2T, var_new_h2_storage_pcap.L(H2T)*h2_storage_capex(H2T))
+sum(H2T, var_tot_h2_storage_pcap.L(H2T)*h2_storage_fom(H2T))
*Capital fuell cost
parameter o_capH2FcC;
o_capH2FcC = sum(FC, var_new_fuel_cell_pcap.L(FC)*fuel_cell_capex(FC))
+sum(FC, var_tot_fuel_cell_pcap.L(FC)*fuel_cell_fom(FC))
*Variable electrolyzer cost
parameter o_varH2ElecC;
o_varH2ElecC = sum(z,cost_electrolyzer_varom.L(z));
parameter o_varH2FcC;
o_varH2FcC = sum(z,cost_fuel_cell_varom.L(z));
*Total capital cost
parameter o_capH2C;
o_capH2C = o_capH2ElecC + o_capH2storC + o_capH2FcC;
parameter o_varH2C;
o_varH2C = o_varH2ElecC + o_varH2FcC;

$endIF

$ifThen "%CSP%" == "ON"
* CSP costs

*Variable CSP cost
parameter o_varCSPC;
o_varCSPC = sum((h,PB_lim(CSP,z)),var_CSP_gen.L(h,z,CSP)*CSP_varom(CSP))

*Capital solar field cost
parameter o_capCSPSfC;
o_capCSPSfC = sum(CSP,var_new_SF_pcap.L(CSP)/SF_cap2area(CSP)*SF_capex(CSP))
*Capital thermal energy storage cost
parameter o_capCSPtesC;
o_capCSPtesC = sum(CSP,  var_new_TES_pcap.L(CSP)*TES_t_capex(CSP));
*Capital power block cost
parameter o_capCSPpbC;
o_capCSPpbC = sum(CSP, var_new_PB_pcap.L(CSP)*PB_capex(CSP)) 
+sum(CSP, var_tot_PB_pcap.L(CSP)*CSP_fom(CSP))
*Total capital CSP cost
parameter o_capCSPC;
o_capCSPC = o_capCSPSfC + o_capCSPtesC + o_capCSPpbC;

$endIF

***************
*Emissions
***************

parameter o_emissions(h,z,non_vre);
o_emissions(h,z,non_vre)=var_gen.L(h,z,non_vre)*gen_emisfac(non_vre) ;

parameter o_emissions_all;
o_emissions_all=Sum((h,z,non_vre), o_emissions(h,z,non_vre));




***************
*Transmission
***************

parameter o_trans_cap_sum(trans);
o_trans_cap_sum(trans)=sum((z,z_alias),var_trans_pcap.L(z,z_alias,trans))/2  ;






*-sum(h,var_trans_flow.l(h,z_alias,z,trans))
*+sum(h,var_trans_flow.l(h,z,z_alias,trans)*(1-(trans_links_dist_bidir(z,z_alias,trans)*trans_loss(trans))));





***************
*Capacities
***************

*parameter vre_cap_z(vre,z);
*vre_cap_z(vre,z)=sum(vre_lim(vre,z,r),var_vre_pcap_r.l(z,vre,r));

*parameter vre_cap_r(vre,r);
*vre_cap_r(vre,r)=sum(vre_lim(vre,z,r),var_vre_pcap_r.l(z,vre,r));

*parameter vre_cap_tot(vre);
*vre_cap_tot(vre)=sum(vre_lim(vre,z,r),var_vre_pcap_r.l(z,vre,r)) ;


***************
*Generation
***************

parameter o_non_vre_gen_tot(non_vre);
o_non_vre_gen_tot(non_vre)=sum((h,z),var_gen.l(h,z,non_vre));

parameter o_non_vre_gen_out(non_vre,h);
o_non_vre_gen_out(non_vre,h)= sum(z,var_gen.l(h,z,non_vre));

parameter o_vre_gen_out(vre,h);
o_vre_gen_out(vre,h)=sum((z,r),var_vre_gen_r.l(h,z,vre,r)$vre_lim(vre,z,r))

parameter o_vre_gen_tot(vre);
o_vre_gen_tot(vre)=sum(h,o_vre_gen_out(vre,h));


parameter o_gen(g,h);
o_gen(g,h)=sum(z,var_gen.l(h,z,g));

parameter o_gen_tot(g);
o_gen_tot(g)=sum(h,o_gen(g,h));


parameter o_pgen_tot_z(z);

$ifThen "%hydrogen%" == "ON"

parameter o_H2_gen(FC);
o_H2_gen(FC) = sum((h,fuel_cell_lim(FC,z)),var_P_fuel_cell.l(h,z,FC)*1);

parameter o_H2_imp;
o_H2_imp = sum((h,electrolyzer_lim("Import",z)),var_P_el.l(h,z,"Import")*1)/HHV_h2;

$endIf

$ifThen "%CSP%" == "ON"

parameter o_CSP_gen(CSP);
o_CSP_gen(CSP) = sum((h,PB_lim(CSP,z)),var_CSP_gen.l(h,z,CSP)*1);

$endIF

*o_pgen_tot_z(z)=sum(h,var_pgen.l(h,z));



*parameter vre_cap(vre);
*vre_cap(vre)=sum((z,r),var_vre_pcap_r.l(z,vre,r));

***************
*Curtailment
***************

*parameter curtail(h);
*curtail(h)=sum((z,vre,r),var_vre_curtail.l(h,z,vre));

*sum of curtailment over all regions
*parameter curtail_z (h,vre);
*curtail_z(h,vre)=sum((z,,var_vre_curtail.l(h,z,vre,r))


*sum of curtailment over all regions and hours

parameter vre_curtail(h,z,vre,r);

vre_curtail(h,z,vre,r)= vre_gen(h,vre,r)*(var_new_vre_pcap_r.l(z,vre,r)+var_exist_vre_pcap_r.l(z,vre,r))-var_vre_gen_r.l(h,z,vre,r);

parameter o_curtail(vre);
o_curtail(vre)=sum((h,z,r),vre_curtail(h,z,vre,r))

* small value to avoid division by zero
parameter o_curtail_frac_vregen(vre);
o_curtail_frac_vregen(vre)=o_curtail(vre)/(o_curtail(vre)+o_gen_tot(vre)+0.0000001);


***************
*Economics
***************


parameter o_eprice(z,h);
o_eprice(z,h)=eq_elc_balance.m(z,h);


*grossRet is the gross return fom power production (revenues - (variable)costs)

*gross Margins non VRE
parameter o_grossRet_non_vre(z,non_vre);
o_grossRet_non_vre(z,non_vre)=sum(h,((o_eprice(z,h)*var_gen.L(h,z,non_vre))- (var_gen.L(h,z,non_vre)*gen_varom(non_vre))))  ;


*gross Margins VRE
parameter o_grossRet_vre(z,vre,r);
o_grossRet_vre(z,vre,r)=sum(h,(o_eprice(z,h)*var_vre_gen_r.L(h,z,vre,r))- (var_vre_gen_r.L(h,z,vre,r)*gen_varom(vre)))

$ifThen "%storage%" == ON
*gross Margins store
parameter o_grossRet_store(z,s);
o_grossRet_store(z,s)=sum(h,(o_eprice(z,h)*var_store_gen.L(h,z,s))- (var_store_gen.L(h,z,s)*store_varom(s)))
$endIf


scalar o_gen_costs;
o_gen_costs=sum((h,z,non_vre),var_gen.l(h,z,non_vre)*gen_varom(non_vre))+sum((vre_lim(vre,z,r),h),var_vre_gen_r.l(h,z,vre,r)*gen_varom(vre));




*sums up over all zones and gives installed capacity per renewable
parameter o_vre_cap_z_sum(vre,r);
o_vre_cap_z_sum(vre,r)=sum(z,var_new_vre_pcap_r.L(z,vre,r)+var_exist_vre_pcap_r.L(z,vre,r));


parameter o_vre_cap_r_sum(z,vre) ;
o_vre_cap_r_sum(z,vre)=sum(r,var_new_vre_pcap_r.L(z,vre,r)+var_exist_vre_pcap_r.L(z,vre,r));


*sums up over all zones and gives installed capacity per generation type
parameter o_nvre_cap_z_sum(non_vre);
o_nvre_cap_z_sum(non_vre)=sum(z,var_tot_pcap_z.L(z,non_vre));


*sums up over all hours +regions and gives the generated electricity per renewable type
parameter o_vre_gen_sum_r(vre);
o_vre_gen_sum_r(vre)=sum((h,z,r),var_vre_gen_r.L(h,z,vre,r));


*sums up over all hours +zones and gives the generated electricity per renewable type
parameter o_vre_gen_sum_z(vre,r);
o_vre_gen_sum_z(vre,r)=sum((z,h),var_vre_gen_r.L(h,z,vre,r));


parameter o_vre_gen_sum_r_z(z,vre);
o_vre_gen_sum_r_z(z,vre)=sum((r,h),var_vre_gen_r.L(h,z,vre,r));


parameter o_vre_gen_sum_r_zone(h,z,vre);
o_vre_gen_sum_r_zone(h,z,vre)=sum((r),var_vre_gen_r.L(h,z,vre,r));



*sums over all regions and zones and gives the generated electricity per generation type
parameter o_vre_gen_sum_h(h,vre);
o_vre_gen_sum_h(h,vre)=sum((z,r),var_vre_gen_r.L(h,z,vre,r));


parameter o_gen_sum_zone(z,non_vre)  ;
o_gen_sum_zone(z,non_vre)=sum(h,var_gen.L(h,z,non_vre));


*sums up over all hours +zones and gives the generated electricity per generation type
parameter o_gen_sum_z(non_vre)  ;
o_gen_sum_z(non_vre)=sum((z,h),var_gen.L(h,z,non_vre));

*sums over all zones and gives the generated electricity per generation type
parameter o_gen_sum_h(h,non_vre)  ;
o_gen_sum_h(h,non_vre)=sum(z,var_gen.L(h,z,non_vre));

$ifThen "%storage%" == ON
parameter o_store_gen_sum_h(h,s)  ;
o_store_gen_sum_h(h,s)=sum(z,var_store_gen.L(h,z,s));
$endIf


*parameter var_trans_pcap_sum(z_alias);
*var_trans_pcap_sum(z_alias)=sum(z,var_trans_pcap.L(z,z_alias))  ;
*display var_trans_pcap_sum;

$ifThen "%storage%" == ON
*sums over all hours and gives the electricity generated per zone and store technology
parameter o_store_gen_sum(z,s);
o_store_gen_sum(z,s)=sum(h,var_store_gen.L(h,z,s));


*sums over all hours and zones and gives the electricity generated per zone and store technology
parameter o_store_gen_all(s);
o_store_gen_all(s)=sum((z,h),var_store_gen.L(h,z,s));

$endIf

*sums up over all hours +zones and gives the generated electricity per generation type
parameter o_nvre_gen_sum_z(non_vre)  ;
o_nvre_gen_sum_z(non_vre)=sum((z,h),var_gen.L(h,z,non_vre));


parameter o_vre_gen_sum_r(vre);
o_vre_gen_sum_r(vre)=sum((h,z,r),var_vre_gen_r.L(h,z,vre,r));

;

parameter o_Residual_D(z,h);
o_Residual_D(z,h)=demand(z,h)-sum(vre,o_vre_gen_sum_r_zone(h,z,vre));


* Total demand
parameter dem_tot;
dem_tot = sum((z,h),demand(z,h));

* LCOE
parameter o_LCOE;
o_LCOE = costs.L / dem_tot;


$ontext
*Average electricity price
parameter price_mean(h);
price_mean(h)= sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre))/sum(vre,var_vre_gen_sum_r(vre)))


parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))
+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre)))
+sum((z,s),(price(z,h)*var_store_gen.L(h,z,s))))
/(sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+
sum((z,non_vre),var_gen.L(h,z,non_vre))
+sum((z,s),var_store_gen.L(h,z,s)));




WORKS: parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre))))
/(sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+sum((z,non_vre),var_gen.L(h,z,non_vre)));
display price_mean;

parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))
+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre)))
+sum((z,s),(price(z,h)*var_store_gen.L(h,z,s))
/((((sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+sum((z,non_vre),var_gen.L(h,z,non_vre))+sum((z,s),var_store_gen.L(h,z,s)));
display price_mean;

parameter price_mean(h);
price_mean(h)=
(sum((z,non_vre),(price(z,h)*var_gen.L(h,z,non_vre)))
+sum((z,vre),(price(z,h)*var_vre_gen_sum_r_zone(h,z,vre)))
+sum((z,s),(price(z,h)*var_store_gen.L(h,z,s))
/(((sum((z,vre),var_vre_gen_sum_r_zone(h,z,vre))+sum((z,non_vre),var_gen.L(h,z,non_vre))+sum((z,s),var_store_gen.L(h,z,s)));
display price_mean;

$offtext

