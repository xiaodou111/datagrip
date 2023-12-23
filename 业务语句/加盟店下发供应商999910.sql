p_rrt_in_vencus_base

                  SELECT *  FROM   hd_msg_in
                    WHERE  table_type = 1015 AND status = 0
                    
                   
                    select * from hd_msg_in where MSG_ID='POS33346D9EE75BD94AE43F3A7D377C3D81F0991'
                    --第一步
                    update hd_msg_in set status=0 where MSG_ID='POS33346D9EE75BD94AE43F3A7D377C3D81F0991'
                    --第二步
                    update hd_in_vencus_base set VENCUSCODE=999912,VENCUSNAME='佰济医药连锁(温州)有限公司'
                    ,msg_id='POS33346D9EE75BD94AE43F3A7D377C3D81F0991',msg_status=0                    
                     where SEQ_ID='POS206200A90B9C1D71E4227A36E83609E9459AB'
                     --验证
                     SELECT a.* FROM hd_in_vencus_base a WHERE a.msg_status = 0 AND a.msg_id = 'POS33346D9EE75BD94AE43F3A7D377C3D81F0991'
                     select * from hd_in_vencus_base a  WHERE a.msg_id = 'POS33346D9EE75BD94AE43F3A7D377C3D81F0991'
                     
                     select * from t_vencus where vencusno='999912'
                     select * from  t_vencus_base  where vencusno='999912'
