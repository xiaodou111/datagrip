declare
  v_qh1 t_cash_coupon_info.coupon_no%type;
 v_cnt integer ;
   v_begin date;
  v_end date;
    v_mobile t_memcard_reg.mobile%type;
--v_MEMBERCARDNO VARCHAR2(30);
i integer;


begin
  
for res in (
select membercardno,  sum(sl) sl from (
select saleno,membercardno,sum(sl) sl from (

select h.saleno,h.membercardno,h.accdate,d.sl as wareqty,d.wareid,case when d.wareid=30968118 then floor(d.sl/6)
when d.wareid in(30968098,30966767) then floor(d.sl/4) end as sl   
from 
(select d.saleno,sum(d.wareqty) as sl,d.wareid
from t_sale_d d
 where d.wareid in (30968118,30968098,30966767) 
and d.accdate between date'2023-09-20' and date'2023-10-05'
and d.saleno not in(select RETSALENO from  t_sale_return_h where CHECKDATE between date'2023-09-20' and date'2023-10-05' )
and d.saleno not in (select SALENO from  t_sale_return_h where CHECKDATE between date'2023-09-20' and date'2023-10-05' )
group by d.saleno,d.wareid)
 d 
join t_sale_h h on h.saleno=d.saleno
where h.saleno not in (select saleno  from t_internal_sale_h   where shiftdate between date'2023-09-20' and date'2023-10-05') 
) a

where sl>0
 group by saleno,membercardno )
 where membercardno is not null
 group by membercardno
) loop 


 /*SELECT COUNT(*)
  into v_cnt
  FROM T_CASH_COUPON_INFO
  WHERE card_no=v_MEMBERCARDNO;*/
i:=1;


WHILE i<=res.sl LOOP
   SELECT seq_memcard_ymh_cashno.nextval
    into  v_qh1
     FROM  dual ;   ---6yuan
     v_begin:=trunc(sysdate) ;
     v_end:=trunc(sysdate)+10;
     SELECT nvl(mobile ,tel)
     into v_mobile
     FROM t_memcard_reg
     WHERE memcardno=res.membercardno ;

INSERT INTO T_CASH_COUPON_INFO
        (COUPON_NO,ISSUING_DATE,COMPID,BUSNOS,COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,
         CARD_NO, MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,CREATEUSER,CREATETIME,COUPON_KIND,
         ADVANCE_PAYAMT, --预约金
         CREATE_BUSNO,
         CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
         BAK4, BAK6,BAK7,BAK9 --券类型1折扣、2满减、3礼品券
         )
        SELECT v_qh1,SYSDATE,0,BUSNOS,COUPON_VALUES,LEAST_SALES,
             COUPON_TYPE,COUPON_TYPE_DESC,res.membercardno,v_mobile,
       v_begin as  starttime,
       v_end as  endtime, 0,1,'礼品券31004041','168',SYSDATE,
             COUPON_KIND,0,null,2,CLASSCODES,null,COUPON_TYPE_DESC,1
       FROM T_CASH_COUPON_TYPE    WHERE COUPON_TYPE='礼品券31004041' ;
       i:=i+1;
       end loop;
 
end loop;

end ;

/*select * from T_CASH_COUPON_INFO where CARD_NO in (

select membercardno  from (
select saleno,membercardno,sum(sl) sl from (

select h.saleno,h.membercardno,h.accdate,d.sl as wareqty,d.wareid,case when d.wareid=30968118 then floor(d.sl/6)
when d.wareid in(30968098,30966767) then floor(d.sl/4) end as sl   
from 
(select d.saleno,sum(d.wareqty) as sl,d.wareid
from t_sale_d d
 where d.wareid in (30968118,30968098,30966767) 
and d.accdate between date'2023-09-20' and date'2023-10-05'
and d.saleno not in(select RETSALENO from  t_sale_return_h where CHECKDATE between date'2023-09-20' and date'2023-10-05' )
and d.saleno not in (select SALENO from  t_sale_return_h where CHECKDATE between date'2023-09-20' and date'2023-10-05' )
group by d.saleno,d.wareid)
 d 
join t_sale_h h on h.saleno=d.saleno
where h.saleno not in (select saleno  from t_internal_sale_h   where shiftdate between date'2023-09-20' and date'2023-10-05') 
) a

where sl>0
 group by saleno,membercardno )
 where membercardno is not null
 group by membercardno )
 and START_DATE=date'2023-10-10'
 and COUPON_TYPE='礼品券31004041'*/
