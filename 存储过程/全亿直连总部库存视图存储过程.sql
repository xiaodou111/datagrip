create procedure proc_sjzl_kc_create (
    p_vname in d_rrt_sjzl_config.view_name%type
)
is
  v_accept_view_name d_rrt_sjzl_config.view_name%type;
  v_name d_rrt_sjzl_config.view_name%type;
  v_cnt pls_integer ;
  v_sql varchar2(8000);
  v_import varchar2(8000);
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
 v_accept_view_name:=p_vname||'_accept' ;

---有的话 根据配置的信息 去生成 视图
for  res in (SELECT * FROM  d_rrt_sjzl_config  WHERE view_name=p_vname   and view_name not in ('v_sy_ty')  ) loop   --不想写变量 用循环
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


if res.qd is null then
   v_sql := 'create or replace view '||v_name||' as SELECT * FROM  V_KC_XDL_RT03 a WHERE  PHYSIC_QTY>0    and  item_num_id in ('|| v_wareid ||') and CORT_NUM_ID in ('||v_werks||')';

    else
     --拼接sql
     v_sql :=  'create or replace view '||v_name||' as SELECT * FROM  V_KC_XDL_RT03  a WHERE  PHYSIC_QTY>0  and  item_num_id in ('|| v_wareid ||')   and CORT_NUM_ID in ('||v_werks||') and  exists(select 1 from  ( SELECT ITEM_NUM_ID,batch_id,SUPPLY_UNIT_NUM_ID FROM '||v_accept_view_name ||'  union all  SELECT to_char(wareid),ph,to_char(gysno ) FROM  d_july_kc ) b  where  a.ITEM_NUM_ID=b.ITEM_NUM_ID  and a.BATCH_ID=b.BATCH_ID  and b.SUPPLY_UNIT_NUM_ID in ('||v_qd||' )) '  ;

end if ;
     --拼接导入数据
v_import:='union all select CORT_NUM_ID 公司编码, CORT_NAME 公司名称, ORDER_DATE 日期, ITEM_NUM_ID 商品编码, ITEM_NAME 商品名称, UNITS_NAME 单位, STYLE_DESC 规格, FACTORY 厂家, BATCH_ID 批号,
       EXPIRY_DATE 有效期, PHYSIC_QTY 数量, 0 , APPROVAL_NO 批准文号,SUPPLY_UNIT_NUM_ID,SUPPLY_NAME
from d_sjzl_kc_dr WHERE REGEXP_LIKE(VIEW_NAME,'''||p_vname||''',''i'')';
v_sql:=v_sql||v_import;
--    dbms_output.put_line(v_sql);
      execute immediate  v_sql  ;


end loop;

end ;
/

