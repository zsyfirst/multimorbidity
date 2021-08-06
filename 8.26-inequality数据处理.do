

/*
author			:Zou
purpose			:analyse of comorbidity
Date created	:Nov 15, 2019
last mordified	:Dec 17, 2020
*/

clear all

pwd
cd"C:/"



use "D:\研究们\共患病\mortality\数据\数据4.28.dta",clear

gen  re_education= 1 if highest_education== 5 |highest_education==4
replace re_education= 2 if highest_education== 3 |highest_education==2
replace re_education= 3 if highest_education== 1
replace re_education= 4 if highest_education== 0
codebook re_education

gen  re_highest_education= 5- highest_education
codebook  highest_education
*LEL MEL HEL   (LEL, no formal education, primary school)
gen  education_3level= 1 if highest_education== 0 |highest_education==1
replace education_3level= 2 if highest_education== 2 |highest_education==3
replace education_3level= 3 if highest_education== 4 |highest_education==5
codebook education_3level 


///////////////table 1//////////////////////////
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==0 & education==1 ,  replace
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==0 & education==2 ,  replace
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==0 & education==3 ,  replace
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==0 & education==4 ,  replace

asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==1 & education==1 ,  replace
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==1 & education==2 ,  replace
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==1 & education==3 ,  replace
asdoc tab1  gender age  income   occup region_is_urban bmi smoke alcohol  activity if  morbidity==1 & education==4 ,  replace
//////////////////////////////////////////////////////////////////////
///////////////////////////age///////////////////////////////////////////

tabulate   num age
by age, sort : stcox i.num   //满足PH假定
by age, sort : stcox i.num gender 
by age, sort : stcox i.num gender i.education i.income i.occup 
by age, sort : stcox i.num  gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest  //依然不满足PH假定
*p for trend
logistic odu_ep0001 num gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if age==1
logistic odu_ep0001 num gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if age==2
logistic odu_ep0001 num gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if age==3
logistic odu_ep0001 num gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if age==4
logistic odu_ep0001 num gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if age==5

/////////////////////////////////////inequality////////////////////////////////
/////////////////////////////////////SII/RII//////////////////////////////////

*redit_wealth
education income
tab education 
tab highest_education
tab re_highest_education
tab income
gen windex5=highest_education
gen windex5=re_highest_education
/*
gen redit_wealth = 0.0928 if windex5==0
replace redit_wealth = 0.3467 if windex5==1
replace redit_wealth = 0.5078 if windex5==2
replace redit_wealth = 0.7904 if windex5==3
replace redit_wealth = 0.9416 if windex5==4
replace redit_wealth = 0.9772 if windex5==5
*/
gen redit_wealth = 0.0114 if windex5==0
replace redit_wealth = 0.0406 if windex5==1
replace redit_wealth = 0.134 if windex5==2
replace redit_wealth = 0.3509 if windex5==3
replace redit_wealth = 0.6533 if windex5==4
replace redit_wealth = 0.9072 if windex5==5

codebook redit_wealth
glm morbidity redit_wealth , fam(bin) link(log) nolog eform /*RII*/
glm morbidity redit_wealth, fam(bin) link(identity) /*SII*/

***************排位***********
1. 从头到底排 2. egen: n=sum(1) 3. gen r=sum(1) 4. gen rank=r/n
****************RIIGEN******************************
 riigen varlist [if] [in] [weight] [ , varprefix(string) riiname(string)  replace]

 
*CI
conindex stunting, rankvar(wscore) truezero  graph ytitle(Cumulative share of Stunting 2018) xtitle(Rank of wealthindex) svy
conindex stunting_severe, rankvar(wscore) truezero  graph ytitle(Cumulative share of Severe Stunting 2018) xtitle(Rank of wealthindex) svy
////////////////////////////////////////////////////////////////////////////////
///////////////rural urban-multimorbidity //////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
*rural urban
gen windex5=highest_education
by region_is_urban, sort: tab highest_education
gen redit_wealth = 0.1192 if windex5==0  & region_is_urban==0
replace redit_wealth = 0.4474 if windex5==1 & region_is_urban==0
replace redit_wealth = 0.7822 if windex5==2 & region_is_urban==0
replace redit_wealth = 0.9485 if windex5==3 & region_is_urban==0
replace redit_wealth = 0.9930 if windex5==4 & region_is_urban==0
replace redit_wealth = 0.9984 if windex5==5 & region_is_urban==0

