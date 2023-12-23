SELECT *  from  d_zhyb_year_2023 ORDER BY execdate DESC 


         
         create table d_zhyb_year_2023
( 
  
  execdate DATE,
  customer VARCHAR2(50),
  idcard   VARCHAR2(50),
  cbdid    VARCHAR2(20),
  cbd      VARCHAR2(40),
  busno    NUMBER
)
DROP TABLE  d_zhyb_year_2023

DELETE from d_zhyb_year_2022_1
INSERT into d_zhyb_year_2022_1
SELECT execdate, customer, idcard, cbdid, cbd,busno,SALENO,CBRYLX FROM (
SELECT execdate, customer, idcard, cbdid, cbd,busno,SALENO,CBRYLX,
ROW_NUMBER() OVER (PARTITION BY idcard ORDER BY execdate DESC) rn
FROM d_zhyb_year_2022
) WHERE rn=1
SELECT * from d_zhyb_year_2022_1
--取医保来诊所的顾客最后一次消费记录
INSERT INTO d_zhyb_year_2023_zs 
SELECT a.execdate,a.customer,a.idcard,a.cbdid,a.cbd,a.busno FROM(
SELECT a.execdate,a.customer,a.idcard,a.cbdid,a.cbd,a.busno,
ROW_NUMBER() OVER (PARTITION BY a.idcard ORDER BY a.execdate DESC) rn
 from d_zhyb_year_2023 a
JOIN t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode=30511) a
WHERE rn=1
--取医保来门店的顾客最后一次消费记录
INSERT INTO d_zhyb_year_2023_yd
SELECT a.execdate,a.customer,a.idcard,a.cbdid,a.cbd,a.busno FROM(
SELECT a.execdate,a.customer,a.idcard,a.cbdid,a.cbd,a.busno,
ROW_NUMBER() OVER (PARTITION BY a.idcard ORDER BY a.execdate DESC) rn
 from d_zhyb_year_2023 a
JOIN t_busno_class_set ts on a.busno=ts.busno and ts.classgroupno ='305' AND ts.classcode=30510) a
WHERE rn=1
SELECT * FROM d_zhyb_year_2023_yd 
SELECT * from d_zhyb_year_2022_notyd
DELETE from d_zhyb_year_2022_notzs
SELECT * from d_zhyb_year_2022_notzs

--插入最后展示数据
INSERT into d_zhyb_year_2022_notzs 
SELECT a.*  FROM d_zhyb_year_2022_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_zs b WHERE a.idcard=b.idcard)

INSERT into d_zhyb_year_2022_notyd 
SELECT a.*  FROM d_zhyb_year_2022_1  a
WHERE NOT EXISTS(SELECT 1 FROM d_zhyb_year_2023_yd b WHERE a.idcard=b.idcard)

