
/*
author			:Zou
purpose			:analyse of comorbidity
Date created	:Nov 15, 2019
last mordified	:Apr 13, 2020
*/

clear all

pwd
cd"C:/"

log using "D:\研究们\共患病\commorbidity_analyse.log",replace

use "D:\研究们\共患病\原始数据\mortality\comorbidity_mortality20191212\comorbidity_mortality20191212.dta",clear  //打开数据库
tab region_code
*multimorbidity：

//糖尿病 has_diabetes==1;高血压hypertension==1
gen hypertension = 1 if hypertension_diag==1 | sbp_mean>=140 | dbp_mean>=90
replace hypertension = 0 if hypertension == .
tabulate hypertension
//慢性病数量number16种
gen number = has_diabetes + hypertension + has_copd + chd_diag + stroke_or_tia_diag + rheum_heart_dis_diag + rheum_arthritis_diag +  emph_bronc_diag ///
 + asthma_diag + cirrhosis_hep_diag + peptic_ulcer_diag + gall_diag + kidney_dis_diag +  psych_disorder_diag + neurasthenia_diag +  cancer_diag
//统计共患病的数量
tabulate number 
mean (number)
*删除异常值（1个）
drop if number == 16
tabulate number
//LTC分组
gen num =0 if number ==0
replace num =1 if number ==1
replace num =2 if number ==2
replace num =3 if number ==3
replace num =4 if number >=4
//LTC2分组
gen num2 =0 if number ==0
replace num2 =1 if number ==1 | number ==2 | number ==3
replace num2 =2 if number >=4

//患病 patients = 1  患1种以上疾病
gen patients = 1 if number >=1
replace patients = 0 if number ==0
//共患病morbidity == 1 同时患2种及以上疾病
gen morbidity = 1 if number >=2
replace morbidity = 0 if number==0 | number==1

//癌症位点_字符转数值
destring cancer_site, generate( cancer_type ) force
sum cancer_type
tab cancer_type
gen lung = 1 if cancer_type==0
replace  lung = 0 if cancer_type !=0
gen esophagus = 1 if cancer_type==1
replace  esophagus = 0 if cancer_type !=1
gen stomach = 1 if cancer_type==2
replace  stomach = 0 if cancer_type !=2
gen liver = 1 if cancer_type==3
replace  liver = 0 if cancer_type !=3
gen intestine = 1 if cancer_type==4
replace  intestine = 0 if cancer_type !=4
gen breast = 1 if cancer_type==5
replace  breast = 0 if cancer_type !=5
gen prostate = 1 if cancer_type==6
replace  prostate = 0 if cancer_type !=6
gen cervix = 1 if cancer_type==7
replace  cervix = 0 if cancer_type !=7
gen other = 1 if cancer_type==8
replace  other = 0 if cancer_type !=8

gen cancer_number= lung+ esophagus+ stomach + liver+intestine+breast+prostate+cervix+other
tab cancer_number

*Socio-demographic 
//性别
gen gender = 1 if is_female==1
replace gender = 2 if is_female==0  //male
//年龄分组30-79.98: 30-39;40-49;50-59;60-69;70-80
gen age0 = age_at_study_date_x100 / 100
mean(age0)  //52.0265
codebook  age0
gen age = 1 if age0 < 40  //30-39.999years old
replace age = 2 if age0 < 50 & age0>=40
replace age = 3 if age0 < 60 & age0>=50
replace age = 4 if age0 < 70 & age0>=60
replace age = 5 if age0 <= 80 & age0>=70 //70-80

gen age10 = 1 if age0 < 35  //30-35years old
replace age10 = 2 if age0 < 40 & age0>=35
replace age10 = 3 if age0 < 45 & age0>=40
replace age10 = 4 if age0 < 50 & age0>=45
replace age10 = 5 if age0 < 55  & age0>=50 
replace age10 = 6 if age0 < 60 & age0>=55
replace age10 = 7 if age0 < 65 & age0>=60
replace age10 = 8 if age0 < 70 & age0>=65
replace age10 = 9 if age0 < 75  & age0>=70 
replace age10 = 10 if age0 <= 80  & age0>=75 
codebook age10
*随访时间//time
td=dofc(tc)
gen begindate = dofc(study_date)
format begindate %tdD_m_Y
gen time = odu_ep0001_date- begindate
gen year = time/365
tab time
codebook year
sum year  //mean 9.93; sd 1.82

codebook odu_ep0001_date
codebook time if odu_ep0001==1 & odu_ep0001_date< '31 Dec 08'  //6711


stset time, failure(odu_ep0001==1)   //time 指随访时间，day
 