gen redit_wealth2 = 0.0595 if windex5==0  & region_is_urban==1
replace redit_wealth2 = 0.2192 if windex5==1 & region_is_urban==1
replace redit_wealth2 = 0.4804 if windex5==2 & region_is_urban==1
replace redit_wealth2 = 0.7814 if windex5==3 & region_is_urban==1
replace redit_wealth2 = 0.9168 if windex5==4 & region_is_urban==1
replace redit_wealth2 = 0.9762 if windex5==5 & region_is_urban==1

  glm morbidity redit_wealth if region_is_urban==0, fam(bin) link(identity) /*SII rural*/
  glm morbidity redit_wealth2 if region_is_urban==1 , fam(bin) link(identity) /*SII urban*/
 
  glm morbidity redit_wealth if region_is_urban==0, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth2 if region_is_urban==1, fam(bin) link(log) nolog eform /*RII*/
i.num  gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi 
  glm morbidity redit_wealth2 gender i.age  if region_is_urban==1 , fam(bin) link(identity) /*SII urban*/
 

////////////////////////////////////////////////////////////////////////////////
///////////////region_code //////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
tab region_code 
tab region_is_urban
by region_code, sort: tab highest_education
codebook wlthind5
gen wlthind5= highest_education
gen hi7=region_code
12	  Qingdao (Urban)
16	  Harbin (Urban)
26	  Haikou (Urban)
36	  Suzhou (Urban)
46	  Liuzhou (Urban)
52	  Sichuan (Rural)
58	  Gansu (Rural)
68	  Henan (Rural)
78	  Zhejiang (Rural)
88	  Hunan (Rural)


gen redit_wealth_1 = 0.2915 if wlthind5==0 & hi7==12
replace redit_wealth_1 = 0.14530 if wlthind5==1 & hi7==12
replace redit_wealth_1 = 0.4382 if wlthind5==2 & hi7==12
replace redit_wealth_1 = 0.77575 if wlthind5==3 & hi7==12
replace redit_wealth_1 = 0.93845 if wlthind5==4 & hi7==12
replace redit_wealth_1 = 0.98475 if wlthind5==5 & hi7==12
*
gen redit_wealth_2 = 0.02085 if wlthind5==0 & hi7==16
*replace redit_wealth_2 = 0.0917 if wlthind5==1 & hi7==16
replace redit_wealth_2 = 0.2955 if wlthind5==2 & hi7==16
replace redit_wealth_2 = 0.6116 if wlthind5==3 & hi7==16
replace redit_wealth_2 = 0.83535 if wlthind5==4 & hi7==16
replace redit_wealth_2 = 0.9484 if wlthind5==5 & hi7==16
//
gen redit_wealth_3 = 0.0738 if wlthind5==0 & hi7==26
replace redit_wealth_3 = 0.245 if wlthind5==1 & hi7==26
replace redit_wealth_3 = 0.48335 if wlthind5==2 & hi7==26
replace redit_wealth_3 = 0.7509 if wlthind5==3 & hi7==26
replace redit_wealth_3 = 0.9103 if wlthind5==4 & hi7==26
replace redit_wealth_3 = 0.97165 if wlthind5==5 & hi7==26

gen redit_wealth_4 = 0.14955 if wlthind5==0 & hi7==36
replace redit_wealth_4 = 0.46095 if wlthind5==1 & hi7==36
replace redit_wealth_4 = 0.7626 if wlthind5==2 & hi7==36
replace redit_wealth_4 = 0.9416 if wlthind5==3 & hi7==36
replace redit_wealth_4 = 0.98765 if wlthind5==4 & hi7==36
replace redit_wealth_4 = 0.9973 if wlthind5==5 & hi7==36

gen redit_wealth_5 = 0.0209 if wlthind5==0 & hi7==46
replace redit_wealth_5 = 0.1454 if wlthind5==1 & hi7==46
replace redit_wealth_5 = 0.4208 if wlthind5==2 & hi7==46
replace redit_wealth_5 = 0.7375 if wlthind5==3 & hi7==46
replace redit_wealth_5 = 0.9232 if wlthind5==4 & hi7==46
replace redit_wealth_5 = 0.982 if wlthind5==5 & hi7==46

