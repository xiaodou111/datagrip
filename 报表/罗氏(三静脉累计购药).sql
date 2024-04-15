
--ÿ���˵�һ�ι���Ƥ�µ�ʱ��(������10601875������תƤ��,����ֻͳ��תƤ��֮ǰ������)
create or replace  view v_luoshi_jmsf as
with px_date as (select *
                 from (select d.WAREID, h.IDCARDNO, a.ACCDATE,
                              row_number() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
                       from t_remote_prescription_h h
                                join t_sale_h a on substr(a.notes, 0,
                                                          decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                                 instr(a.notes, ' ')) - 1) =
                                                   h.CFNO
                                join t_sale_d d on a.SALENO = d.SALENO
                       where d.WAREID in (10601875) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                         and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                         and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h))
                 where rn = 1),
--��תƤ�µ�Ŀ¼�е����֤,ͳ��תƤ��ǰ�Ĺ���10600308������
   in_px as (
       select
a.SALENO, a.ACCDATE, d.WAREQTY,
h.busno, s.ORGNAME, tb.CLASSNAME as ҩ������ʡ��, tb1.CLASSNAME as ҩ�����ڳ���, d.WAREID, w.WARENAME, h.IDCARDNO,
h.USERNAME,
-- null as ��ҩ����, null as �÷��������鵥���Ƿ�Ϊ����͡, null as ��������, null as �Ƿ������¸�������,
-- null as k���߱����ܹ�ҩ֧��,
-- null as l������1����ǰ�ۼƹ�ҩ����,
sum(d.WAREQTY)
    over ( partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) m������1�����������ۼƹ�ҩ֧��,
Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS r�������һ�ι�ҩʱ��,
LAG(a.ACCDATE, 1) OVER (PARTITION BY h.IDCARDNO,d.WAREID ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��,
min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS ac�����һ�ι�ҩʱ��,
(Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) - min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) +
 21) / 21 as N���۹�ҩ֧��,
count(distinct a.SALENO) over ( partition by a.busno,h.IDCARDNO) as q�����ۼƹ�ҩ����,
row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE desc) rn
              from t_remote_prescription_h h
                       join t_sale_h a on substr(a.notes, 0,
                                                 decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                        instr(a.notes, ' ')) - 1) =
                                          h.CFNO
                       join t_sale_d d on a.SALENO = d.SALENO
                       join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
                       left join d_patient_files fi on fi.IDCARDNO = h.IDCARDNO
                       join s_busi s on h.BUSNO = s.BUSNO
                       join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '322'
                       join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                       join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '323'
                       join t_busno_class_base tb1
                            on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                       join t_ware_base w on w.WAREID = d.WAREID
              where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)
                and exists(select 1 from px_date  where px_date.IDCARDNO=h.IDCARDNO and a.ACCDATE<px_date.ACCDATE)
              ),
--����תƤ�µ�Ŀ¼�е����֤,ͳ�����й���10600308������
    out_px as (
      select
a.SALENO, a.ACCDATE, d.WAREQTY,
h.busno, s.ORGNAME, tb.CLASSNAME as ҩ������ʡ��, tb1.CLASSNAME as ҩ�����ڳ���, d.WAREID, w.WARENAME, h.IDCARDNO,
h.USERNAME,
-- null as ��ҩ����, null as �÷��������鵥���Ƿ�Ϊ����͡, null as ��������, null as �Ƿ������¸�������,
-- null as k���߱����ܹ�ҩ֧��,
-- null as l������1����ǰ�ۼƹ�ҩ����,
sum(d.WAREQTY)
    over ( partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) m������1�����������ۼƹ�ҩ֧��,
Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS r�������һ�ι�ҩʱ��,
LAG(a.ACCDATE, 1) OVER (PARTITION BY h.IDCARDNO,d.WAREID ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��,
min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS ac�����һ�ι�ҩʱ��,
(Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) - min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) +
 21) / 21 as N���۹�ҩ֧��,