*SES  均无缺失
//收入分组:0-9999;10000-19999;20000-34999;>=35000    
*不用合并分组的话直接用household_income即可
gen income = 1 if household_income == 0 |household_income == 1 |household_income==2
replace income = 2 if household_income == 3  
replace income = 3 if household_income == 4
replace income = 4 if household_income == 5
//教育分组:No formal school 1;Primary School 2;Middle or high School 3;College and above
gen education = 1 if highest_education ==0
replace education = 2 if highest_education ==1
replace education = 3 if highest_education ==2 |highest_education ==3
replace education = 4 if highest_education ==4 |highest_education ==5
  No formal school
  Primary School
  Middle School
  High School
  Technical school / college
  University
//职业分组:Employed<5;Unemployed;Retired5
gen occup = 1 if occupation <5 
replace occup = 2 if occupation >5 
replace occup = 3 if occupation ==5
//健康保险 has_health_cover
gen insured = 0 if has_health_cover==1
replace insured = 1 if has_health_cover==0

*health indicator
//BMI: bmi_calc
codebook bmi_calc
*删除异常值（2个：缺失）
drop if bmi_calc == .
mean (bmi_calc)  //23.658
gen bmi = 1 if bmi_calc <18.5
replace bmi = 2 if bmi_calc>=18.5 & bmi_calc < 24
replace bmi = 3 if bmi_calc>=24 & bmi_calc < 28
replace bmi = 4 if bmi_calc>=28 & bmi_calc != .

*health behaviors
//smoking_category：  Never smoker 1；Occasional smoker 2；Ex regular smoker 3；Smoker 4
//smoke 不吸烟；戒烟；吸烟
codebook smoking_category
gen smoke = 1 if smoking_category ==1
replace smoke = 2 if smoking_category ==3
replace smoke = 3 if smoking_category ==2 |smoking_category ==4
//Alcohol category：Never regular drinker 1；Ex regular drinker 2；Occasional or seasonal drinker 3；Monthly drinker 4；Reduced intake 5；Weekly 6
*分层： non drinkers; 戒酒；喝酒
codebook alcohol_category
gen alcohol = 0 if alcohol_category ==1 
replace alcohol = 1 if alcohol_category ==2 
replace alcohol = 2 if alcohol_category ==3 |alcohol_category==4 |alcohol_category ==5 |alcohol_category==6
//physical activity：met（MET hours /day）
mean(met)
codebook met
*physical inactivity (<21.08 MET-h/day [median of total physical activity in all participants]),
gen activity = 2 if met <21.08
replace activity  = 1 if  met >= 21.08

///////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////table1////////////////////////////////////////////////////
//p Values were derived from Pearsons c2 test for association between the indicated variable and the number of chronic diseases for categorical variables or one-way ANOVA for continuous variables.
tabulate  num 
tabulate  num gender ,chi2 row
tabulate   num age,chi2 row
tabulate  num education2 ,chi2 row
tabulate   num income,chi2 row
tabulate  num occup ,chi2 row
tabulate  num region_is_urban ,chi2 row

tabulate  num  smoke,chi2 row
tabulate  num  alcohol2,chi2 row
tabulate  num activity ,chi2 row
tabulate   num bmi2,chi2 row
tabulate  num  cardio_number ,chi2 row
tabulate   num cancer_diag,chi2 row

tab  age morbidity,chi2 row

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////table2 ///////////////////////////////////////////////////////////////////
/////////////////////Multimorbidity and all-cause mortality: Cox’s regression analysis//////////////////////
stset time, failure(odu_ep0001==1)   //time 指随访时间，day
 
sts graph,hazard //graph of hazard ratio
sts graph, cumhaz //graph of cumulative hazard ratio
sts graph, survival //KM survival curval  生存曲线

tab num odu_ep0001, row
//Model 3: model 1 plus cigarette smoking, alcohol drinking, physical activity, BMI 
stcox i.num  //num指共患病数量
*xi:stcox i.num 

estat phtest  //p=0.38 不拒绝零假设，符合PH假定
stcox i.age gender i.region_code i.num
estat phtest  // 0.0000

*p for trend
logistic odu_ep0001 num    //0.0000
logistic odu_ep0001 i.age gender i.region_code num  //0.0000

stcox i.num , strata(age10 gender region_code)
estat phtest  // 0.02

stcox i.age gender i.region_code i.education i.income i.occup i.num
estat phtest // 0.0000

stcox i.education i.income i.occup i.num , strata(age10 gender region_code)
estat phtest // 0.0000

stcox i.age gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi i.num
estat phtest // 0.0000
///
stcox  i.education  i.income i.occup i.smoke i.alcohol  activity i.bmi  i.num , strata(age10 gender region_code)
estat phtest // 0.0000
//均不满足PH假定
stphplot, by(num) adjust(age gender region_code)  //画图 ：共线性超级夸张

*分组尝试：
by age, sort : stcox i.num if gender == 2, strata( region_code )
estat phtest  //依然不满足PH假定

*加入时间*暴露交互项
gen et_year=year*num   //num指共患病的数量：0,1,2,3,>=4
stcox i.num et_year if gender == 2, strata(age region_code )
estat phtest //依然不满足
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


