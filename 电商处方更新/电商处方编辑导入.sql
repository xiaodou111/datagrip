CALL proc_sale_customer_all()--三合一


--双轨制药品销售登记表(病情主诉)
CALL proc_sale_customer_data();  --t_sale_mes_customer_temp2   MERGE INTO t_sale_mes_customer
--电商处方编辑
CALL proc_oms_dscf()  --d_oms_sgcf_dr    merge into  d_oms_sgcf_h

merge into  d_oms_sgcf_h a
using (SELECT * FROM  d_oms_sgcf_dr WHERE status=0) b
on (a.cfno=b.cfno)
when matched then 
  update set a.username=nvl(a.username,trim(replace(b.username,',',''))) ,
  a.SEX=nvl(a.SEX,trim(replace(b.SEX,',',''))),
  a.age=nvl(a.age,trim(replace(b.age,',',''))),
 a.address=nvl(a.address,trim(replace(b.address,',',''))),
  a.DOCTORNAME=nvl(a.DOCTORNAME,trim(replace(b.doctorname,',',''))),
 a.ZDCONT=nvl(a.ZDCONT,trim(replace(b.ZD,',',''))),
 a.DOCTOR =nvl(a.DOCTOR,trim(replace(b.cfdoctor,',','')));
  DELETE from d_oms_sgcf_dr;
  
------单轨导入后更新(处方来源单号) --d_cf_dr     merge into  t_remote_prescription_h
CALL proc_t_remote_prescription_h()

merge into  t_remote_prescription_h a
using d_cf_dr b
on (a.cfno=b.cfno)
when matched then 
  update set a.username=nvl(a.username,trim(replace(b.username,',',''))) ,
  a.SEX=nvl(a.SEX,trim(replace(b.SEX,',',''))),
  a.cage=nvl(a.cage,trim(replace(b.age,',',''))),
 a.address=nvl(a.address,trim(replace(b.address,',',''))),
  a.DOCTORNAME=nvl(a.DOCTORNAME,trim(replace(b.CFYY,',',''))),
 a.ZDCONT=nvl(a.ZDCONT,trim(replace(b.ZD,',',''))),
 a.doctor  = nvl(a.doctor,trim(replace(b.cfys,',','')))
 ;
 
 delete from  t_remote_prescription_h
 
 merge into  d_oms_sgcf_h a
 USING T_doctor_hos_zd_temp b
 ON (a.cfno=TRIM(b.cfno))
 when matched then 
 UPDATE SET a.doctor=b.doctor,
 a.doctorname=b.doctorname,
 a.zdcont=b.zdcont
 SELECT * from T_doctor_hos_zd_temp
 DELETE from T_doctor_hos_zd_temp