count(distinct a.SALENO) over ( partition by a.busno,h.IDCARDNO) as q�����ۼƹ�ҩ����,
row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE desc) rn
              from t_remote_prescription_h h
                       join t_sale_h a on substr(a.notes, 0,
                                                 decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                        instr(a.notes, ' ')) - 1) =
                                          h.CFNO
                       join t_sale_d d on a.SALENO = d.SALENO
                       join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
                       left join d_patient_files fi on fi.IDCARDNO = h.IDCARDNO
                       join s_busi s on h.BUSNO = s.BUSNO
                       join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '322'
                       join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                       join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '323'
                       join t_busno_class_base tb1
                            on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                       join t_ware_base w on w.WAREID = d.WAREID
              where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)
              and not exists(select 1 from px_date where px_date.IDCARDNO=h.IDCARDNO )
    ),
--22����ǰ����10600308�ۼƺ���(22����ǰ��10601875����,ֱ��ȡ�����˵�)
     before_22 as (
     select * from (
     select h.IDCARDNO,
                         sum(d.WAREQTY)
                             over ( partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                             as ��������ǰ�ۼƹ�ҩ����,
                        row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE desc) rn22
                  from t_remote_prescription_h h
                           join t_sale_h a on substr(a.notes, 0,
                                                     decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                            instr(a.notes, ' ')) - 1) = h.CFNO
                           join t_sale_d d on a.SALENO = d.SALENO
                  where a.ACCDATE < date'2022-01-01' and d.WAREID in (10600308) ---10502445,
--                     and h.IDCARDNO = '330106196808190140'
                    and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                    and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)
                   ) where rn22=1
              )
select
    base.busno,
       ORGNAME, ҩ������ʡ��, ҩ�����ڳ���,
--        WAREID, WARENAME,
       base.IDCARDNO, base.USERNAME,
       files.ԭ��ҩ���� as ��ҩ����,
       files.�÷��������鵥���Ƿ�Ϊ����͡,
       files.��������,
       files.�Ƿ������¸�������,
       nvl(before_22.��������ǰ�ۼƹ�ҩ����,0)+nvl(m������1�����������ۼƹ�ҩ֧��,0) as  k���߱����ܹ�ҩ֧��,
       nvl(before_22.��������ǰ�ۼƹ�ҩ����,0) as l������1����ǰ�ۼƹ�ҩ����,
       m������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��,
       case when N���۹�ҩ֧�� - m������1�����������ۼƹ�ҩ֧�� >= 1 then '�зǱ��깺�����' else '���ڱ��깺��' end as oʵ��ҩ����ҩ�ڼ����ƫ�����,
       case when m������1�����������ۼƹ�ҩ֧�� - q�����ۼƹ�ҩ���� < 0 then '���º˲����' else '0' end as p���깺������˲�,
       q�����ۼƹ�ҩ����,
       r�������һ�ι�ҩʱ��,
       s����ǰһ�ι�ҩʱ��,
       r�������һ�ι�ҩʱ�� - s����ǰһ�ι�ҩʱ�� as t������ι�ҩ����,
       r�������һ�ι�ҩʱ�� + 21 as u�����´����۹�ҩʱ��,
       case when nvl(before_22.��������ǰ�ۼƹ�ҩ����,0)+nvl(m������1�����������ۼƹ�ҩ֧��,0) >= 19 then 'Y' else 'N' end as v�Ʋ��Ƿ�������Ƴ�,
       trunc(sysdate - r�������һ�ι�ҩʱ��) as w���һ�ι�ҩ�����������,
       trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��) as x�����ҩ���״ι�ҩ�ۼ�ʱ��,
       case when q�����ۼƹ�ҩ����<=1 then null else (trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��)) / (q�����ۼƹ�ҩ���� - 1) end as y2022����������ƽ����ҩ����,
       null as ���ʱ��,null as ��÷���,null as ��ñ�ע,
--        hf.sfday as ���ʱ��, hf.sfresult as ��÷���, hf.notes as ��ñ�ע,
       ac�����һ�ι�ҩʱ��,rn
from (
    select *
from out_px
union all
select *
from in_px ) base
left join before_22 on base.IDCARDNO=before_22.IDCARDNO
-- left join d_luoshi_jm_hf hf on hf.idcard=base.IDCARDNO
left join d_patient_files files on files.IDCARDNO=base.IDCARDNO
where rn = 1;

