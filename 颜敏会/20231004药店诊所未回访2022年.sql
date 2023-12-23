alter table d_zhyb_year_2022_yd add saleno VARCHAR2(50); 
alter table d_zhyb_year_2022_yd add CBRYLX varchar2(200); 
alter table d_zhyb_year_2022_zs add saleno VARCHAR2(50); 
alter table d_zhyb_year_2022_zs add CBRYLX varchar2(200); 
select * from 
D_ZHYB_YEAR_2022_ZS

 --ÿ�����֤22�� ҩ�����ڵغͲα��ض�Ӧ�� ���һ�����������ѵļ�¼
    delete from D_ZHYB_YEAR_2022_ZS;
    INSERT INTO D_ZHYB_YEAR_2022_ZS (execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx)
    SELECT execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,saleno,cbrylx,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM v_zhyb_year_2022 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30511'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate < DATE '2023-01-01'
  and 
   --ȡ�α��غ�ҩ�����ڵض�Ӧ������
    CASE WHEN a.cbd IN ('̨���б���','̨���н�����','̨���л�����','̨����·����')
 
  and CBRYLX='ҽ��'  THEN 'ҽ���б���' 
  when a.cbd IN ('̨���б���','̨���н�����') and CBRYLX='ũ��'  THEN 'ũ���б���'
    else a.cbd end 
      =
      case when replace(tb2.classname,'̨��������','̨��������')  in ('̨���б���','̨���н�����','̨���л�����','̨����·����')
    and CBRYLX='ҽ��'  THEN 'ҽ���б���' 
    when replace(tb2.classname,'̨��������','̨��������') IN ('̨���б���','̨���н�����') and CBRYLX='ũ��'  THEN 'ũ���б���'
      else  replace(tb2.classname,'̨��������','̨��������') end
) WHERE rn = 1;
--ÿ�����֤22�� ҩ�����ڵغͲα��ض�Ӧ�� ���һ����ҩ�����ѵļ�¼
 delete from d_zhyb_year_2022_yd;
   INSERT INTO d_zhyb_year_2022_yd (execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx)
     SELECT execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx  FROM (
  SELECT a.execdate, a.customer, a.idcard, a.cbdid, a.cbd, a.busno,saleno,cbrylx,
    ROW_NUMBER() OVER (PARTITION BY IDCARD ORDER BY EXECDATE DESC) rn
  FROM d_zhyb_year_2022 a
  JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30510'
  JOIN t_busno_class_set ts2 on a.busno=ts2.busno and ts2.classgroupno ='324'
   join t_busno_class_base tb2 on ts2.classgroupno=ts2.classgroupno and ts2.classcode=tb2.classcode
  WHERE a.execdate < DATE '2023-01-01'
  and 
   --ȡ�α��غ�ҩ�����ڵض�Ӧ������
    CASE WHEN a.cbd IN ('̨���б���','̨���н�����','̨���л�����','̨����·����')
 
  and CBRYLX='ҽ��'  THEN 'ҽ���б���' 
  when a.cbd IN ('̨���б���','̨���н�����') and CBRYLX='ũ��'  THEN 'ũ���б���'
    else a.cbd end 
      =
      case when replace(tb2.classname,'̨��������','̨��������')  in ('̨���б���','̨���н�����','̨���л�����','̨����·����')
    and CBRYLX='ҽ��'  THEN 'ҽ���б���' 
    when replace(tb2.classname,'̨��������','̨��������') IN ('̨���б���','̨���н�����') and CBRYLX='ũ��'  THEN 'ũ���б���'
      else  replace(tb2.classname,'̨��������','̨��������') end
) WHERE rn = 1;

 delete from d_zhyb_year_2022_notyd where execdate < DATE '2023-01-01'
 
   INSERT into d_zhyb_year_2022_notyd(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT a.*,'2022����ҩ���Ա'  FROM d_zhyb_year_2022_yd  a
WHERE NOT EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2023_1 b WHERE a.idcard=b.idcard)

delete from d_zhyb_year_2022_notzs where execdate < DATE '2023-01-01'
   INSERT into d_zhyb_year_2022_notzs(execdate,customer,idcard,cbdid,cbd,busno,saleno,cbrylx,TYPE)
SELECT a.*,'2022����������Ա'  FROM d_zhyb_year_2022_zs  a
WHERE NOT EXISTS(SELECT 1 FROM D_ZHYB_YEAR_2023_1 b WHERE a.idcard=b.idcard)


 MERGE INTO d_zhyb_year_2022_notyd a
   USING (SELECT ERP���۵���,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP���۵��� is not null and EXT_CHAR04 is not null 
   group by  ERP���۵���,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP���۵���)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;

 MERGE INTO d_zhyb_year_2022_notzs a
   USING (SELECT ERP���۵���,EXT_CHAR04
   FROM d_zhyb_hz_cyb where ERP���۵��� is not null and EXT_CHAR04 is not null 
   group by  ERP���۵���,EXT_CHAR04
    ) b
   ON (a.SALENO = b.ERP���۵���)
   WHEN MATCHED THEN
   UPDATE SET
   a.CBDW = b.EXT_CHAR04;
   
 merge into d_zhyb_year_2022_notyd
   
   /*select count(*) from d_zhyb_year_2022_notzs
   select count(*) from d_zhyb_year_2022_notyd
   
   
  SELECT count(*)   FROM d_zhyb_year_2022_1  a
JOIN t_busno_class_set ts ON a.busno = ts.busno AND ts.classgroupno = '305' AND ts.classcode = '30511'
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023 b WHERE a.idcard=b.idcard)*/

select * from d_zhyb_year_2023 where idcard='331081199302080023'
select * from v_zhybjsjlb WHERE ���֤��='331081199302080023'
delete from d_zhyb_year_2022_notyd where execdate<date'2023-01-01'



