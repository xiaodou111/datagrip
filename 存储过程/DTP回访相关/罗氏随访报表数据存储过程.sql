create or replace procedure proc_luoshi_basedata

is



begin
--1.ά��d_patient_files��IDCARDNO������ɸ��²���,�����µ�IDCARDNOʱ,��Ҫ����d_patient_files��֧�ֺ�����ĸ���
MERGE INTO d_patient_files T1
USING
    (select IDCARDNO, busno, rn, lastbuytime,�α���,��ر�־,USERNAME,CAGE,SEX
from (select h.IDCARDNO,a.busno,cyb.�α���,cyb.��ر�־,h.USERNAME,h.CAGE,h.SEX,
             row_number() over (partition by h.IDCARDNO order by a.ACCDATE desc) rn,
             max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS lastbuytime
      from t_remote_prescription_h h
                        join t_sale_h a on substr(a.notes, 0,
                                                  decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                         instr(a.notes, ' ')) -
                                                  1) =
                                           h.CFNO
                        join t_sale_d d on a.SALENO = d.SALENO
      left join D_ZHYB_HZ_CYB cyb on cyb.ERP���۵��� = a.SALENO
      where
--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308))
where lastbuytime>date'2023-01-01' and rn=1 and IDCARDNO is not null) T2
ON (T1.IDCARDNO = T2.IDCARDNO )

WHEN NOT MATCHED THEN
    INSERT (IDCARDNO,BUSNO,�α���,��ر�־,USERNAME,CAGE,SEX)
    VALUES (T2.IDCARDNO,T2.BUSNO,t2.�α���,t2.��ر�־,t2.USERNAME,t2.CAGE,t2.SEX);
--2.ÿ��������֤�Ŷ�Ӧ�����
-- MERGE INTO d_luoshi_idrank T1
-- USING
-- (
-- select DENSE_RANK() over ( order by IDCARDNO) as idno,IDCARDNO,USERNAME from
--       (select
--        h.IDCARDNO,h.USERNAME,
--        row_number() over (partition by h.IDCARDNO order by a.ACCDATE) rn
-- from t_remote_prescription_h h
--          join t_sale_h a on substr(a.notes, 0,
--                                    decode(instr(a.notes, ' '), 0, length(a.notes) + 1, instr(a.notes, ' ')) - 1) =
--           h.CFNO
--          join t_sale_d d on a.SALENO = d.SALENO
-- where
-- --           a.ACCDATE >= date'2023-01-01' and
-- d.WAREID in (10502445, 10601875, 10600308) and h.IDCARDNO is not null )
--           where rn=1
-- )  T2
-- ON ( T1.IDCARDNO=T2.IDCARDNO)
-- -- WHEN MATCHED THEN
-- -- UPDATE SET T1.b= T2.b
-- WHEN NOT MATCHED THEN
-- INSERT (IDCARDNO,rank,username) VALUES(T2.IDCARDNO,T2.idno,t2.USERNAME);

-- 3.���»��ܱ���ʹ�õľ�����Ƥ������
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

