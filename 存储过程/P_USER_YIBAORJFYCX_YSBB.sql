create PROCEDURE p_user_yibaorjfycx_ysbb(p_busno     s_busi.busno%type,
                                                    p_begindate in date,
                                                    p_enddate   in date,
                                                    p_iszy      in int,
                                                    p_qs        in int,
                                                    p_sql       OUT SYS_REFCURSOR) as
  v_busno     s_busi.busno%type;
  v_iszy      int;
  v_ndhzrcrtb number(30);
  v_ndjcfy    number(30);
begin
  IF p_busno IS NULL or p_busno = 0 THEN
    v_busno := 0;
  else
    v_busno := p_busno;
  END IF;

  IF p_iszy IS NULL or p_iszy = 0 THEN
    v_iszy := 0;
  
  END IF;

  /*
      insert into d_hz_order(orderno)
      select orderno from hydee_huzhou.hangzhou_order f
      where creationtime>= trunc(p_begindate,'yyyy')
      and f.creationtime< add_months(trunc(p_begindate, 'YYYY'),12)
      group by f.orderno having COUNT(f.orderno)>1;
  */

  /*
      insert into D_HZ_YBJSLS(ord,ord2,depotid,transkind,ylfyze,zlje,GRZFJE,sysdate1,zyts,cardid)
      select  ROW_NUMBER() over(partition by b.idcard order by a.creationtime) as ord,
      ROW_NUMBER() over (partition by b.idcard,to_char(a.creationtime,'yyyy-mm-dd') order by b.cardid,a.creationtime) as ord2,
      c.erpmedicalno,1 as transkind,a.COSTTOTAL as ylfyze,a.SELFDEAL as zlje,
      a.selfCOST as GRZFJE,a.creationtime as sysdate1,nvl(case when d.chargetype='13' then 2 else 1 end,1) as zyts,b.cardid
      from hydee_huzhou.hangzhou_order a,hydee_huzhou.hangzhou_person_info b,hydee_huzhou.medicare_organ_config c,
      (select orderno,max(chargetype) as chargetype from hydee_huzhou.hangzhou_order_detail group by orderno) d
      where a.personalno=b.personalno
      --and a.ORDERSTATUS<>'0'
      and a.isdeleted = 0 and a.orderstatus in(1,2)
      and a.refid=c.refid and a.orderno=d.orderno
      and a.creationtime>=trunc(p_begindate,'yyyy')
      and a.creationtime<add_months(trunc(p_begindate, 'YYYY'),12)
      and a.orderno not in(select orderno from d_hz_order)
      and (c.erpmedicalno=v_busno or 0=v_busno);
  
      insert into D_HZ_YBJSLS(ord,ord2,depotid,transkind,ylfyze,zlje,GRZFJE,sysdate1,zyts,cardid)
      select ord,ord2,b.busno,transkind,ylfyze,zlje,GRZFJE,sysdate1,zyts,cardid from D_HZ_YBJSLS_LIS a,s_busi b
      where a.depotid=b.c_buscode
      and a.sysdate1>=trunc(p_begindate,'yyyy')
      and a.sysdate1<add_months(trunc(p_begindate, 'YYYY'),12)
      and (b.busno=v_busno or 0=v_busno);
  */

  insert into D_HZ_YBJSLS_zeysbb
    (ord,
     ord2,
     depotid,
     transkind,
     ylfyze,
     zlje,
     GRZFJE,
     sysdate1,
     zyts,
     cardid)
    select ROW_NUMBER() over(partition by busno,idcard order by sysdate1) as ord,
           ROW_NUMBER() over(partition by busno,idcard, to_char(sysdate1, 'yyyy-mm-dd') order by busno,idcard, sysdate1) as ord2,
           busno,
           transkind,
           ylfyze,
           zlje,
           GRZFJE,
           sysdate1,
           zyts,
           cardid
      from v_hz_ybrccx_year
     where sysdate1 >= trunc(p_begindate, 'yyyy')
       and sysdate1 < add_months(trunc(p_begindate, 'YYYY'), 12)
       and (busno = v_busno or 0 = v_busno)
       --and busno not in ('85031', '85035', '85038','85033')
    /*union all
    select ROW_NUMBER() over(partition by busno,idcard order by sysdate1) as ord,
           ROW_NUMBER() over(partition by busno,idcard, to_char(sysdate1, 'yyyy-mm-dd') order by busno,idcard, sysdate1) as ord2,
           busno,
           transkind,
           ylfyze,
           zlje,
           GRZFJE,
           sysdate1,
           zyts,
           cardid
      from v_hz_ybrccx_year
     where sysdate1 >= trunc(p_begindate, 'yyyy')
       and sysdate1 < add_months(trunc(p_begindate, 'YYYY'), 12)
       and (busno = v_busno or 0 = v_busno)
       --and busno in ('85031', '85035', '85038','85033')
       and sysdate1 < trunc(date '2021-09-01')
    union all
    select ROW_NUMBER() over(partition by busno,idcard order by sysdate1) as ord,
           ROW_NUMBER() over(partition by busno,idcard, to_char(sysdate1, 'yyyy-mm-dd') order by busno,idcard, sysdate1) as ord2,
           busno,
           transkind,
           ylfyze,
           zlje,
           GRZFJE,
           sysdate1,
           zyts,
           cardid
      from v_hz_ybrccx_year
     where sysdate1 >= trunc(p_begindate, 'yyyy')
          --and to_char(p_begindate,'yyyy-mm-dd')>= '2022-07-01'
       and sysdate1 < add_months(trunc(p_begindate, 'YYYY'), 12)
       and (busno = v_busno or 0 = v_busno)
       --and busno in ('85031', '85035', '85038','85033')
       and sysdate1 >= trunc(date '2021-09-01')*/;

  update D_HZ_YBJSLS_zeysbb set transkind = 0 where ord2 > 1; --过虑一人在一天内多次销售的人次问题

  --   区属划分 否
  if p_qs = 0 then
    --统计门店年度人次数
    --部门，年度人次数，年度列支费用
    insert into D_HZ_YWSJ_zeys
      (depotid, mdndrcs, mdndlzfy)
      select depotid, sum(transkind), sum(ylfyze - zlje - GRZFJE)
        from D_HZ_YBJSLS_zeysbb
       where (depotid = v_busno or v_busno < 1)
       group by depotid;
  
    --统计门店年度人头数
    insert into D_HZ_YWSJ_zeys
      (depotid, mdndrts)
      select depotid, sum(transkind) --部门，年度人头数
        from D_HZ_YBJSLS_zeysbb
       where (depotid = v_busno or v_busno < 1)
         and ord = 1
       group by depotid;
  
  end if;

  --   区属划分 是
  if p_qs = 1 then
    --统计门店年度人次数
    --部门，年度人次数，年度列支费用
    insert into D_HZ_YWSJ_zeys
      (ord, ord2, depotid, mdndrcs, mdndlzfy)
      select 1060,
             MAX(classname),
             qs ,
             sum(transkind),
             sum(ylfyze - zlje - GRZFJE)
        from D_HZ_YBJSLS_zeysbb bb
        join t_zeys_zb zb
          on bb.depotid = zb.busno
       where (depotid = v_busno or v_busno < 1)
       group by qs;
  
    --统计门店年度人头数
    insert into D_HZ_YWSJ_zeys
      (ord, ord2, depotid, mdndrts)
      select 1060, MAX(classname), qs , sum(transkind) --部门，年度人头数
        from D_HZ_YBJSLS_zeysbb bb
         join t_zeys_zb zb
          on bb.depotid = zb.busno
       where (depotid = v_busno or v_busno < 1)
         and ord = 1
       group by qs;
  
  end if;

  --统计门店指定时间人次数

  -- 判断是否去除国谈高值药品  0 不去  1 - 去除

  if p_iszy = 0 then
    if p_qs = 0 then
      insert into D_HZ_YWSJ_zeys
        (depotid, mdzdsjrcs, mdzdsjlzfy)
        select depotid, sum(transkind), sum(ylfyze - zlje - GRZFJE) --部门指定时间人次数，年度列支费用
          from D_HZ_YBJSLS_zeysbb
         where (depotid = v_busno or v_busno < 1)
           and sysdate1 < p_enddate + 1
           and to_char(p_begindate, 'yyyy-mm-dd') >= '2022-01-01'
           --取消限制三季度
           --and to_char(p_enddate, 'yyyy-mm-dd') < '2022-10-01'
         group by depotid;
    end if;
    if p_qs = 1 then
      insert into D_HZ_YWSJ_zeys
        (ord, ord2, depotid, mdzdsjrcs, mdzdsjlzfy)
        select 1060,
               MAX(classname),
               qs,
               sum(transkind),
               sum(ylfyze - zlje - GRZFJE) --部门指定时间人次数，年度列支费用
          from D_HZ_YBJSLS_zeysbb bb
          join t_zeys_zb zb
            on bb.depotid = zb.busno
         where (depotid = v_busno or v_busno < 1)
           and sysdate1 < p_enddate + 1
           and to_char(p_begindate, 'yyyy-mm-dd') >= '2022-01-01'
           --取消限制三季度
           --and to_char(p_enddate, 'yyyy-mm-dd') < '2022-10-01'
         group by qs;
    end if;
  end IF;
  if p_iszy = 1 then
    if p_qs = 0 then
      insert into D_HZ_YWSJ_zeys
        (depotid, mdzdsjrcs, mdzdsjlzfy)
        select aa.depotid, aa.mdzdsjrcs, aa.mdzdsjlzfy - nvl(bb.gtbx, 0)
          from (select depotid,
                       sum(transkind) as mdzdsjrcs,
                       sum(ylfyze - zlje - GRZFJE) as mdzdsjlzfy --部门指定时间人次数，年度列支费用
                  from D_HZ_YBJSLS_zeysbb aa
                --where (depotid=v_busno or v_busno<1)
                 group by depotid) aa
          left join (select sum(amount) * 0.97 as gtbx, busno
                       from V_HZ_YBRCCX_YEAR_GT
                      where to_char(sysdate1, 'yyyy-mm-dd') >= '2022-01-01'
                        and sysdate1 < p_enddate + 1
                        --取消三季度限制
                        --and to_char(sysdate1, 'yyyy-mm-dd') < '2022-10-01'
                      group by busno) bb
            on bb.busno = aa.depotid;
    end if;
    if p_qs = 1 then
      insert into D_HZ_YWSJ_zeys
        (depotid, mdzdsjrcs, mdzdsjlzfy)
        select qs,
               aa.mdzdsjrcs,
               aa.mdzdsjlzfy - nvl(bb.gtbx, 0)
          from (select depotid,
                       sum(transkind) as mdzdsjrcs,
                       sum(ylfyze - zlje - GRZFJE) as mdzdsjlzfy --部门指定时间人次数，年度列支费用
                  from D_HZ_YBJSLS_zeysbb aa
                --where (depotid=v_busno or v_busno<1)
                 group by depotid) aa
          left join (select sum(amount) * 0.97 as gtbx, busno
                       from V_HZ_YBRCCX_YEAR_GT
                      where to_char(sysdate1, 'yyyy-mm-dd') >= '2022-01-01'
                        and sysdate1 < p_enddate + 1
                        --取消三季度限制
                        --and to_char(sysdate1, 'yyyy-mm-dd') < '2022-10-01'
                      group by busno) bb
            on bb.busno = aa.depotid
           join t_zeys_zb zb
            on aa.depotid = zb.busno;
    end if;
  end IF;

  --统计门店指定时间人头数
  if p_qs = 0 then
    insert into D_HZ_YWSJ_zeys
      (depotid, mdzdsjrts)
      select depotid, sum(transkind) --部门，指定时间人头数
        from D_HZ_YBJSLS_zeysbb
       where (depotid = v_busno or v_busno < 1)
         and sysdate1>= p_begindate and sysdate1<p_enddate+1
         --and sysdate1 < p_enddate + 1
         --and to_char(p_begindate, 'yyyy-mm-dd') >= '2022-01-01'
         -- 取消三季度限制
         --and to_char(p_enddate, 'yyyy-mm-dd') < '2022-10-01'
         and ord = 1
       group by depotid;
  end if;

  /*if p_qs = 1 then
    insert into D_HZ_YWSJ_zeys
      (ord, ord2, depotid, mdzdsjrts)
      select 1060, MAX(classname), qs, sum(transkind) --部门，指定时间人头数
        from D_HZ_YBJSLS_zeysbb bb
        left join t_zeys_zb zb
          on bb.depotid = zb.busno
       where (depotid = v_busno or v_busno < 1)
         and sysdate1 < p_enddate + 1
         and to_char(p_begindate, 'yyyy-mm-dd') >= '2022-01-01'
         -- 取消三季度限制
         --and to_char(p_enddate, 'yyyy-mm-dd') < '2022-10-01'
         and ord = 1
       group by qs;
  end if;*/

  --年度汇总人次人头比  ，均次费用
  select sum(mdndrcs) / sum(mdndrts) into v_ndhzrcrtb from D_HZ_YWSJ_zeys;
  select sum(mdndlzfy) / sum(mdndrcs) into v_ndjcfy from D_HZ_YWSJ_zeys;

  --查询出最终结果
  if p_qs = 0 then
    OPEN p_sql FOR
    
    --insert into d_hz_ndrtrc(depotid,busno,orgname,mdndrcs,mdndrts,mdzdsjrcs,mdzdsjrts,mdndlzfy,mdzdsjlzfy,mdndrcrtb,mdndkdj,mdzdsjkdj,ndhzrcrtb,ndhzjcfy)
      WITH A AS (
      select
              
               a.depotid,
               b.busno,
               b.orgname,
               sum(a.mdndrts) as mdndrts,
               
               --年度人次数
               sum(a.mdndrcs) as mdndrcs,
               
               -- 年度人次人头比指标--2
               case
                 when sum(a.mdndrts) <> 0 then
                  sum(a.mdndrcs) / sum(a.mdndrts)
                 else
                  0
               end as mdndrcrtb,
               --年度均次消费 ---3
               case
                 when sum(a.mdndrcs) <> 0 then
                  sum(a.mdndlzfy) / sum(a.mdndrcs)
                 else
                  0
               end as mdndkdj,
               -- 指定时间人头数 --4
               sum(a.mdzdsjrts) as mdzdsjrts,
               --指定时间人次数
               sum(a.mdzdsjrcs) as mdzdsjrcs,
               
               --  指定时间人头人次比 --5
               case
                 when sum(a.mdzdsjrts) <> 0 then
                  sum(a.mdzdsjrcs) / sum(a.mdzdsjrts)
                 else
                  0
               end as mdzdsjrtrcb,
               -- 指定时间列支费用 /指定时间人次 --6
               case
                 when sum(a.mdzdsjrcs) <> 0 then
                  sum(a.mdzdsjlzfy) / sum(a.mdzdsjrcs)
                 else
                  0
               end mdzdsjlzfy,
               sum(a.mdzdsjlzfy) as mdzdsjlzfyze
                from D_HZ_YWSJ_zeys a
                join s_busi b
                  on a.depotid = b.busno
               group by b.busno, a.depotid, b.orgname              
      )
      SELECT       
      --depotid,
       classname,
       qs,
       A.busno,
       orgname,
       --年度人次数
       year_rtzb * year_rcb as yearmdndrcs,
       mdndrcs,
       
       -- 年度人头数--1
       year_rtzb,
       mdndrts,
       
       mdndrts / year_rtzb AS wczb1,
       -- 年度人次人头比指标--2
       year_rcb,
       mdndrcrtb,
       
       mdndrcrtb / year_rcb AS wczb2,
       --年度均次消费 ---3
       year_ndcjfy,
       mdndkdj,
       
       mdndkdj / year_ndcjfy AS wczb3,
       
       -- 指定时间人次数
       three_rtzb * three_rczb as three_rcs,
       mdzdsjrcs,
       
       -- 指定时间人头数 --4
       three_rtzb,
       mdzdsjrts,
       
       mdzdsjrts / three_rtzb AS wczb4,
       
       --  指定时间人头人次比 --5
       three_rczb,
       mdzdsjrtrcb,
       
       mdzdsjrtrcb / three_rczb AS wczb5,
       
       -- 指定时间列支费用 /指定时间人次 --6
       three_cjfy,
       mdzdsjlzfy,
       
       mdzdsjlzfy / three_cjfy AS wczb6,
       mdzdsjlzfyze
      
        FROM A
         join t_zeys_zb B
          on B.busno = A.busno
         and YEAR_YEAR = 2023
       UNION ALL
       --区属小计
       SELECT 
       NULL,
       qs||'小计',
       NULL,
       NULL,
       --年度人次数
       SUM(year_rtzb * year_rcb) as yearmdndrcs,
       SUM(mdndrcs),
       
       -- 年度人头数--1
       SUM(year_rtzb),
       SUM(mdndrts),
       
       SUM(mdndrts) /SUM( year_rtzb) AS wczb1,
       -- 年度人次人头比指标--2
       SUM(year_rcb),
       SUM(mdndrcrtb),
       
       SUM(mdndrcrtb) / SUM(year_rcb) AS wczb2,
       --年度均次消费 ---3
       SUM(year_ndcjfy),
       SUM(mdndkdj),
       
       SUM(mdndkdj) / SUM(year_ndcjfy) AS wczb3,
       
       -- 指定时间人次数
       SUM(three_rtzb) * SUM(three_rczb) as three_rcs,
       SUM(mdzdsjrcs),
       
       -- 指定时间人头数 --4
       SUM(three_rtzb),
       SUM(mdzdsjrts),
       
       SUM(mdzdsjrts) / SUM(three_rtzb) AS wczb4,
       
       --  指定时间人头人次比 --5
       sum(three_rczb),
       sum(mdzdsjrtrcb),
       
       sum(mdzdsjrtrcb) / SUM(three_rczb) AS wczb5,
       
       -- 指定时间列支费用 /指定时间人次 --6
       sum(three_cjfy),
       sum(mdzdsjlzfy),
       
       sum(mdzdsjlzfy) / SUM(three_cjfy) AS wczb6,
       sum(mdzdsjlzfyze)
       FROM A
        join t_zeys_zb B
          on B.busno = A.busno
         and YEAR_YEAR = 2023
        GROUP BY qs
       UNION ALL
       --片区小计
       SELECT 
       classname||'小计',
       NULL,
       NULL,
       NULL,
       --年度人次数
       SUM(year_rtzb * year_rcb) as yearmdndrcs,
       SUM(mdndrcs),
       
       -- 年度人头数--1
       SUM(year_rtzb),
       SUM(mdndrts),
       
       SUM(mdndrts) /SUM( year_rtzb) AS wczb1,
       -- 年度人次人头比指标--2
       SUM(year_rcb),
       SUM(mdndrcrtb),
       
       SUM(mdndrcrtb) / SUM(year_rcb) AS wczb2,
       --年度均次消费 ---3
       SUM(year_ndcjfy),
       SUM(mdndkdj),
       
       SUM(mdndkdj) / SUM(year_ndcjfy) AS wczb3,
       
       -- 指定时间人次数
       SUM(three_rtzb) * SUM(three_rczb) as three_rcs,
       SUM(mdzdsjrcs),
       
       -- 指定时间人头数 --4
       SUM(three_rtzb),
       SUM(mdzdsjrts),
       
       SUM(mdzdsjrts) / SUM(three_rtzb) AS wczb4,
       
       --  指定时间人头人次比 --5
       sum(three_rczb),
       sum(mdzdsjrtrcb),
       
       sum(mdzdsjrtrcb) / SUM(three_rczb) AS wczb5,
       
       -- 指定时间列支费用 /指定时间人次 --6
       sum(three_cjfy),
       sum(mdzdsjlzfy),
       
       sum(mdzdsjlzfy) / SUM(three_cjfy) AS wczb6,
       sum(mdzdsjlzfyze)
       FROM A
       join t_zeys_zb B
          on B.busno = A.busno
         and YEAR_YEAR = 2023
        GROUP BY classname 
        ;
       
  end if;

  if p_qs = 1 then
    OPEN p_sql FOR
    --insert into d_hz_ndrtrc(depotid,busno,orgname,mdndrcs,mdndrts,mdzdsjrcs,mdzdsjrts,mdndlzfy,mdzdsjlzfy,mdndrcrtb,mdndkdj,mdzdsjkdj,ndhzrcrtb,ndhzjcfy)
      select --depotid,
       qss as classname,
       qss as qs,
       qss as busno,
       qss as orgname,
       
       year_rcs as yearmdndrcs,
       --年度人次数
       mdndrcs,
       
       year_rtzb,
       mdndrts,
       
       mdndrts / year_rtzb AS wczb1,
       
       -- 年度人次人头比指标--2
       year_rcs / year_rtzb as year_rcb,
       mdndrcrtb,
       mdndrcrtb / (year_rcs / year_rtzb) AS wczb2,
       
       --年度均次消费 ---3
       year_ndcjfyze / year_rcs as year_ndcjfy,
       mdndkdj,
       mdndkdj / (year_ndcjfyze / year_rcs) AS wczb3,
       -- 指定时间人次数
       three_rcs as three_rcs,
       mdzdsjrcs,
       
       -- 指定时间人头数 --4
       three_rtzb,
       mdzdsjrts,
       mdzdsjrts / three_rtzb AS wczb4,
       
       --  指定时间人头人次比 --5
       three_rcs / three_rtzb as three_rczb,
       mdzdsjrtrcb,
       mdzdsjrtrcb / (three_rcs / three_rtzb) AS wczb5,
       
       -- 指定时间列支费用 /指定时间人次 --6
       three_ndcjfyze / three_rcs as three_cjfy,
       mdzdsjlzfy,
       mdzdsjlzfy / (three_ndcjfyze / three_rcs) AS wczb6,
       mdzdsjlzfyze
      
      --year_rtzb/year_rcs as year_rcb,
      
      -- 年度人头数--1
      --year_rtzb,
      
      --
      
        from (select
              
               a.depotid,
               '' as busno,
               '' as orgname,
               sum(a.mdndrts) as mdndrts,
               
               --年度人次数
               sum(a.mdndrcs) as mdndrcs,
               
               -- 年度人次人头比指标--2
               case
                 when sum(a.mdndrts) <> 0 then
                  sum(a.mdndrcs) / sum(a.mdndrts)
                 else
                  0
               end as mdndrcrtb,
               --年度均次消费 ---3
               case
                 when sum(a.mdndrcs) <> 0 then
                  sum(a.mdndlzfy) / sum(a.mdndrcs)
                 else
                  0
               end as mdndkdj,
               -- 指定时间人头数 --4
               sum(a.mdzdsjrts) as mdzdsjrts,
               --指定时间人次数
               sum(a.mdzdsjrcs) as mdzdsjrcs,
               
               --  指定时间人头人次比 --5
               case
                 when sum(a.mdzdsjrts) <> 0 then
                  sum(a.mdzdsjrcs) / sum(a.mdzdsjrts)
                 else
                  0
               end as mdzdsjrtrcb,
               -- 指定时间列支费用 /指定时间人次 --6
               case
                 when sum(a.mdzdsjrcs) <> 0 then
                  sum(a.mdzdsjlzfy) / sum(a.mdzdsjrcs)
                 else
                  0
               end mdzdsjlzfy,
               sum(a.mdzdsjlzfy) as mdzdsjlzfyze
                from D_HZ_YWSJ_zeys a
               group by a.depotid
              
              ) A
       inner join (select (qs ) as qss,
                          year_year,
                          sum(year_rtzb) as year_rtzb,
                          sum(year_rcs) as year_rcs,
                          sum(year_ndcjfyze) as year_ndcjfyze,
                          sum(three_rtzb) as three_rtzb,
                          sum(three_rcs) as three_rcs,
                          sum(three_ndcjfyze) as three_ndcjfyze
                     from (select qs,
                                  classname,
                                  year_year,
                                  year_rtzb,
                                  year_rtzb * year_rcb as year_rcs,
                                  year_rcb,
                                  year_ndcjfy,
                                  year_ndcjfy * year_rtzb * year_rcb as year_ndcjfyze,
                                  three_rtzb,
                                  three_rtzb * three_rczb as three_rcs,
                                  three_rczb,
                                  three_cjfy,
                                  three_cjfy * three_rtzb * three_rczb as three_ndcjfyze
                             from t_zeys_zb)
                    group by qs, year_year) b
          on qss = A.depotid
         and YEAR_YEAR = 2023
      
      union all
      
      select --depotid,
       qss as classname,
       qss as qs,
       qss as busno,
       qss as orgname,
       
       year_rcs as yearmdndrcs,
       --年度人次数
       mdndrcs,
       
       year_rtzb,
       mdndrts,
       
       mdndrts / year_rtzb AS wczb1,
       
       -- 年度人次人头比指标--2
       year_rcs / year_rtzb as year_rcb,
       mdndrcrtb,
       mdndrcrtb / (year_rcs / year_rtzb) AS wczb2,
       
       --年度均次消费 ---3
       year_ndcjfyze / year_rcs as year_ndcjfy,
       mdndkdj,
       mdndkdj / (year_ndcjfyze / year_rcs) AS wczb3,
       -- 指定时间人次数
       three_rcs as three_rcs,
       mdzdsjrcs,
       
       -- 指定时间人头数 --4
       three_rtzb,
       mdzdsjrts,
       mdzdsjrts / three_rtzb AS wczb4,
       
       --  指定时间人头人次比 --5
       three_rcs / three_rtzb as three_rczb,
       mdzdsjrtrcb,
       mdzdsjrtrcb / (three_rcs / three_rtzb) AS wczb5,
       
       -- 指定时间列支费用 /指定时间人次 --6
       three_ndcjfyze / three_rcs as three_cjfy,
       mdzdsjlzfy,
       mdzdsjlzfy / (three_ndcjfyze / three_rcs) AS wczb6,
       mdzdsjlzfyze
      
      --year_rtzb/year_rcs as year_rcb,
      
      -- 年度人头数--1
      --year_rtzb,
      
      --
      
        from (select
              
               ord2 as depotid,
               '' as busno,
               '' as orgname,
               sum(a.mdndrts) as mdndrts,
               
               --年度人次数
               sum(a.mdndrcs) as mdndrcs,
               
               -- 年度人次人头比指标--2
               case
                 when sum(a.mdndrts) <> 0 then
                  sum(a.mdndrcs) / sum(a.mdndrts)
                 else
                  0
               end as mdndrcrtb,
               --年度均次消费 ---3
               case
                 when sum(a.mdndrcs) <> 0 then
                  sum(a.mdndlzfy) / sum(a.mdndrcs)
                 else
                  0
               end as mdndkdj,
               -- 指定时间人头数 --4
               sum(a.mdzdsjrts) as mdzdsjrts,
               --指定时间人次数
               sum(a.mdzdsjrcs) as mdzdsjrcs,
               
               --  指定时间人头人次比 --5
               case
                 when sum(a.mdzdsjrts) <> 0 then
                  sum(a.mdzdsjrcs) / sum(a.mdzdsjrts)
                 else
                  0
               end as mdzdsjrtrcb,
               -- 指定时间列支费用 /指定时间人次 --6
               case
                 when sum(a.mdzdsjrcs) <> 0 then
                  sum(a.mdzdsjlzfy) / sum(a.mdzdsjrcs)
                 else
                  0
               end mdzdsjlzfy,
               sum(a.mdzdsjlzfy) as mdzdsjlzfyze
                from D_HZ_YWSJ_zeys a
               group by ord2
              
              ) A
       inner join (select (MAX(classname)) as qss,
                          year_year,
                          sum(year_rtzb) as year_rtzb,
                          sum(year_rcs) as year_rcs,
                          sum(year_ndcjfyze) as year_ndcjfyze,
                          sum(three_rtzb) as three_rtzb,
                          sum(three_rcs) as three_rcs,
                          sum(three_ndcjfyze) as three_ndcjfyze
                     from (select qs,
                                  classname,
                                  year_year,
                                  year_rtzb,
                                  year_rtzb * year_rcb as year_rcs,
                                  year_rcb,
                                  year_ndcjfy,
                                  year_ndcjfy * year_rtzb * year_rcb as year_ndcjfyze,
                                  three_rtzb,
                                  three_rtzb * three_rczb as three_rcs,
                                  three_rczb,
                                  three_cjfy,
                                  three_cjfy * three_rtzb * three_rczb as three_ndcjfyze
                             from t_zeys_zb)
                    group BY  year_year) b
          on qss = A.depotid
         and YEAR_YEAR = 2023
      
      union all
      
      select --depotid,
       '杭州总计' as classname,
       '杭州总计' as qs,
       '杭州总计' as busno,
       '杭州总计' as orgname,
       
       year_rcs as yearmdndrcs,
       --年度人次数
       mdndrcs,
       
       year_rtzb,
       mdndrts,
       
       mdndrts / year_rtzb AS wczb1,
       
       -- 年度人次人头比指标--2
       year_rcs / year_rtzb as year_rcb,
       mdndrcrtb,
       mdndrcrtb / (year_rcs / year_rtzb) AS wczb2,
       
       --年度均次消费 ---3
       year_ndcjfyze / year_rcs as year_ndcjfy,
       mdndkdj,
       mdndkdj / (year_ndcjfyze / year_rcs) AS wczb3,
       -- 指定时间人次数
       three_rcs as three_rcs,
       mdzdsjrcs,
       
       -- 指定时间人头数 --4
       three_rtzb,
       mdzdsjrts,
       mdzdsjrts / three_rtzb AS wczb4,
       
       --  指定时间人头人次比 --5
       three_rcs / three_rtzb as three_rczb,
       mdzdsjrtrcb,
       mdzdsjrtrcb / (three_rcs / three_rtzb) AS wczb5,
       
       -- 指定时间列支费用 /指定时间人次 --6
       three_ndcjfyze / three_rcs as three_cjfy,
       mdzdsjlzfy,
       mdzdsjlzfy / (three_ndcjfyze / three_rcs) AS wczb6,
       mdzdsjlzfyze
      
      --year_rtzb/year_rcs as year_rcb,
      
      -- 年度人头数--1
      --year_rtzb,
      
      --
      
        from (select
              
               ord as depotid,
               '' as busno,
               '' as orgname,
               sum(a.mdndrts) as mdndrts,
               
               --年度人次数
               sum(a.mdndrcs) as mdndrcs,
               
               -- 年度人次人头比指标--2
               case
                 when sum(a.mdndrts) <> 0 then
                  sum(a.mdndrcs) / sum(a.mdndrts)
                 else
                  0
               end as mdndrcrtb,
               --年度均次消费 ---3
               case
                 when sum(a.mdndrcs) <> 0 then
                  sum(a.mdndlzfy) / sum(a.mdndrcs)
                 else
                  0
               end as mdndkdj,
               -- 指定时间人头数 --4
               sum(a.mdzdsjrts) as mdzdsjrts,
               --指定时间人次数
               sum(a.mdzdsjrcs) as mdzdsjrcs,
               
               --  指定时间人头人次比 --5
               case
                 when sum(a.mdzdsjrts) <> 0 then
                  sum(a.mdzdsjrcs) / sum(a.mdzdsjrts)
                 else
                  0
               end as mdzdsjrtrcb,
               -- 指定时间列支费用 /指定时间人次 --6
               case
                 when sum(a.mdzdsjrcs) <> 0 then
                  sum(a.mdzdsjlzfy) / sum(a.mdzdsjrcs)
                 else
                  0
               end mdzdsjlzfy,
               sum(a.mdzdsjlzfy) as mdzdsjlzfyze
                from D_HZ_YWSJ_zeys a
               group by ord
              
              ) A
       inner join (select ('1060') as qss,
                          year_year,
                          sum(year_rtzb) as year_rtzb,
                          sum(year_rcs) as year_rcs,
                          sum(year_ndcjfyze) as year_ndcjfyze,
                          sum(three_rtzb) as three_rtzb,
                          sum(three_rcs) as three_rcs,
                          sum(three_ndcjfyze) as three_ndcjfyze
                     from (select qs,
                                  classname,
                                  year_year,
                                  year_rtzb,
                                  year_rtzb * year_rcb as year_rcs,
                                  year_rcb,
                                  year_ndcjfy,
                                  year_ndcjfy * year_rtzb * year_rcb as year_ndcjfyze,
                                  three_rtzb,
                                  three_rtzb * three_rczb as three_rcs,
                                  three_rczb,
                                  three_cjfy,
                                  three_cjfy * three_rtzb * three_rczb as three_ndcjfyze
                             from t_zeys_zb)
                    group by year_year) b
          on qss = A.depotid
          -- 这里和导入的 杭州预算数据 匹配 后期不需要可以删掉字段 和当前条件
         and YEAR_YEAR = 2023
         ;
  end if;
  --commit;
end;
/

