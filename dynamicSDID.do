*====================================================================
****《动态合成DID——理论与房产税的经验证据》，工作论文，2022-5
****作者：许文立
****单位：安徽大学经济学院
****版本：Stata 17
****房产税数据来源：刘友金,曾小明.房产税对产业转移的影响:来自重庆和上海的经验证据[J].中国工业经济,2018(11):98-116.
*====================================================================

clear
use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/DSGE建模及软件编程/教学大纲与讲稿/应用计量经济学讲稿/应用计量经济学讲稿与code/data/synthetic control method/SC：2018房产税与产业转移-中国工业经济/数据.dta",replace
//生成工业相对产值变量
bysort 年份: egen 工业产值均值= mean(工业总产值万元)
gen 工业相对产值= 工业总产值万元/ 工业产值均值
//生成工业相对就业率变量
bysort 年份: egen 工业年平均从业人员数均值= mean(工业年平均从业人员数)
gen 工业相对就业率= 工业年平均从业人员数万人/工业年平均从业人员数均值
//生成第三产业相对就业率变量
bysort 年份: egen 第三产业从业人员数均值= mean(第三产业从业人员数万人)
gen 第三产业相对就业率= 第三产业从业人员数万人/第三产业从业人员数均值
//生成第三产业相对产值变量
bysort 年份: egen 第三产业产值均值= mean(第三产业增加值亿元)
gen 第三产业相对产值=第三产业增加值亿元/第三产业产值均值
//生成相对工资变量
bysort 年份: egen 职工平均工资均值= mean(职工平均工资元)
gen 相对工资= 职工平均工资元/职工平均工资均值
//生成相对房价变量
bysort 年份: egen 房价均值= mean(房价元平方米)
gen 相对房价= 房价元平方米/房价均值
gen ln人均GDP=log(人均GDP元)
gen ln人口密度人平方公里=log(人口密度人平方公里)
gen ln年末金融机构存款余额万元=log(年末金融机构存款余额万元)
gen ln医院卫生院床位数张=log(医院卫生院床位数张)
gen ln国际互联网用户数户=log(国际互联网用户数户)
gen 上海工业相对产值=工业相对产值 if 序号==35
gen 重庆工业相对产值=工业相对产值 if 序号==26
gen 上海第三产业相对产值=第三产业相对产值 if 序号==35
gen 重庆第三产业相对产值=第三产业相对产值 if 序号==26
cap drop id t D
gen id=0
replace id=1 if 序号==35 | 序号==26
gen t=0
replace t=1 if 年份>=2011
gen D=id*t

