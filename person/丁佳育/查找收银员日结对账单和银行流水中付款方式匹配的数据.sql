-- 查找收银员日结对账单和银行流水中付款方式匹配的数据
with confirm as (
select h.CHECKNO,h.BUSNO,trunc(createdate) as ACCDATE ,d.AMT_CONFIRM as AMT_CONFIRM,d.PAYTYPE from t_payee_check_h h join t_payee_check_d d on h.CHECKNO=d.CHECKNO
where d.AMT_CONFIRM<>0 and
      h.COMPID=1040
      and h.STATUS<>2
--       and h.BUSNO=84045
and  createdate >= to_date('2024-04-01', 'yyyy-MM-dd') and createdate < to_date('2024-05-01', 'yyyy-MM-dd')
  ),--6818
md_bank as (
    select BUSNO,trunc(USEDATE) as USEDATE,sum(BUSNO_PAYAMT) as BUSNO_PAYAMT,PAYMENT_METHOD as PAYTYPE  from t_busno_bank_paydetails
    where COMPID=1040 and USEDATE between date'2024-04-01' and date'2024-04-30'
--     and BUSNO=84045
    group by BUSNO,PAYMENT_METHOD,trunc(USEDATE)
),--7298
    ina as (
-- 查找confirm中有但md_bank中没有匹配的数据
SELECT a.*
FROM confirm a
LEFT JOIN md_bank b
ON a.BUSNO = b.BUSNO AND a.PAYTYPE = b.PAYTYPE AND a.ACCDATE = b.USEDATE
WHERE b.BUSNO IS NULL OR b.PAYTYPE IS NULL OR b.USEDATE IS NULL
), inb as (
    -- 查找md_bank中有但confirm中没有匹配的数据
SELECT b.*
FROM md_bank b
LEFT JOIN confirm a
ON a.BUSNO = b.BUSNO AND a.PAYTYPE = b.PAYTYPE AND a.ACCDATE = b.USEDATE
WHERE a.BUSNO IS NULL  OR a.PAYTYPE IS NULL OR a.ACCDATE IS NULL
)
-- select max(accdate) from confirm;
select qq.*,li.DDDWLISTDISPLAY from inb qq
left join s_dddw_list li on qq.PAYTYPE=li.DDDWLISTDATA and li.dddwliststatus = 1 and li.dddwname = '222';







  select sum(BUSNO_PAYAMT) as BUSNO_PAYAMT,trunc(USEDATE)  from t_busno_bank_paydetails
    where COMPID=1040 and USEDATE between date'2024-04-01' and date'2024-04-30' group by trunc(USEDATE);   --6128500.24

    with a as (
    select sum(d.AMT_CONFIRM) as AMT_CONFIRM,trunc(createdate) as createdate,PAYTYPE,h.BUSNO from t_payee_check_h h join t_payee_check_d d on h.CHECKNO=d.CHECKNO
where d.AMT_CONFIRM<>0 and
      h.COMPID=1040
      and h.STATUS<>2
  and h.BUSNO=84045
and  createdate >= to_date('2024-04-01', 'yyyy-MM-dd') and createdate < to_date('2024-05-01', 'yyyy-MM-dd') group by trunc(createdate),PAYTYPE,h.BUSNO),
        b as (

      select sum(BUSNO_PAYAMT) as BUSNO_PAYAMT,trunc(USEDATE) as USEDATE,PAYMENT_METHOD ,BUSNO from t_busno_bank_paydetails
    where COMPID=1040 and BUSNO=84045 and USEDATE between date'2024-04-01' and date'2024-04-30' group by trunc(USEDATE),PAYMENT_METHOD,busno)
    select * from a left join b ON a.BUSNO = b.BUSNO AND a.PAYTYPE = b.PAYMENT_METHOD AND a.createdate = b.USEDATE
    WHERE b.BUSNO IS NULL OR b.PAYMENT_METHOD IS NULL OR b.USEDATE IS NULL
    ;
    ;