//////////////////////////////////////////////////////////////////////
///////////////////////////table2_add////////////////////////////////////////
// 分类cardiometabolic conditions: hypertension, coronary heart disease, atrial fibrillation, diabetes, Rheumatic heart disease and stroke or transient ischaemic attack. 
drop cardio_number non_cardio_number cancer cardio non_cardio 

gen cardio_number = has_diabetes + hypertension + chd_diag + stroke_or_tia_diag + rheum_heart_dis_diag
gen non_cardio_number = has_copd + rheum_arthritis_diag +  emph_bronc_diag  + asthma_diag + cirrhosis_hep_diag + peptic_ulcer_diag + gall_diag + kidney_dis_diag +  psych_disorder_diag + neurasthenia_diag

gen cancer =1 if  cancer_diag==1 & cardio_number == 0 & non_cardio_number==0  //1 or 0
replace cancer =0 if  cancer_diag==0 & cardio_number == 0 & non_cardio_number==0
gen cancer0 =1 if  cancer_diag==1 //1 or 0
replace cancer0 =0 if  cancer_diag==0 
stcox i.cancer0 

//ref为无病，仅心血管cardiovascular：1-4，无其他疾病； 
gen cardio = 0 if cardio_number ==0 & cancer_diag == 0 & non_cardio_number==0
replace cardio = 1 if cardio_number ==1 & cancer_diag == 0 & non_cardio_number==0
replace cardio = 2 if cardio_number ==2 & cancer_diag == 0 & non_cardio_number==0
replace cardio = 3 if cardio_number ==3 & cancer_diag == 0 & non_cardio_number==0
replace cardio = 4 if cardio_number >=4 & cardio_number !=. & cancer_diag == 0 & non_cardio_number==0
gen non_cardio = 0 if non_cardio_number ==0 & cancer_diag == 0 & cardio_number==0
replace non_cardio = 1 if non_cardio_number ==1 & cancer_diag == 0 & cardio_number==0
replace non_cardio = 2 if non_cardio_number ==2 & cancer_diag == 0 & cardio_number==0
replace non_cardio = 3 if non_cardio_number ==3 & cancer_diag == 0 & cardio_number==0
replace non_cardio = 4 if non_cardio_number >=4 & non_cardio_number !=. & cancer_diag == 0 & cardio_number==0


stcox i.cancer 
stcox i.age gender i.region_code i.cancer
stcox i.age gender i.region_code i.education  i.income i.occup i.cancer 
stcox i.age i.gender i.education  i.income i.occup i.smoke i.alcohol  activity i.bmi  i.region_code cancer 
estat phtest

stcox i.cardio  //满足
stcox i.age gender i.region_code i.cardio  //不满足
stcox i.age gender i.region_code i.education  i.income i.occup i.cardio
stcox i.age i.gender i.education  i.income i.occup i.smoke i.alcohol  activity i.bmi  i.region_code i.cardio   //不满足ph

stcox i.non_cardio
stcox i.age gender i.region_code i.non_cardio
stcox i.age gender i.region_code i.education  i.income i.occup i.non_cardio
stcox i.age i.gender i.education  i.income i.occup i.smoke i.alcohol  activity i.bmi  i.region_code i.non_cardio //不满足ph


gen non_cardio_num2= non_cardio_number
replace non_cardio_num2=4 if non_cardio_num2>=4

stcox i.cancer i.cardio_number i.non_cardio_num2
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////table3/////////////////////////////////////////////////////////////////////////
///////////////////////////////////pattern///////////////////////////////////////////////////////////////////////
*pca 主成分分析
global xlist has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension  rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag
//no cancer
global xlist2 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension  rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag 
global ncomp 3
describe $xlist
corr $xlist
//principal component analysis PCA
pca $xlist
//scree plot of the eigenvalues
screeplot
screeplot, yline(1)

*pca 
pca $xlist, mineigen(1) 
pca $xlist, comp($ncomp) blanks(.3)
pca $xlist, comp(6) blanks(.3)
pca $xlist, comp(6)
*rotate
rotate, varimax
rotate, clear 