gen redit_wealth_6 = 0.07715 if wlthind5==0 & hi7==52
replace redit_wealth_6 = 0.4036 if wlthind5==1 & hi7==52
replace redit_wealth_6  = 0.78655 if wlthind5==2 & hi7==52
replace redit_wealth_6  = 0.94905 if wlthind5==3 & hi7==52
replace redit_wealth_6  = 0.98475 if wlthind5==4 & hi7==52
replace redit_wealth_6  = 0.99580 if wlthind5==5 & hi7==52

gen redit_wealth_7 = 0.2296 if wlthind5==0 & hi7==58
replace redit_wealth_7 = 0.5951 if wlthind5==1 & hi7==58
replace redit_wealth_7 = 0.8203 if wlthind5==2 & hi7==58
replace redit_wealth_7 = 0.9506 if wlthind5==3 & hi7==58
replace redit_wealth_7 = 0.995 if wlthind5==4 & hi7==58
replace redit_wealth_7 = 0.9992 if wlthind5==5 & hi7==58
//
gen redit_wealth_8 = 0.06585 if wlthind5==0 & hi7==68
replace redit_wealth_8 = 0.3092 if wlthind5==1 & hi7==68
replace redit_wealth_8 = 0.6659 if wlthind5==2 & hi7==68
replace redit_wealth_8 = 0.9182 if wlthind5==3 & hi7==68
replace redit_wealth_8 = 0.9950 if wlthind5==4 & hi7==68
replace redit_wealth_8 = 0.9994 if wlthind5==5 & hi7==68

gen redit_wealth_9 = 0.2203 if wlthind5==0 & hi7==78
replace redit_wealth_9 = 0.6217 if wlthind5==1 & hi7==78
replace redit_wealth_9 = 0.8823 if wlthind5==2 & hi7==78
replace redit_wealth_9 = 0.9796 if wlthind5==3 & hi7==78
replace redit_wealth_9 = 0.9985 if wlthind5==4 & hi7==78
replace redit_wealth_9 = 0.9999 if wlthind5==5 & hi7==78

gen redit_wealth_10 = 0.0253 if wlthind5==0 & hi7==88
replace redit_wealth_10 = 0.3438 if wlthind5==1 & hi7==88
replace redit_wealth_10 = 0.7736 if wlthind5==2 & hi7==88
replace redit_wealth_10 = 0.9489 if wlthind5==3 & hi7==88
replace redit_wealth_10 = 0.9918 if wlthind5==4 & hi7==88
replace redit_wealth_10 = 0.9980 if wlthind5==5 & hi7==88
//////////////////////////SII/////////////////////////////////////////

glm morbidity redit_wealth, fam(bin) link(identity) /*SII*/
  glm morbidity redit_wealth_1 if hi7==12, fam(bin) link(identity) /*SII kinshasa*/
  glm morbidity redit_wealth_2 if hi7==16, fam(bin) link(identity) /*SII kinshasa*/
  glm morbidity redit_wealth_3 if hi7==26, fam(bin) link(identity) /*SII kinshasa*/
  glm morbidity redit_wealth_4 if hi7==36, fam(bin) link(identity) /*SII kinshasa*/
  glm morbidity redit_wealth_5 if hi7==46, fam(bin) link(identity) /*SII kinshasa*/
  glm morbidity redit_wealth_6 if hi7==52, fam(bin) link(identity) /*SII Bas-congo*/
  glm morbidity redit_wealth_7 if hi7==58, fam(bin) link(identity) /*SII Bas-congo*/
  glm morbidity redit_wealth_8 if hi7==68, fam(bin) link(identity) /*SII Bas-congo*/
  glm morbidity redit_wealth_9 if hi7==78, fam(bin) link(identity) /*SII Bas-congo*/
  glm morbidity redit_wealth_10 if hi7==88, fam(bin) link(identity) /*SII Bas-congo*/

///////////////////////////RII/////////////////////////////////////////////
glm morbidity redit_wealth, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_1 if hi7==12, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_2 if hi7==16, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_3 if hi7==26, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_4 if hi7==36, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_5 if hi7==46, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_6 if hi7==52, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_7 if hi7==58, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_8 if hi7==68, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_9 if hi7==78, fam(bin) link(log) nolog eform /*RII*/
  glm morbidity redit_wealth_10 if hi7==88, fam(bin) link(log) nolog eform /*RII*/

///////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////LTC分层  total/////////////////////////////////////////////////
by num , sort: tab highest_education

