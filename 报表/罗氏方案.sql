--d_luoshi_qcsj ������Ҫ������ڳ�����
    --D_LUOSHI_PROG  ���߷�����ʼʱ��ͽ���ʱ��ά��,��Ҫ�Ӹ���ʷ��,ÿ����������Ҫһ����¼,�Ӹ���ʷ���ֹ��ԭ������޸Ĳ����ָ�����
    alter table d_luoshi_qcsj add firsttime date;
--todo �����޸ķ���ʱ��
select BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE, ENDDATE
from D_LUOSHI_PROG;
332623195005301346
 insert into D_LUOSHI_PROG(IDCARDNO,PROGRAMME,BEGINDATE,ENDDATE) values('332623195005301346',1,date'2021-04-01',date'2021-07-25');
 insert into D_LUOSHI_PROG(IDCARDNO,PROGRAMME,BEGINDATE,ENDDATE) values('332623195005301346',3,date'2021-07-25',date'2023-12-31');
 insert into D_LUOSHI_PROG(IDCARDNO,PROGRAMME,BEGINDATE,ENDDATE) values('332623195005301346',5,date'2023-12-31',date'9999-12-31');

select a.busno, s.ORGNAME, a.idcardno, a.username, a.programme, a.wareid, w.WARENAME, a.begindate, a.ENDDATE
from d_luoshi_prog a
         left join s_busi s on a.busno = s.BUSNO
         left join t_ware_base w on a.wareid = w.WAREID
����(�������鵥��)~t1/˫��(�����鵥��)~t2/˫��(�����鵥��)~t3/��������(�������鵥��)~t4/��������(�������鵥��)~t5/����(�����鵥��HSC)~t6/˫��(�������鵥��HSC)~t7/˫��(�����鵥��)~t8/��������(�����鵥��HSC+��������)~t9

     alter table D_LUOSHI_PROG
    add enddate date;
--����ʱ��ָ��ENDDATE�ֶλ�ʹ��Ĭ��ֵ
insert into D_LUOSHI_PROG(BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE)
values (null, 332623195005301346, '��˹', 9, 10502445, DATE'2023-12-31');
ALTER TABLE D_LUOSHI_PROG
    MODIFY (enddate DATE DEFAULT TO_DATE('9999-12-31', 'YYYY-MM-DD'));

-- select h.IDCARDNO,a.busno,cyb.�α���,cyb.��ر�־,h.USERNAME,h.CAGE,h.SEX,d.WAREID,d.WAREQTY,a.ACCDATE
--                     from t_remote_prescription_h h
--                         join t_sale_h a on substr(a.notes, 0,
--                                                   decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
--                                                          instr(a.notes, ' ')) -
--                                                   1) =
--                                            h.CFNO
--                         join t_sale_d d on a.SALENO = d.SALENO
--       left join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
--       where
--           IDCARDNO='332623195005301346' AND
--           a.ACCDATE between date'2023-01-01' and date'2023-09-01' and
-- d.WAREID in (10502445);
--����һ
select * from d_luoshi_jmsf_1 ;
select * from D_LUOSHI_PROG;

--����һ,��

with a as (
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by a.busno,h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (1,4)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10502445)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
union all
--������,��,��
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,a.SALENO,a.BUSNO,h.USERNAME,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (2,3,5)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
),
a1 as(
select
a.SALENO, a.ACCDATE, a.WAREQTY,a.IDCARDNO,a.USERNAME,WAREID,
a.busno,
sum(a.WAREQTY)
    over ( partition by a.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) m������1�����������ۼƹ�ҩ֧��,
Max(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) AS r�������һ�ι�ҩʱ��,
LAG(a.ACCDATE, 1) OVER (PARTITION BY a.IDCARDNO ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��,
min(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) AS ac�����һ�ι�ҩʱ��,
(Max(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) - min(a.ACCDATE) OVER (PARTITION BY a.IDCARDNO ) +
 21) / 21 as N���۹�ҩ֧��,
count(distinct a.SALENO) over ( partition by a.IDCARDNO) as q�����ۼƹ�ҩ����,
row_number() over (partition by a.IDCARDNO order by a.ACCDATE desc) rn
 from a
left join d_patient_files fi on fi.IDCARDNO = a.IDCARDNO
),
add_qc as (
   select a1.busno as busno,a1.IDCARDNO as IDCARDNO,a1.USERNAME as USERNAME,a1.WAREID as WAREID,
    nvl(qc.LBEFORE22,0)+nvl(qc.MSUMSLNOW,0)+nvl(m������1�����������ۼƹ�ҩ֧��,0) as  k���߱����ܹ�ҩ֧��,
       nvl(qc.LBEFORE22,0) as l������1����ǰ�ۼƹ�ҩ����,
       nvl(qc.MSUMSLNOW,0)+nvl(m������1�����������ۼƹ�ҩ֧��,0) as m������1�����������ۼƹ�ҩ֧��,
    N���۹�ҩ֧��,
       nvl(q�����ۼƹ�ҩ����,qc.QSUMCS) as q�����ۼƹ�ҩ����,
       nvl(r�������һ�ι�ҩʱ��,qc.RLASTBUYTIME) as r�������һ�ι�ҩʱ��,
       nvl(s����ǰһ�ι�ҩʱ��,qc.SLAGBUYTIME) as s����ǰһ�ι�ҩʱ��,
       nvl(ac�����һ�ι�ҩʱ��,qc.firsttime) as ac�����һ�ι�ҩʱ��,rn
    from  a1
    left join d_luoshi_qcsj qc on a1.IDCARDNO=qc.IDCARDNO
    where rn=1
    )
select
aa.busno,
tb.CLASSNAME as ҩ������ʡ��,
tb1.CLASSNAME as ҩ�����ڳ���,
       aa.IDCARDNO, aa.USERNAME,
       files.ԭ��ҩ���� as ��ҩ����,
       files.�÷��������鵥���Ƿ�Ϊ����͡,
       files.��������,
       files.�Ƿ������¸�������,
       k���߱����ܹ�ҩ֧��,
       l������1����ǰ�ۼƹ�ҩ����,
       m������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��,
       case when N���۹�ҩ֧�� - m������1�����������ۼƹ�ҩ֧�� >= 1 then '�зǱ��깺�����' else '���ڱ��깺��' end as oʵ��ҩ����ҩ�ڼ����ƫ�����,
       case when m������1�����������ۼƹ�ҩ֧�� - q�����ۼƹ�ҩ���� < 0 then '���º˲����' else '0' end as p���깺������˲�,
       q�����ۼƹ�ҩ����,
       r�������һ�ι�ҩʱ��,
       s����ǰһ�ι�ҩʱ��,
       r�������һ�ι�ҩʱ�� - s����ǰһ�ι�ҩʱ�� as t������ι�ҩ����,
       r�������һ�ι�ҩʱ�� + 21 as u�����´����۹�ҩʱ��,
       case when k���߱����ܹ�ҩ֧�� >= 19 then 'Y' else 'N' end as v�Ʋ��Ƿ�������Ƴ�,
       trunc(sysdate - r�������һ�ι�ҩʱ��) as w���һ�ι�ҩ�����������,
       trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��) as x�����ҩ���״ι�ҩ�ۼ�ʱ��,
       case when q�����ۼƹ�ҩ����<=1 then null else (trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��)) / (q�����ۼƹ�ҩ���� - 1) end as y2022����������ƽ����ҩ����,
       null as ���ʱ��,null as ��÷���,null as ��ñ�ע,
