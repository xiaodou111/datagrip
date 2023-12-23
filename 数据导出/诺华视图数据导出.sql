select *
from V_ACCEPT_NH_P001 where CJSJ>=date'2023-11-01';


select *
from V_ACCEPT_NH_P001_ZJ;


select *
from V_KC_NH_P001;

select *
from V_KC_NH_P001_ZJ;

select *
from V_SALE_NH_P001_1 where  CJSJ>=date'2023-11-01';
select count(*)
from D_NH_BUSSLFP where WAREID=10100473

select min(zdate),max(zdate),count(*)
from D_NH_BUSSLFP
delete from D_NH_BUSSLFP
    select *
from V_SALE_NH_P001_ZJ --where CPDM='10100473';

select *
from  d_nh_ps_py where WAREID ='10100473' and NAME1='Õã½­ÈğÈËÌÃÒ©Òµ²Ö¿â';

select zdate, name1, djlx, wareid, scqy, orgname, rksl, cksl, ph from d_nh_ps_py
group by  zdate, name1, djlx, wareid, scqy, orgname, rksl, cksl, ph having count(*)>1;

select *
from d_nh_cg_py
    where NAME1='Ì¨ÖİÈğÈËÌÃÒ©Òµ²Ö¿â'
    and ZDATE>=date '2023-11-01'

        delete from d_nh_cg_py where NAME1='Ì¨ÖİÈğÈËÌÃÒ©Òµ²Ö¿â'
    and ZDATE>=date '2023-11-01'

120970   25132
119770