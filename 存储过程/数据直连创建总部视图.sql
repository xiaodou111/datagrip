select files.BUSNO,
       files.IDCARDNO,
       s.orgname,
       tb.CLASSNAME as ҩ������ʡ��,
       tb1.CLASSNAME as ҩ�����ڳ���,
       rank.RANK,
       rank.USERNAME,
       --��������	�Ƿ������¸�������	ԭ��ҩ����	�÷��������鵥���Ƿ�Ϊ����͡	��Ƥ�·���	�Ƿ��ɾ���תΪƤ������	������֧��
       files.��������,
       files.�Ƿ������¸�������,
       files.ԭ��ҩ����,
       files.�÷��������鵥���Ƿ�Ϊ����͡,
       files.��Ƥ�·���,
       files.�Ƿ���ת��ΪƤ��,
       nvl(jm.K���߱����ܹ�ҩ֧��, 0) + nvl(px.KתƤ�º������鵥��֧��, 0) as m������֧��,
       jm.K���߱����ܹ�ҩ֧�� as nת��ǰ����֧��,
       px.KתƤ�º������鵥��֧�� as oת������֧��,
       nvl(px.JƤ�������鵥��֧��, 0) + nvl(px.LƤ��PHEGSO֧��, 0) as pƤ����֧��,
       px.JƤ�������鵥��֧�� as q������HSC֧��,
       px.LƤ��PHEGSO֧�� as r˫��Phegso֧��,
       nvl(jm.Q�����ۼƹ�ҩ����, 0) + nvl(px.Q�����ۼƹ�ҩ����, 0) as s���߱��깺ҩ����,
       jm.Q�����ۼƹ�ҩ���� as t������ҩ����,
       px.Q�����ۼƹ�ҩ���� as uת����Ƥ�¹�ҩ����,
       case
           when nvl(jm.Y2022����������ƽ����ҩ����, 0) = 0 then nvl(px.Y2022����������ƽ����ҩ����, 0)
           else case
                    when nvl(px.Y2022����������ƽ����ҩ����, 0) = 0 then nvl(jm.Y2022����������ƽ����ҩ����, 0)
                    else (nvl(jm.Y2022����������ƽ����ҩ����, 0) + nvl(px.Y2022����������ƽ����ҩ����, 0)) / 2 end end as v����ƽ����ҩ����,
       nvl(jm.Y2022����������ƽ����ҩ����, 0) as wУ׼����ƽ����ҩ����,
       jm.Y2022����������ƽ����ҩ���� as x����ƽ����ҩ����,
       nvl(px.Y2022����������ƽ����ҩ����, 0) as yУ׼��Ƥ��ƽ����ҩ����,
       px.Y2022����������ƽ����ҩ���� as zƤ��ƽ����ҩ����,
       jm.R�������һ�ι�ҩʱ�� as aa���꾲�����һ�ι�ҩʱ��,
       jm.S����ǰһ�ι�ҩʱ�� as ab���꾲����һ�ι�ҩʱ��,
       jm.R�������һ�ι�ҩʱ�� - jm.S����ǰһ�ι�ҩʱ�� as ac����������ι�ҩ����,
       nvl(px.R�������һ�ι�ҩʱ��, date'1900-01-01') as adУ׼��Ƥ�����һ�ι�ҩʱ��,
       px.R�������һ�ι�ҩʱ�� as ae����Ƥ�����һ�ι�ҩʱ��,
       px.S����ǰһ�ι�ҩʱ�� as af����Ƥ����һ�ι�ҩʱ��,
       px.R�������һ�ι�ҩʱ�� - px.S����ǰһ�ι�ҩʱ�� as agƤ��������ι�ҩ����,
       GREATEST(nvl(jm.R�������һ�ι�ҩʱ��, date'1900-01-01'),
                nvl(px.R�������һ�ι�ҩʱ��, date'1900-01-01')) as ah�����´����۹�ҩʱ��,

       case
           when GREATEST(nvl(jm.R�������һ�ι�ҩʱ��, date'1900-01-01'),
                         nvl(px.R�������һ�ι�ҩʱ��, date'1900-01-01')) = date'1900-01-01'
               then null
           else trunc(sysdate - GREATEST(nvl(jm.R�������һ�ι�ҩʱ��, date'1900-01-01'),
                                         nvl(px.R�������һ�ι�ҩʱ��, date'1900-01-01')))
           end
           as ai���һ�ι�ҩ�����������,
       pxhf.SFDAY as Ƥ�����һ�����ʱ��,
       pxhf.SFRESULT as Ƥ�����һ����÷���,
       pxhf.NOTES as Ƥ�����һ����ñ�ע,
       jmhf.SFDAY as �������һ�����ʱ��,
       jmhf.SFRESULT as �������һ����÷���,
       jmhf.NOTES as �������һ����ñ�ע,
       jm.AC�����һ�ι�ҩʱ�� as ��һ�ξ�����ҩʱ��,
       px.AC�����һ�ι�ҩʱ�� as ��һ��Ƥ�¹�ҩʱ��
from d_patient_files files
         left join D_LUOSHI_JMSF jm on files.IDCARDNO = jm.IDCARDNO and files.BUSNO = jm.BUSNO
         left join d_luoshi_pxsf px on files.IDCARDNO = px.IDCARDNO and files.BUSNO = px.BUSNO
         left join d_luoshi_jm_hf jmhf on files.IDCARDNO = jmhf.IDCARD and files.busno = jmhf.BUSNO
         left join d_luoshi_px_hf pxhf on files.IDCARDNO = pxhf.IDCARD and files.busno = pxhf.BUSNO
         left join d_luoshi_idrank rank on files.IDCARDNO = RANK.IDCARDNO
         left join s_busi s on files.BUSNO = s.BUSNO
         join t_busno_class_set ts on files.busno = ts.busno and ts.classgroupno = '322'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on files.busno = ts1.busno and ts1.classgroupno = '323'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode;
select * from d_luoshi_jm_hf;


select * from D_LUOSHI_JMSF;
select * from D_LUOSHI_PX_HF;
-- auto-generated definition
drop table d_luoshi_pxsf
create table d_luoshi_pxsf
(
    BUSNO                         NUMBER(10)   not null,
    ORGNAME                       VARCHAR2(60) not null,
    ҩ������ʡ��                  VARCHAR2(40) not null,
    ҩ�����ڳ���                  VARCHAR2(40) not null,
    IDCARDNO                      VARCHAR2(20),
    USERNAME                      VARCHAR2(40),
    I��Ƥ�·���                   VARCHAR2(100),
    JƤ�������鵥��֧��           NUMBER,
    KתƤ�º������鵥��֧��       NUMBER,
    LƤ��PHEGSO֧��               NUMBER,
    M���۹�ҩ֧��                 NUMBER,
    Nʵ��ҩ����ҩ�ڼ����ƫ����� VARCHAR2(16),
    OƤ��֧���˲�                 VARCHAR2(12),
    PתƤ�º�����֧���˲�         VARCHAR2(12),
    Q�����ۼƹ�ҩ����             NUMBER,
    R�������һ�ι�ҩʱ��         DATE,
    S����ǰһ�ι�ҩʱ��           DATE,
    T������ι�ҩ����             NUMBER,
    U�����´����۹�ҩʱ��         DATE,
    V�Ʋ��Ƿ�������Ƴ�           CHAR,
    W���һ�ι�ҩ�����������     NUMBER,
    X�����ҩ���״ι�ҩ�ۼ�ʱ��   NUMBER,
    Y2022����������ƽ����ҩ����   NUMBER,
    ���ʱ��                      DATE,
    ��÷���                      VARCHAR2(400),
    ��ñ�ע                      VARCHAR2(400),
    AC�����һ�ι�ҩʱ��          DATE,
    RN2                           NUMBER
)
/

select * from d_luoshi_pxsf;

create table D_O2O_NOPS
(
    BUSNO  NUMBER(10) not null,
    WAREID NUMBER(10) not null,
    constraint PK_D_O2O_NOPS
        primary key (BUSNO, WAREID)
)


create or replace procedure proc_add_sycompany(P_VENCUSCODE  VARCHAR2,P_VENCUSNAME VARCHAR2)

as

begin

update hd_msg_in set status = 0  WHERE  table_type = 1015
and MSG_ID='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8';

update hd_in_vencus_base a set msg_status=0,VENCUSCODE=P_VENCUSCODE,VENCUSNAME=P_VENCUSNAME
                    WHERE  a.msg_id ='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8' and  SEQ_ID='POS0001149FEB0B309D54E308B51F36C67FD9FA7';
end;

    call proc_sjzl_create_new();
call proc_sjzl_create_new()