/*
///////////////////////////////////PCA///////////////////////////////////////////////////////////////////////
use "D:\研究们\共患病\mortality\数据\数据4.28.dta",clear

codebook  has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension  rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag
*pca 主成分分析
global xlist2  has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension  rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag
corr $xlist2
//principal component analysis PCA
pca $xlist2 
//scree plot of the eigenvalues
screeplot, yline(1)  // 6 pattern
pca $xlist2, comp(6)

/////////////////////////////////////factor///////////////////////////////////////////////////////////////
factor  $xlist2
estat kmo   

            0.00 to 0.49    unacceptable
            0.50 to 0.59    miserable
            0.60 to 0.69    mediocre
            0.70 to 0.79    middling
            0.80 to 0.89    meritorious
            0.90 to 1.00    marvelous
screeplot  //6 factor
scoreplot
loadingplot

predict f1 f2 f3 f4 f5 f6
sum f1 f2 f3 f4 f5 f6    //range[-3,5.5]

rotate, varimax   // rotate,  oblimin   结果相同
predict pc1 pc2 pc3 pc4 pc5 pc6
sum pc1 pc2 pc3 pc4 pc5 pc6
rotate,  clear

 rotate,  oblimin(p/2) //结果相同

*选中点，

htopen using PCA_model_2.4,replace

htput <h2> Tab 4 - PCA model in total </h2>
htlog  xi:stcox pc1 pc2 pc3 pc4 pc5 pc6  , nolog
htlog  xi:stcox pc1 pc2 pc3 pc4 pc5 pc6 i.gender i.age  , nolog
htlog  xi:stcox pc1 pc2 pc3 pc4 pc5 pc6 i.gender i.age i.income   i.education i.occup i.region_is_urban  , nolog
htlog  xi:stcox pc1 pc2 pc3 pc4 pc5 pc6 i.gender i.age i.income   i.education i.occup i.region_is_urban i.bmi  i.smoke i.alcohol  activity  , nolog
htclose
 xi:stcox pc1 pc2 pc3 pc4 pc5 pc6 i.gender i.age  , nolog
// f1-f6 insignificant for f4 f5
// pc1-pc6 significant for all
*/
//最后得到6个pattern
gen pattern1 = has_copd + emph_bronc_diag  + asthma_diag 
gen pattern2 = has_diabetes + hypertension + chd_diag + stroke_or_tia_diag
gen pattern3 = cirrhosis_hep_diag + kidney_dis_diag + gall_diag + peptic_ulcer_diag 
gen pattern4 = rheum_arthritis_diag + rheum_heart_dis_diag
gen pattern5 = psych_disorder_diag + neurasthenia_diag 
gen pattern6 = cancer_diag



//对比每一种pattern类型 only， ref:无病
gen p=0 if  pattern1 ==0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace p=1 if  pattern1 !=0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace p=2 if  pattern2 !=0 & pattern1 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace p=3 if  pattern3 !=0 & pattern2 ==0 &  pattern1 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace p=4 if  pattern4 !=0 & pattern2 ==0 &  pattern3 ==0 &  pattern1 ==0 &  pattern5 ==0 &  pattern6 ==0
replace p=5 if  pattern5 !=0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern1 ==0 &  pattern6 ==0
replace p=6 if  pattern6 !=0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern1 ==0

codebook  p
tab p odu_ep0001

stcox i.age gender i.region_code i.p
estat phtest  //all不满足PH假定
stcox i.p 
stcox i.age gender i.region_code i.P
stcox i.age gender i.region_code i.education  i.income i.occup i.P
stcox i.age i.gender i.education  i.income i.occup i.smoke i.alcohol  activity i.bmi  i.region_code i.p
estat phtest


//pattern 组合：3大类：nuit1； nuit2； nuit3
*nuit1：Category为 pattern count = 2
gen nuit1 = 1 if pattern1 !=0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit1 = 2 if pattern1 !=0 &  pattern3 !=0 &  pattern2 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit1 = 3 if pattern1 !=0 &  pattern4 !=0 &  pattern2 ==0 &  pattern3 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit1 = 4 if pattern1 !=0 &  pattern5 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern2 ==0 &  pattern6 ==0
replace nuit1 = 5 if pattern1 !=0 &  pattern6 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern2 ==0

replace nuit1 = 6 if pattern2 !=0 &  pattern3 !=0 &  pattern1 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit1 = 7 if pattern2 !=0 &  pattern4 !=0 &  pattern3 ==0 &  pattern1 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit1 = 8 if pattern2 !=0 &  pattern5 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern1 ==0 &  pattern6 ==0
replace nuit1 = 9 if pattern2 !=0 &  pattern6 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern1 ==0
replace nuit1 = 10 if pattern3 !=0 &  pattern4 !=0 &  pattern1 ==0 &  pattern2 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit1 = 11 if pattern3 !=0 &  pattern5 !=0 &  pattern1 ==0 &  pattern2 ==0 &  pattern4 ==0 &  pattern6 ==0
replace nuit1 = 12 if pattern3 !=0 &  pattern6 !=0 &  pattern1 ==0 &  pattern2 ==0 &  pattern4 ==0 &  pattern5 ==0

replace nuit1 = 13 if pattern4 !=0 &  pattern5 !=0 &  pattern1 ==0 &  pattern2 ==0 &  pattern3 ==0 &  pattern6 ==0
replace nuit1 = 14 if pattern4 !=0 &  pattern6 !=0 &  pattern1 ==0 &  pattern2 ==0 &  pattern3 ==0 &  pattern5 ==0
replace nuit1 = 15 if pattern5 !=0 &  pattern6 !=0 &  pattern1 ==0 &  pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0

