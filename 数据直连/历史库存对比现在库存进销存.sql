--阿斯利康
with hz as 
(select cpdm,ph from  v_LSkc_aslk_p001 group by cpdm,ph
 union select cpdm,ph from  v_kc_aslk_p001 group by cpdm,ph),
LSKC AS (select cpdm,ph,sum(sl) historykcsl from  v_LSkc_aslk_p001 group by cpdm,ph),
kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_aslk_p001 group by cpdm,ph),
CG AS (select cpdm,ph,sum(sl) rksl from  v_accept_aslk_p001 where zdate between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph),
PS AS (select cpdm,ph,sum(sl) cksl from  v_sale_aslk_p001 where zdate between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph)
select hz.CPDM,hz.PH,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) as jxc
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.PH=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.PH=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.PH=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.PH=ps.ph
where nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) <>0
--阿斯利康特药
with hz as 
(select cpdm,ph from  v_lskc_aslk_p001_ty group by cpdm,ph
 union select cpdm,ph from  v_kc_aslk_p001_ty group by cpdm,ph),
LSKC AS (select cpdm,ph,sum(sl) historykcsl from  v_lskc_aslk_p001_ty group by cpdm,ph),
kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_aslk_p001_ty group by cpdm,ph),
CG AS (select cpdm,ph,sum(sl) rksl from  v_accept_aslk_p001_ty where zdate between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph),
PS AS (select cpdm,ph,sum(sl) cksl from  v_sale_aslk_p001_ty where CJSJ between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph)
select hz.CPDM,hz.PH,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) as jxc
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.PH=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.PH=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.PH=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.PH=ps.ph


--默沙东特药
with hz as 
(select cpdm,ph from  v_lskc_msd_ty_p001 group by cpdm,ph
 union select cpdm,ph from  v_kc_msd_ty_p001 group by cpdm,ph),
lskc as
(select cpdm,ph,sum(sl) historykcsl from  v_lskc_msd_ty_p001 group by cpdm,ph),
 kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_msd_ty_p001 group by cpdm,ph),
 cg as (select cpdm,ph,sum(sl) rksl from  V_ACCEPT_MSD_TY_P001 where cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph),
 ps as (select cpdm,ph,sum(sl) cksl from  V_SALE_MSD_TY_P001 where cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph)
select hz.cpdm,hz.ph,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) 
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.ph=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.ph=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.ph=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.ph=ps.ph

--诺华总视图去除普药后的特药进销存
with hz as 
(select cpdm,ph from  v_lskc_nh_p001 where cpdm not in(select wareid from  d_nh_ware_py) group by cpdm,ph
 union select cpdm,ph from  v_kc_nh_p001 where cpdm not in(select wareid from  d_nh_ware_py) group by cpdm,ph),
lskc as
(select cpdm,ph,sum(sl) historykcsl from  v_lskc_nh_p001 where cpdm not in(select wareid from  d_nh_ware_py) group by cpdm,ph),
 kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_nh_p001 where cpdm not in(select wareid from  d_nh_ware_py) group by cpdm,ph),
 cg as (select cpdm,ph,sum(sl) rksl from  v_accept_nh_p001 where cpdm not in(select wareid from  d_nh_ware_py) and cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph),
 ps as (select cpdm,ph,sum(sl) cksl from  v_sale_nh_p001 where cpdm not in(select wareid from  d_nh_ware_py) and cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph)
select hz.cpdm,hz.ph,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) 
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.ph=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.ph=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.ph=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.ph=ps.ph

--辉瑞
with hz as 
(select cpdm,ph from  v_lskc_hr_p001  group by cpdm,ph
 union select cpdm,ph from  v_kc_hr_p001  group by cpdm,ph),
lskc as
(select cpdm,ph,sum(sl) historykcsl from  v_lskc_hr_p001  group by cpdm,ph),
 kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_hr_p001 group by cpdm,ph),
 cg as (select cpdm,ph,sum(sl) rksl from  v_accept_hr_p001 where  cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph),
 ps as (select cpdm,ph,sum(sl) cksl from  v_sale_hr_p001 where cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph)