gen wlthind5= highest_education
gen hi7=num
gen redit_wealth_1 = 0.0713 if wlthind5==0 & hi7==0 
replace redit_wealth_1 = 0.29350 if wlthind5==1 & hi7==0
replace redit_wealth_1 = 0.6047 if wlthind5==2 & hi7==0
replace redit_wealth_1 = 0.8512 if wlthind5==3 & hi7==0
replace redit_wealth_1 = 0.9570 if wlthind5==4 & hi7==0
replace redit_wealth_1 = 0.9884 if wlthind5==5 & hi7==0

gen redit_wealth_2 = 0.1106 if wlthind5==0 & hi7==1 
replace redit_wealth_2 = 0.391 if wlthind5==1 & hi7==1 
replace redit_wealth_2 = 0.689 if wlthind5==2 & hi7==1 
replace redit_wealth_2 = 0.8837 if wlthind5==3 & hi7==1  
replace redit_wealth_2 = 0.9653 if wlthind5==4 & hi7==1 
replace redit_wealth_2 = 0.9903 if wlthind5==5 & hi7==1 
//
gen redit_wealth_3 = 0.1218 if wlthind5==0 & hi7==2 
replace redit_wealth_3 = 0.4194 if wlthind5==1 & hi7==2 
replace redit_wealth_3 = 0.7071 if wlthind5==2 & hi7==2 
replace redit_wealth_3 = 0.8801 if wlthind5==3 & hi7==2 
replace redit_wealth_3 = 0.9578 if wlthind5==4 & hi7==2 
replace redit_wealth_3 = 0.9872 if wlthind5==5 & hi7==2 

gen redit_wealth_4 = 0.1259 if wlthind5==0 & hi7==3 
replace redit_wealth_4 = 0.4245 if wlthind5==1 & hi7==3 
replace redit_wealth_4 = 0.7014 if wlthind5==2 & hi7==3 
replace redit_wealth_4 = 0.867 if wlthind5==3 & hi7==3 
replace redit_wealth_4 = 0.9484 if wlthind5==4 & hi7==3 
replace redit_wealth_4 = 0.9841 if wlthind5==5 & hi7==3 

gen redit_wealth_5 = 0.1101 if wlthind5==0 & hi7==4 
replace redit_wealth_5 = 0.3751 if wlthind5==1 & hi7==4 
replace redit_wealth_5 = 0.6421 if wlthind5==2 & hi7==4 
replace redit_wealth_5 = 0.8285 if wlthind5==3 & hi7==4 
replace redit_wealth_5 = 0.9292 if wlthind5==4 & hi7==4 
replace redit_wealth_5 = 0.978 if wlthind5==5 & hi7==4 
//////////////////////////SII/////////////////////////////////////////
 
  glm odu_ep0001 redit_wealth_1 if hi7==0, fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_2 if hi7==1 , fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_3 if hi7==2 , fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_4 if hi7==3 , fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_5 if hi7==4 , fam(bin) link(identity) /*SII kinshasa*/

///////////////////////////RII/////////////////////////////////////////////
 
  glm odu_ep0001 redit_wealth_1 if hi7==0, fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_2 if hi7==1 , fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_3 if hi7==2 , fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_4 if hi7==3 , fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_5 if hi7==4 , fam(bin) link(log) nolog eform /*RII*/
 
 *model 1
  glm odu_ep0001 redit_wealth_1 i.age gender i.region_code if hi7==0, fam(bin) link(log) nolog eform /*RII*/
 *model 2
  glm odu_ep0001 redit_wealth_1 i.age gender i.region_code  i.income i.occup if hi7==0, fam(bin) link(log) nolog eform /*RII*/
 *model 3
  glm odu_ep0001 redit_wealth_1 i.age gender i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi if hi7==0, fam(bin) link(log) nolog eform /*RII*/
 
 *model 1
  glm odu_ep0001 redit_wealth_2 i.age gender i.region_code if hi7==1, fam(bin) link(log) nolog eform /*RII*/
 *model 2
  glm odu_ep0001 redit_wealth_2 i.age gender i.region_code  i.income i.occup if hi7==1, fam(bin) link(log) nolog eform /*RII*/
 *model 3
  glm odu_ep0001 redit_wealth_2 i.age gender i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi if hi7==1, fam(bin) link(log) nolog eform /*RII*/
  
  glm odu_ep0001 redit_wealth_2 if hi7==1 , fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_3 if hi7==2 , fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_4 if hi7==3 , fam(bin) link(log) nolog eform /*RII*/
  glm odu_ep0001 redit_wealth_5 if hi7==4 , fam(bin) link(log) nolog eform /*RII*/
