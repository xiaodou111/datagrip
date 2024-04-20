create view V_LUOSHI_PXSF as
with first as (select a.SALENO, a.ACCDATE, d.WAREQTY,
                      h.busno, s.ORGNAME, tb.CLASSNAME as 药店所在省份, tb1.CLASSNAME as 药店所在城市, d.WAREID,
                      h.IDCARDNO,
                      h.USERNAME,
                      min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) as 本店第一次购10601875时间,
                      sum(d.WAREQTY) over ( partition by h.IDCARDNO,d.WAREID
                          order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as 购买10601875总数量,
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
     after10601875 as (select a.SALENO, a.ACCDATE, d.WAREQTY, 药店所在省份, 药店所在城市,
                              h.busno, s.ORGNAME, d.WAREID,
                              w.WARENAME, h.IDCARDNO, h.USERNAME,
                              购买10601875总数量 as j皮下曲妥珠单抗支数,
                              sum(d.WAREQTY) over ( partition by h.IDCARDNO,d.WAREID
                                  order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as k转皮下后帕妥珠单抗支数,
                              0 as l皮下phegso支数,
                              Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS r本店最近一次购药时间,
                              LAG(a.ACCDATE, 1)
                                  OVER (PARTITION BY h.IDCARDNO,d.WAREID ORDER BY a.ACCDATE ) AS s本店前一次购药时间,
                              min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS ac本店第一次购药时间,
                              (Max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) -
                               min(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) +
                               21) / 21 as M理论购药支数,
                              count(distinct a.ACCDATE) over ( partition by h.IDCARDNO) as q本店累计购药次数,
                              row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE desc) rn2

                       from t_remote_prescription_h h
                                join t_sale_h a on substr(a.notes, 0,
                                                          decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                                 instr(a.notes, ' ')) - 1) =
                                                   h.CFNO
                                join t_sale_d d on a.SALENO = d.SALENO
                                left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
                                left join d_patient_files fi on fi.IDCARDNO = h.IDCARDNO
                                join s_busi s on h.BUSNO = s.BUSNO
                                join t_ware_base w on w.WAREID = d.WAREID
                                join first
                                     on first.IDCARDNO = h.IDCARDNO and a.ACCDATE >= first.本店第一次购10601875时间 and
                                        first.rn = 1
                       where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308))
select first.busno,
       first.ORGNAME, first.药店所在省份, first.药店所在城市,
--        WAREID, WARENAME,
       first.IDCARDNO, first.USERNAME,
--        用药方案,
--        该方案曲妥珠单抗是否为赫赛汀, 疾病分期, 是否早期新辅助治疗,
       files.新皮下方案 as i新皮下方案,
       first.购买10601875总数量 as j皮下曲妥珠单抗支数,
       k转皮下后帕妥珠单抗支数,
       l皮下phegso支数,
       M理论购药支数,
       case when M理论购药支数 - j皮下曲妥珠单抗支数 >= 1 then '有非本店购买可能' else '皆在本店购买' end as n实际药房购药期间盒数偏差分析,
       case when j皮下曲妥珠单抗支数 + l皮下phegso支数 - q本店累计购药次数 < 0 then '重新核查盒数' else '0' end as o皮下支数核查,
       case
           when files.新皮下方案 = '双靶(曲妥珠单抗HSC+帕妥珠单抗)' and k转皮下后帕妥珠单抗支数 < q本店累计购药次数
               then '重新核查盒数'
           else '0' end as p转皮下后帕妥支数核查,
       q本店累计购药次数,
       r本店最近一次购药时间,
       s本店前一次购药时间,
       r本店最近一次购药时间 - s本店前一次购药时间 as t最近两次购药周期,
       r本店最近一次购药时间 + 21 as u本店下次理论购药时间,
       case when k转皮下后帕妥珠单抗支数 >= 19 then 'Y' else 'N' end as v推测是否已完成疗程,
       trunc(sysdate - r本店最近一次购药时间) as w最近一次购药距离今日天数,
       trunc(r本店最近一次购药时间 - ac本店第一次购药时间) as x最近购药距首次购药累计时长,
       case
           when q本店累计购药次数 <= 1 then null
           else (trunc(r本店最近一次购药时间 - ac本店第一次购药时间)) / (q本店累计购药次数 - 1) end as y2022年以来本店平均购药周期,
       hf.sfday as 随访时间, hf.sfresult as 随访反馈, hf.notes as 随访备注,
       ac本店第一次购药时间, rn2
from first
         left join after10601875 aa on first.IDCARDNO = aa.IDCARDNO and aa.rn2 = 1
         left join d_luoshi_px_hf hf on aa.IDCARDNO = hf.idcard
         left join d_patient_files files on files.IDCARDNO = aa.IDCARDNO
where rn = 1
/

