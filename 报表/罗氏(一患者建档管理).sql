
-- with px_date as (select *
--                  --���������˵������תƤ����
--                  from (select d.WAREID, h.IDCARDNO, a.ACCDATE,
--                               row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ) rn
--                        from t_remote_prescription_h h
--                                 join t_sale_h a on substr(a.notes, 0,
--                                                           decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
--                                                                  instr(a.notes, ' ')) - 1) =
--                                                    h.CFNO
--                                 join t_sale_d d on a.SALENO = d.SALENO
--                        where d.WAREID in (10601875) ---10502445,
-- --                 and h.IDCARDNO = '330106196808190140'
--                          and a.SALENO not in (select saleno from T_SALE_RETURN_h)
--                          and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h))
--                  where rn = 1);


select * from d_luoshi_user_temp;
--���һ�ι�ҩ��2023.1.1��ǰ�Ĳ�����,�״ν����󣬺������ŵ�Ļ�����ҩ�����Ƹĳ����µ��Ǽ�
--���䱨��
select busno, ORGNAME, ҩ������ʡ��, ҩ�����ڳ���, IDCARDNO,rank,
       USERNAME, CAGE, SEX, ����ҽԺ���Ҳ���, �α���,
       ��ر�־, �����Ƿ�֪��, �Ƿ�ͬ�⽫��Ϣ����������ҽ��, ���������, ������뻼�߹�ϵ, �������ϵ�绰, ��������,
       �Ƿ������¸�������, ԭ��ҩ����, �÷��������鵥���Ƿ�Ϊ����͡, ��Ϊ����������ѡ���巽��, ��Ƥ�·���,
       �Ƿ���ת��ΪƤ��,
       �Ƿ����ϻ���, �Ƿ�����, ER�Ƽ��������Ƿ�����, PR�м��������Ƿ�����, �Ƿ����ܰͽ�ת��, �Ƿ�ת����Զ������ת��,
       �����״�ȷ��ʱ��, �״���ע�������׻����׵�ʱ��, ����ҽԺ, ���߷Ǳ��깺ҩ���׻�����֧��, ���߱��꾲����ҩ֧��,
       ���߱���Ƥ�¹�ҩ֧��
from (select
--     a.ACCDATE,a.SALENO,h.CFNO,
fi.busno, s.ORGNAME, tb.CLASSNAME as ҩ������ʡ��, tb1.CLASSNAME as ҩ�����ڳ���, fi.IDCARDNO,
substr(fi.IDCARDNO,-10) as RANK,
fi.USERNAME, CAGE, SEX, fi.����ҽԺ���Ҳ���,
fi.ҽ�������� as �α���, fi.�Ƿ����ҽ�� as ��ر�־,
fi.�����Ƿ�֪��, fi.�Ƿ�ͬ�⽫��Ϣ����������ҽ�� as �Ƿ�ͬ�⽫��Ϣ����������ҽ��, fi.���������, fi.������뻼�߹�ϵ,
fi.�������ϵ�绰,
fi.��������, fi.�Ƿ������¸�������, fi.ԭ��ҩ����, fi.�÷��������鵥���Ƿ�Ϊ����͡, fi.��Ϊ����������ѡ���巽��,
fi.��Ƥ�·���, fi.�Ƿ���ת��ΪƤ��, fi.�Ƿ����ϻ���, fi.�Ƿ�����, fi.ER�Ƽ��������Ƿ�����, fi.PR�м��������Ƿ�����,
fi.�Ƿ����ܰͽ�ת��, fi.�Ƿ�ת����Զ������ת��,
fi.�����״�ȷ��ʱ�� as �����״�ȷ��ʱ��, fi.�״���עʱ�� as �״���ע�������׻����׵�ʱ��,
fi.����ҽԺ as ����ҽԺ, fi.���߷Ǳ��깺ҩ���׻�����֧��,
nvl(jm.K���߱����ܹ�ҩ֧��,0)+nvl(px.KתƤ�º������鵥��֧��,0) as ���߱��꾲����ҩ֧��,
px.JƤ�������鵥��֧�� as ���߱���Ƥ�¹�ҩ֧��
--h.CREATETIME, h.ZDCONT, a.ACCDATE,
--        count(h.IDCARDNO) over (partition by h.IDCARDNO,d.WAREID) sl
              from
               d_patient_files fi
               left join s_busi s on fi.BUSNO = s.BUSNO
               left join t_busno_class_set ts on fi.busno = ts.busno and ts.classgroupno = '322'
               left join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
               left join t_busno_class_set ts1 on fi.busno = ts1.busno and ts1.classgroupno = '323'
               left join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
--                left join d_luoshi_idrank rank on h.IDCARDNO=rank.idcardno
               left join d_luoshi_pxsf_1  px on fi.IDCARDNO=px.IDCARDNO
               left join D_LUOSHI_JMSF_1  jm on fi.IDCARDNO=jm.IDCARDNO);

alter table d_patient_files  add �α��� varchar2(40);
alter table d_patient_files  add ��ر�־ varchar2(40);
select * from d_patient_files;




select * from d_patient_files;


select * from d_luoshi_pxsf;
select * from D_LUOSHI_JMSF_1;
select * from d_luoshi_pxsf_1;


