create or replace procedure proc_nh_pjfp2

is
-----ŵ��������������
v_buscount NUMBER(8);
random_num NUMBER;
--v_wareid NUMBER(8);
v_numa NUMBER(8);
v_single NUMBER(8);
i NUMBER;

begin

 /*INSERT INTO d_nh_orgname(orgname) SELECT cgfmc 
from V_SALE_NH_P001_1 WHERE CJSJ BETWEEN DATE'2023-05-01' AND DATE'2023-05-31' AND cgfmc<>'�ŵ������' AND cgfmc<>'�ŵ��˻���'
 GROUP BY cgfmc
 INSERT INTO d_nh_warenum(wareid,ph,dj,sl)
 
  SELECT CPDM,ph,b.lastpurprice,SUM(SL) FROM V_SALE_NH_P001_1 a
 JOIN t_ware@hydee_zy b ON a.cpdm=b.wareid AND  b.compid=1000 
  WHERE CJSJ BETWEEN DATE'2023-05-01' AND DATE'2023-05-31' 
 GROUP BY CPDM,ph,b.lastpurprice 
 
 SELECT CPDM,ph,DJ,SUM(SL) FROM V_SALE_NH_P001_1 WHERE CJSJ BETWEEN DATE'2023-05-01' AND DATE'2023-05-31' 
 GROUP BY CPDM,ph,DJ 
  
  UPDATE d_nh_orgname SET ID=ROWNUM*/
DELETE from d_nh_md_fp;

 ---ѭ������    ���� --����1��2�������ɱ����������ȷ���
 for res in (SELECT wareid,ph,dj,CEIL(sl*0.65) sl  FROM  d_nh_warenum WHERE sl<>0 AND wareid IN(10111858,10114011,10111871,10115418)
             )  loop

   --�Ȼ�ȡ�����Ʒ���ŵ�
   --;
   
   v_numa:=res.sl;
   
   --10111858������,10114011��͡��3�л���3�еı�����һ�����۵��ݺŷⶥ12�У������������۽��Ҫ�����ۿۺ�ļ۸�Ϊʵ�����۶��8�ۡ������׺�������ռ�ȴ��װ