*nuit2：Category为 pattern count = 3
gen nuit2 = 1 if pattern1 !=0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit2 = 2 if pattern1 !=0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 ==0
replace nuit2 = 3 if pattern1 !=0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 ==0
replace nuit2 = 4 if pattern1 !=0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 !=0

replace nuit2 = 5 if pattern1 !=0 &  pattern2 ==0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 ==0
replace nuit2 = 6 if pattern1 !=0 &  pattern2 ==0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 ==0
replace nuit2 = 7 if pattern1 !=0 &  pattern2 ==0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 !=0

replace nuit2 = 8 if pattern1 !=0 &  pattern2 ==0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 ==0
replace nuit2 = 9 if pattern1 !=0 &  pattern2 ==0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 !=0
replace nuit2 = 10 if pattern1 !=0 &  pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 !=0

replace nuit2 = 11 if pattern1 ==0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 ==0
replace nuit2 = 12 if pattern1 ==0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 ==0

replace nuit2 = 13 if pattern1 ==0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 !=0
replace nuit2 = 14 if pattern1 ==0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 ==0
replace nuit2 = 15 if pattern1 ==0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 !=0
replace nuit2 = 16 if pattern1 ==0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 !=0

replace nuit2 = 17 if pattern1 ==0 &  pattern2 ==0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 ==0
replace nuit2 = 18 if pattern1 ==0 &  pattern2 ==0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 !=0
replace nuit2 = 19 if pattern1 ==0 &  pattern2 ==0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 !=0
replace nuit2 = 20 if pattern1 ==0 &  pattern2 ==0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 !=0


*nuit3：Category为 pattern count >=4
gen nuit3 = 1 if pattern1 !=0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 ==0
replace nuit3 = 2 if pattern1 !=0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 ==0
replace nuit3 = 3 if pattern1 !=0 &  pattern2 !=0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 !=0
replace nuit3 = 4 if pattern1 !=0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 ==0
replace nuit3 = 5 if pattern1 !=0 &  pattern2 !=0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 !=0
replace nuit3 = 6 if pattern1 !=0 & pattern2 !=0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 !=0

replace nuit3 = 7 if pattern1 !=0 & pattern2 ==0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 ==0
replace nuit3 = 8 if pattern1 !=0 & pattern2 ==0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 !=0
replace nuit3 = 9 if pattern1 !=0 & pattern2 ==0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 !=0
replace nuit3 = 10 if pattern1 !=0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 !=0

replace nuit3 = 11 if pattern1 ==0 & pattern2 !=0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 ==0
replace nuit3 = 12 if pattern1 ==0 & pattern2 !=0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 ==0 &  pattern6 !=0
replace nuit3 = 13 if pattern1 ==0 & pattern2 !=0 &  pattern3 !=0 &  pattern4 ==0 &  pattern5 !=0 &  pattern6 !=0
replace nuit3 = 14 if pattern1 ==0 & pattern2 !=0 &  pattern3 ==0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 !=0
replace nuit3 = 15 if pattern1 ==0 & pattern2 ==0 &  pattern3 !=0 &  pattern4 !=0 &  pattern5 !=0 &  pattern6 !=0

//reference
replace nuit1 = 0 if pattern1 ==0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit2 = 0 if pattern1 ==0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0
replace nuit3 = 0 if pattern1 ==0 & pattern2 ==0 &  pattern3 ==0 &  pattern4 ==0 &  pattern5 ==0 &  pattern6 ==0

codebook  nuit1 nuit2 nuit3
tab nuit1 odu_ep0001  // nuit1=13 only 21obs ,nuit1=14 only 27obs   0
tab nuit2 odu_ep0001
tab nuit3 odu_ep0001
tab nuit2  //nuit2=7/10,15/16,18/20  obs<20(1-17)        73
tab nuit3  //nuit3=5/10 12/14  obs<20(1-17)              36

replace nuit2=. if (nuit2 >=7&nuit2 <=10 ) | (nuit2 >=15 & nuit2 <=16 ) | (nuit2 >=18 & nuit2 <=20 ) 
replace nuit3=. if (nuit3 >=5&nuit3 <=10 ) | (nuit3 >=12 & nuit3 <=14 ) 


by income, sort : stcox i.p if gender==1, strata(age region_code)
by age gender, sort : stcox i.p , strata(region_code)
stcox i.nuit1 , strata(age region_code gender)  //分层和adjusted结果几乎一样，但参考其他，采用adjusted
stcox i.nuit1  i.age  i.gender i.region_code 
stcox i.nuit2  i.age  i.gender i.region_code 
stcox i.nuit3  i.age  i.gender i.region_code 
//////////////////////////////////////Table 4& figure 3//////////////////////////////////////////////////////////
 //     0.000 不满足
stcox  i.nuit1 i.age gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  
stcox  i.nuit2 i.age gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  
stcox  i.nuit3 i.age gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi  