by education_3level, sort : stcox i.num i.age gender i.region_code //满足PH假定
by education_3level, sort : stcox i.num i.age gender i.region_code i.income i.occup   //满足PH假定
by education_3level, sort : stcox i.num i.age gender i.region_code i.income i.occup i.smoke i.alcohol  activity i.bmi 

 
 /*//////////////////////////trend/////////////////////////////////////////
 */
 gen redit_wealth_1_LTC = redit_wealth_1 * num
 
  glm odu_ep0001 redit_wealth_1 redit_wealth_1_LTC num if hi7==0, fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_2 if hi7==1 , fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_3 if hi7==2 , fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_4 if hi7==3 , fam(bin) link(identity) /*SII kinshasa*/
  glm odu_ep0001 redit_wealth_5 if hi7==4 , fam(bin) link(identity) /*SII kinshasa*/


  
////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////gender分层///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
use "D:\研究们\共患病\mortality\数据\数据4.28.dta",clear
keep if gender==1  //female
by num , sort: tab highest_education
gen wlthind5= highest_education
gen hi7=num
 drop redit_wealth_1- redit_wealth_5
gen redit_wealth_1 = 0.0953 if wlthind5==0 & hi7==0 
replace redit_wealth_1 = 0.3404 if wlthind5==1 & hi7==0
replace redit_wealth_1 = 0.6384 if wlthind5==2 & hi7==0
replace redit_wealth_1 = 0.8666 if wlthind5==3 & hi7==0
replace redit_wealth_1 = 0.9642 if wlthind5==4 & hi7==0
replace redit_wealth_1 = 0.9909 if wlthind5==5 & hi7==0

gen redit_wealth_2 = 0.1553 if wlthind5==0 & hi7==1 
replace redit_wealth_2 = 0.476 if wlthind5==1 & hi7==1 
replace redit_wealth_2 = 0.7498 if wlthind5==2 & hi7==1 
replace redit_wealth_2 = 0.9129 if wlthind5==3 & hi7==1  
replace redit_wealth_2 = 0.9782 if wlthind5==4 & hi7==1 
replace redit_wealth_2 = 0.9944 if wlthind5==5 & hi7==1 
//
gen redit_wealth_3 = 0.1689 if wlthind5==0 & hi7==2 
replace redit_wealth_3 = 0.5044 if wlthind5==1 & hi7==2 
replace redit_wealth_3 = 0.7663 if wlthind5==2 & hi7==2 
replace redit_wealth_3 = 0.9127 if wlthind5==3 & hi7==2 
replace redit_wealth_3 = 0.9751 if wlthind5==4 & hi7==2 
replace redit_wealth_3 = 0.9931 if wlthind5==5 & hi7==2 

gen redit_wealth_4 = 0.17 if wlthind5==0 & hi7==3 
replace redit_wealth_4 = 0.4983 if wlthind5==1 & hi7==3 
replace redit_wealth_4 = 0.75 if wlthind5==2 & hi7==3 
replace redit_wealth_4 = 0.8983 if wlthind5==3 & hi7==3 
replace redit_wealth_4 = 0.9687 if wlthind5==4 & hi7==3 
replace redit_wealth_4 = 0.9921 if wlthind5==5 & hi7==3 

gen redit_wealth_5 = 0.1463 if wlthind5==0 & hi7==4 
replace redit_wealth_5 = 0.4389 if wlthind5==1 & hi7==4 
replace redit_wealth_5 = 0.6885 if wlthind5==2 & hi7==4 
replace redit_wealth_5 = 0.8622 if wlthind5==3 & hi7==4 
replace redit_wealth_5 = 0.9537 if wlthind5==4 & hi7==4 
replace redit_wealth_5 = 0.9873 if wlthind5==5 & hi7==4 

