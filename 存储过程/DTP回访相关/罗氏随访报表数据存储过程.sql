create or replace procedure proc_luoshi_basedata

is



begin
--1.维护d_patient_files表IDCARDNO用来完成更新操作,当有新的IDCARDNO时,需要插入d_patient_files表支持海典里的更新
MERGE INTO d_patient_files T1
USING
    (select IDCARDNO, busno, rn, lastbuytime,参保地,异地标志,USERNAME,CAGE,SEX
from (select h.IDCARDNO,a.busno,cyb.参保地,cyb.异地标志,h.USERNAME,h.CAGE,h.SEX,
             row_number() over (partition by h.IDCARDNO order by a.ACCDATE desc) rn,
             max(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS lastbuytime
      from t_remote_prescription_h h
                        join t_sale_h a on substr(a.notes, 0,
                                                  decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                         instr(a.notes, ' ')) -
                                                  1) =
                                           h.CFNO
                        join t_sale_d d on a.SALENO = d.SALENO
      left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
      where
--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308))
where lastbuytime>date'2023-01-01' and rn=1 and IDCARDNO is not null) T2
ON (T1.IDCARDNO = T2.IDCARDNO )

WHEN NOT MATCHED THEN
    INSERT (IDCARDNO,BUSNO,参保地,异地标志,USERNAME,CAGE,SEX)
    VALUES (T2.IDCARDNO,T2.BUSNO,t2.参保地,t2.异地标志,t2.USERNAME,t2.CAGE,t2.SEX);
--2.每天更新身份证号对应的序号
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

-- 3.更新汇总表里使用的静脉和皮下数据
MERGE INTO d_luoshi_jmsf_1 T1
USING
(
select busno, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO, USERNAME, 用药方案,
                                    该方案曲妥珠单抗是否为赫赛汀, 疾病分期, 是否早期新辅助治疗, k患者本店总购药支数,
                                    l二二年1月以前累计购药盒数, m二二年1月以来本店累计购药支数, N理论购药支数,
                                    o实际药房购药期间盒数偏差分析, p本店购买盒数核查, q本店累计购药次数, r本店最近一次购药时间,
                                    s本店前一次购药时间, t最近两次购药周期, u本店下次理论购药时间, v推测是否已完成疗程,
                                    w最近一次购药距离今日天数, x最近购药距首次购药累计时长, y2022年以来本店平均购药周期,
                                    随访时间, 随访反馈, 随访备注, ac本店第一次购药时间, rn
                             from v_luoshi_jmsf where IDCARDNO is not null
)  T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
WHEN MATCHED THEN
UPDATE SET
           T1.k患者本店总购药支数= T2.k患者本店总购药支数,
           T1.l二二年1月以前累计购药盒数= T2.l二二年1月以前累计购药盒数,
           T1.m二二年1月以来本店累计购药支数= T2.m二二年1月以来本店累计购药支数,
           T1.N理论购药支数= T2.N理论购药支数,
           T1.o实际药房购药期间盒数偏差分析= T2.o实际药房购药期间盒数偏差分析,
           T1.p本店购买盒数核查= T2.p本店购买盒数核查,
           T1.q本店累计购药次数= T2.q本店累计购药次数,
           T1.r本店最近一次购药时间= T2.r本店最近一次购药时间,
           T1.s本店前一次购药时间= T2.s本店前一次购药时间,
           T1.t最近两次购药周期= T2.t最近两次购药周期,
           T1.u本店下次理论购药时间= T2.u本店下次理论购药时间,
           T1.v推测是否已完成疗程= T2.v推测是否已完成疗程,
           T1.w最近一次购药距离今日天数= T2.w最近一次购药距离今日天数,
           T1.x最近购药距首次购药累计时长= T2.x最近购药距首次购药累计时长,
           T1.y2022年以来本店平均购药周期= T2.y2022年以来本店平均购药周期,
           T1.ac本店第一次购药时间= T2.ac本店第一次购药时间

WHEN NOT MATCHED THEN
INSERT (busno, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO, USERNAME, 用药方案,
                                    该方案曲妥珠单抗是否为赫赛汀, 疾病分期, 是否早期新辅助治疗, k患者本店总购药支数,
                                    l二二年1月以前累计购药盒数, m二二年1月以来本店累计购药支数, N理论购药支数,
                                    o实际药房购药期间盒数偏差分析, p本店购买盒数核查, q本店累计购药次数, r本店最近一次购药时间,
                                    s本店前一次购药时间, t最近两次购药周期, u本店下次理论购药时间, v推测是否已完成疗程,
                                    w最近一次购药距离今日天数, x最近购药距首次购药累计时长, y2022年以来本店平均购药周期,
                                    随访时间, 随访反馈, 随访备注, ac本店第一次购药时间, rn)