tab 年份, gen(年份)
tsset 序号 年份
****
* allsynth depvar predictorvars , trunit(#) trperiod(#) [ counit(numlist) xperiod(numlist) mspeperiod() resultsperiod() nested allopt unitnames(varname) figure keep(file) bcorrect(string) gapfigure(string) pvalues placeboskeep customV(numlist) optsettings ]

/*
// 传统合成控制估计量——重庆
preserve
drop if 城市=="上海"
synth 工业相对产值 工业相对产值(2006(1)2010) 相对工资 ln人均GDP 财政支出占GDP比重 ln人口密度人平方公里  ln年末金融机构存款余额万元 ln医院卫生院床位数张 ln国际互联网用户数户  工业相对产值(2006) 工业相对产值(2008) 工业相对产值(2010), trunit(26) trperiod(2011) nested fig
restore

allsynth 工业相对产值 工业相对产值(2006(1)2010) 相对工资 ln人均GDP 财政支出占GDP比重 ln人口密度人平方公里  ln年末金融机构存款余额万元 ln医院卫生院床位数张 ln国际互联网用户数户  工业相对产值(2006) 工业相对产值(2008) 工业相对产值(2010), trunit(26) trperiod(2011) nested fig

allsynth 工业相对产值 工业相对产值(2006(1)2010) 相对工资 ln人均GDP 财政支出占GDP比重 ln人口密度人平方公里  ln年末金融机构存款余额万元 ln医院卫生院床位数张 ln国际互联网用户数户  工业相对产值(2006) 工业相对产值(2008) 工业相对产值(2010), trunit(26) trperiod(2011) fig bcor(replace figure) gapfig(bcorrect placebos lineback) pval plac keep(smokingresults) rep
*/

* 表2的结果

sdid 工业相对产值 序号 年份 D,vce(placebo) seed(1213) graph g1_opt(xtitle("") scheme(s1mono)) g2_opt(ylabel(0.5(0.5)3.5) scheme(s1mono))

sdid 工业相对就业率 序号 年份 D,vce(placebo) seed(1213)

sdid 第三产业相对产值 序号 年份 D,vce(placebo) seed(1213)

sdid 第三产业相对就业率 序号 年份 D,vce(placebo) seed(1213)

preserve
drop if 城市=="上海"

sdid 工业相对产值 序号 年份 D,vce(placebo) seed(1213)

sdid 工业相对就业率 序号 年份 D,vce(placebo) seed(1213)

sdid 第三产业相对产值 序号 年份 D,vce(placebo) seed(1213)

sdid 第三产业相对就业率 序号 年份 D,vce(placebo) seed(1213)

preserve
drop if 城市=="重庆市"

sdid 工业相对产值 序号 年份 D,vce(placebo) seed(1213)

sdid 工业相对就业率 序号 年份 D,vce(placebo) seed(1213)

sdid 第三产业相对产值 序号 年份 D,vce(placebo) seed(1213)

sdid 第三产业相对就业率 序号 年份 D,vce(placebo) seed(1213)

//双重差分法
***房产税对上海相对工业产值的影响
gen treated=0 
replace treated=1 if 序号==35

replace t=1 if 年份>=2011
gen gd=t*treated
preserve
keep if 序号==1 | 序号==11 | 序号==12 | 序号==22 | 序号==23 | 序号==35
reghdfe 工业相对产值 gd,a(序号 年份)

reghdfe 工业相对就业率 gd,a(序号 年份)

reghdfe 第三产业相对产值 gd,a(序号 年份)

reghdfe 第三产业相对就业率 gd,a(序号 年份)

* 图2的结果
sdid 工业相对产值 序号 年份 D,method(sdid) vce(noinference) graph g1_opt(xtitle("") scheme(s1mono)) g1on g2_opt(ylabel(0.5(0.5)3.5) ytitle("工业相对产值") scheme(s1mono))

graph rename g1_2011 sdid_weights2011,replace
graph rename g2_2011 sdid_trends2011,replace

graph save "sdid_weights2011" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sdid_weights2011.gph",replace

graph save "sdid_trends2011" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sdid_trends2011.gph",replace

sdid 工业相对产值 序号 年份 D,method(did) vce(noinference) graph msize(small) g1_opt(xtitle("") scheme(s1mono)) g1on g2_opt(ylabel(0.5(0.5)3.5) ytitle("工业相对产值") scheme(s1mono))

graph rename g1_2011 did_weights2011,replace
graph rename g2_2011 did_trends2011,replace

graph save "did_weights2011" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/did_weights2011.gph",replace
graph save "did_trends2011" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/did_trends2011.gph",replace

sdid 工业相对产值 序号 年份 D,method(did) vce(noinference) graph g1_opt(xtitle("") scheme(s1mono)) g1on g2_opt(ylabel(0.5(0.5)3.5) ytitle("工业相对产值") scheme(s1mono))

graph rename g1_2011 sc_weights2011,replace
graph rename g2_2011 sc_trends2011,replace

graph save "sc_weights2011" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sc_weights2011.gph",replace
graph save "sc_trends2011" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sc_trends2011.gph",replace

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sdid_weights2011.gph"
graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sdid_trends2011.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/did_weights2011.gph"
graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/did_trends2011.gph"

graph use  "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sc_weights2011.gph"
graph use  "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架 with 孙磊/sc_trends2011.gph"


graph combine sdid_trends2011.gph did_trends2011.gph sc_trends2011.gph sdid_weights2011.gph did_weights2011.gph sc_weights2011.gph,scheme(s1mono)


* 图3的结果

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
    sdid 工业相对产值 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("工业相对产值") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.25)0.5) scheme(s1mono);
	 graph rename industry
#delimit cr

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
    sdid 工业相对就业率 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("工业相对就业率") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.25)1.5) scheme(s1mono);
	 graph rename industry_labor1
#delimit cr

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
    sdid 第三产业相对产值 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("第三产业相对产值") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.25)0.5) scheme(s1mono);
	 graph rename servce
