select files.BUSNO,
       files.IDCARDNO,
       s.orgname,
       tb.CLASSNAME as ҩ������ʡ��,
       tb1.CLASSNAME as ҩ�����ڳ���,
       substr(files.IDCARDNO,-10) as RANK,
       files.USERNAME,
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
       px.���ʱ�� as Ƥ�����һ�����ʱ��,
       px.��÷��� as Ƥ�����һ����÷���,
       px.��ñ�ע as Ƥ�����һ����ñ�ע,
       jm.���ʱ�� as �������һ�����ʱ��,
       jm.��÷��� as �������һ����÷���,
       jm.��ñ�ע as �������һ����ñ�ע,
       jm.AC�����һ�ι�ҩʱ�� as ��һ�ξ�����ҩʱ��,
       px.AC�����һ�ι�ҩʱ�� as ��һ��Ƥ�¹�ҩʱ��
from d_patient_files files
         left join D_LUOSHI_JMSF_1 jm on files.IDCARDNO = jm.IDCARDNO and files.BUSNO = jm.BUSNO
         left join d_luoshi_pxsf_1 px on files.IDCARDNO = px.IDCARDNO and files.BUSNO = px.BUSNO
--          left join d_luoshi_jm_hf jmhf on files.IDCARDNO = jmhf.IDCARD and files.busno = jmhf.BUSNO
--          left join d_luoshi_px_hf pxhf on files.IDCARDNO = pxhf.IDCARD and files.busno = pxhf.BUSNO
--          left join d_luoshi_idrank rank on files.IDCARDNO = RANK.IDCARDNO
         left join s_busi s on files.BUSNO = s.BUSNO
         join t_busno_class_set ts on files.busno = ts.busno and ts.classgroupno = '322'
         join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
         join t_busno_class_set ts1 on files.busno = ts1.busno and ts1.classgroupno = '323'
         join t_busno_class_base tb1 on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode;

--10112609
select count(*)
from t_sale_d;