create or replace procedure proc_luoshi_basedata

is



begin
--1.ά��d_patient_files��IDCARDNO������ɸ��²���,�����µ�IDCARDNOʱ,��Ҫ����d_patient_files��֧�ֺ�����ĸ���
MERGE INTO d_patient_files T1
USING
    (SELECT IDCARDNO,busno
     FROM (select h.IDCARDNO,a.busno,
                  row_number() over (partition by h.IDCARDNO,a.BUSNO order by a.ACCDATE) rn
--        count(h.IDCARDNO) over (partition by h.IDCARDNO,d.WAREID) sl
           from t_remote_prescription_h h

                    join t_sale_h a on substr(a.notes, 0,
                                              decode(instr(a.notes, ' '), 0, length(a.notes) + 1, instr(a.notes, ' ')) -
                                              1) =
                                       h.CFNO
                    join t_sale_d d on a.SALENO = d.SALENO
           where
--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308)
--         and IDCARDNO = '332627195902110027'
          )
     WHERE rn = 1 and IDCARDNO is not null) T2
ON (T1.IDCARDNO = T2.IDCARDNO and T1.BUSNO=T2.BUSNO )

WHEN NOT MATCHED THEN
    INSERT (IDCARDNO,BUSNO)
    VALUES (T2.IDCARDNO,T2.BUSNO);
--2.ÿ��������֤�Ŷ�Ӧ�����
MERGE INTO d_luoshi_idrank T1
USING
(
select DENSE_RANK() over ( order by IDCARDNO) as idno,IDCARDNO,USERNAME from
      (select
       h.IDCARDNO,h.USERNAME,
       row_number() over (partition by h.IDCARDNO order by a.ACCDATE) rn
from t_remote_prescription_h h
         join t_sale_h a on substr(a.notes, 0,
                                   decode(instr(a.notes, ' '), 0, length(a.notes) + 1, instr(a.notes, ' ')) - 1) =
          h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where
--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308) and h.IDCARDNO is not null )
          where rn=1
)  T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
-- WHEN MATCHED THEN
-- UPDATE SET T1.b= T2.b
WHEN NOT MATCHED THEN
INSERT (IDCARDNO,rank,username) VALUES(T2.IDCARDNO,T2.idno,t2.USERNAME);

-- 3.���»��ܱ���ʹ�õľ�����Ƥ������
delete from  D_LUOSHI_JMSF;
insert into D_LUOSHI_JMSF
select BUSNO, ORGNAME,  IDCARDNO, K���߱����ܹ�ҩ֧��, L������1����ǰ�ۼƹ�ҩ����, M������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��, Oʵ��ҩ����ҩ�ڼ����ƫ�����, P���깺������˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��,
       S����ǰһ�ι�ҩʱ��, T������ι�ҩ����, U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������,
       X�����ҩ���״ι�ҩ�ۼ�ʱ��, Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��,
       RN
from v_luoshi_jmsf;

delete from  d_luoshi_pxsf;
insert into d_luoshi_pxsf
select BUSNO, ORGNAME, IDCARDNO, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��, RN2
from
v_luoshi_pxsf;

end ;