VALUES(T2.busno, T2.ORGNAME, T2.药店所在省份, T2.药店所在城市, T2.IDCARDNO, T2.USERNAME, T2.用药方案,
        T2.该方案曲妥珠单抗是否为赫赛汀, T2.疾病分期, T2.是否早期新辅助治疗, T2.k患者本店总购药支数,
        T2.l二二年1月以前累计购药盒数, T2.m二二年1月以来本店累计购药支数, T2.N理论购药支数,
        T2.o实际药房购药期间盒数偏差分析, T2.p本店购买盒数核查, T2.q本店累计购药次数, T2.r本店最近一次购药时间,
        T2.s本店前一次购药时间, T2.t最近两次购药周期, T2.u本店下次理论购药时间, T2.v推测是否已完成疗程,
        T2.w最近一次购药距离今日天数, T2.x最近购药距首次购药累计时长, T2.y2022年以来本店平均购药周期,
        T2.随访时间, T2.随访反馈, T2.随访备注, T2.ac本店第一次购药时间, T2.rn);

--罗氏皮下
merge into d_luoshi_pxsf_1 T1
using (
  select BUSNO, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO, USERNAME, 疾病分期, 是否早期新辅助治疗, 新皮下方案,
       J皮下曲妥珠单抗支数, K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析,
       O皮下支数核查, P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, 随访时间, 随访反馈, 随访备注, AC本店第一次购药时间, RN
from v_luoshi_pxsf where IDCARDNO is not null
) T2
ON ( T1.IDCARDNO=T2.IDCARDNO)
WHEN MATCHED THEN
UPDATE SET
           T1.J皮下曲妥珠单抗支数= T2.J皮下曲妥珠单抗支数,
           T1.K转皮下后帕妥珠单抗支数= T2.K转皮下后帕妥珠单抗支数,
           T1.L皮下PHEGSO支数= T2.L皮下PHEGSO支数,
           T1.M理论购药支数= T2.M理论购药支数,
           T1.N实际药房购药期间盒数偏差分析= T2.N实际药房购药期间盒数偏差分析,
           T1.O皮下支数核查= T2.O皮下支数核查,
           T1.P转皮下后帕妥支数核查= T2.P转皮下后帕妥支数核查,
           T1.Q本店累计购药次数= T2.Q本店累计购药次数,
           T1.R本店最近一次购药时间= T2.R本店最近一次购药时间,
           T1.S本店前一次购药时间= T2.S本店前一次购药时间,
           T1.T最近两次购药周期= T2.T最近两次购药周期,
           T1.U本店下次理论购药时间= T2.U本店下次理论购药时间,
           T1.V推测是否已完成疗程= T2.V推测是否已完成疗程,
           T1.W最近一次购药距离今日天数= T2.W最近一次购药距离今日天数,
           T1.X最近购药距首次购药累计时长= T2.X最近购药距首次购药累计时长,
           T1.Y2022年以来本店平均购药周期= T2.Y2022年以来本店平均购药周期,
           T1.AC本店第一次购药时间= T2.AC本店第一次购药时间
WHEN NOT MATCHED THEN
INSERT(BUSNO, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO, USERNAME, J皮下曲妥珠单抗支数,
       K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
       P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, 随访时间, 随访反馈, 随访备注, AC本店第一次购药时间)
VALUES(T2.BUSNO, T2.ORGNAME, T2.药店所在省份, T2.药店所在城市, T2.IDCARDNO, T2.USERNAME, T2.J皮下曲妥珠单抗支数,
T2.K转皮下后帕妥珠单抗支数, T2.L皮下PHEGSO支数, T2.M理论购药支数, T2.N实际药房购药期间盒数偏差分析, T2.O皮下支数核查,
T2.P转皮下后帕妥支数核查, T2.Q本店累计购药次数, T2.R本店最近一次购药时间, T2.S本店前一次购药时间, T2.T最近两次购药周期,
T2.U本店下次理论购药时间, T2.V推测是否已完成疗程, T2.W最近一次购药距离今日天数, T2.X最近购药距首次购药累计时长,
T2.Y2022年以来本店平均购药周期, T2.随访时间, T2.随访反馈, T2.随访备注, T2.AC本店第一次购药时间);



-- delete from  D_LUOSHI_JMSF;
-- insert into D_LUOSHI_JMSF
-- select BUSNO, ORGNAME,  IDCARDNO, K患者本店总购药支数, L二二年1月以前累计购药盒数, M二二年1月以来本店累计购药支数,
--        N理论购药支数, O实际药房购药期间盒数偏差分析, P本店购买盒数核查, Q本店累计购药次数, R本店最近一次购药时间,
--        S本店前一次购药时间, T最近两次购药周期, U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数,
--        X最近购药距首次购药累计时长, Y2022年以来本店平均购药周期, AC本店第一次购药时间,
--        RN
-- from v_luoshi_jmsf;
--
-- delete from  d_luoshi_pxsf;
-- --海典直接查太慢v_luoshi_pxsf_temp,用 v_luoshi_pxsf 查 d_luoshi_pxsf
-- insert into d_luoshi_pxsf
-- select BUSNO, ORGNAME, "药店所在省份", "药店所在城市", IDCARDNO, USERNAME, I新皮下方案, J皮下曲妥珠单抗支数,
--        K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
--        P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
--        U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
--        Y2022年以来本店平均购药周期, "随访时间", "随访反馈", "随访备注", AC本店第一次购药时间, RN2
-- from
-- v_luoshi_pxsf_temp;

end ;