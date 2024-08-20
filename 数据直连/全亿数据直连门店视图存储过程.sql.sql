create procedure proc_sjzl_md_create_dtp(p_vname in d_rrt_sjzl_config.view_name%type

                                             )
is
  v_name d_rrt_sjzl_config.view_name%type;
  v_cnt pls_integer ;
  v_wareid varchar2(4000);--配置的商品
  v_kc_name varchar2(40);
  v_accept_name varchar2(40);
  v_sale_name varchar2(40);
  v_create_kc varchar2(4000);
  v_create_accept varchar2(4000);
  v_create_sale varchar2(4000);
  v_busnos   varchar2(4000);
  v_busnos2   varchar2(4000);
begin
       --判断
SELECT COUNT(*)
into v_cnt
 FROM d_rrt_sjzl_config
 WHERE view_name=p_vname  ;

 if v_cnt=0  then
   raise_application_error(-20001,'未配置厂家视图数据',true);
 end if ;

for  res in (SELECT VIEW_NAME,WAREID,BUSNOS FROM  d_rrt_sjzl_config  WHERE view_name=p_vname  ) loop   --不想写变量 用循环
     --转换一下编码格式
     select f_get_sjzl_rename(res.wareid)
     into v_wareid
     from dual ;

     if res.busnos is not null  then
      --分割门店
       v_busnos:=res.busnos ;


       while  instr(v_busnos,',') >0 loop
         --视图统一格式命名
         v_kc_name := p_vname||'_kc_md_'||substr(v_busnos,1,instr(v_busnos,',')-1);
         v_accept_name := p_vname||'_accept_md_'||substr(v_busnos,1,instr(v_busnos,',')-1);
         v_sale_name := p_vname||'_sale_md_'||substr(v_busnos,1,instr(v_busnos,',')-1);
--       创建库存视图
         v_create_kc:='CREATE OR REPLACE  VIEW '|| v_kc_name ||' AS
select kcrq, SUB_UNIT_NUM_ID, sub_unit_name, item_num_id, item_name, style_desc, batch_id, physic_qty, RETAIL_PRICE,
       total_amount, units_name, actual_production_date, factory, expiry_date, approval_no
from v_kc_md
where  SUB_UNIT_NUM_ID in ('''||substr(v_busnos,1,instr(v_busnos,',')-1)||''') and item_num_id in ('|| v_wareid ||')';

        --创建采购视图
        v_create_accept:='CREATE OR REPLACE  VIEW '|| v_accept_name ||' AS
        select * from v_accept_md
where  SUB_UNIT_NUM_ID in ('''||substr(v_busnos,1,instr(v_busnos,',')-1)||''') and item_num_id in ('|| v_wareid ||')';
         --创建纯销视图
        v_create_sale:='CREATE OR REPLACE  VIEW '|| v_sale_name ||' AS
        select * from v_sale_md
where  SUB_UNIT_NUM_ID in ('''||substr(v_busnos,1,instr(v_busnos,',')-1)||''') and item_num_id in ('|| v_wareid ||')';


        v_busnos:=substr(v_busnos,instr(v_busnos,',')+1,length(v_busnos) );
 --   dbms_output.put_line(v_create_kc);
  --  DBMS_OUTPUT.PUT_LINE('----------------------');
    execute immediate v_create_kc;
  --  dbms_output.put_line(v_create_accept);
  --  DBMS_OUTPUT.PUT_LINE('----------------------');
    execute immediate v_create_accept;
 --   dbms_output.put_line(v_create_sale);
 --   DBMS_OUTPUT.PUT_LINE('----------------------');
    execute immediate v_create_sale;
         end loop;

         --视图统一格式命名
         v_kc_name := p_vname||'_kc_md_'||v_busnos;
         v_accept_name := p_vname||'_accept_md_'||v_busnos;
         v_sale_name := p_vname||'_sale_md_'||v_busnos;
         v_create_kc:='CREATE OR REPLACE  VIEW '|| v_kc_name ||' AS
select kcrq, SUB_UNIT_NUM_ID, sub_unit_name, item_num_id, item_name, style_desc, batch_id, physic_qty, RETAIL_PRICE,
       total_amount, units_name, actual_production_date, factory, expiry_date, approval_no
from v_kc_md
where  SUB_UNIT_NUM_ID in ('''||v_busnos||''') and item_num_id in ('|| v_wareid ||')';

       v_create_accept:='CREATE OR REPLACE  VIEW '|| v_accept_name ||' AS
        select * from v_accept_md
where  SUB_UNIT_NUM_ID in ('''||v_busnos||''') and item_num_id in ('|| v_wareid ||')';

       v_create_sale:='CREATE OR REPLACE  VIEW '|| v_sale_name ||' AS
        select * from v_sale_md
where  SUB_UNIT_NUM_ID in ('''||v_busnos||''') and item_num_id in ('|| v_wareid ||')';
 --   dbms_output.put_line(v_create_kc);
 --   DBMS_OUTPUT.PUT_LINE('----------------------');
    execute immediate v_create_kc;
 --   dbms_output.put_line(v_create_accept);
--    DBMS_OUTPUT.PUT_LINE('----------------------');
    execute immediate v_create_accept;
 --   dbms_output.put_line(v_create_sale);
--    DBMS_OUTPUT.PUT_LINE('----------------------');
    execute immediate v_create_sale;
    end if ;

    end loop;


--
-- v_create_kc:='CREATE  VIEW '|| v_kc_name ||' AS
-- select kcrq, SUB_UNIT_NUM_ID, sub_unit_name, item_num_id, item_name, style_desc, batch_id, physic_qty, RETAIL_PRICE,
--        total_amount, units_name, actual_production_date, factory, expiry_date, approval_no
-- from v_kc_md
-- where  SUB_UNIT_NUM_ID in ('||v_busnos||') and item_num_id in ('|| v_wareid ||')';
--
--        dbms_output.put_line(v_create_kc);
--        execute immediate  v_create_kc ;
end;
/

