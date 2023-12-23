DECLARE
 p_begindate DATE:=DATE'2023-01-01';
 p_enddate DATE:=DATE'2023-05-31';
 v_busno s_busi.busno%type:=85065;
 v_iszy int:=0;
 v_ndhzrcrtb number(30);
 v_ndjcfy number(30);
p_sql  SYS_REFCURSOR;


BEGIN
  
insert into D_HZ_YBJSLS(ord,ord2,depotid,transkind,ylfyze,zlje,GRZFJE,sysdate1,zyts,cardid)
    select ROW_NUMBER() over(partition BY idcard order by sysdate1) as ord,
    ROW_NUMBER() over (partition BY idcard,to_char(sysdate1,'yyyy-mm-dd') order by idcard,sysdate1) as ord2,
    busno,transkind,ylfyze,zlje,GRZFJE,sysdate1,zyts,cardid 
    from v_hz_ybrccx
    where sysdate1>=trunc(p_begindate,'yyyy')
    and sysdate1<add_months(trunc(p_begindate, 'YYYY'),12)
    and (busno=v_busno or 0=v_busno);

update D_HZ_YBJSLS set transkind=0 where ord2>1; --过虑一人在一天内多次销售的人次问题
 --如果是中药
     if v_iszy = 1 then
      delete from  D_HZ_YBJSLS where zyts<2;    --若是中药则删除非中药记录
     end IF;


--统计门店年度人次数
--部门，年度人次数，年度列支费用
 insert into D_HZ_YWSJ(depotid,mdndrcs,mdndlzfy)
 select  depotid,sum(transkind),sum(ylfyze-zlje-GRZFJE)
 from D_HZ_YBJSLS
 where (depotid=v_busno or v_busno<1)
 group by depotid;

--统计门店年度人头数
 insert into D_HZ_YWSJ (depotid,mdndrts)
 select
  depotid,sum(transkind)--部门，年度人头数
 from D_HZ_YBJSLS
 where (depotid=v_busno or v_busno<1)
 and ord=1
 group by depotid;

--统计门店指定时间人次数
 insert into D_HZ_YWSJ (depotid,mdzdsjrcs,mdzdsjlzfy)
 select
  depotid,sum(transkind),sum(ylfyze-zlje-GRZFJE)--部门指定时间人次数，年度列支费用
 from D_HZ_YBJSLS
 where (depotid=v_busno or v_busno<1)
 and sysdate1>= p_begindate and sysdate1<p_enddate+1
 group by depotid;


--统计门店指定时间人头数
 insert into D_HZ_YWSJ (depotid,mdzdsjrts)
 select
  depotid,sum(transkind)--部门，指定时间人头数
 from D_HZ_YBJSLS
 where (depotid=v_busno or v_busno<1)
 and sysdate1>= p_begindate and sysdate1<p_enddate+1
 and ord=1
 group by depotid;

--年度汇总人次人头比  ，均次费用
 select sum(mdndrcs)/sum(mdndrts) into v_ndhzrcrtb from D_HZ_YWSJ ;
 select sum(mdndlzfy)/sum(mdndrcs) into v_ndjcfy from D_HZ_YWSJ ;

--查询出最终结果
 OPEN p_sql FOR
 --insert into d_hz_ndrtrc(depotid,busno,orgname,mdndrcs,mdndrts,mdzdsjrcs,mdzdsjrts,mdndlzfy,mdzdsjlzfy,mdndrcrtb,mdndkdj,mdzdsjkdj,ndhzrcrtb,ndhzjcfy)
 select
  a.depotid,
  b.busno,
  b.orgname,
  sum(a.mdndrcs) as mdndrcs,
  sum(a.mdndrts) as mdndrts,
  sum(a.mdzdsjrcs) as mdzdsjrcs,
  sum(a.mdzdsjrts) as mdzdsjrts,
  sum(a.mdndlzfy) as mdndlzfy,
  sum(a.mdzdsjlzfy) as mdzdsjlzfy,
  case when sum(a.mdndrts)<>0 then sum(a.mdndrcs)/sum(a.mdndrts) else 0 end as mdndrcrtb, --门店年度人次人头比
  case when sum(a.mdndrcs)<>0 then sum(a.mdndlzfy)/sum(a.mdndrcs) else 0 end as mdndkdj, --门店年度客单价
  case when sum(a.mdzdsjrcs)<>0 then sum(a.mdzdsjlzfy)/sum(a.mdzdsjrcs) else 0 end as mdzdsjkdj, --门店指定时间客单价
  v_ndhzrcrtb as ndhzrcrtb,v_ndjcfy as ndhzjcfy
  from D_HZ_YWSJ a
     join s_busi b on a.depotid=b.busno
     group by b.busno,a.depotid,b.orgname
     order by b.busno;


END ;

SELECT * from D_HZ_YBJSLS
SELECT * from D_HZ_YWSJ
