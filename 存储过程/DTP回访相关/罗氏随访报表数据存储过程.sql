create or replace procedure proc_luoshi_basedata

is



begin
--1.维护d_patient_files表IDCARDNO用来完成更新操作,当有新的IDCARDNO时,需要插入d_patient_files表支持海典里的更新
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
--2.每天更新身份证号对应的序号
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

-- 3.更新汇总表里使用的静脉和皮下数据
delete from  D_LUOSHI_JMSF;
insert into D_LUOSHI_JMSF
select BUSNO, ORGNAME,  IDCARDNO, K患者本店总购药支数, L二二年1月以前累计购药盒数, M二二年1月以来本店累计购药支数,
       N理论购药支数, O实际药房购药期间盒数偏差分析, P本店购买盒数核查, Q本店累计购药次数, R本店最近一次购药时间,
       S本店前一次购药时间, T最近两次购药周期, U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数,
       X最近购药距首次购药累计时长, Y2022年以来本店平均购药周期, AC本店第一次购药时间,
       RN
from v_luoshi_jmsf;

delete from  d_luoshi_pxsf;
insert into d_luoshi_pxsf
select BUSNO, ORGNAME, IDCARDNO, J皮下曲妥珠单抗支数,
       K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
       P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, AC本店第一次购药时间, RN2
from
v_luoshi_pxsf;

end ;