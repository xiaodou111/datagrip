SELECT d.applyno from 
t_distapply_h h  
JOIN t_distapply_d d  ON h.applyno=d.applyno
  WHERE LIABLER IS NULL 
  AND h.notes='滞销自动生成'  GROUP BY d.applyno
  status=2
UPDATE t_distapply_h SET  status=2
WHERE applyno IN (
SELECT h.applyno from 
t_distapply_h h  
JOIN t_distapply_d d  ON h.applyno=d.applyno
  WHERE LIABLER IS NULL 
  AND h.notes='滞销自动生成' GROUP BY h.applyno
) AND status<>2 
UPDATE  t_distapply_d SET LIABLER='50002455'
WHERE applyno IN (
SELECT h.applyno from 
t_distapply_h h  
JOIN t_distapply_d d  ON h.applyno=d.applyno
  WHERE LIABLER IS NULL 
  AND h.notes='滞销自动生成' GROUP BY h.applyno
)

SELECT * from 

  SELECT * from t_distapply_h