--����Ƥ��
merge into d_luoshi_pxsf_1 T1
using (
  select BUSNO, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO, USERNAME, ��������, �Ƿ������¸�������, ��Ƥ�·���,
       JƤ�������鵥��֧��, KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����,
       OƤ��֧���˲�, PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, ���ʱ��, ��÷���, ��ñ�ע, AC�����һ�ι�ҩʱ��, RN
from v_luoshi_pxsf where IDCARDNO is not null
) T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
WHEN MATCHED THEN
UPDATE SET
           T1.JƤ�������鵥��֧��= T2.JƤ�������鵥��֧��,
           T1.KתƤ�º������鵥��֧��= T2.KתƤ�º������鵥��֧��,
           T1.LƤ��PHEGSO֧��= T2.LƤ��PHEGSO֧��,
           T1.M���۹�ҩ֧��= T2.M���۹�ҩ֧��,
           T1.Nʵ��ҩ����ҩ�ڼ����ƫ�����= T2.Nʵ��ҩ����ҩ�ڼ����ƫ�����,
           T1.OƤ��֧���˲�= T2.OƤ��֧���˲�,
           T1.PתƤ�º�����֧���˲�= T2.PתƤ�º�����֧���˲�,
           T1.Q�����ۼƹ�ҩ����= T2.Q�����ۼƹ�ҩ����,
           T1.R�������һ�ι�ҩʱ��= T2.R�������һ�ι�ҩʱ��,
           T1.S����ǰһ�ι�ҩʱ��= T2.S����ǰһ�ι�ҩʱ��,
           T1.T������ι�ҩ����= T2.T������ι�ҩ����,
           T1.U�����´����۹�ҩʱ��= T2.U�����´����۹�ҩʱ��,
           T1.V�Ʋ��Ƿ�������Ƴ�= T2.V�Ʋ��Ƿ�������Ƴ�,
           T1.W���һ�ι�ҩ�����������= T2.W���һ�ι�ҩ�����������,
           T1.X�����ҩ���״ι�ҩ�ۼ�ʱ��= T2.X�����ҩ���״ι�ҩ�ۼ�ʱ��,
           T1.Y2022����������ƽ����ҩ����= T2.Y2022����������ƽ����ҩ����,
           T1.AC�����һ�ι�ҩʱ��= T2.AC�����һ�ι�ҩʱ��
WHEN NOT MATCHED THEN
INSERT(BUSNO, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO, USERNAME, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, ���ʱ��, ��÷���, ��ñ�ע, AC�����һ�ι�ҩʱ��)
VALUES(T2.BUSNO, T2.ORGNAME, T2.ҩ������ʡ��, T2.ҩ�����ڳ���, T2.IDCARDNO, T2.USERNAME, T2.JƤ�������鵥��֧��,
T2.KתƤ�º������鵥��֧��, T2.LƤ��PHEGSO֧��, T2.M���۹�ҩ֧��, T2.Nʵ��ҩ����ҩ�ڼ����ƫ�����, T2.OƤ��֧���˲�,
T2.PתƤ�º�����֧���˲�, T2.Q�����ۼƹ�ҩ����, T2.R�������һ�ι�ҩʱ��, T2.S����ǰһ�ι�ҩʱ��, T2.T������ι�ҩ����,
T2.U�����´����۹�ҩʱ��, T2.V�Ʋ��Ƿ�������Ƴ�, T2.W���һ�ι�ҩ�����������, T2.X�����ҩ���״ι�ҩ�ۼ�ʱ��,
T2.Y2022����������ƽ����ҩ����, T2.���ʱ��, T2.��÷���, T2.��ñ�ע, T2.AC�����һ�ι�ҩʱ��);



-- delete from  D_LUOSHI_JMSF;
-- insert into D_LUOSHI_JMSF
-- select BUSNO, ORGNAME,  IDCARDNO, K���߱����ܹ�ҩ֧��, L������1����ǰ�ۼƹ�ҩ����, M������1�����������ۼƹ�ҩ֧��,
--        N���۹�ҩ֧��, Oʵ��ҩ����ҩ�ڼ����ƫ�����, P���깺������˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��,
--        S����ǰһ�ι�ҩʱ��, T������ι�ҩ����, U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������,
--        X�����ҩ���״ι�ҩ�ۼ�ʱ��, Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��,
--        RN
-- from v_luoshi_jmsf;
--
-- delete from  d_luoshi_pxsf;
-- --����ֱ�Ӳ�̫��v_luoshi_pxsf_temp,�� v_luoshi_pxsf �� d_luoshi_pxsf
-- insert into d_luoshi_pxsf
-- select BUSNO, ORGNAME, "ҩ������ʡ��", "ҩ�����ڳ���", IDCARDNO, USERNAME, I��Ƥ�·���, JƤ�������鵥��֧��,
--        KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
--        PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
--        U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
--        Y2022����������ƽ����ҩ����, "���ʱ��", "��÷���", "��ñ�ע", AC�����һ�ι�ҩʱ��, RN2
-- from
-- v_luoshi_pxsf_temp;

end ;