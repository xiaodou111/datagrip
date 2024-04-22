
with base as (select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY, a.SALENO, a.BUSNO, h.USERNAME,
                     SUM(case when d.WAREID = 10601875 then d.WAREQTY else 0 end) over
                         ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumqtqty,--��������
                     SUM(case when d.WAREID = 10600308 then d.WAREQTY else 0 end) over
                         ( partition by h.IDCARDNO order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) sumptqty,--��������
                     COUNT(case when d.WAREID = 10601875 then d.WAREQTY else null end)
                           over ( partition by h.IDCARDNO) count,  --������������״���Ϊ׼
                     MAX(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO ) AS r�������һ�ι�ҩʱ��,
--                      LAG(a.ACCDATE, 1) OVER (PARTITION BY h.IDCARDNO ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��,��Ҫ�����ϴ���10601875�ļ�¼
                     MIN(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO ) AS ac�����һ�ι�ҩʱ��,
                     ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE desc ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
from D_LUOSHI_PROG p
where h.IDCARDNO = p.IDCARDNO
  and p.PROGRAMME in (5, 6, 7)
  and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10601875, 10600308)
  and not EXISTS(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = a.SALENO)
  and not EXISTS(select 1 from T_SALE_RETURN_H rh where rh.SALENO = a.SALENO)),
a1 as ( 
select B1.WAREID, B1.IDCARDNO, B1.ACCDATE, B1.WAREQTY, B1.SALENO, B1.BUSNO, B1.USERNAME, B1.sumqtqty, B1.sumptqty, B1.count,
       B1.r�������һ�ι�ҩʱ��, B2.s����ǰһ�ι�ҩʱ��, B1.ac�����һ�ι�ҩʱ��, B1.rn
from base B1
left join (
    select d.WAREID, h.IDCARDNO, a.ACCDATE,a.SALENO,LAG(a.ACCDATE, 1) OVER (PARTITION BY IDCARDNO ORDER BY a.ACCDATE ) AS s����ǰһ�ι�ҩʱ��
    from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
    where d.WAREID=10601875
) B2 on b1.IDCARDNO=b2.IDCARDNO and b1.SALENO=b2.SALENO and b1.WAREID=b2.WAREID
where b1.rn=1 ),
 add_qc as (
   select a1.busno as busno,a1.IDCARDNO as IDCARDNO,a1.USERNAME as USERNAME,a1.WAREID as WAREID,
       nvl(qc.QTZSL,0)+nvl(sumqtqty,0) as jƤ�������鵥��֧��,
       nvl(qc.PTZSL,0)+nvl(sumptqty,0)  as kתƤ�º������鵥��֧��,
       nvl(qc.SUMCS,0)+nvl(count,0) as q����Ƥ���ۼƹ�ҩ����,
       nvl(r�������һ�ι�ҩʱ��,qc.LASTBUYTIME) as r�������һ�ι�ҩʱ��,
       nvl(s����ǰһ�ι�ҩʱ��,qc.LAGBUYTIME) as s����ǰһ�ι�ҩʱ��,
       nvl(ac�����һ�ι�ҩʱ��,qc.firsttime) as ac�����һ�ι�ҩʱ��,
       (trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��)+21)/21 as M���۹�ҩ֧��,
       0 as lƤ��phegso֧��,
       rn
    from  a1
    left join d_luoshi_qcpx qc on a1.IDCARDNO=qc.IDCARDNO
    )
 select aa.busno,s.ORGNAME,tb.CLASSNAME as ҩ������ʡ��,tb1.CLASSNAME as ҩ�����ڳ���,aa.IDCARDNO,aa.USERNAME,
        files.��������,files.�Ƿ������¸�������,files.��Ƥ�·���,
        aa.jƤ�������鵥��֧��, aa.kתƤ�º������鵥��֧��,aa.lƤ��phegso֧��,
        aa.M���۹�ҩ֧��,
        case when M���۹�ҩ֧�� - jƤ�������鵥��֧�� >= 1 then '�зǱ��깺�����' else '���ڱ��깺��' end as nʵ��ҩ����ҩ�ڼ����ƫ�����,
        case when jƤ�������鵥��֧�� + lƤ��phegso֧�� - q����Ƥ���ۼƹ�ҩ���� < 0 then '���º˲����' else '0' end as oƤ��֧���˲�,
        case
           when files.��Ƥ�·��� = '˫��(�����鵥��HSC+�����鵥��)' and kתƤ�º������鵥��֧�� < q����Ƥ���ۼƹ�ҩ����
               then '���º˲����'
           else '0' end as pתƤ�º�����֧���˲�,
        q����Ƥ���ۼƹ�ҩ���� as q�����ۼƹ�ҩ����,
        r�������һ�ι�ҩʱ��,
        s����ǰһ�ι�ҩʱ��,
        r�������һ�ι�ҩʱ�� - s����ǰһ�ι�ҩʱ�� as t������ι�ҩ����,
        r�������һ�ι�ҩʱ�� + 21 as u�����´����۹�ҩʱ��,
        case when kתƤ�º������鵥��֧�� >= 19 then 'Y' else 'N' end as v�Ʋ��Ƿ�������Ƴ�,
        trunc(sysdate - r�������һ�ι�ҩʱ��) as w���һ�ι�ҩ�����������,
        trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��) as x�����ҩ���״ι�ҩ�ۼ�ʱ��,
        case
           when q����Ƥ���ۼƹ�ҩ���� <= 1 then null
           else (trunc(r�������һ�ι�ҩʱ�� - ac�����һ�ι�ҩʱ��)) / (q����Ƥ���ۼƹ�ҩ���� - 1) end as y2022����������ƽ����ҩ����,
       null as ���ʱ��, null as ��÷���, null as ��ñ�ע, aa.ac�����һ�ι�ҩʱ��, aa.rn
from add_qc aa
left join s_busi s on aa.busno=s.BUSNO
join t_busno_class_set ts on aa.busno = ts.busno and ts.classgroupno = '322'
join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
join t_busno_class_set ts1 on aa.busno = ts1.busno and ts1.classgroupno = '323'
join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
left join d_patient_files files on files.IDCARDNO=aa.IDCARDNO;

select * from  V_LUOSHI_PXSF;
create table d_luoshi_pxsf_1 as
select BUSNO, ORGNAME, "ҩ������ʡ��", "ҩ�����ڳ���", IDCARDNO, USERNAME, I��Ƥ�·���, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, "���ʱ��", "��÷���", "��ñ�ע", AC�����һ�ι�ҩʱ��, RN2
from v_luoshi_pxsf;
select * from d_luoshi_pxsf_1;
--����
select a.BUSNO, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, fi.IDCARDNO, a.USERNAME,fi.��������,fi.�Ƿ������¸�������,fi.��Ƥ�·���, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, ���ʱ��, ��÷���, ��ñ�ע, AC�����һ�ι�ҩʱ��, RN2
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
             :new.IDCARDNO IDCARDNO,
             :new.���ʱ�� ���ʱ��,
             :new.��÷��� ��÷���,
             :new.��ñ�ע ��ñ�ע
         FROM dual) T2
    ON (T1.idcard = T2.IDCARDNO)
    WHEN MATCHED THEN
        UPDATE SET
        T1.sfday= T2.���ʱ��,
        T1.sfresult= T2.��÷���,
        T1.notes= T2.��ñ�ע
    WHEN NOT MATCHED THEN
        INSERT (idcard, sfday,sfresult,notes) VALUES (
             :new.IDCARDNO,
             :new.���ʱ��,
             :new.��÷���,
             :new.��ñ�ע);
end;