#delimit cr

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
    sdid 第三产业相对就业率 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("第三产业相对就业率") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.25)0.5) scheme(s1mono);
	 graph rename servce_labor
#delimit cr

graph combine industry.gph industry_labor1.gph servce.gph servce_labor.gph,scheme(s1mono)

*preserve
*drop if 城市=="上海"

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
drop if 城市=="上海"
    sdid 工业相对产值 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("工业相对产值") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.25)0.5) scheme(s1mono);
#delimit cr

graph rename industry_cq,replace
	 graph save "industry_cq" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_cq.gph",replace



matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
	drop if 城市=="上海"
    sdid 工业相对就业率 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("工业相对就业率") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.5)3) scheme(s1mono);
#delimit cr

graph rename industry_labor_cq,replace
	 graph save "industry_labor_cq" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_labor_cq.gph",replace

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
	drop if 城市=="上海"
    sdid 第三产业相对产值 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("第三产业相对产值") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.25(0.25)0.75) scheme(s1mono);
#delimit cr

graph rename servce_cq,replace
	 graph save "servce_cq" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/servce_cq.gph",replace

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
	drop if 城市=="上海"
    sdid 第三产业相对就业率 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("第三产业相对就业率") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.5)3.5) scheme(s1mono);
#delimit cr

graph rename servce_labor_cq,replace
	 graph save "servce_labor_cq" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/servce_labor_cq.gph",replace



graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_cq.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_labor_cq.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/servce_cq.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_labor_cq.gph"

graph combine industry_cq.gph industry_labor_cq.gph servce_cq.gph servce_labor_cq.gph,scheme(s1mono)


* 图4的结果

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
drop if 城市=="重庆市"
    sdid 工业相对产值 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("工业相对产值") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.25)0.5) scheme(s1mono);
#delimit cr

graph rename industry_sh,replace
	 graph save "industry_sh" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_sh.gph",replace



matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
	drop if 城市=="重庆市"
    sdid 工业相对就业率 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("工业相对就业率") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.5)3) scheme(s1mono);
#delimit cr

graph rename industry_labor_sh,replace
	 graph save "industry_labor_sh" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_labor_sh.gph",replace

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
	drop if 城市=="重庆市"
    sdid 第三产业相对产值 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("第三产业相对产值") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.25(0.25)0.75) scheme(s1mono);
#delimit cr

graph rename servce_sh,replace
	 graph save "servce_sh" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/servce_sh.gph",replace

matrix tau_ptax=J(5,3,.) //create an matrix to hold the results

local j=1
forval t=2011(1)2015 {
	drop if 城市=="重庆市"
    sdid 第三产业相对就业率 序号 年份 D if 年份<=2010 | 年份==`t', vce(placebo) seed(1213) reps(100)
    
    *save tau and lower and upper bound
    local tau=e(tau)[1,1]
    local se=e(se)
    local lci=`tau'+invnormal(0.05)*`se'
    local uci=`tau'+invnormal(0.95)*`se'
    matrix tau_ptax[`j',1]=`tau'
    matrix tau_ptax[`j',2]=`lci'
    matrix tau_ptax[`j',3]=`uci'
    local ++j
}

matlist tau_ptax
matrix coln tau_ptax=tau lower upper
clear
svmat tau_ptax, n(col)
gen year=_n+2010 //define the time variable for the graph

#delimit ;
tw line tau year, || rcap lower upper year || scatter tau year, mc(black) ||
   , yline(0,lc(balck%50) lp(dash)) legend(off) ytitle("第三产业相对就业率") 
     xtitle("年份") xlabel(2011(1)2015) ylabel(-0.5(0.5)3.5) scheme(s1mono);
#delimit cr

graph rename servce_labor_sh,replace
	 graph save "servce_labor_sh" "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/servce_labor_sh.gph",replace



graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_sh.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_labor_sh.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/servce_sh.gph"

graph use "/Users/xuwenli/Library/CloudStorage/OneDrive-个人/0paper/155 合成DID的备择推断框架/industry_labor_sh.gph"

graph combine industry_sh.gph industry_labor_sh.gph servce_sh.gph servce_labor_sh.gph,scheme(s1mono)



