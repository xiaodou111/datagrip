p_rrt_in_vencus_base
  --p_rrt_in_vencus_base存储过程
  --轮询消息表
    FOR rec_msg IN (SELECT *
                    FROM   hd_msg_in
                    WHERE  table_type = v_table_type AND status = 0
                    ORDER  BY outer_timestamp) LOOP
        --轮询接口表
        FOR rec IN (SELECT a.* FROM hd_in_vencus_base a WHERE a.msg_status = 0 AND a.msg_id = rec_msg.msg_id) LOOP

hd_in_vencus_base

SELECT *
                    FROM   hd_msg_in
                    WHERE  table_type = 1015 AND status = 0;
--第一步,先把MSG_ID='POS98078C1235E7A4C914A6BAD88C509E6BF2E01' 状态改为0
update hd_msg_in set status = 0  WHERE  table_type = 1015 
and MSG_ID='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8';
/*SELECT *
                    FROM   hd_msg_in
                    WHERE  table_type = 1015 AND status = 0
                    and MSG_ID='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8';*/
                    
                    --第二步,更改这个为要添加的企业名称
                    update hd_in_vencus_base a set msg_status=0,VENCUSCODE=999920,VENCUSNAME='重庆药九九医药科技有限公司'
                    WHERE  a.msg_id ='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8' and  SEQ_ID='POS0001149FEB0B309D54E308B51F36C67FD9FA7';

select VENCUSNO, VENCUSNAME, VENCUSABC, VENCUSCODE, VENCUSFLAG, STAMP
from t_vencus_base
lj
--验证是否已添加                
select * from t_vencus_base where trim(VENCUSNO)='999920'  order by VENCUSNO desc;
select * from t_vencus  where trim(VENCUSNO)='999914';


四川龙一医药有限公司	            999914
河南冠统医药有限公司	            999915
陕西福盛兴医药有限公司	999916
青岛悦康医药有限公司	            999917
东莞齐华祥医药有限公司	999918
河南康辉医药物流有限公司	999919

select * from hd_in_vencus_base where msg_id='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8' 
and  SEQ_ID='POS0001149FEB0B309D54E308B51F36C67FD9FA7';

SELECT a.* FROM hd_in_vencus_base a 
WHERE  a.msg_id ='POS873554D8FFA9ACD8A4A718B3765EC1065B5B8' and  SEQ_ID='POS0001149FEB0B309D54E308B51F36C67FD9FA7'

SELECT * FROM   hd_msg_in
WHERE  table_type = 1015 and FQ_TIME>=date'2023-12-01' 
