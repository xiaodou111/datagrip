-- 查找收银员日结对账单和银行流水中付款方式匹配的数据
with confirm as (select h.CHECKNO, h.BUSNO, trunc(createdate) as ACCDATE, d.AMT_CONFIRM as AMT_CONFIRM, d.PAYTYPE
                 from t_payee_check_h h
                          join t_payee_check_d d on h.CHECKNO = d.CHECKNO
                 where d.AMT_CONFIRM <> 0
--      and h.COMPID=1040
                   and h.STATUS <> 2
--                    and h.BUSNO = 81097
                   and trunc(createdate) between date'2024-01-01' and date'2024-04-30'),--6818
     md_bank as (select USE_BUSNO as busno, trunc(USEDATE) as USEDATE, sum(BUSNO_PAYAMT) as BUSNO_PAYAMT,
                        PAYMENT_METHOD as PAYTYPE
                 from t_busno_bank_paydetails
                 where USEDATE between date'2024-01-01' and date'2024-04-30'
--       and  COMPID=1040
--                    and USE_BUSNO = 81097
                 group by USE_BUSNO, PAYMENT_METHOD, trunc(USEDATE)),--7298
     ina as (
-- 查找confirm中有但md_bank中没有匹配的数据
         SELECT a.*
         FROM confirm a
                  LEFT JOIN md_bank b
                            ON a.BUSNO = b.BUSNO AND a.PAYTYPE = b.PAYTYPE AND a.ACCDATE = b.USEDATE
         WHERE b.BUSNO IS NULL OR b.PAYTYPE IS NULL OR b.USEDATE IS NULL),
     inb as (
         -- 查找md_bank中有但confirm中没有匹配的数据
         SELECT b.*
         FROM md_bank b
                  LEFT JOIN confirm a
                            ON a.BUSNO = b.BUSNO AND a.PAYTYPE = b.PAYTYPE AND a.ACCDATE = b.USEDATE
         WHERE a.BUSNO IS NULL OR a.PAYTYPE IS NULL OR a.ACCDATE IS NULL)
-- select max(accdate) from confirm;
select qq.*, li.DDDWLISTDISPLAY
from inb qq
         left join s_dddw_list li on qq.PAYTYPE = li.DDDWLISTDATA and li.dddwliststatus = 1 and li.dddwname = '222';



select h.BUSNO, trunc(createdate) as ACCDATE, sum(d.AMT_CONFIRM) as AMT_CONFIRM, d.PAYTYPE
from t_payee_check_h h
         join t_payee_check_d d on h.CHECKNO = d.CHECKNO
where d.AMT_CONFIRM <> 0 and
--       h.COMPID=1040
    h.STATUS <> 2
  and h.BUSNO = 81097
  and createdate >= to_date('2024-01-01', 'yyyy-MM-dd') and createdate < to_date('2024-01-31', 'yyyy-MM-dd')
group by h.BUSNO, trunc(createdate), d.PAYTYPE;

select USE_BUSNO, trunc(USEDATE) as USEDATE, BUSNO_PAYAMT as BUSNO_PAYAMT, PAYMENT_METHOD as PAYTYPE
from t_busno_bank_paydetails a
left join s_busi sb
                   on a.busno = sb.busno
--     where COMPID=1040
where a.usedate >= to_date('2024-01-01', 'yyyy-MM-dd') and
                                         a.usedate < to_date('2024-01-02', 'yyyy-MM-dd')
  and a.USE_BUSNO = 81097
;


SELECT a.seq_id, a.compid, a.busno, sb.orgname, a.payment_method, a.paydate, a.consult,trunc(USEDATE)as usedate,
       a.busno_payamt, a.lastmodify, a.lasttime, a.temp_seq_id,
       a.mdm_busno, a.HDEE_NOTES, a.DR_NOTES, a.USE_BUSNO, a.is_jr
FROM t_busno_bank_paydetails a
         left join s_busi sb
                   on a.busno = sb.busno
WHERE (1000 = 0 or a.compid = 1000) and (a.use_busno = 81097 and a.usedate >= to_date('2024-01-01', 'yyyy-MM-dd') and
                                         a.usedate < to_date('2024-01-02', 'yyyy-MM-dd'))
  AND EXISTS (SELECT 1 FROM S_USER WHERE S_USER.STATUS = 1 AND S_USER.USERID = 50002418 AND S_USER.COMPID = a.compid)

