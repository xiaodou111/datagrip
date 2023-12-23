SELECT cfno, username, sex, age, address, doctorname, zd 
from  D_OMS_SGCF_DR 
GROUP BY cfno, username, sex, age, address, doctorname, zd 
HAVING COUNT(*)>1 AND MAX(CFDOCTOR) IS NULL
,CFDOCTOR

SELECT * from D_OMS_SGCF_DR

--查找不重复的数据
SELECT * FROM(
SELECT cfno, username, sex, age, address, doctorname, zd,cfdoctor,
row_number() over(partition by cfno, username, sex, age, address, doctorname, zd order by cfdoctor) rn
FROM D_OMS_SGCF_DR) WHERE rn=1

--查找重复数据
SELECT * FROM(
SELECT cfno, username, sex, age, address, doctorname, zd,cfdoctor,
row_number() over(partition by cfno, username, sex, age, address, doctorname, zd order by cfdoctor) rn
FROM D_OMS_SGCF_DR) WHERE rn<>1
--删除重复数据中cfdoctor为空的
DELETE  FROM D_OMS_SGCF_DR WHERE ROWID IN (
SELECT ROWID FROM(
SELECT cfno, username, sex, age, address, doctorname, zd,cfdoctor,ROWID,
row_number() over(partition by cfno, username, sex, age, address, doctorname, zd order by cfdoctor) rn
FROM D_OMS_SGCF_DR  ) WHERE rn<>1  )