--���۵�85%  ���ѭ�����������ŵ����Ļ�������д��
  IF res.wareid IN(10111858) THEN
     --�ٷ�֮15��������1��2
     SELECT COUNT(*)
     INTO v_buscount
     FROM D_NH_ORGNAME_10111858;
     i:=1;
     v_single:=ceil(v_numa*0.15);
     WHILE v_single >= 1  LOOP
     random_num := TRUNC(DBMS_RANDOM.VALUE(1, 3)); 
     INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,res.dj*random_num
    FROM  D_NH_ORGNAME_10111858 WHERE id=i;
    i:=i+1;
    --DBMS_OUTPUT.PUT_LINE('v_single: ' || v_single);
    
    v_single:=v_single-random_num;
  
   END LOOP;
    
    i:=1;
    
    v_numa:=ceil(v_numa*0.85);
    DBMS_OUTPUT.PUT_LINE('v_numa: ' || v_numa);
    WHILE v_numa >= 3 LOOP
    random_num := TRUNC(DBMS_RANDOM.VALUE(1, 5))*3;   
    INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,random_num*res.dj*0.8
    FROM  D_NH_ORGNAME_10111858 WHERE id=i;
    
    --DBMS_OUTPUT.PUT_LINE('v_numa: ' || v_numa);
    --DBMS_OUTPUT.PUT_LINE('i: ' || i);
    i:=i+1;
    v_numa:=v_numa-random_num;
    
    END LOOP;
  END IF;
  
  IF res.wareid IN(10114011) THEN
     --�ٷ�֮15��������1��2
     SELECT COUNT(*)
     INTO v_buscount
     FROM D_NH_ORGNAME_10114011;
     i:=1;
     v_single:=ceil(v_numa*0.15);
     WHILE v_single >= 1  LOOP
     random_num := TRUNC(DBMS_RANDOM.VALUE(1, 3)); 
     INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,res.dj*random_num
    FROM  D_NH_ORGNAME_10114011 WHERE id=i;
    i:=i+1;
    --DBMS_OUTPUT.PUT_LINE('v_single: ' || v_single);
    
    v_single:=v_single-random_num;
  
   END LOOP;
    
    i:=1;
    
    v_numa:=ceil(v_numa*0.85);
    DBMS_OUTPUT.PUT_LINE('v_numa: ' || v_numa);
    WHILE v_numa >= 3 LOOP
    random_num := TRUNC(DBMS_RANDOM.VALUE(1, 5))*3;   
    INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,random_num*res.dj*0.8
    FROM  D_NH_ORGNAME_10114011 WHERE id=i;
    
    --DBMS_OUTPUT.PUT_LINE('v_numa: ' || v_numa);
    --DBMS_OUTPUT.PUT_LINE('i: ' || i);
    i:=i+1;
    v_numa:=v_numa-random_num;
    
    END LOOP;
  END IF;
  
  IF res.wareid IN(10111871,10115418) THEN
     SELECT COUNT(*)
     INTO v_buscount
     FROM D_NH_ORGNAME_10111871;
     i:=1;
     v_single:=ceil(v_numa*0.15);
     DBMS_OUTPUT.PUT_LINE('v_single: ' || v_single);
     WHILE v_single >= 1  LOOP
     random_num := TRUNC(DBMS_RANDOM.VALUE(1, 4)); 
     INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,res.dj*random_num
    FROM  D_NH_ORGNAME_10111871 WHERE id=i;
    --ѭ�����������ŵ�Ļ���˵
    IF i>v_buscount THEN
    INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,res.dj*random_num
    FROM  D_NH_ORGNAME_10111871 WHERE id=i-v_buscount;
    END IF;
    i:=i+1;
   -- DBMS_OUTPUT.PUT_LINE('i: ' || i);
    
    v_single:=v_single-random_num;
  
   END LOOP;
    i:=1;
    v_numa:=ceil(v_numa*0.85);
    DBMS_OUTPUT.PUT_LINE('v_numa: ' || v_numa);
    WHILE v_numa>=4 LOOP
    random_num := TRUNC(DBMS_RANDOM.VALUE(1, 13))*4; 
    
    INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph,je) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph,res.dj*random_num*0.8
    FROM  D_NH_ORGNAME_10111871 WHERE id=i;
    --���ѭ���������ŵ����������¿�ʼ����
    IF i>v_buscount THEN
    INSERT into d_nh_md_fp(orgname,wareid,sl,dj,ph) 
    SELECT orgname,res.wareid,random_num,res.dj,res.ph
    FROM  D_NH_ORGNAME_10111871 WHERE id=i-v_buscount;
    END IF;
    
    --10111871ŵ���׺�10115418ŵ����4�л���4�еı�����һ�����۵��ݺŷⶥ48�У�
    --�����������۽��Ҫ�����ۿۺ�ļ۸�(Ϊʵ�����۶��8�ۣ������׺�������ռ��ŵ����100����*+14sȫ�����۵�85%��
    --��ŵ����ÿһ��ƥ���Ա���š�
 
    --DBMS_OUTPUT.PUT_LINE('i: ' || i);
    
    i:=i+1;
    v_numa:=v_numa-random_num;
    
    END LOOP;
    --DBMS_OUTPUT.PUT_LINE('v_numa: ' || v_numa);
  END IF;  
   /*IF  res.wareid NOT IN(10111858,10114011,10111871,10115418) THEN 
      
   IF res.sl<v_buscount THEN
   INSERT INTO d_nh_md_fp(orgname,wareid,sl,dj,ph) 
   SELECT  orgname,res.wareid,1,res.dj,res.ph
   FROM d_nh_orgname WHERE ID<res.sl;
   ELSE
   INSERT INTO d_nh_md_fp(orgname,wareid,sl,dj,ph) 
   SELECT  orgname, res.wareid,
   CASE WHEN ID<MOD(res.sl,v_buscount) THEN FLOOR(res.sl/v_buscount)+1 ELSE FLOOR(res.sl/v_buscount) END,
   res.dj,res.ph
   FROM d_nh_orgname ;
   END IF;
   
   
   
   
 END IF;*/




 end loop ;
--���ɶ�������
UPDATE d_nh_md_fp 
SET accdate = TRUNC(SYSDATE, 'MM') + TRUNC(DBMS_RANDOM.VALUE(0, EXTRACT(DAY FROM LAST_DAY(SYSDATE)) ));
--���ɵ���
UPDATE d_nh_md_fp SET SALENO=to_char(accdate,'yymmdd')||FLOOR(DBMS_RANDOM.VALUE(100000, 1000000));

FOR res IN (SELECT saleno FROM d_nh_md_fp GROUP BY saleno HAVING COUNT(*)>1 ) LOOP
  UPDATE d_nh_md_fp SET SALENO=to_char(accdate,'yymmdd')||FLOOR(DBMS_RANDOM.VALUE(100000, 1000000))
  WHERE saleno=res.saleno;
  END LOOP;
  


--��ȡ��Ա��
--SELECT COUNT(*)
--INTO v_numnxt
-- FROM d_nh_md_fp WHERE  wareid IN(10111871,10115418);
 --�ӱ���� 
--SELECT meid FROM d_nh_md_fp WHERE  wareid IN(10111871,10115418) FOR UPDATE
   
  /*SELECT memcardno
  FROM t_memcard_reg@hydee_zy
  where rownum<=v_numnxt
  ORDER BY DBMS_RANDOM.VALUE ;*/

 end ;
