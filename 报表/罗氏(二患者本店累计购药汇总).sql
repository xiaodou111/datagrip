select files.BUSNO,
       files.IDCARDNO,
       s.orgname,
       tb.CLASSNAME as 药店所在省份,
       tb1.CLASSNAME as 药店所在城市,
       substr(files.IDCARDNO,-10) as RANK,
       files.USERNAME,
       --疾病分期	是否早期新辅助治疗	原用药方案	该方案曲妥珠单抗是否为赫赛汀	新皮下方案	是否由静脉转为皮下治疗	静脉总支数
       files.疾病分期,
       files.是否早期新辅助治疗,
       files.原用药方案,
       files.该方案曲妥珠单抗是否为赫赛汀,
       files.新皮下方案,
       files.是否静脉转化为皮下,
       nvl(jm.K患者本店总购药支数, 0) + nvl(px.K转皮下后帕妥珠单抗支数, 0) as m静脉总支数,
       jm.K患者本店总购药支数 as n转化前静脉支数,
       px.K转皮下后帕妥珠单抗支数 as o转化后静脉支数,
       nvl(px.J皮下曲妥珠单抗支数, 0) + nvl(px.L皮下PHEGSO支数, 0) as p皮下总支数,
       px.J皮下曲妥珠单抗支数 as q曲妥珠HSC支数,
       px.L皮下PHEGSO支数 as r双靶Phegso支数,
       nvl(jm.Q本店累计购药次数, 0) + nvl(px.Q本店累计购药次数, 0) as s患者本店购药次数,
       jm.Q本店累计购药次数 as t静脉购药次数,
       px.Q本店累计购药次数 as u转换后皮下购药次数,
       case
           when nvl(jm.Y2022年以来本店平均购药周期, 0) = 0 then nvl(px.Y2022年以来本店平均购药周期, 0)
           else case
                    when nvl(px.Y2022年以来本店平均购药周期, 0) = 0 then nvl(jm.Y2022年以来本店平均购药周期, 0)
                    else (nvl(jm.Y2022年以来本店平均购药周期, 0) + nvl(px.Y2022年以来本店平均购药周期, 0)) / 2 end end as v本店平均购药天数,
       nvl(jm.Y2022年以来本店平均购药周期, 0) as w校准后静脉平均购药天数,
       jm.Y2022年以来本店平均购药周期 as x静脉平均购药天数,
       nvl(px.Y2022年以来本店平均购药周期, 0) as y校准后皮下平均购药天数,
       px.Y2022年以来本店平均购药周期 as z皮下平均购药天数,
       jm.R本店最近一次购药时间 as aa本店静脉最近一次购药时间,
       jm.S本店前一次购药时间 as ab本店静脉上一次购药时间,
       jm.R本店最近一次购药时间 - jm.S本店前一次购药时间 as ac静脉最近两次购药周期,
       nvl(px.R本店最近一次购药时间, date'1900-01-01') as ad校准后皮下最近一次购药时间,
       px.R本店最近一次购药时间 as ae本店皮下最近一次购药时间,
       px.S本店前一次购药时间 as af本店皮下上一次购药时间,
       px.R本店最近一次购药时间 - px.S本店前一次购药时间 as ag皮下最近两次购药周期,
       GREATEST(nvl(jm.R本店最近一次购药时间, date'1900-01-01'),
                nvl(px.R本店最近一次购药时间, date'1900-01-01')) as ah本店下次理论购药时间,

       case
           when GREATEST(nvl(jm.R本店最近一次购药时间, date'1900-01-01'),
                         nvl(px.R本店最近一次购药时间, date'1900-01-01')) = date'1900-01-01'
               then null
           else trunc(sysdate - GREATEST(nvl(jm.R本店最近一次购药时间, date'1900-01-01'),
                                         nvl(px.R本店最近一次购药时间, date'1900-01-01')))
           end
           as ai最近一次购药距离今日天数,
       px.随访时间 as 皮下最近一次随访时间,
       px.随访反馈 as 皮下最近一次随访反馈,
       px.随访备注 as 皮下最近一次随访备注,
       jm.随访时间 as 静脉最近一次随访时间,
       jm.随访反馈 as 静脉最近一次随访反馈,
       jm.随访备注 as 静脉最近一次随访备注,
       jm.AC本店第一次购药时间 as 第一次静脉购药时间,
       px.AC本店第一次购药时间 as 第一次皮下购药时间
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