--����
select a.BUSNO, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, a.IDCARDNO, a.USERNAME, fi.ԭ��ҩ���� as ��ҩ����, fi.�÷��������鵥���Ƿ�Ϊ����͡,
       fi.��������, fi.�Ƿ������¸�������, K���߱����ܹ�ҩ֧��, L������1����ǰ�ۼƹ�ҩ����, M������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��, Oʵ��ҩ����ҩ�ڼ����ƫ�����, P���깺������˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��,
       S����ǰһ�ι�ҩʱ��, T������ι�ҩ����, U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������,
       X�����ҩ���״ι�ҩ�ۼ�ʱ��, Y2022����������ƽ����ҩ����, ���ʱ��, ��÷���, ��ñ�ע, AC�����һ�ι�ҩʱ��,
       RN
from D_LUOSHI_JMSF_1 a
left join d_patient_files fi on a.idcardno=fi.idcardno;

MERGE INTO d_luoshi_jmsf_1 T1
USING
(
select busno, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO, USERNAME, ��ҩ����,
                                    �÷��������鵥���Ƿ�Ϊ����͡, ��������, �Ƿ������¸�������, k���߱����ܹ�ҩ֧��,
                                    l������1����ǰ�ۼƹ�ҩ����, m������1�����������ۼƹ�ҩ֧��, N���۹�ҩ֧��,
                                    oʵ��ҩ����ҩ�ڼ����ƫ�����, p���깺������˲�, q�����ۼƹ�ҩ����, r�������һ�ι�ҩʱ��,
                                    s����ǰһ�ι�ҩʱ��, t������ι�ҩ����, u�����´����۹�ҩʱ��, v�Ʋ��Ƿ�������Ƴ�,
                                    w���һ�ι�ҩ�����������, x�����ҩ���״ι�ҩ�ۼ�ʱ��, y2022����������ƽ����ҩ����,
                                    ���ʱ��, ��÷���, ��ñ�ע, ac�����һ�ι�ҩʱ��, rn
                             from v_luoshi_jmsf where IDCARDNO is not null
)  T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
WHEN MATCHED THEN
UPDATE SET
           T1.k���߱����ܹ�ҩ֧��= T2.k���߱����ܹ�ҩ֧��,
           T1.l������1����ǰ�ۼƹ�ҩ����= T2.l������1����ǰ�ۼƹ�ҩ����,
           T1.m������1�����������ۼƹ�ҩ֧��= T2.m������1�����������ۼƹ�ҩ֧��,
           T1.N���۹�ҩ֧��= T2.N���۹�ҩ֧��,
           T1.oʵ��ҩ����ҩ�ڼ����ƫ�����= T2.oʵ��ҩ����ҩ�ڼ����ƫ�����,
           T1.p���깺������˲�= T2.p���깺������˲�,
           T1.q�����ۼƹ�ҩ����= T2.q�����ۼƹ�ҩ����,
           T1.r�������һ�ι�ҩʱ��= T2.r�������һ�ι�ҩʱ��,
           T1.s����ǰһ�ι�ҩʱ��= T2.s����ǰһ�ι�ҩʱ��,
           T1.t������ι�ҩ����= T2.t������ι�ҩ����,
           T1.u�����´����۹�ҩʱ��= T2.u�����´����۹�ҩʱ��,
           T1.v�Ʋ��Ƿ�������Ƴ�= T2.v�Ʋ��Ƿ�������Ƴ�,
           T1.w���һ�ι�ҩ�����������= T2.w���һ�ι�ҩ�����������,
           T1.x�����ҩ���״ι�ҩ�ۼ�ʱ��= T2.x�����ҩ���״ι�ҩ�ۼ�ʱ��,
           T1.y2022����������ƽ����ҩ����= T2.y2022����������ƽ����ҩ����,
           T1.ac�����һ�ι�ҩʱ��= T2.ac�����һ�ι�ҩʱ��

