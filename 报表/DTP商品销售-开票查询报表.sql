create table d_h2_dtpware
(factory varchar2(100),
wareid number)
drop table d_h2_dtpware
delete from d_h2_dtpware
select * from d_h2_dtpware for update


create table D_DTP_invoice(
saleno varchar2(100),
invoice varchar2(100)
)
drop table D_DTP_invoice

select h.saleno,h.busno,s.orgname,h.accdate,th.USERNAME,th.SEX,
FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), TRUNC(BIRTHDAY)) / 12) as age,
th.phone,th.Idcardno,h.payee,su.username as salername,h.netsum,
 case when zhyb.saleno is null then '·ñ' else 'ÊÇ' end as if_yb,vo.invoice
   from t_sale_h h
--join t_sale_d d on h.saleno=d.saleno
left join s_busi s on h.busno=s.busno
left join d_zhyb_year_2023 zhyb on h.saleno=zhyb.saleno
LEFT JOIN t_remote_prescription_h th ON  substr(h.notes,0,decode(instr(h.notes,' '),0,length(h.notes)+1,instr(h.notes,' '))-1)=th.cfno
left join s_user_base su on su.userid=h.payee
left join D_DTP_invoice vo on vo.saleno=h.saleno
where exists (select 1 from t_sale_d d where h.saleno=d.saleno and d.wareid in (select wareid from d_h2_dtpware) ) 
and h.accdate>=date'2023-11-01'

select * from t_remote_prescription_h 
select trunc(BIRTHDAY,'yyyy') from t_remote_prescription_h
select age from t_remote_prescription_h
select FLOOR(MONTHS_BETWEEN(TRUNC(SYSDATE), TRUNC(BIRTHDAY)) / 12),BIRTHDAY from t_remote_prescription_h 