/////////////////////////////////////////////////////////////
///////////////////male///////////////////////////////////////
gen redit_wealth_1 = 0.034 if wlthind5==0 & hi7==0 
replace redit_wealth_1 = 0.2207 if wlthind5==1 & hi7==0
replace redit_wealth_1 = 0.5525 if wlthind5==2 & hi7==0
replace redit_wealth_1 = 0.8272 if wlthind5==3 & hi7==0
replace redit_wealth_1 = 0.9457 if wlthind5==4 & hi7==0
replace redit_wealth_1 = 0.9842 if wlthind5==5 & hi7==0

gen redit_wealth_2 = 0.0511 if wlthind5==0 & hi7==1 
replace redit_wealth_2 = 0.2778 if wlthind5==1 & hi7==1 
replace redit_wealth_2 = 0.608 if wlthind5==2 & hi7==1 
replace redit_wealth_2 = 0.8448 if wlthind5==3 & hi7==1  
replace redit_wealth_2 = 0.9481 if wlthind5==4 & hi7==1 
replace redit_wealth_2 = 0.9846 if wlthind5==5 & hi7==1 
//
gen redit_wealth_3 = 0.0588 if wlthind5==0 & hi7==2 
replace redit_wealth_3 = 0.3056 if wlthind5==1 & hi7==2 
replace redit_wealth_3 = 0.6277 if wlthind5==2 & hi7==2 
replace redit_wealth_3 = 0.8364 if wlthind5==3 & hi7==2 
replace redit_wealth_3 = 0.9347 if wlthind5==4 & hi7==2 
replace redit_wealth_3 = 0.9792 if wlthind5==5 & hi7==2 

gen redit_wealth_4 = 0.0662 if wlthind5==0 & hi7==3 
replace redit_wealth_4 = 0.3246 if wlthind5==1 & hi7==3 
replace redit_wealth_4 = 0.6356 if wlthind5==2 & hi7==3 
replace redit_wealth_4 = 0.8247 if wlthind5==3 & hi7==3 
replace redit_wealth_4 = 0.9209 if wlthind5==4 & hi7==3 
replace redit_wealth_4 = 0.9733 if wlthind5==5 & hi7==3 

gen redit_wealth_5 = 0.0549 if wlthind5==0 & hi7==4 
replace redit_wealth_5 = 0.2775 if wlthind5==1 & hi7==4 
replace redit_wealth_5 = 0.5713 if wlthind5==2 & hi7==4 
replace redit_wealth_5 = 0.7768 if wlthind5==3 & hi7==4 
replace redit_wealth_5 = 0.8915 if wlthind5==4 & hi7==4 
replace redit_wealth_5 = 0.9633 if wlthind5==5 & hi7==4 
 


  ////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////城乡,SES分层//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
stcox i.num i.age gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest 

bysort region_is_urban: asdoc tab num odu_ep0001 , replace
*1分组尝试：by region, sort : stcox i.num if gender == 2, strata( region_code )
by region_is_urban, sort : stcox i.num   //满足PH假定
by region_is_urban, sort : stcox i.num i.age gender 
by region_is_urban, sort : stcox i.num i.age gender i.education i.income i.occup 
by region_is_urban, sort : stcox i.num i.age gender i.education i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest  //依然不满足PH假定

bysort education: asdoc tab num odu_ep0001 , replace
*2分组尝试：by education, sort : stcox i.num if gender == 2, strata( region_code )
by education, sort : stcox i.num   //满足PH假定
by education, sort : stcox i.num i.age gender i.region_code
by education, sort : stcox i.num i.age gender i.region_code i.income i.occup   //满足PH假定
by education, sort : stcox i.num i.age gender i.region_code i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest 
by education, sort : stcox i.num  if gender==1
*LEL MEL HEL新分层
by education_3level, sort : stcox i.num   //满足PH假定
by education_3level, sort : stcox i.num i.age gender i.region_code //满足PH假定
by education_3level, sort : stcox i.num i.age gender i.region_code i.income i.occup   //满足PH假定
by education_3level, sort : stcox i.num i.age gender i.region_code i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest 


bysort income: asdoc tab num odu_ep0001 , replace
*3分组尝试：by income, sort : stcox i.num if gender == 2, strata( region_code )
by income, sort : stcox i.num   //满足PH假定
by income, sort : stcox i.num i.age gender i.region_code
by income, sort : stcox i.num i.age gender i.region_code i.education i.occup   
by income, sort : stcox i.num i.age gender i.region_code i.education i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest 

