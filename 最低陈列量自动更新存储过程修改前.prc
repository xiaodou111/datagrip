CREATE OR REPLACE PROCEDURE proc_update_store_h_zdcll IS
    --v_conde PLS_INTEGER;
BEGIN
    /*
    业务场景：用于自动更新t_store_h表的lowestqty最低陈列量。*/
    FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_A va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid and va.mdsx=md.mddysx 
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_B va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid  and va.company=md.gsfl 
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                           WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_C va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid  and va.syb=md.sybfl
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                     WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_D va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid and va.mdsx=md.mddysx and va.company=md.gsfl 
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                     WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_E va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid and va.mdsx=md.mddysx  and va.syb=md.sybfl
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                     WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_F va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid  and va.company=md.gsfl and va.syb=md.sybfl
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_G va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid and va.mdsx=md.mddysx and va.company=md.gsfl and va.syb=md.sybfl
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     FOR rec IN (SELECT compid, busno FROM s_busi sb WHERE sb.orgtype <> '10') LOOP
        --循环除总部外每个门店的数据。
        MERGE INTO t_store_h a
        USING (SELECT va.compid, va.wareid, md.busno,va.pllx,va.mdsx,va.company,va.syb, va.lv_code, va.lowest_note,
                      CASE
                          WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN  va.lowestqty
                               WHEN md.JYBJY='2' THEN  va.lowestqty
                               WHEN md.JYBJY='3' THEN  va.lowestqty                                
                               WHEN md.JYBJY='4' THEN va.lowestqty                                
                               WHEN md.JYBJY='5' THEN va.lowestqty                              
                               WHEN md.JYBJY='6' THEN va.lowestqty                                
                               WHEN md.JYBJY='7' THEN va.lowestqty                               
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN va.lowestqty                              
                               WHEN md.fyb='2' THEN va.lowestqty                            
                               WHEN md.fyb='3' THEN va.lowestqty                               
                               WHEN md.fyb='4' THEN va.lowestqty                                
                               WHEN md.fyb='5' THEN va.lowestqty                              
                               WHEN md.fyb='6' THEN va.lowestqty                               
                                WHEN md.fyb='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN va.lowestqty                              
                               WHEN md.qbjy='2' THEN va.lowestqty                            
                               WHEN md.qbjy='3' THEN va.lowestqty                             
                               WHEN md.qbjy='4' THEN va.lowestqty                              
                               WHEN md.qbjy='5' THEN va.lowestqty                               
                               WHEN md.qbjy='6' THEN va.lowestqty                               
                               WHEN md.qbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                            WHEN  va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN va.lowestqty                               
                               WHEN md.jzsjy='2' THEN va.lowestqty                                
                               WHEN md.jzsjy='3' THEN va.lowestqty                               
                               WHEN md.jzsjy='4' THEN va.lowestqty                               
                               WHEN md.jzsjy='5' THEN va.lowestqty                                
                               WHEN md.jzsjy='6' THEN va.lowestqty                                
                               WHEN md.jzsjy='7' THEN va.lowestqty                                
                               ELSE
                                0
                           END
                             WHEN  va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN va.lowestqty                               
                               WHEN md.zsbjy='2' THEN va.lowestqty                               
                               WHEN md.zsbjy='3' THEN va.lowestqty                              
                               WHEN md.zsbjy='4' THEN va.lowestqty                               
                               WHEN md.zsbjy='5' THEN va.lowestqty                                
                               WHEN md.zsbjy='6' THEN va.lowestqty                               
                               WHEN md.zsbjy='7' THEN va.lowestqty                              
                               ELSE
                                0
                           END
                           WHEN  va.pllx = '6' THEN
                           --双通道门店
                           CASE
                               WHEN md.stdmd='1' THEN va.lowestqty
                               WHEN md.stdmd='2' THEN va.lowestqty
                               WHEN md.stdmd='3' THEN va.lowestqty
                               WHEN md.stdmd='4' THEN va.lowestqty
                               WHEN md.stdmd='5' THEN va.lowestqty
                               WHEN md.stdmd='6' THEN va.lowestqty
                               WHEN md.stdmd='7' THEN va.lowestqty 
                           END
                           END AS lowestqty
               FROM   V_CLL_LOWEST_H va
               INNER  JOIN v_mdjydj md
                ON     va.compid=md.compid and md.sfstdmd='32810' and va.pllx='6' 
                --and va.mdsx=md.mddysx and va.company=md.gsfl and va.syb=md.sybfl
               where lv_code=
               case
                WHEN va.pllx = '1' THEN
                          --医保药品，仅医保经营
                           CASE
                               WHEN md.JYBJY='1' THEN '特A'
                               WHEN md.JYBJY='2' THEN  'A'
                               WHEN md.JYBJY='3' THEN  'B'
                               WHEN md.JYBJY='4' THEN  'C'
                               WHEN md.JYBJY='5' THEN  'D'
                               WHEN md.JYBJY='6' THEN  'E'
                                WHEN md.JYBJY='7' THEN  'F'
                               ELSE
                               ''
                           END
                WHEN va.pllx = '2' THEN
                          --非医保药品
                           CASE
                               WHEN md.fyb='1' THEN '特A'
                               WHEN md.fyb='2' THEN  'A'
                               WHEN md.fyb='3' THEN  'B'
                               WHEN md.fyb='4' THEN  'C'
                               WHEN md.fyb='5' THEN  'D'
                               WHEN md.fyb='6' THEN  'E'
                                WHEN md.fyb='7' THEN  'F'
                               ELSE
                               ''
                           END
                  WHEN va.pllx = '3' THEN
                          --医保药品，全部经营
                           CASE
                               WHEN md.qbjy='1' THEN '特A'
                               WHEN md.qbjy='2' THEN  'A'
                               WHEN md.qbjy='3' THEN  'B'
                               WHEN md.qbjy='4' THEN  'C'
                               WHEN md.qbjy='5' THEN  'D'
                               WHEN md.qbjy='6' THEN  'E'
                                WHEN md.qbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                   WHEN va.pllx = '4' THEN
                          --医保药品，仅诊所经营
                           CASE
                               WHEN md.jzsjy='1' THEN '特A'
                               WHEN md.jzsjy='2' THEN  'A'
                               WHEN md.jzsjy='3' THEN  'B'
                               WHEN md.jzsjy='4' THEN  'C'
                               WHEN md.jzsjy='5' THEN  'D'
                               WHEN md.jzsjy='6' THEN  'E'
                                WHEN md.jzsjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '5' THEN
                          --医保药品，诊所不经营
                           CASE
                               WHEN md.zsbjy='1' THEN '特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                                WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                           END
                    WHEN va.pllx = '6' THEN
                          --双通道门店
                          CASE
                               WHEN md.stdmd='1' THEN'特A'
                               WHEN md.zsbjy='2' THEN  'A'
                               WHEN md.zsbjy='3' THEN  'B'
                               WHEN md.zsbjy='4' THEN  'C'
                               WHEN md.zsbjy='5' THEN  'D'
                               WHEN md.zsbjy='6' THEN  'E'
                               WHEN md.zsbjy='7' THEN  'F'
                               ELSE
                               ''
                            END
                            END
               ) b
        ON (a.compid = b.compid AND a.wareid = b.wareid )
        WHEN MATCHED THEN
           UPDATE SET a.lowestqty = b.lowestqty         
       WHEN NOT MATCHED THEN          
              INSERT  (a.lowestqty)  values (b.lowestqty);             
    END LOOP;
    
     COMMIT;
END  proc_update_store_h_zdcll;
/
