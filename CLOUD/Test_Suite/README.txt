

=============
cnhss_ROB.cfg 
=============
It contains the list of JSON files to run Robustness traffic, mainly latency and overload tests. 
To run the JSON files you want, just remove the "#" at the beginning of the line.
Latency JSON files uses the traffic references creates in the "max_cps" json file, 
that's why they are included too in the cfg file. In this case, you also have to execute both of them.

==============
cnhss_STAB.cfg 
==============
It contains the list of JSON files to run STABILITY traffic, for the diferent periods and for 
the diferent type of traffic.
You have to run the "max_cps" json file to calculate the max capacity nd to create the traffic 
references that will be create for that type of traffic for the different periods 
(1H, 8H, 48 and a week)


-- Command example ro run some TCs of ROBUSTNESS on an environment configured with mTLS

HSS_rtc -o /opt/hss/<user_id>/<workdir>/  --macro_file ~/GIT_repos/ST_AUTOMATION/CLOUD/json/epc_ims_st.mkr --cfg ~/GIT_repos/ST_AUTOMATION/CLOUD/Test_Suite/cnhss_ROB.cfg


-- Command example ro run some TCs of STABILITY on an environment configured with clear

HSS_rtc -o /opt/hss/<user_id>/<workdir>/  --macro_file ~/GIT_repos/ST_AUTOMATION/CLOUD/json/epc_ims_st_clear.mkr --cfg ~/GIT_repos/ST_AUTOMATION/CLOUD/Test_Suite/cnhss_STAB.cfg