bysort age: asdoc tab num odu_ep0001 , replace
*4分组尝试：by age, sort : stcox i.num if gender == 2, strata( region_code )
by age, sort : stcox i.num   //满足PH假定
by age, sort : stcox i.num gender i.region_code
by age, sort : stcox i.num gender i.region_code i.education i.income i.occup   
by age, sort : stcox i.num gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest 


bysort gender: asdoc tab num odu_ep0001 , replace
*5分组尝试：by gender, sort : stcox i.num if gender == 2, strata( region_code )
by gender, sort : stcox i.num   //满足PH假定
by gender, sort : stcox i.num i.age i.region_code
by gender, sort : stcox i.num i.age i.region_code i.education i.income i.occup   
by gender, sort : stcox i.num i.age i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest


*6分组：男女城乡
by region_is_urban, sort : stcox i.num  if gender==1  //满足PH假定
by region_is_urban, sort : stcox i.num i.age  if gender==1
by region_is_urban, sort : stcox i.num i.age i.education i.income i.occup  if gender==1
by region_is_urban, sort : stcox i.num i.age i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if gender==1
estat phtest
by region_is_urban, sort : stcox i.num  if gender==2  //满足PH假定
by region_is_urban, sort : stcox i.num i.age  if gender==2  //满足PH假定
by region_is_urban, sort : stcox i.num i.age i.education i.income i.occup  if gender==2
by region_is_urban, sort : stcox i.num i.age i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  if gender==2
estat phtest

*加入时间*暴露交互项
gen et_year=year*num   //num指共患病的数量：0,1,2,3,>=4
stcox i.num et_year if gender == 2, strata(age region_code )
estat phtest //满足


////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////城乡,SES分层2 table4//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
*education
by num, sort : stcox i.region_is_urban  if gender==1   //满足
bysort num: asdoc tab education odu_ep0001 , replace
* by num, sort : stcox i.education  i.age i.region_code if gender==1   //满足

by num, sort : stcox i.re_education  //满足
by num, sort : stcox i.re_education  i.age gender i.region_code // 0.0182
estat phtest //满足
by num, sort : stcox i.re_education  i.age gender i.region_code  i.income i.occup  //  0.0496
by num, sort : stcox i.re_education  i.age gender i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   //  0.0714
//分性别？
*income
by num, sort : stcox i.income  if gender==1   //满足
bysort num: asdoc tab income odu_ep0001 , replace
by num, sort : stcox i.income    //满足
by num, sort : stcox i.income  i.age gender i.region_code //0.01
by num, sort : stcox i.income  i.age gender i.region_code  i.education i.occup  //0.0496
by num, sort : stcox i.income  i.age gender i.region_code  i.education i.occup i.smoke i.alcohol  activity i.bmi //满足


by num, sort : stcox  gender  i.age i.region_is_urban  i.education i.income i.occup i.smoke i.alcohol  activity i.bmi //满足

//////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////person years//////////////////////////////////////
*time = person day 
use "D:\研究们\共患病\mortality\数据\数据4.28.dta",clear
gen year=time/365

bysort age :tab num odu_ep0001
bysort education :tab num odu_ep0001
bysort income :tab num odu_ep0001

*bysort gender :tab num odu_ep0001
*bysort region_is_urban :tab num odu_ep0001

collapse (sum) year, by (education num    ) 
collapse (sum) year, by (income num ) 
collapse (sum) year, by (gender num ) 
collapse (sum) year, by (region_is_urban num ) 