estat phtest
//全部不满足PH假定
*年龄分层
 stcox i.nuit1   i.gender i.region_code if age==1   //  0.0980
stcox i.nuit2   i.gender i.region_code  if age==1    // 0.8989
stcox i.nuit3   i.gender i.region_code  if age==1    // 0.9577
estat phtest
 stcox i.nuit1   i.gender i.region_code if age==2 
stcox i.nuit2   i.gender i.region_code  if age==2   //   0.0928满足
stcox i.nuit3   i.gender i.region_code  if age==2    //0.1284
estat phtest
 stcox i.nuit1   i.gender i.region_code if age==3
stcox i.nuit2   i.gender i.region_code  if age==3   //    0.0849满足
stcox i.nuit3   i.gender i.region_code  if age==3    //  0.1855
estat phtest
 stcox i.nuit1   i.gender i.region_code if age==4
stcox i.nuit2   i.gender i.region_code  if age==4   //     0.0002不满足
stcox i.nuit3   i.gender i.region_code  if age==4   //0.0004不满足
estat phtest
 stcox i.nuit1   i.gender i.region_code if age==5    //    0.0692满足
stcox i.nuit2   i.gender i.region_code  if age==5   //     0.0893满足
stcox i.nuit3   i.gender i.region_code  if age==5   //     0.0182不满足
estat phtest
stphplot, by(nuit1) adjust(age   gender  region_code )     

//////////////////////////////////////apendix figure S2-6//////////////////////////////////////////////////////////
est tab, p(%12.4f)  //先stcox再跑这个语句，显示4位小数
est tab, p(%12.5f)  //先stcox再跑这个语句，显示4位小数
stcox  i.nuit1   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==1  ,  pformat(%3.3f) 
estat phtest   //   0.0370
stcox  i.nuit2   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==1
estat phtest   // 0.3268
stcox  i.nuit3   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==1 
estat phtest  // 0.4691

stcox  i.nuit1  gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==2 
estat phtest  // 0.0000
stcox  i.nuit2   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==2 
estat phtest  //0.0699
stcox  i.nuit3   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==2 
estat phtest  //  0.0156

stcox  i.nuit1   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==3 
estat phtest   //0.000
stcox  i.nuit2   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==3 
estat phtest   //  0.2182
stcox  i.nuit3   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==3 
estat phtest   //  0.2708
  est tab, p(%12.5f) 
stcox  i.nuit1   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==4 
estat phtest  //0.000
stcox  i.nuit2   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==4
estat phtest  //0.001
stcox  i.nuit3   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==4
estat phtest   // 0.0002

stcox  i.nuit1   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==5 
estat phtest   //0.0063
stcox  i.nuit2   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==5 
estat phtest   // 0.0164
stcox  i.nuit3   gender i.region_code i.education i.income i.occup i.smoke i.alcohol  activity i.bmi     if age==5
estat phtest   //  0.0076
  
////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////城乡,SES分层//////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////


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

by education, sort : stcox i.num  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male

by education, sort : stcox i.num  i.age  i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi   if gender==1

bysort income: asdoc tab num odu_ep0001 , replace
*3分组尝试：by income, sort : stcox i.num if gender == 2, strata( region_code )
by income, sort : stcox i.num   //满足PH假定
by income, sort : stcox i.num i.age gender i.region_code
by income, sort : stcox i.num i.age gender i.region_code i.education i.occup   
by income, sort : stcox i.num i.age gender i.region_code i.education i.occup i.smoke i.alcohol  activity i.bmi 
estat phtest 

by income, sort : stcox i.num  i.age  i.region_code  i.education i.occup i.smoke i.alcohol  activity i.bmi   if gender==2   //male

by income, sort : stcox i.num  i.age  i.region_code  i.education i.occup i.smoke i.alcohol  activity i.bmi   if gender==1


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
by num, sort : stcox i.education  i.age i.region_code if gender==1   //满足
by num, sort : stcox i.education  //满足
by num, sort : stcox i.education  i.age gender i.region_code //0.01
by num, sort : stcox i.education  i.age gender i.region_code  i.income i.occup  //0.0496
by num, sort : stcox i.education  i.age gender i.region_code  i.income i.occup i.smoke i.alcohol  activity i.bmi 
*income
by num, sort : stcox i.income  if gender==1   //满足
bysort num: asdoc tab income odu_ep0001 , replace
by num, sort : stcox i.income    //满足
by num, sort : stcox i.income  i.age gender i.region_code //0.01
by num, sort : stcox i.income  i.age gender i.region_code  i.education i.occup  //0.0496
by num, sort : stcox i.income  i.age gender i.region_code  i.education i.occup i.smoke i.alcohol  activity i.bmi //满足


by num, sort : stcox  gender  i.age i.region_is_urban  i.education i.income i.occup i.smoke i.alcohol  activity i.bmi //满足

