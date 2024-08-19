create procedure proc_sjzl_accept_create (
    p_vname in d_rrt_sjzl_config.view_name%type
)
is
  v_name d_rrt_sjzl_config.view_name%type;
  v_cnt pls_integer ;
  v_sql varchar2(8000);
  v_wareid varchar2(4000);--配置的商品
  v_qd varchar2(4000);--配置的渠道
  v_werks varchar2(40);--配置的仓库
  --v_qd varchar2(40);--配置的渠道
  --v_wareid varchar2(40);--配置的商品
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

 v_name:=p_vname||'_accept' ;

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

     --判断有没有固化的数据
     SELECT COUNT(*)
     into v_cnt
     FROM d_accept_def
     WHERE view_name  = p_vname ;

if res.qd is null then
   v_sql := ' select  * from v_accept_xdl_rt03 where item_num_id in ('|| v_wareid ||') and CORT_NUM_ID in ('||v_werks||') ';
    v_sql := v_sql||' and ORDER_DATE >= date'''||res.zdate||''' and ( ORDER_DATE > (select max(ORDER_DATE)  from d_accept_def where view_name='''||p_vname||''') or 0='||v_cnt||' )';
  else
    v_sql := '  select  * from v_accept_xdl_rt03 where item_num_id in ('|| v_wareid ||') and CORT_NUM_ID in ('||v_werks||') and SUPPLY_UNIT_NUM_ID in ( '|| v_qd ||' )';
    v_sql := v_sql||' and ORDER_DATE >= date'''||res.zdate||''' and ( ORDER_DATE > (select max(ORDER_DATE)  from d_accept_def where view_name='''||p_vname||''') or 0='||v_cnt||' )';
end if ;

 --台州杭州互调 体现的话
if  res.hd =1 then
  v_sql := v_sql|| ' union all SELECT  PAY_CORT,CUSTOMER_NAME ,REC_DATE ,  SUPPLY_UNIT_NUM_ID ,SUPPLY_NAME ,to_char(ITEM_NUM_ID),ITEM_NAME, QTY,STYLE_DESC ,UNITS_NAME ,FACTORY,APPROVAL_NO,BATCH_ID,null,EXPIRY_DATE,13,  TRADE_PRICE,TRADE_PRICE,TOTAL_AMOUNT,TOTAL_AMOUNT,';
 v_sql := v_sql||'CASE WHEN QTY>0 THEN  55 ELSE 56 end ,case when  QTY>0 THEN to_char(41801) else to_char(40101) END       FROM v_pf_rt03 where REC_DATE >= date'''||res.zdate||''' and ( REC_DATE > (select max(ORDER_DATE)  from d_accept_def where view_name='''||p_vname||''') or 0='||v_cnt||' )' ;
end if ;

--拼接固话数据
v_sql:= 'create or replace view '||v_name||' as SELECT * FROM  ( '||v_sql  ||' ) where ORDER_DATE < trunc(sysdate)';
v_sql := v_sql || ' union all SELECT a.cort_num_id,a.cort_name,a.order_date,a.supply_unit_num_id,a.supply_name,a.item_num_id,a.item_name,a.qty,a.style_desc,a.units_name,a.factory,a.approval_no,';
v_sql := v_sql ||' a.batch_id,a.actual_production_date,a.expiry_date,a.tax_rate,a.sup_price,a.sup_price_no_tax,a.total_amount,a.total_amount_no_tax,a.type_num_id,a.in_storage FROM   d_accept_def a where VIEW_NAME= '''||v_name ||''' ' ;


    dbms_output.put_line(v_sql);
      execute immediate  v_sql  ;


end loop;

end ;
/

