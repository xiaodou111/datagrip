create procedure proc_sjzl_sale_create  (
  p_vname in d_rrt_sjzl_config.view_name%type
)
is
  v_name d_rrt_sjzl_config.view_name%type;
  v_cnt pls_integer ;
  v_sql varchar2(8000);
  v_wareid varchar2(4000);--配置的商品
  v_qd varchar2(4000);
  v_werks varchar2(40);
  v_busnos varchar2(400);
begin
   --判断
SELECT COUNT(*)
into v_cnt
 FROM d_rrt_sjzl_config
 WHERE view_name=p_vname  ;

 if v_cnt=0  then
   raise_application_error(-20001,'未配置厂家视图数据',true);
 end if ;


---有的话 根据配置的信息 去生成 视图
for  res in (SELECT * FROM  d_rrt_sjzl_config  WHERE view_name=p_vname  ) loop   --不想写变量 用循环
    --********仓库端********--
    --********仓库端********--
--           dbms_output.put_line(res.werks);
    if res.werks is not null   then
      --视图统一格式命名
      v_name := p_vname||'_sale';

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
     FROM d_sale_def
     WHERE view_name  = p_vname ;
     --正常的流向
   --  v_sql :=' SELECT * FROM v_sale_xdl_rt03  WHERE   orgname like '''||%诊%||''''
     v_sql :='SELECT * FROM v_sale_xdl_rt03  WHERE   orgname  not like '''||'%诊%'||''' and IN_STORAGE not like '''||'2%'||''' and  in_storage   not like  '''||'9%'||''' and DIST_NUM_ID in ('||v_werks||')'  ;

     v_sql :=v_sql|| ' union all ' ;

     ---判断诊所 转不转门店组
     if res.zs=1 then
     v_sql:=v_sql ||'SELECT a.cort_num_id,a.cort_name,a.reserved_no,a.dist_num_id,a.dist_name,to_char(b.zmdz) ,(select orgname from s_busi@h2 where busno=b.zmdz1),a.REC_DATE,a.item_num_id,';
     v_sql:=v_sql ||' a.item_name,a.style_desc,a.factory,a.approval_no,a.batch_id,a.expiry_date,a.qty,a.tax_rate,a.trade_price,a.total_amount,a.total_amount_no_tax,a.units_name,a.supply_unit_num_id,a.supply_name FROM v_sale_xdl_rt03 a';
     v_sql:=v_sql ||' left join s_busi@h2 b on   a.IN_STORAGE +80000=b.busno  where a.orgname like '''||'%诊%'||''' and ( REC_DATE > (select max(REC_DATE)  from d_sale_def where view_name='''||p_vname||''') or 0='||v_cnt||' ) and DIST_NUM_ID in ('||v_werks||')' ;
     else
       v_sql:=v_sql ||'SELECT * FROM v_sale_xdl_rt03  where orgname like '''||'%诊%'||''' and ( REC_DATE > (select max(REC_DATE)  from d_sale_def where view_name='''||p_vname||''') or 0='||v_cnt|| ' ) and DIST_NUM_ID in ('||v_werks||')'   ;
     end if ;

     v_sql :=v_sql|| ' union all ' ;

     --判断加盟 需不需要换门店
     if res.jmd is not null  then
       v_sql:=v_sql||'SELECT a.cort_num_id,a.cort_name,a.reserved_no,a.dist_num_id,a.dist_name,'''||res.jmd||''',(select orgname from s_busi@h2 where 80000+busno='||res.jmd||'),a.REC_DATE,a.item_num_id,';
     v_sql:=v_sql ||' a.item_name,a.style_desc,a.factory,a.approval_no,a.batch_id,a.expiry_date,a.qty,a.tax_rate,a.trade_price,a.total_amount,a.total_amount_no_tax,a.units_name,a.supply_unit_num_id,a.supply_name FROM v_sale_xdl_rt03 a';
     v_sql:=v_sql ||' where a.IN_STORAGE like '''||'2%'||''' and ( REC_DATE > (select max(REC_DATE)  from d_sale_def where view_name='''||p_vname||''') or 0='||v_cnt||' ) and DIST_NUM_ID in ('||v_werks||')' ;

     else
        v_sql:=v_sql ||'SELECT * FROM v_sale_xdl_rt03  where IN_STORAGE like '''||'2%'||''' and ( REC_DATE > (select max(REC_DATE)  from d_sale_def where view_name='''||p_vname||''') or 0='||v_cnt|| ' ) and DIST_NUM_ID in ('||v_werks||')' ;
        end if ;

     v_sql :=v_sql|| ' union all ' ;

     --判断电商 改不改门店
     if  res.ds is not null  then
     v_sql:=v_sql||'SELECT CORT_NUM_ID, CORT_NAME,SUPPLY_UNIT_NUM_ID||ITEM_NUM_ID,CORT_NUM_ID, CORT_NAME,'''||res.ds||''',(select orgname from s_busi@h2 where 80000+busno='||res.ds||'),ORDER_DATE,ITEM_NUM_ID,ITEM_NAME,STYLE_DESC,FACTORY,APPROVAL_NO,BATCH_ID,EXPIRY_DATE,QTY,';
     v_sql:=v_sql||'TAX_RATE,SUP_PRICE,total_amount,TOTAL_AMOUNT_NO_TAX,UNITS_NAME,SUPPLY_UNIT_NUM_ID,SUPPLY_NAME FROM  v_accept_xdl_rt03  a WHERE IN_STORAGE<>'''||40101||''' and ( ORDER_DATE > (select max(REC_DATE)  from d_sale_def where view_name='''||p_vname||''') or 0='||v_cnt|| ' ) and DIST_NUM_ID in ('||v_werks||')' ;

     else
     v_sql:=v_sql||'SELECT * FROM   v_sale_xdl_rt03  where in_storage   like  '''||'9%'||''' and ( REC_DATE > (select max(REC_DATE)  from d_sale_def where view_name='''||p_vname||''') or 0='||v_cnt|| ' ) and DIST_NUM_ID in ('||v_werks||')' ;
     end if ;

     v_sql :=v_sql|| ' union all ' ;

    --判断批发 B2B 改不改门店
    if  res.pf is not null then
      v_sql:=v_sql||' SELECT '''||'RT01'||''','''||'瑞人堂医药集团股份有限公司'||''',to_char(RESERVED_NO),'''||res.pf||''',(select orgname from s_busi@h2 where 80000+busno='||res.pf||'),PAY_CORT ,CUSTOMER_NAME ,rec_date,to_char(item_num_id),item_name,style_desc,factory,APPROVAL_NO,batch_id,expiry_date,qty,13,trade_price,total_amount,total_amount,UNITS_NAME,supply_unit_num_id,supply_name FROM v_pf_rt03 where PAY_CORT<>'''||'RH03'||'''' ;
    else
      v_sql:=v_sql||' SELECT '''||'RT01'||''','''||'瑞人堂医药集团股份有限公司'||''',to_char(RESERVED_NO),CORT_NUM_ID,CORT_NAME,PAY_CORT ,CUSTOMER_NAME ,rec_date,to_char(item_num_id),item_name,style_desc,factory,APPROVAL_NO,batch_id,expiry_date,qty,13,trade_price,total_amount,total_amount,UNITS_NAME,supply_unit_num_id,supply_name FROM v_pf_rt03 where PAY_CORT<>'''||'RH03'||'''' ;
    end if ;

    --RT03 到RH03 显不显示
    if  res.hd = 1 then
      v_sql:=v_sql||' SELECT '''||'RT01'||''','''||'瑞人堂医药集团股份有限公司'||''',to_char(RESERVED_NO),CORT_NUM_ID,CORT_NAME,PAY_CORT ,CUSTOMER_NAME ,rec_date,to_char(item_num_id),item_name,style_desc,factory,APPROVAL_NO,batch_id,expiry_date,qty,13,trade_price,total_amount,total_amount,UNITS_NAME,supply_unit_num_id,supply_name FROM v_pf_rt03 where PAY_CORT='''||'RH03'||'''' ;
    end if  ;


     ---外面套一层视图   有屏蔽的加屏蔽  T+1数据
     v_sql:='create or replace view '|| v_name || ' as select * from ( ' || v_sql || ') a where not exists(select 1 from d_sjzl_pbsj  b where b.view_name='''||p_vname||''' and a.REC_DATE between begindate and enddate and (a.item_num_id=b.wareid or trim(b.wareid)='''||'全部'||''')';
     v_sql:=v_sql ||'and (a.BATCH_ID=b.MAKENO or decode(b.makeno,'''||'全部'||''',0,1 )=0 ) )  and trunc(REC_DATE) <=trunc(sysdate)-1 and item_num_id in ('|| v_wareid ||') and DIST_NUM_ID in ('||v_werks||') '   ;


     --拼接导入数据
     v_sql :=v_sql|| ' union all ' ;
     v_sql:=v_sql|| ' SELECT a.cort_num_id,a.cort_name,a.reserved_no,a.dist_num_id,a.dist_name,a.in_storage,a.orgname,a.REC_DATE,a.item_num_id,a.item_name,a.style_desc,a.factory,a.approval_no,a.batch_id,a.expiry_date,a.qty,a.tax_rate,a.trade_price,a.total_amount,a.total_amount_no_tax,a.units_name,a.supply_unit_num_id,a.supply_name FROM d_rrt_sjzl_dr a where VIEW_NAME= '''||v_name ||'''';

     --拼接固化数据
     v_sql :=v_sql|| ' union all ' ;

     v_sql:=v_sql|| ' SELECT a.cort_num_id,a.cort_name,a.reserved_no,a.dist_num_id,a.dist_name,a.in_storage,a.orgname,a.REC_DATE,a.item_num_id,a.item_name,a.style_desc,a.factory,a.approval_no,a.batch_id,a.expiry_date,a.qty,a.tax_rate,a.trade_price,a.total_amount,a.total_amount_no_tax,a.units_name,a.supply_unit_num_id,a.supply_name FROM d_sale_def a where VIEW_NAME= '''||v_name ||'''';



  --  dbms_output.put_line(v_sql);

     execute immediate v_sql;


     end if ;

    --********门店端********--
    --********门店端********--
    /*if res.busnos is not null  then
      --分割门店

       v_busnos:=res.busnos ;


       while  instr(v_busnos,',') >0 loop
         --视图统一格式命名
         v_name := p_vname||'_sale_md_'||substr(v_busnos,1,instr(v_busnos,',')-1);

         --转换一下编码格式
         select f_get_sjzl_rename(res.wareid)
         into v_wareid
         from dual ;

         v_sql:='create or replace view '||v_name||' as SELECT * FROM v_sale_md where item_num_id  in ('||v_wareid||') and sub_unit_num_id ='''||substr(v_busnos,1,instr(v_busnos,',')-1)||'''';
         v_busnos:=substr(v_busnos,instr(v_busnos,',')+1,length(v_busnos) );

    execute immediate v_sql;
         end loop;

         --视图统一格式命名
         v_name := p_vname||'_sale_md_'||v_busnos;

         --转换一下编码格式
         select f_get_sjzl_rename(res.wareid)
         into v_wareid
         from dual ;
         v_sql:='create or replace view '||v_name||' as SELECT * FROM v_sale_md where item_num_id  in ('||v_wareid||') and sub_unit_num_id ='''||v_busnos||'''';

      execute immediate v_sql;
    end if ;*/



end loop;
end ;
/