gen re_education = 4-education
codebook re_education
gen re_income = 4-income
by num, sort : stcox i.re_education   i.re_income  i.age gender i.region_code  i.occup i.smoke i.alcohol  activity i.bmi 

//////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////person years//////////////////////////////////////
*time = person day 
gen year=time/365

bysort  importer: gen s=sum(year) 
bysort cancer : sum year
bysort cardio  : sum year
bysort non_cardio : sum year
bysort num : sum year


bysort age :tab num odu_ep0001
tab num  odu_ep0001
tab cancer  odu_ep0001
tab cardio  odu_ep0001
tab non_cardio  odu_ep0001
collapse (sum) year, by (num ) 
collapse (sum) year, by ( cancer ) 
collapse (sum) year, by ( cardio) 
collapse (sum) year, by ( non_cardio) 

*adjusted age(5组)，sex(1女，2男)
collapse (sum) year, by (num  age) 
bysort age: tab num  odu_ep0001 

collapse (sum) year, by (num ) 


* cancer CMS RD only(4大组) nuit1-3 
tab nuit1  odu_ep0001 
collapse (sum) year, by (nuit1 ) 

tab nuit2  odu_ep0001 
collapse (sum) year, by (nuit2 ) 

tab nuit3  odu_ep0001 
collapse (sum) year, by (nuit3 ) 
tab nuit3  odu_ep0001  if age==2

* 16种疾病(16大组)  
has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag 
gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag 
tab has_diabetes  odu_ep0001 
collapse (sum) year, by (has_diabetes ) 

collapse (sum) year, by (has_copd ) 

collapse (sum) year, by (chd_diag ) 
collapse (sum) year, by (stroke_or_tia_diag ) 

collapse (sum) year, by (hypertension ) 

collapse (sum) year, by (rheum_heart_dis_diag ) 
collapse (sum) year, by (emph_bronc_diag ) 
collapse (sum) year, by (asthma_diag ) 
collapse (sum) year, by (cirrhosis_hep_diag ) 
collapse (sum) year, by (peptic_ulcer_diag ) 

collapse (sum) year, by (gall_diag ) 
collapse (sum) year, by (kidney_dis_diag ) 
collapse (sum) year, by (rheum_arthritis_diag ) 
collapse (sum) year, by (psych_disorder_diag ) 
collapse (sum) year, by (neurasthenia_diag ) 
collapse (sum) year, by (cancer_diag ) 

collapse (sum) year, by (odu_ep0001 ) 

////////////////////////////appendix 5-8//////////////////////////////////////////
bysort age :tab nuit1 odu_ep0001
collapse (sum) year, by (nuit1 age) 
bysort age :tab nuit2 odu_ep0001
collapse (sum) year, by (nuit2 age) 
bysort age :tab nuit3 odu_ep0001
collapse (sum) year, by (nuit3 age) 


save "C:\Users\可爱\Desktop\共患病\mortality\数据4.28.dta",replace
use "C:\Users\可爱\Desktop\共患病\mortality\数据4.28.dta",clear

use "D:\研究们\共患病\mortality\数据\数据4.28.dta",clear



/////////////////////////////////////etable1/////////////////////////////////////////////////////////////////////
/////////////////////Fig. 1 Comorbidity patterns of the included 16 chronic conditions (n = 512712)/////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

 asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if num==1 ,  replace
 asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if num==2 ,  replace
 asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if num==3 ,  replace
 asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if num==4 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag,  replace
tab num
tab morbidity
tab odu_ep0001
//heat map
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if has_diabetes==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if has_copd==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if chd_diag   ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if stroke_or_tia_diag==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if hypertension==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if rheum_heart_dis_diag ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if emph_bronc_diag==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if asthma_diag   ==1 ,  replace


asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if cirrhosis_hep_diag  ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if peptic_ulcer_diag==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if gall_diag  ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if kidney_dis_diag    ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if rheum_arthritis_diag==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if psych_disorder_diag   ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if neurasthenia_diag  ==1 ,  replace
asdoc tab1 has_diabetes has_copd chd_diag stroke_or_tia_diag hypertension rheum_heart_dis_diag emph_bronc_diag asthma_diag cirrhosis_hep_diag peptic_ulcer_diag gall_diag kidney_dis_diag rheum_arthritis_diag psych_disorder_diag neurasthenia_diag cancer_diag if cancer_diag==1 ,  replace




/////////////////////////////////////etable1/////////////////////////////////////////////////////////////////////
/////////////////////Fig. 2 Comorbidity patterns of the included 16 chronic conditions (n = 512712)/////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
*Cells are colour-coded by percent of data redistributed in a given country-year from garbage coding to a likely underlying cause of death. 

stcox hypertension  i.age  i.gender i.region_code 
estat phtest

Hypertension
COPD
Diabetes
CHD
Kidney disorder
Emphysema/bronchitis
Gallstone/gallbladder disease
Rheumatoid arthritis
Stroke
Asthma
Neurasthenia
Cirrhosis/chronic hepatitis
Peptic ulcer
Psychiatric disorders
Cancer
Rheumatic heart disease

