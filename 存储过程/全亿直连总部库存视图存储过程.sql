create procedure proc_sjzl_kc_create (
    p_vname in d_rrt_sjzl_config.view_name%type
)
is
  v_name d_rrt_sjzl_config.view_name%type;
  v_cnt pls_integer ;
  v_sql varchar2(8000);
  v_wareid varchar2(4000);--配置的商品
  v_qd varchar2(4000);--配置的渠道
  v_werks varchar2(40);--配置的仓库
/*  v_qd varchar2(40);--配置的渠道
  v_wareid varchar2(40);--配置的商品
  v_zdate  date ;--配置*/
begin
   --判断
SELECT COUNT(*)
into v_cnt
 FROM d_rrt_sjzl_config
 WHERE view_name=p_vname  ;

 if v_cnt=0  then
   raise_application_error(-20001,'未配置厂家视图数据',true);
 end if ;

 v_name:=p_vname||'_kc' ;

---有的话 根据配置的信息 去生成 视图
for  res in (SELECT * FROM  d_rrt_sjzl_config  WHERE view_name=p_vname  ) loop   --不想写变量 用循环
     --转换一下编码格式
     select f_get_sjzl_rename(res.wareid)
     into v_wareid
     from dual ;

     --转换一下渠道格式
     select f_get_sjzl_rename(res.qd)
     into v_qd
     from dual ;

     --转换一下仓库格式
     select f_get_sjzl_rename(res.werks)
     into v_werks
     from dual ;

 dbms_output.put_line(v_werks); 
 dbms_output.put_line(res.qd ); 
if res.qd is null then
   v_sql := 'create or replace view '||v_name||' as SELECT * FROM  V_KC_XDL_RT03  WHERE  PHYSIC_QTY>0    and  item_num_id in ('|| v_wareid ||') and CORT_NUM_ID in ('||v_werks||')';

    else
     --拼接sql
     v_sql :=  'create or replace view '||v_name||' as SELECT * FROM  V_KC_XDL_RT03  WHERE  PHYSIC_QTY>0  and  item_num_id in ('|| v_wareid ||')    and SUPPLY_UNIT_NUM_ID in ( '|| v_qd ||' ) and CORT_NUM_ID in ('||v_werks||')';

end if ;
     dbms_output.put_line(v_sql);
      execute immediate  v_sql  ;


end loop;

end ;
/

