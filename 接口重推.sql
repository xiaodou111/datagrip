---hd_out_dist_dssm_h  调拨单,不能随便推
---hd_out_distapply_app_h  配送申请单,请货单
---hd_out_distapply_rap_h   退仓申请单
---hd_out_abnormity_h  盘点作业单，损益单
--p_distapply_msg
CALL p_distapply_msg('230615432297') --输入四种单号之一获取msg
call p_hd_out_dist_dssm_h(202305048100981293) --调拨单
call p_hd_out_distapply_app_h(221207165833) --配送申请单,请货单
call p_hd_out_distapply_rap_h(2211190053537)  --退仓申请单
CALL p_hd_out_abnormity_h(22111411660794) --盘点作业单，损益单
call    p_jkctsj(22111412640445) --MSG_ID,COMPID,BILLCODE 

SELECT * FROM hd_out_dist_dssm_h where DISTNO='23040500003811' 
SELECT * FROM hd_out_distapply_app_h where applyno='230516607378'
SELECT * FROM hd_out_distapply_rap_h where applyno='2211190053537';--fq_time between to_date('2022/11/03 13:00:00','YYYY-MM-DD HH24:MI:SS')
--and to_date('2022/11/04 00:00:00','YYYY-MM-DD HH24:MI:SS')
SELECT * FROM hd_out_abnormity_h where ABNORMITYNO='23021050462391'

SELECT * FROM t_distapply_h where applyno='230615432297'
SELECT * FROM t_distapply_d where applyno='230615432297'
SELECT * FROM t_abnormity_h WHERE abnormityno='23080290630252'

SELECT abnormityno,a.wareid,WAREQTYA as 损溢后数量,WAREQTYB as 损溢前数量,SAP_BATID as sap批号,a.makeno as 生产批号,a.batid as 批次号 FROM t_abnormity_d a
left join t_store_i c on a.wareid=c.wareid and a.batid=c.batid
WHERE abnormityno='23080290630252' and  WAREQTYB-WAREQTYA<>0
select * from t_abnormity_d WHERE abnormityno='23080290630252'

SELECT * FROM t_dist_h where distno='221122359371'

SELECT * from t_store_d WHERE busno=81049 AND wareid=10232868 AND batid=2345120


-----接口重推
insert into hd_msg_out(msg_id,fq_time,outer_msg_id,outer_timestamp, source_system,
                        target_system,compid,table_type,status,trans_falg,error_times,error_lasttime,
                        has_notify,http_code,msg, notes,createtime,createuser,billno,billcode) 
                          
                        select msg_id,fq_time,outer_msg_id,outer_timestamp, source_system,
                        target_system,compid,table_type,0,trans_falg,error_times,error_lasttime,
                        has_notify,http_code,msg, notes,createtime,createuser,billno,billcode 
                        from hd_msg_out_bak where MSG_ID ='10100000000155450687'
                        union  
                         select msg_id,fq_time,outer_msg_id,outer_timestamp, source_system,
                        target_system,compid,table_type,0,trans_falg,error_times,error_lasttime,
                        has_notify,http_code,msg, notes,createtime,createuser,billno,billcode 
                         from hd_msg_out_error where  MSG_ID ='10100000000155450687'  ;

----3.删除以处理记录     
 ---注意  第二第三步需同时执行 ，统一提交                     
                        delete from hd_msg_out_bak where MSG_ID in (select msg_id from d_bl_saleno)    ;   
                                              
                        delete from hd_msg_out_error  WHERE MSG_ID in (select msg_id from d_bl_saleno)    ;   
                        
                        
                        
                        SELECT b.srcbusno as 调出门店,b.objbusno as 调入门店,a.wareid as 商品编码,
                        a.wareqty as 商品数量,c.sap_batid as sap批次 
                         FROM   t_dist_d a 
                        inner join t_dist_h b on a.distno=b.distno
                        left join t_store_i c on a.wareid=c.wareid and a.batid=c.batid
                        WHERE a.distno='23080290630252'
                        
                        
                        
                        MSG_ID in (select MSG_ID from hd_out_distapply_rap_h  where fq_time between to_date('2022/11/03 13:00:00','YYYY-MM-DD HH24:MI:SS') 
and to_date('2022/11/04 00:00:00','YYYY-MM-DD HH24:MI:SS')  );  

select * from t_dist_h where distno='231004182897' 