//////////////////////////////////////inequality////////////////////////////////
/////////////////////////////////////SII/RII//////////////////////////////////

*redit_wealth
education income
tab education 
tab highest_education
tab income
gen windex5=highest_education
gen redit_wealth = 0.0928 if windex5==0
replace redit_wealth = 0.3467 if windex5==1
replace redit_wealth = 0.5078 if windex5==2
replace redit_wealth = 0.7904 if windex5==3
replace redit_wealth = 0.9416 if windex5==4
replace redit_wealth = 0.9772 if windex5==5

codebook redit_wealth
glm morbidity redit_wealth, fam(bin) link(log) nolog eform /*RII*/
glm morbidity redit_wealth, fam(bin) link(identity) /*SII*/

*CI
conindex stunting, rankvar(wscore) truezero  graph ytitle(Cumulative share of Stunting 2018) xtitle(Rank of wealthindex) svy
conindex stunting_severe, rankvar(wscore) truezero  graph ytitle(Cumulative share of Severe Stunting 2018) xtitle(Rank of wealthindex) svy



********************************************************************************	

** LIFE EXPECTANCY CALCULATIONS **

* Run each programme in separate do files

********************************************************************************	

* With and without multimorbidity *
set more off 
clear
*cd "\\uol.le.ac.uk\root\staff\home\y\yc244\My Documents\1 PhD Folder\7 Data\Data"
use "D:\研究们\共患病\mortality\数据\数据4.28.dta", clear
count

/*随访时间//time
td=dofc(tc)
gen begindate = dofc(study_date)
format begindate %tdD_m_Y
gen time = odu_ep0001_date- begindate
gen year = time/365
sum time 
sum year  //mean 9.93; sd 1.82
*/
stset, clear
stset time, failure(odu_ep0001==1) enter(age0)  //time 指随访时间，day
 
 ssc install stpm2
 ssc install rcsgen
stpm2 morbidity , df(4) scale(hazard) eform nolog   
predict xb, xb
predict s, survival
predict h, hazard
*stcox morbidity  //差别不大
			
// create an empty file to save the yll results - ru altogether 
preserve
clear
tempfile results2
save `results2', emptyok replace
restore
timer clear 1
// create the conditional age and the time variable
foreach i  of num 30(1)100 {
		timer on 1
		preserve
		gen t`i'= `i' in 1/100  
		range tt`i' `i' 100 100
	    predictnl mm`i' = [predict( surv timevar(tt`i') at( morbidity 0) ) / predict( surv timevar(t`i') at(morbidity 0))] ///
				    	- [predict( surv timevar(tt`i') at( morbidity 1) ) / predict( surv timevar(t`i') at(morbidity 1) ) ],  ci(lci`i' uci`i') level(95) 
					
		integ mm`i' tt`i'
	    scalar area_mm`i' = r(integral)
		
		integ lci`i' tt`i'
	    scalar area_lci`i' = r(integral)
		
		integ uci`i' tt`i'
	    scalar area_uci`i' = r(integral)
		
		
		clear
		set obs 1
		gen cond = `i'
		gen erl_mm = area_mm`i'
		gen erl_lci = area_lci`i'
		gen erl_uci = area_uci`i'
		append using `results2'
		save `results2', replace
		restore
		timer off 1
	  } 
timer list 1    
use `results2', clear
sort cond

********************************************************************************


********************************************************************************	
* Example of life expectancy calculation 

set more off 
clear
cd "\\uol.le.ac.uk\root\staff\home\y\yc244\My Documents\1 PhD Folder\7 Data\Data"
use "UKKBB_CMMH_07March2019.dta", clear

stset currentag, failure(dead == 1) enter(age)  

// create an empty file to save the yll results - run
stpm2 i.disease cancer sex	newethnic twn2 i.empcat bmi  sedtime  excess_alcohol i.smoke guideline_fruitveg, df(4) scale(hazard) eform nolog   

preserve
clear
tempfile results1
save `results1', emptyok replace
restore
timer clear 1
// create the conditional age and the time variable
forval d= 0/7 {
foreach i  of num 30(1)100 {
		timer on 1
		preserve
		gen t`i'= `i' in 1/100  
		range tt`i' `i' 100 100
	    predictnl d`i'`d' = predict(meansurv timevar(tt`i') at(disease `d')) / predict(meansurv timevar(t`i') at(disease `d'))  
		integ d`i'`d' tt`i'
	    scalar area_d`i'`d' = r(integral)
		clear
		set obs 1
		gen cond = `i'
		gen erl`d' = area_d`i'`d'
		append using `results1'
		save `results1', replace
		restore
		timer off 1
	  }
	  }
timer list 1    
use `results1', clear
save "yll_lifestyle_March2019.dta", replace

********************************************************************************