select hz.cpdm,hz.ph,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) 
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.ph=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.ph=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.ph=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.ph=ps.ph

--南京正大天晴 

with hz as 
(select cpdm,ph from  v_lskc_zdtq_nj_p001  group by cpdm,ph
 union select cpdm,ph from  v_kc_zdtq_nj_p001  group by cpdm,ph),
lskc as
(select cpdm,ph,sum(sl) historykcsl from  v_lskc_zdtq_nj_p001  group by cpdm,ph),
 kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_zdtq_nj_p001 group by cpdm,ph),
 cg as (select MATNR as cpdm,ph,sum(ls) rksl from  v_accept_zdtq_nj_p001 where  ZDATE between date'2023-09-02' and trunc(sysdate)-1
group by  MATNR,ph),
 ps as (select MATNR as cpdm,ph,sum(cksl)-sum(rksl) cksl from  v_sale_zdtq_nj_p001 where ZDATE between date'2023-09-02' and trunc(sysdate)-1
group by  MATNR,ph)
select hz.cpdm,hz.ph,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) 
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.ph=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.ph=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.ph=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.ph=ps.ph
--爱而开

with hz as 
(select cpdm,ph from  v_lskc_aek_p001  group by cpdm,ph
 union select cpdm,ph from  v_kc_aek_p001  group by cpdm,ph),
lskc as
(select cpdm,ph,sum(sl) historykcsl from  v_lskc_aek_p001  group by cpdm,ph),
 kc as ( select cpdm,ph,sum(sl) kcsl from  v_kc_aek_p001 group by cpdm,ph),
 cg as (select cpdm as cpdm,ph,sum(sl) rksl from  v_accept_aek_p001 where  cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph),
 ps as (select cpdm as cpdm,ph,sum(sl) cksl from  v_sale_aek_p001 where cjsj between date'2023-09-02' and trunc(sysdate)-1
group by  cpdm,ph)
select hz.cpdm,hz.ph,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) 
from hz
left join lskc on hz.cpdm=lskc.cpdm and hz.ph=lskc.ph
left join kc on hz.cpdm=kc.cpdm and hz.ph=kc.ph
left join cg on hz.cpdm=cg.cpdm and hz.ph=cg.ph
left join ps on hz.cpdm=ps.cpdm and hz.ph=ps.ph


--拜尔 

select lskc.cpdm,lskc.ph,nvl(lskc.historykcsl,0)as lssl,nvl(kc.kcsl,0) as kcsl,nvl(cg.rksl,0) as cgsl,nvl(ps.cksl,0) as cksl,
nvl(lskc.historykcsl,0)+nvl(cg.rksl,0)-nvl(ps.cksl,0)-nvl(kc.kcsl,0) 
from 
(
select MATNR as cpdm,ZGYSPH as ph,sum(MENGE+ZT_WAREQTY) historykcsl 
from stock_history s where  s.werks IN ( 'D001','D010') AND s.lgort  IN ('P001','P018','P021')
      AND s.matnr in(select wareid from D_BAIER_cgspml) group by MATNR,ZGYSPH 
      ) lskc
left join ( select cpdm,ph,sum(sl) kcsl from  v_kc_baier group by cpdm,ph)kc ON LSKC.cpdm=kc.cpdm and LSKC.ph=kc.ph
left join (select MATNR as cpdm,ph,sum(LS) rksl from  v_accept_baier where zdate between date'2023-09-01' and trunc(sysdate)-1
group by  MATNR,ph)cg on kc.cpdm=cg.cpdm and kc.ph=cg.ph
left join (select MATNR as cpdm,ph,sum(cksl)-sum(rksl) as cksl from  v_sale_baier where zdate between date'2023-09-01' and trunc(sysdate)-1
group by  MATNR,ph)ps on kc.cpdm=ps.cpdm and kc.ph=ps.ph



   


v_accept_nh_p001
v_kc_nh_p001
v_sale_nh_p001
select count(*)  from stock
select * from stock_history
delete from stock_history
select count(*) from stock_history

select max(zdate) from stock_history


