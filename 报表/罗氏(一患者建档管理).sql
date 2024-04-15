
-- with px_date as (select *
--                  --在这个表中说明属于转皮下了
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
--最后一次购药在2023.1.1以前的不建档,首次建档后，后续换门店的话，把药店名称改成最新的那家
--海典报表
select busno, ORGNAME, 药店所在省份, 药店所在城市, IDCARDNO,rank,
       USERNAME, CAGE, SEX, 就诊医院科室病区, 参保地,
       异地标志, 患者是否知情, 是否同意将信息反馈给主治医生, 随访人姓名, 随访人与患者关系, 随访人联系电话, 疾病分期,
       是否早期新辅助治疗, 原用药方案, 该方案曲妥珠单抗是否为赫赛汀, 如为其他方案请选具体方案, 新皮下方案,
       是否静脉转化为皮下,
       是否联合化疗, 是否手术, ER雌激素受体是否阳性, PR孕激素受体是否阳性, 是否有淋巴结转移, 是否转移有远处器官转移,
       疾病首次确诊时间, 首次输注购买帕妥或曲妥的时间, 首诊医院, 患者非本店购药帕妥或曲妥支数, 患者本店静脉购药支数,
       患者本店皮下购药支数
from (select
--     a.ACCDATE,a.SALENO,h.CFNO,
fi.busno, s.ORGNAME, tb.CLASSNAME as 药店所在省份, tb1.CLASSNAME as 药店所在城市, fi.IDCARDNO,
substr(fi.IDCARDNO,-10) as RANK,
fi.USERNAME, CAGE, SEX, fi.就诊医院科室病区,
fi.医保归属地 as 参保地, fi.是否异地医保 as 异地标志,
fi.患者是否知情, fi.是否同意将信息反馈给主治医生 as 是否同意将信息反馈给主治医生, fi.随访人姓名, fi.随访人与患者关系,
fi.随访人联系电话,
fi.疾病分期, fi.是否早期新辅助治疗, fi.原用药方案, fi.该方案曲妥珠单抗是否为赫赛汀, fi.如为其他方案请选具体方案,
fi.新皮下方案, fi.是否静脉转化为皮下, fi.是否联合化疗, fi.是否手术, fi.ER雌激素受体是否阳性, fi.PR孕激素受体是否阳性,
fi.是否有淋巴结转移, fi.是否转移有远处器官转移,
fi.疾病首次确诊时间 as 疾病首次确诊时间, fi.首次输注时间 as 首次输注购买帕妥或曲妥的时间,
fi.首诊医院 as 首诊医院, fi.患者非本店购药帕妥或曲妥支数,
nvl(jm.K患者本店总购药支数,0)+nvl(px.K转皮下后帕妥珠单抗支数,0) as 患者本店静脉购药支数,
px.J皮下曲妥珠单抗支数 as 患者本店皮下购药支数
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

alter table d_patient_files  add 参保地 varchar2(40);
alter table d_patient_files  add 异地标志 varchar2(40);
select * from d_patient_files;




select * from d_patient_files;


select * from d_luoshi_pxsf;
select * from D_LUOSHI_JMSF_1;
select * from d_luoshi_pxsf_1;


alter table d_patient_files add 就诊医院科室病区 varchar2(200);
alter table d_patient_files add 医保归属地 varchar2(40);
alter table d_patient_files add 是否异地医保 varchar2(6);
alter table d_patient_files add 疾病首次确诊时间 date;
alter table d_patient_files add 首诊医院 varchar2(200);
alter table d_patient_files add username varchar2(40);
alter table d_patient_files add cage varchar2(40);
alter table d_patient_files add sex varchar2(2);
select * from d_patient_files;
UPDATE d_patient_files SET 是否早期新辅助治疗='是' WHERE idcardno='330324197209215762';
select * from D_LUOSHI_JMSF;

select * from D_ZHYB_HZ_CYB where ERP销售单号='2403181248079181';






create table D_LUOSHI_JMSF as
select BUSNO, ORGNAME,  IDCARDNO, K患者本店总购药支数, L二二年1月以前累计购药盒数, M二二年1月以来本店累计购药支数,
       N理论购药支数, O实际药房购药期间盒数偏差分析, P本店购买盒数核查, Q本店累计购药次数, R本店最近一次购药时间,
       S本店前一次购药时间, T最近两次购药周期, U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数,
       X最近购药距首次购药累计时长, Y2022年以来本店平均购药周期, AC本店第一次购药时间,
       RN
from v_luoshi_jmsf;


select BUSNO, ORGNAME,  IDCARDNO, K患者本店总购药支数, L二二年1月以前累计购药盒数, M二二年1月以来本店累计购药支数,
       N理论购药支数, O实际药房购药期间盒数偏差分析, P本店购买盒数核查, Q本店累计购药次数, R本店最近一次购药时间,
       S本店前一次购药时间, T最近两次购药周期, U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数,
       X最近购药距首次购药累计时长, Y2022年以来本店平均购药周期, AC本店第一次购药时间,
       RN
from v_luoshi_jmsf;

create table  d_luoshi_pxsf as
select BUSNO, ORGNAME, IDCARDNO, J皮下曲妥珠单抗支数,
       K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
       P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, AC本店第一次购药时间, RN2
from
v_luoshi_pxsf;

insert into d_luoshi_pxsf
select BUSNO, ORGNAME, IDCARDNO, J皮下曲妥珠单抗支数,
       K转皮下后帕妥珠单抗支数, L皮下PHEGSO支数, M理论购药支数, N实际药房购药期间盒数偏差分析, O皮下支数核查,
       P转皮下后帕妥支数核查, Q本店累计购药次数, R本店最近一次购药时间, S本店前一次购药时间, T最近两次购药周期,
       U本店下次理论购药时间, V推测是否已完成疗程, W最近一次购药距离今日天数, X最近购药距首次购药累计时长,
       Y2022年以来本店平均购药周期, AC本店第一次购药时间, RN2
from
v_luoshi_pxsf;


select * from D_ZHYB_HZ_CYB;


create table d_luoshi_pxsf (
    busno number,
    orgname varchar2(100),
    IDCARDNO varchar2(20),
    J皮下曲妥珠单抗支数 number,
    K转皮下后帕妥珠单抗支数  number,
    L皮下PHEGSO支数  number,
    M理论购药支数  number(6,4),
    N实际药房购药期间盒数偏差分析  varchar2(100),
    O皮下支数核查  varchar2(100),
    P转皮下后帕妥支数核查  varchar2(100),
    Q本店累计购药次数  number,
    R本店最近一次购药时间  date,
    S本店前一次购药时间  date,
    T最近两次购药周期  number,
    U本店下次理论购药时间  date,
    V推测是否已完成疗程  varchar2(20),
    W最近一次购药距离今日天数  number,
    X最近购药距首次购药累计时长  number,
    Y2022年以来本店平均购药周期  number(6,4),
    AC本店第一次购药时间  date,
    RN2  number
)

--用处方找
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


--用医保找
select a.ACCDATE,a.SALENO,cyb.身份证号,h.IDCARDNO,h.CFNO from D_ZHYB_HZ_CYB cyb
join t_sale_h a on a.SALENO=cyb.ERP销售单号
join t_sale_d d on a.SALENO = d.SALENO
left join t_remote_prescription_h h  on substr(a.notes, 0,
                                                 decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                        instr(a.notes, ' ')) - 1) =
                                          h.CFNO
 where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10600308) ---10502445,
                and cyb.身份证号 = '53293019850121172X';



select substr(IDCARDNO,-12),max(IDCARDNO) from t_remote_prescription_h group by substr(IDCARDNO,-12)
having count(*)>1;

select substr(IDCARDNO,-4),IDCARDNO from t_remote_prescription_h
                                         where substr(IDCARDNO,-12)='197010204435';



                                    group by IDCARDNO






