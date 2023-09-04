
* Emission factors definitios

parameter gen_emisfac(g)                        Direct emission factor per technology (kg CO2e per MWh);
parameter gen_OM_emisfac(g)                     Maintenance emission factor per technology (kg CO2e per year per MW);
parameter gen_repl_emisfac(g)                   Fixed replacement emission factor (kg CO2e per year per MW);
parameter gen_build_emisfac(g)                  Initial building emission factor (kg CO2e per MW);
parameter trans_link_build_emis(trans)          Initial building emission factor for transmission line (kg CO2e);
parameter trans_link_repl_emisfac(trans)        Fixed replacement emission factor (kg CO2e per year);
parameter commute_emis                          Fixed cost - maintenance workers commute (kg CO2e per year);

$ifThen "%storage%" == ON
parameter store_build_emisfac(s)                Initial building emission factor for storage (kg CO2e per MWh);
parameter store_repl_emisfac(s)                 Fixed replacement emission factor (kg CO2e per year per MWh);
$endIf


$ifThen "%hydrogen%" == ON
parameter h2_des_emisfac(FC)                    Direct emission factor for des (kg CO2e per MWh in PEMFC);
parameter electrolyzer_build_emisfac(El)        Initial builidng emission factor for electrolyzer (kg CO2e per MWe);
parameter electrolyzer_repl_emisfac(El)         Fixed replacement emission factor (kg CO2e per year per MWe);
parameter h2_storage_build_emisfac(H2T)         Initial building emission factor for H2 storage (kg CO2e per kg H2);
parameter h2_storage_repl_emisfac(H2T)          Fixed replacement emission factor (kg CO2e per year per kg H2);
parameter fuel_cell_build_emisfac(FC)           Initial building emission factor for fuel cell (kg CO2e per MWe);
parameter fuel_cell_repl_emisfac(FC)            Fixed replacement emission factor (kg CO2e per year per MWe);
$endIf

*************** Extra parameters for annualized initial building emissions ***************

parameter gen_build_emisfac_a(g)                  Annualised Initial building emission factor (kg CO2e per MW);
parameter trans_link_build_emis_a(trans)          Annualised Initial building emission factor for transmission line (kg CO2e);
$ifThen "%storage%"== ON
parameter store_build_emisfac_a(s)                Annualised Initial building emission factor for storage (kg CO2e per MWh);
$endIf
$ifthen "%hydrogen%" == ON
parameter electrolyzer_build_emisfac_a(El)        Annualised Initial builidng emission factor for electrolyzer (kg CO2e per MWe);
parameter h2_storage_build_emisfac_a(H2T)         Annualised Initial building emission factor for H2 storage (kg CO2e per kg H2);
parameter fuel_cell_build_emisfac_a(FC)           Annualised Initial building emission factor for fuel cell (kg CO2e per MWe);
$endIf


****************************************************************

$INCLUDE data_inputs/%psys_scen%_ghg.dd


*************** Annualized values ***********************

gen_build_emisfac_a(g) = gen_build_emisfac(g)/PLT + gen_repl_emisfac(g);
trans_link_build_emis_a(trans) = trans_link_build_emis(trans)/PLT + trans_link_repl_emisfac(trans);

$ifThen "%storage%"== ON
store_build_emisfac_a(s) = store_build_emisfac(s)/PLT + store_repl_emisfac(s);
$endIf

$ifthen "%hydrogen%" == ON
electrolyzer_build_emisfac_a(El) = electrolyzer_build_emisfac(El)/PLT + electrolyzer_repl_emisfac(El);
h2_storage_build_emisfac_a(H2T) = h2_storage_build_emisfac(H2T)/PLT + h2_storage_repl_emisfac(H2T);
fuel_cell_build_emisfac_a(FC) = fuel_cell_build_emisfac(FC)/PLT + fuel_cell_repl_emisfac(FC);
$endIf



****************************************************************


