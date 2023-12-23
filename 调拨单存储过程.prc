create or replace procedure p_hd_out_dist_dssm_h(v_distno     hd_out_dist_dssm_h.distno%type)
as
v_MSG_ID     hd_out_dist_dssm_h.msg_id%type;
begin
select MSG_ID into v_MSG_ID from hd_out_dist_dssm_h where DISTNO=v_distno;
-----�ӿ�����
insert into hd_msg_out(msg_id,fq_time,outer_msg_id,outer_timestamp, source_system,
                        target_system,compid,table_type,status,trans_falg,error_times,error_lasttime,
                        has_notify,http_code,msg, notes,createtime,createuser,billno,billcode)

                        select msg_id,fq_time,outer_msg_id,outer_timestamp, source_system,
                        target_system,compid,table_type,0,trans_falg,error_times,error_lasttime,
                        has_notify,http_code,msg, notes,createtime,createuser,billno,billcode
                        from hd_msg_out_bak where MSG_ID =v_MSG_ID
                        union
                         select msg_id,fq_time,outer_msg_id,outer_timestamp, source_system,
                        target_system,compid,table_type,0,trans_falg,error_times,error_lasttime,
                        has_notify,http_code,msg, notes,createtime,createuser,billno,billcode
                         from hd_msg_out_error where MSG_ID =v_MSG_ID  ;

----3.ɾ���Դ����¼
 ---ע��  �ڶ���������ͬʱִ�� ��ͳһ�ύ
                        delete from hd_msg_out_bak where MSG_ID =v_MSG_ID  ;

                        delete from hd_msg_out_error  WHERE MSG_ID =v_MSG_ID  ;
end p_hd_out_dist_dssm_h;
/