WHEN NOT MATCHED THEN
INSERT (busno, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO, USERNAME, ��ҩ����,
                                    �÷��������鵥���Ƿ�Ϊ����͡, ��������, �Ƿ������¸�������, k���߱����ܹ�ҩ֧��,
                                    l������1����ǰ�ۼƹ�ҩ����, m������1�����������ۼƹ�ҩ֧��, N���۹�ҩ֧��,
                                    oʵ��ҩ����ҩ�ڼ����ƫ�����, p���깺������˲�, q�����ۼƹ�ҩ����, r�������һ�ι�ҩʱ��,
                                    s����ǰһ�ι�ҩʱ��, t������ι�ҩ����, u�����´����۹�ҩʱ��, v�Ʋ��Ƿ�������Ƴ�,
                                    w���һ�ι�ҩ�����������, x�����ҩ���״ι�ҩ�ۼ�ʱ��, y2022����������ƽ����ҩ����,
                                    ���ʱ��, ��÷���, ��ñ�ע, ac�����һ�ι�ҩʱ��, rn)
VALUES(T2.busno, T2.ORGNAME, T2.ҩ������ʡ��, T2.ҩ�����ڳ���, T2.IDCARDNO, T2.USERNAME, T2.��ҩ����,
        T2.�÷��������鵥���Ƿ�Ϊ����͡, T2.��������, T2.�Ƿ������¸�������, T2.k���߱����ܹ�ҩ֧��,
        T2.l������1����ǰ�ۼƹ�ҩ����, T2.m������1�����������ۼƹ�ҩ֧��, T2.N���۹�ҩ֧��,
        T2.oʵ��ҩ����ҩ�ڼ����ƫ�����, T2.p���깺������˲�, T2.q�����ۼƹ�ҩ����, T2.r�������һ�ι�ҩʱ��,
        T2.s����ǰһ�ι�ҩʱ��, T2.t������ι�ҩ����, T2.u�����´����۹�ҩʱ��, T2.v�Ʋ��Ƿ�������Ƴ�,
        T2.w���һ�ι�ҩ�����������, T2.x�����ҩ���״ι�ҩ�ۼ�ʱ��, T2.y2022����������ƽ����ҩ����,
        T2.���ʱ��, T2.��÷���, T2.��ñ�ע, T2.ac�����һ�ι�ҩʱ��, T2.rn);


select * from d_luoshi_jmsf_1;
--   and  base.IDCARDNO in ( select base.IDCARDNO from before_22)
;
create table d_luoshi_jm_hf
(
    idcard   varchar2(100),
    busno    number,
    sfday    date,
    sfresult varchar2(400),
    notes    varchar2(400)
);
UPDATE v_luoshi_jmsf SET ��÷���='1215',��ñ�ע='qq' WHERE busno=81248 AND idcardno='332601197804065168';

select *
from d_luoshi_jm_hf;

select *
from ;







--ÿ���˵�һ�ι���Ƥ�µ�ʱ��
select * from (select d.WAREID, h.IDCARDNO, a.ACCDATE,
                      row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ) rn
               from t_remote_prescription_h h
                        join t_sale_h a on substr(a.notes, 0,
                                                  decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                         instr(a.notes, ' ')) - 1) =
                                           h.CFNO
                        join t_sale_d d on a.SALENO = d.SALENO
               where  d.WAREID in (10601875) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                 and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                 and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)
               ) where rn=1;



create or replace trigger TR_V_LUOSHI_JMSF
    instead of update
    on V_LUOSHI_JMSF
    for each row
begin
    MERGE INTO d_luoshi_jm_hf T1
    USING
        (SELECT
             :new.BUSNO   BUSNO,
             :new.IDCARDNO IDCARDNO,
             :new.���ʱ�� ���ʱ��,
             :new.��÷��� ��÷���,
             :new.��ñ�ע ��ñ�ע
         FROM dual) T2
    ON (T1.idcard = T2.IDCARDNO AND T1.BUSNO=T2.BUSNO)
    WHEN MATCHED THEN
        UPDATE SET
        T1.sfday= T2.���ʱ��,
        T1.sfresult= T2.��÷���,
        T1.notes= T2.��ñ�ע
    WHEN NOT MATCHED THEN
        INSERT (idcard,BUSNO, sfday,sfresult,notes) VALUES (

             :new.IDCARDNO,
             :new.BUSNO,
             :new.���ʱ��,
             :new.��÷���,
             :new.��ñ�ע);
end;

