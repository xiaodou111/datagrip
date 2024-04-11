create or replace view v_luoshi_pxsf as
with first as (select a.SALENO, a.ACCDATE, d.WAREQTY,
                      h.busno, s.ORGNAME, tb.CLASSNAME as ҩ������ʡ��, tb1.CLASSNAME as ҩ�����ڳ���, d.WAREID,
                      h.IDCARDNO,
                      USERNAME,
                      min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) as �����һ�ι�10601875ʱ��,
                      sum(d.WAREQTY) over ( partition by h.IDCARDNO,d.WAREID
                          order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ����10601875������,
                      row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ) rn
               from t_remote_prescription_h h
                        join t_sale_h a on substr(a.notes, 0,
                                                  decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                         instr(a.notes, ' ')) - 1) =
                                           h.CFNO
                        join t_sale_d d on a.SALENO = d.SALENO
                        left join d_patient_files fi on fi.IDCARDNO = h.IDCARDNO
                        join s_busi s on h.BUSNO = s.BUSNO
                        join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '322'
                        join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                        join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '323'
                        join t_busno_class_base tb1
                             on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
               where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10601875)
                 --and a.BUSNO=81124 ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                 and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                 and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)),
     after10601875 as (select a.SALENO, a.ACCDATE, d.WAREQTY, ҩ������ʡ��, ҩ�����ڳ���,
                              h.busno, s.ORGNAME, d.WAREID,
                              w.WARENAME, h.IDCARDNO, h.USERNAME,
                              ����10601875������ as jƤ�������鵥��֧��,
                              sum(d.WAREQTY) over ( partition by h.IDCARDNO,d.WAREID
                                  order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as kתƤ�º������鵥��֧��,
                              0 as lƤ��phegso֧��,
                              Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS r�������һ�ι�ҩʱ��,
                              LAG(a.ACCDATE, 1)
                                  OVER (PARTITION BY h.IDCARDNO,d.WAREID ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��,
                              min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS ac�����һ�ι�ҩʱ��,
                              (Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) -
                               min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) +
                               21) / 21 as M���۹�ҩ֧��,
                              count(distinct a.ACCDATE) over ( partition by h.IDCARDNO) as q�����ۼƹ�ҩ����,
                              row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE desc) rn2

                       from t_remote_prescription_h h
                                join t_sale_h a on substr(a.notes, 0,
                                                          decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                                 instr(a.notes, ' ')) - 1) =
                                                   h.CFNO
                                join t_sale_d d on a.SALENO = d.SALENO
                                join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
                                left join d_patient_files fi on fi.IDCARDNO = h.IDCARDNO
                                join s_busi s on h.BUSNO = s.BUSNO
                                join t_ware_base w on w.WAREID = d.WAREID
                                join first
                                     on first.IDCARDNO = h.IDCARDNO and a.ACCDATE >= first.�����һ�ι�10601875ʱ�� and
                                        first.rn = 1
                       where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308))
select first.busno,
       first.ORGNAME, first.ҩ������ʡ��, first.ҩ�����ڳ���,
--        WAREID, WARENAME,
       first.IDCARDNO, first.USERNAME,
--        ��ҩ����,
--        �÷��������鵥���Ƿ�Ϊ����͡, ��������, �Ƿ������¸�������,
       files.��Ƥ�·��� as i��Ƥ�·���,
       first.����10601875������ as jƤ�������鵥��֧��,
       kתƤ�º������鵥��֧��,
       lƤ��phegso֧��,
       M���۹�ҩ֧��,
       case when M���۹�ҩ֧�� - jƤ�������鵥��֧�� >= 1 then '�зǱ��깺�����' else '���ڱ��깺��' end as nʵ��ҩ����ҩ�ڼ����ƫ�����,
       case when jƤ�������鵥��֧�� + lƤ��phegso֧�� - q�����ۼƹ�ҩ���� < 0 then '���º˲����' else '0' end as oƤ��֧���˲�,
       case
           when files.��Ƥ�·��� = '˫��(�����鵥��HSC+�����鵥��)' and kתƤ�º������鵥��֧�� < q�����ۼƹ�ҩ����
               then '���º˲����'
           else '0' end as pתƤ�º�����֧���˲�,
       q�����ۼƹ�ҩ����,
       r�������һ�ι�ҩʱ��,
       s����ǰһ�ι�ҩʱ��,
       r�������һ�ι�ҩʱ�� - s����ǰһ�ι�ҩʱ�� as t������ι�ҩ����,
       r�������һ�ι�ҩʱ�� + 21 as u�����´����۹�ҩʱ��,
       case when kתƤ�º������鵥��֧�� >= 19 then 'Y' else 'N' end as v�Ʋ��Ƿ�������Ƴ�,
       trunc(sysdate - r�������һ�ι�ҩʱ��) as w���һ�ι�ҩ�����������,
       trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��) as x�����ҩ���״ι�ҩ�ۼ�ʱ��,
       case
           when q�����ۼƹ�ҩ���� <= 1 then null
           else (trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��)) / (q�����ۼƹ�ҩ���� - 1) end as y2022����������ƽ����ҩ����,
       hf.sfday as ���ʱ��, hf.sfresult as ��÷���, hf.notes as ��ñ�ע,
       ac�����һ�ι�ҩʱ��, rn2
from first
         left join after10601875 aa on first.IDCARDNO = aa.IDCARDNO and aa.rn2 = 1
         left join d_luoshi_px_hf hf on aa.IDCARDNO = hf.idcard
         left join d_patient_files files on files.IDCARDNO = aa.IDCARDNO
where rn = 1;

create table d_luoshi_pxsf_1 as
select BUSNO, ORGNAME, "ҩ������ʡ��", "ҩ�����ڳ���", IDCARDNO, USERNAME, I��Ƥ�·���, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, "���ʱ��", "��÷���", "��ñ�ע", AC�����һ�ι�ҩʱ��, RN2
from v_luoshi_pxsf;
select * from d_luoshi_pxsf_1;
--����
select a.BUSNO, ORGNAME, "ҩ������ʡ��", "ҩ�����ڳ���", fi.IDCARDNO, USERNAME,fi.��������,fi.�Ƿ������¸�������,fi.��Ƥ�·���, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, "���ʱ��", "��÷���", "��ñ�ע", AC�����һ�ι�ҩʱ��, RN2
from d_luoshi_pxsf_1 a
left join d_patient_files fi on a.idcardno=fi.idcardno;



--��ñ�
create table d_luoshi_px_hf
(
    idcard   varchar2(100),
    busno    number,
    sfday    date,
    sfresult varchar2(400),
    notes    varchar2(400)
);
drop table d_luoshi_px_hf;
--������ TR_V_LUOSHI_PXSF


create or replace trigger TR_V_LUOSHI_PXSF
    instead of update
    on V_LUOSHI_PXSF
    for each row
begin
    MERGE INTO d_luoshi_px_hf T1
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