alter table d_patient_files add ����ҽԺ���Ҳ��� varchar2(200);
alter table d_patient_files add ҽ�������� varchar2(40);
alter table d_patient_files add �Ƿ����ҽ�� varchar2(6);
alter table d_patient_files add �����״�ȷ��ʱ�� date;
alter table d_patient_files add ����ҽԺ varchar2(200);
alter table d_patient_files add username varchar2(40);
alter table d_patient_files add cage varchar2(40);
alter table d_patient_files add sex varchar2(2);
select * from d_patient_files;
UPDATE d_patient_files SET �Ƿ������¸�������='��' WHERE idcardno='330324197209215762';
select * from D_LUOSHI_JMSF;

select * from D_ZHYB_HZ_CYB where ERP���۵���='2403181248079181';






create table D_LUOSHI_JMSF as
select BUSNO, ORGNAME,  IDCARDNO, K���߱����ܹ�ҩ֧��, L������1����ǰ�ۼƹ�ҩ����, M������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��, Oʵ��ҩ����ҩ�ڼ����ƫ�����, P���깺������˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��,
       S����ǰһ�ι�ҩʱ��, T������ι�ҩ����, U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������,
       X�����ҩ���״ι�ҩ�ۼ�ʱ��, Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��,
       RN
from v_luoshi_jmsf;


select BUSNO, ORGNAME,  IDCARDNO, K���߱����ܹ�ҩ֧��, L������1����ǰ�ۼƹ�ҩ����, M������1�����������ۼƹ�ҩ֧��,
       N���۹�ҩ֧��, Oʵ��ҩ����ҩ�ڼ����ƫ�����, P���깺������˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��,
       S����ǰһ�ι�ҩʱ��, T������ι�ҩ����, U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������,
       X�����ҩ���״ι�ҩ�ۼ�ʱ��, Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��,
       RN
from v_luoshi_jmsf;

create table  d_luoshi_pxsf as
select BUSNO, ORGNAME, IDCARDNO, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��, RN2
from
v_luoshi_pxsf;

insert into d_luoshi_pxsf
select BUSNO, ORGNAME, IDCARDNO, JƤ�������鵥��֧��,
       KתƤ�º������鵥��֧��, LƤ��PHEGSO֧��, M���۹�ҩ֧��, Nʵ��ҩ����ҩ�ڼ����ƫ�����, OƤ��֧���˲�,
       PתƤ�º�����֧���˲�, Q�����ۼƹ�ҩ����, R�������һ�ι�ҩʱ��, S����ǰһ�ι�ҩʱ��, T������ι�ҩ����,
       U�����´����۹�ҩʱ��, V�Ʋ��Ƿ�������Ƴ�, W���һ�ι�ҩ�����������, X�����ҩ���״ι�ҩ�ۼ�ʱ��,
       Y2022����������ƽ����ҩ����, AC�����һ�ι�ҩʱ��, RN2
from
v_luoshi_pxsf;


select * from D_ZHYB_HZ_CYB;


create table d_luoshi_pxsf (
    busno number,
    orgname varchar2(100),
    IDCARDNO varchar2(20),
    JƤ�������鵥��֧�� number,
    KתƤ�º������鵥��֧��  number,
    LƤ��PHEGSO֧��  number,
    M���۹�ҩ֧��  number(6,4),
    Nʵ��ҩ����ҩ�ڼ����ƫ�����  varchar2(100),
    OƤ��֧���˲�  varchar2(100),
    PתƤ�º�����֧���˲�  varchar2(100),
    Q�����ۼƹ�ҩ����  number,
    R�������һ�ι�ҩʱ��  date,
    S����ǰһ�ι�ҩʱ��  date,
    T������ι�ҩ����  number,
    U�����´����۹�ҩʱ��  date,
    V�Ʋ��Ƿ�������Ƴ�  varchar2(20),
    W���һ�ι�ҩ�����������  number,
    X�����ҩ���״ι�ҩ�ۼ�ʱ��  number,
    Y2022����������ƽ����ҩ����  number(6,4),
    AC�����һ�ι�ҩʱ��  date,
    RN2  number
)

--�ô�����
select * from t_remote_prescription_h h
                       join t_sale_h a on substr(a.notes, 0,
                                                 decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                        instr(a.notes, ' ')) - 1) =
                                          h.CFNO
                       join t_sale_d d on a.SALENO = d.SALENO

 where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308) ---10502445,
                and h.IDCARDNO = '53293019850121172X'
                and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);


--��ҽ����
select a.ACCDATE,a.SALENO,cyb.���֤��,h.IDCARDNO,h.CFNO from D_ZHYB_HZ_CYB cyb
join t_sale_h a on a.SALENO=cyb.ERP���۵���
join t_sale_d d on a.SALENO = d.SALENO
left join t_remote_prescription_h h  on substr(a.notes, 0,
                                                 decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                        instr(a.notes, ' ')) - 1) =
                                          h.CFNO
 where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308) ---10502445,
                and cyb.���֤�� = '53293019850121172X';



select substr(IDCARDNO,-12),max(IDCARDNO) from t_remote_prescription_h group by substr(IDCARDNO,-12)
having count(*)>1;

select substr(IDCARDNO,-4),IDCARDNO from t_remote_prescription_h
                                         where substr(IDCARDNO,-12)='197010204435';



                                    group by IDCARDNO