--        hf.sfday as ���ʱ��, hf.sfresult as ��÷���, hf.notes as ��ñ�ע,
       ac�����һ�ι�ҩʱ��,rn
from add_qc aa
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO

;
;
--������,��,��
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (6,7,9)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10601875)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
;




--������
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       SUM(d.WAREQTY) over ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqty,
       COUNT(distinct a.SALENO) over ( partition by h.IDCARDNO) count
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (6,7,9)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO=a.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO);
--������

create or replace procedure proc_luoshi_update
    is
    v_varcahr1 varchar2(100);
    v_varcahr2 varchar2(100);
    v_varcahr3 varchar2(100);
    v_num      number;
    v_num      number;
    v_num      number;
    v_begin    Date;
    v_end      Date;


begin

    DBMS_OUTPUT.PUT_LINE(v_row_count);
exception
    when others then
        RAISE_APPLICATION_ERROR(-20001, '�����Ƹ���(������Դ����)û�����ܵ�Ӱ��');

end ;
insert into D_LUOSHI_PROG
values (81001, '123456789012345678', '����', '����1', 10502445, date'2024-04-01');
select BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE
from D_LUOSHI_PROG;



update D_LUOSHI_PROG
set PROGRAMME='����2',
    BEGINDATE=date'2024-04-15'
where IDCARDNO = '123456789012345678';


select *
from D_LUOSHI_PROG_HISTORY;
CREATE OR REPLACE TRIGGER trg_d_luoshi_prog
    AFTER UPDATE
    ON D_LUOSHI_PROG
    FOR EACH ROW
BEGIN

    INSERT INTO D_LUOSHI_PROG_HISTORY (HISTORY_ID, BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE, ACTION,
                                       ACTION_DATE)
    VALUES (D_LUOSHI_PROG_HISTORY_SEQ.NEXTVAL, :NEW.BUSNO, :NEW.IDCARDNO, :NEW.USERNAME, :NEW.PROGRAMME, :NEW.WAREID,
            :NEW.BEGINDATE, 'UPDATE', SYSDATE);


END;
/



select IDCARDNO, COUNT(*)
FROM (select IDCARDNO, busno, rn, lastbuytime, �α���, ��ر�־, USERNAME, CAGE, SEX
from (select h.IDCARDNO, a.busno, cyb.�α���, cyb.��ر�־, h.USERNAME, h.CAGE, h.SEX,
             ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE desc) rn,
             MAX(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS lastbuytime
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
where

--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308))
where lastbuytime > date'2023-01-01'
  and IDCARDNO is not null)
GROUP BY IDCARDNO;



select h.IDCARDNO, d.WAREID
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
where

--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308)
GROUP BY h.IDCARDNO, d.WAREID
HAVING COUNT(DISTINCT d.WAREID) = 2;



select h.IDCARDNO, a.busno, cyb.�α���, cyb.��ر�־, h.USERNAME, h.CAGE, h.SEX, d.WAREID, d.WAREQTY, a.ACCDATE


from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
where IDCARDNO = '332623195005301346'
  AND
--           a.ACCDATE >= date'2023-01-01' and
    d.WAREID in (10502445, 10601875, 10600308);