/*ref似乎不应该用 无共患病病；而是用 no formal school
/////////////////////////figure 1 COX-SES-sex//////////////////////////////////////////
*0-4LTC分层
by education, sort : stcox i.num  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male

by education, sort : stcox i.num  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==1
/////////////SES分层，2分类（有无multimorbidity），2 model
////////education
*model1
by education, sort : stcox i.morbidity  i.age  i.region_code  i.income i.occup     if gender==2   //male
by education, sort : stcox i.morbidity  i.age  i.region_code  i.income i.occup     if gender==1
estat phtest //满足
*model2
by education, sort : stcox i.morbidity  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male
by education, sort : stcox i.morbidity  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==1
estat phtest //满足
////////income
by income, sort : stcox i.morbidity  i.age  i.region_code  i.education i.occup     if gender==2   //male
by income, sort : stcox i.morbidity  i.age  i.region_code  i.education i.occup     if gender==1
estat phtest //满足
*model2
by income, sort : stcox i.morbidity  i.age  i.region_code  i.education i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male
by income, sort : stcox i.morbidity  i.age  i.region_code  i.education i.occup i.smoke i.alcohol  activity i.bmi   if gender==1
estat phtest //满足

/////////////////////////figure 2 COX-SES-rural urban//////////////////////////////////////////
*0-4LTC分层
model 1
by education, sort : stcox i.num  i.age  i.gender  i.income i.occup   if region_is_urban  ==0   //rural
by education, sort : stcox i.num  i.age  i.gender  i.income i.occup   if region_is_urban  ==1    //urban
estat phtest //满足
by income, sort : stcox i.num  i.age  i.gender  i.education i.occup   if region_is_urban  ==0   //rural
by income, sort : stcox i.num  i.age  i.gender  i.education i.occup   if region_is_urban  ==1    //urban
estat phtest //满足

model 2
by education, sort : stcox i.num  i.age  i.gender  i.income i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==0   //rural
by education, sort : stcox i.num  i.age  i.gender  i.income i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==1    //urban

by income, sort : stcox i.num  i.age  i.gender  i.education i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==0   //rural
by income, sort : stcox i.num  i.age  i.gender  i.education i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==1    //urban

/////////////multi& non-multi分层
////////education
*model1
by education, sort : stcox i.morbidity  i.age  i.gender  i.income i.occup     if  region_is_urban  ==0   //rural
by education, sort : stcox i.morbidity  i.age  i.gender  i.income i.occup     if region_is_urban  ==1    //urban
estat phtest //满足
*model2
by education, sort : stcox i.morbidity  i.age  i.gender  i.income i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==0   //rural
by education, sort : stcox i.morbidity  i.age  i.gender  i.income i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==1    //urban
estat phtest //满足
////////income
by income, sort : stcox i.morbidity  i.age  i.gender  i.education i.occup     if region_is_urban  ==0   //rural
by income, sort : stcox i.morbidity  i.age  i.gender  i.education i.occup     if region_is_urban  ==1    //urban
estat phtest //满足
*model2
by income, sort : stcox i.morbidity  i.age  i.gender  i.education i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==0   //rural
by income, sort : stcox i.morbidity  i.age  i.gender  i.education i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==1    //urban
estat phtest //满足

*/
/////////////multi& non-multi分层
////////education；income
*model1
by morbidity, sort : stcox i.education  i.age  i.region_code  i.income i.occup     if gender==2   //male
by morbidity, sort : stcox i.education  i.age  i.region_code  i.income i.occup     if gender==1
estat phtest //不满足
*model2
by morbidity, sort : stcox i.education  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male
by morbidity, sort : stcox i.education  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==1
estat phtest //满足

gen re_education = 5 - education
gen re_income = 5- income
codebook re_education re_income
*model1
by morbidity, sort : stcox i.re_education  i.age  i.region_code  i.re_income i.occup     if gender==2   //male
by morbidity, sort : stcox i.re_education  i.age  i.region_code  i.re_income i.occup     if gender==1
estat phtest //不满足
*model2
by morbidity, sort : stcox i.re_education  i.age  i.region_code  i.re_income i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male
by morbidity, sort : stcox i.re_education  i.age  i.region_code  i.re_income i.occup i.smoke i.alcohol  activity i.bmi   if gender==1
estat phtest //不满足

////////education；income 城乡分层
*model1
by morbidity, sort : stcox i.re_education  i.age  i.gender  i.re_income i.occup     if  region_is_urban  ==0   //rural
by morbidity, sort : stcox i.re_education  i.age  i.gender  i.re_income i.occup     if region_is_urban  ==1    //urban
estat phtest //满足
*model2
by morbidity, sort : stcox i.re_education  i.age  i.gender  i.re_income i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==0   //rural
by morbidity, sort : stcox i.re_education  i.age  i.gender  i.re_income i.occup i.smoke i.alcohol  activity i.bmi   if region_is_urban  ==1    //urban
estat phtest //满足



/////////////multi& non-multi分层  加age  //结果不好解释，无规律
////////education；income
*model2
by education, sort : stcox   i.age  i.gender i.region_code i.income i.occup i.smoke i.alcohol  activity i.bmi   if morbidity  ==0   //rural
by education, sort : stcox   i.age  i.gender i.region_code i.income i.occup i.smoke i.alcohol  activity i.bmi   if morbidity  ==1    //urban
estat phtest //满足


