with zmdz as (
    select busno,zmdz1,ORGNAME from s_busi where zmdz1 in (81001,81006)
)
select busno,zmdz1,orgname,
LISTAGG(busno,',') WITHIN group (ORDER BY busno)  OVER (PARTITION BY zmdz1) RANK
from zmdz;


with zmdz as (
    select busno,zmdz1,ORGNAME from s_busi where zmdz1 in (81001,81006)
)
select zmdz1,
LISTAGG(busno,',') WITHIN group (ORDER BY busno)  as LISTAGG
-- LISTAGG(busno,',') WITHIN group (ORDER BY busno)  OVER (PARTITION BY zmdz1) RANK
from zmdz
group by zmdz1;

SELECT LISTAGG(HOSPITAL || '~t' || HOSPITAL, '/') WITHIN GROUP (ORDER BY ID) AS result
FROM d_dtp_hosptial where id<>82;


WITH TEMP AS (SELECT 500 POPULATION, 'CHINA' NATION, 'GUANGZHOU' CITY
              FROM DUAL
              UNION ALL
              SELECT 1500 POPULATION, 'CHINA' NATION, 'SHANGHAI' CITY
              FROM DUAL
              UNION ALL
              SELECT 500 POPULATION, 'CHINA' NATION, 'BEIJING' CITY
              FROM DUAL
              UNION ALL
              SELECT 1000 POPULATION, 'USA' NATION, 'NEW YORK' CITY
              FROM DUAL
              UNION ALL
              SELECT 500 POPULATION, 'USA' NATION, 'BOSTOM' CITY
              FROM DUAL
              UNION ALL
              SELECT 500 POPULATION, 'JAPAN' NATION, 'TOKYO' CITY
              FROM DUAL)
SELECT POPULATION,
       NATION,
       CITY,
       LISTAGG(CITY, ',') WITHIN GROUP (ORDER BY CITY) OVER (PARTITION BY NATION) RANK
FROM TEMP;

WITH TEMP AS (SELECT 'CHINA' NATION, 'GUANGZHOU' CITY
              FROM DUAL
              UNION ALL
              SELECT 'CHINA' NATION, 'SHANGHAI' CITY
              FROM DUAL
              UNION ALL
              SELECT 'CHINA' NATION, 'BEIJING' CITY
              FROM DUAL
              UNION ALL
              SELECT 'USA' NATION, 'NEW YORK' CITY
              FROM DUAL
              UNION ALL
              SELECT 'USA' NATION, 'BOSTOM' CITY
              FROM DUAL
              UNION ALL
              SELECT 'JAPAN' NATION, 'TOKYO' CITY
              FROM DUAL)
SELECT NATION, LISTAGG(CITY, ',') WITHIN GROUP (ORDER BY CITY) AS CITIES
FROM TEMP
GROUP BY NATION;