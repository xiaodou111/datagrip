create PROCEDURE cproc_blance_check_rrt( p_check_month IN d_check_computation.check_month%TYPE)
IS

-- v_cnt  pls_integer;

begin


/*
西药 ~t12-保健(食品)~t13-器械~t14-日化~t15/大病医保 ~t02/冷藏 ~t03/非成型包装(中药饮片) ~t04/非成型包装(参茸贵细) ~t05/成型包装 ~t06/赠品 ~t07/物资 ~t08/收银长款 ~t09
select distinct store_req from t_ware where nvl(store_req,'99') in('03','04','11','10') 冷藏下列选项 262
20210507 新增审核过的门店不能刷新
*/

  insert into temp_balance_check
  (accdate,busno,classgroupno,wareqtyb,wareqtya,abnqty,abnprice,jsprice,pdpfbl,gscdje,jsje,ckje,check_status,createtime,createuser)
  select check_month,busno,b.classgroupno,0,0,0,0,0,0,0,0,0,0,sysdate,168
  from d_check_computation a ,
  ( SELECT REGEXP_SUBSTR('02,03,04,05,06,07,08,09,11', '[^,]+', 1, rownum) as classgroupno  FROM DUAL
   CONNECT BY ROWNUM <=LENGTH('02,03,04,05,06,07,08,09,11') - LENGTH(REPLACE('02,03,04,05,06,07,08,09,11', ',', NULL)) + 1) b
  where a.check_month =p_check_month
  union all
  select check_month,busno,b.classgroupno||c.classcode as classgroupno,0,0,0,0,0,0,0,0,0,0,sysdate,168
  from d_check_computation a ,
  ( SELECT REGEXP_SUBSTR('12,13,14,15', '[^,]+', 1, rownum) as classgroupno  FROM DUAL
   CONNECT BY ROWNUM <=LENGTH('12,13,14,15') - LENGTH(REPLACE('12,13,14,15', ',', NULL)) + 1) b,
   (SELECT REGEXP_SUBSTR('A,B,C,D,E,Q', '[^,]+', 1, rownum) as classcode FROM DUAL
   CONNECT BY ROWNUM <=LENGTH('A,B,C,D,E,Q') - LENGTH(REPLACE('A,B,C,D,E,Q', ',', NULL)) + 1) c
  where  a.check_month =p_check_month;

--先批量生成当月数据模板
delete from d_balance_check where accdate=p_check_month and check_status <> 1;

insert into d_balance_check
(accdate,busno,classgroupno,wareqtyb,wareqtya,abnqty,abnprice,jsprice,pdpfbl,gscdje,jsje,ckje,check_status,createtime,createuser)
select accdate,busno,classgroupno,wareqtyb,wareqtya,abnqty,abnprice,jsprice,pdpfbl,gscdje,jsje,ckje,check_status,createtime,createuser
from temp_balance_check a
where not exists(select 1 from d_balance_check b where a.accdate=b.accdate and a.busno=b.busno and a.classgroupno=b.classgroupno);

--刷新赔付比例
  MERGE INTO d_balance_check T1
  USING (  select busno,zxcybl as pfbl,'12'||b.classcode as classgroupno  from d_check_compensation a,
           (SELECT REGEXP_SUBSTR('A,B,C,D,E,Q', '[^,]+', 1, rownum) as classcode FROM DUAL
           CONNECT BY ROWNUM <=LENGTH('A,B,C,D,E,Q') - LENGTH(REPLACE('A,B,C,D,E,Q', ',', NULL)) + 1) b
            union all
           select busno,zxcybl as pfbl,'13'||b.classcode as classgroupno  from d_check_compensation a,
           (SELECT REGEXP_SUBSTR('A,B,C,D,E,Q', '[^,]+', 1, rownum) as classcode FROM DUAL
           CONNECT BY ROWNUM <=LENGTH('A,B,C,D,E,Q') - LENGTH(REPLACE('A,B,C,D,E,Q', ',', NULL)) + 1) b
            union all
           select busno,zxcybl as pfbl,'14'||b.classcode as classgroupno  from d_check_compensation a,
           (SELECT REGEXP_SUBSTR('A,B,C,D,E,Q', '[^,]+', 1, rownum) as classcode FROM DUAL
           CONNECT BY ROWNUM <=LENGTH('A,B,C,D,E,Q') - LENGTH(REPLACE('A,B,C,D,E,Q', ',', NULL)) + 1) b
            union all
           select busno,zxcybl as pfbl,'15'||b.classcode as classgroupno  from d_check_compensation a,
           (SELECT REGEXP_SUBSTR('A,B,C,D,E,Q', '[^,]+', 1, rownum) as classcode FROM DUAL
           CONNECT BY ROWNUM <=LENGTH('A,B,C,D,E,Q') - LENGTH(REPLACE('A,B,C,D,E,Q', ',', NULL)) + 1) b
            union all
            select busno,zyypbl as pfbl,'04' as classgroupno  from d_check_compensation
            union all
            select busno,srgxbl as pfbl,'05' as classgroupno  from d_check_compensation
            union all
            select busno,cxbzbl as pfbl,'06' as classgroupno  from d_check_compensation) T2
  ON ( T1.busno=T2.busno and T1.classgroupno=T2.classgroupno and T1.accdate=p_check_month and T1.Check_Status <> 1)
  WHEN MATCHED THEN
      UPDATE SET T1.pdpfbl = T2.pfbl;


--盘点信息 类别10暂时没用到（包含其他和未分配的数据）
--损益单类型  ABL  是物资自动损益单 不参与核算
insert into tmp_balance_check_abn
(check_month,busno, classgroupno, wareqtyb, wareqtya, abnqty, abnprice)

select p_check_month,a.busno,case when b.wareid in (30506529,30505892,30506085,30506530,80101079,80103873,30505825,30506556) then '11'
                                 when nvl(twc27.classcode,'9999')='2710' then '02'
                                 when nvl(tw.store_req,'99') in('03','04','11','10') then '03'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011201' then '04'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011202' then '06'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011203' then '05'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0119' then '07'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0118' then '08'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4) in ('0110','0111','0113','0114','0115','0116')
                                      then
                                      -- 西药 保健 器械 日化 加入考核类别拆封
                                           case when substr(nvl(twc01.classcode,'99999999'),1,4) in('0110','0111') then '12'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) in('0113','0114') then '13'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0115' then '14'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0116' then '15'
                                             end||case when nvl(twc90.classcode,'9020') ='9011' then 'A'
                                                       when nvl(twc90.classcode,'9020') in('9012','9017','9019') then 'B'
                                                       when nvl(twc90.classcode,'9020') ='9013' then 'C'
                                                       when nvl(twc90.classcode,'9020') ='9014' then 'D'
                                                       when nvl(twc90.classcode,'9020') ='9015' then 'E'
                                                       when nvl(twc90.classcode,'9020') in('9018','9020') then 'Q' end
                               else '10' end classgroupno,sum(b.wareqtyb) as wareqtyb,
      round(sum(b.wareqtya),2) as wareqtya,round(sum(b.wareqtya-b.wareqtyb),2) as  abnqty,round(sum((b.wareqtya-b.wareqtyb)*tws.saleprice),2) as abnprice
from t_abnormity_h a
     join s_busi bs on a.compid=bs.compid and a.busno=bs.busno
     join d_check_computation c on a.busno=c.busno and c.check_month=p_check_month and trunc(a.execdate) between trunc(c.starttime) and trunc(c.endtime)
     join t_abnormity_d b on a.abnormityno=b.abnormityno
     join t_ware tw on a.compid=tw.compid and b.wareid=tw.wareid
     left join t_ware_class_base twc01 on tw.compid=twc01.compid and  tw.wareid=twc01.wareid and twc01.classgroupno='01'
     left join t_ware_class_base twc27 on tw.compid=twc27.compid and  tw.wareid=twc27.wareid and twc27.classgroupno='27'
     left join t_ware_saleprice tws on a.compid=tws.compid and bs.salegroupid=tws.salegroupid and b.wareid=tws.wareid
     left join t_ware_class_base twc90 on tw.compid=twc90.compid and  tw.wareid=twc90.wareid and twc90.classgroupno='90'
where a.status=1 and a.billcode='ABN'
group by a.busno,case when b.wareid in (30506529,30505892,30506085,30506530,80101079,80103873,30505825,30506556) then '11'
                                 when nvl(twc27.classcode,'9999')='2710' then '02'
                                 when nvl(tw.store_req,'99') in('03','04','11','10') then '03'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011201' then '04'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011202' then '06'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011203' then '05'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0119' then '07'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0118' then '08'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4) in ('0110','0111','0113','0114','0115','0116')
                                      then
                                      -- 西药 保健 器械 日化 加入考核类别拆封
                                           case when substr(nvl(twc01.classcode,'99999999'),1,4) in('0110','0111') then '12'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) in('0113','0114') then '13'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0115' then '14'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0116' then '15'
                                             end||case when nvl(twc90.classcode,'9020') ='9011' then 'A'
                                                       when nvl(twc90.classcode,'9020') in('9012','9017','9019') then 'B'
                                                       when nvl(twc90.classcode,'9020') ='9013' then 'C'
                                                       when nvl(twc90.classcode,'9020') ='9014' then 'D'
                                                       when nvl(twc90.classcode,'9020') ='9015' then 'E'
                                                       when nvl(twc90.classcode,'9020') in('9018','9020') then 'Q' end
                               else '10' end;


--零售信息 类别10暂时没用到（包含其他和未分配的数据）
insert into tmp_balance_check_sale
(check_month, busno, classgroupno, netsum)

select p_check_month,a.busno,case when tw.wareid in (30506529,30505892,30506085,30506530,80101079,80103873,30505825,30506556) then '11'
                                 when nvl(twc27.classcode,'9999')='2710' then '02'
                                 when nvl(tw.store_req,'99') in('03','04','11','10') then '03'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011201' then '04'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011202' then '06'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011203' then '05'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0119' then '07'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0118' then '08'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4) in ('0110','0111','0113','0114','0115','0116')
                                      then
                                      -- 西药 保健 器械 日化 加入考核类别拆封
                                           case when substr(nvl(twc01.classcode,'99999999'),1,4) in('0110','0111') then '12'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) in('0113','0114') then '13'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0115' then '14'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0116' then '15'
                                             end||case when nvl(twc90.classcode,'9020') ='9011' then 'A'
                                                       when nvl(twc90.classcode,'9020') in('9012','9017','9019') then 'B'
                                                       when nvl(twc90.classcode,'9020') ='9013' then 'C'
                                                       when nvl(twc90.classcode,'9020') ='9014' then 'D'
                                                       when nvl(twc90.classcode,'9020') ='9015' then 'E'
                                                       when nvl(twc90.classcode,'9020') in('9018','9020') then 'Q' end
                               else '10' end classgroupno,sum(a.netsum ) as netsum
from t_rpt_sale a
     join d_check_computation c on a.busno=c.busno and c.check_month=p_check_month and trunc(a.accdate) between trunc(c.starttime) and trunc(c.endtime)
     join t_ware tw on a.compid=tw.compid and a.wareid=tw.wareid
     left join t_ware_class_base twc01 on tw.compid=twc01.compid and  tw.wareid=twc01.wareid and twc01.classgroupno='01'
     left join t_ware_class_base twc27 on tw.compid=twc27.compid and  tw.wareid=twc27.wareid and twc27.classgroupno='27'
     left join t_ware_class_base twc90 on tw.compid=twc90.compid and  tw.wareid=twc90.wareid and twc90.classgroupno='90'
group by a.busno,case when tw.wareid in (30506529,30505892,30506085,30506530,80101079,80103873,30505825,30506556) then '11'
                                 when nvl(twc27.classcode,'9999')='2710' then '02'
                                 when nvl(tw.store_req,'99') in('03','04','11','10') then '03'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011201' then '04'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011202' then '06'
                                 when substr(nvl(twc01.classcode,'99999999'),1,6)='011203' then '05'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0119' then '07'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4)='0118' then '08'
                                 when substr(nvl(twc01.classcode,'99999999'),1,4) in ('0110','0111','0113','0114','0115','0116')
                                      then
                                      -- 西药 保健 器械 日化 加入考核类别拆封
                                           case when substr(nvl(twc01.classcode,'99999999'),1,4) in('0110','0111') then '12'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) in('0113','0114') then '13'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0115' then '14'
                                                when substr(nvl(twc01.classcode,'99999999'),1,4) = '0116' then '15'
                                             end||case when nvl(twc90.classcode,'9020') ='9011' then 'A'
                                                       when nvl(twc90.classcode,'9020') in('9012','9017','9019') then 'B'
                                                       when nvl(twc90.classcode,'9020') ='9013' then 'C'
                                                       when nvl(twc90.classcode,'9020') ='9014' then 'D'
                                                       when nvl(twc90.classcode,'9020') ='9015' then 'E'
                                                       when nvl(twc90.classcode,'9020') in('9018','9020') then 'Q' end
                               else '10' end;



--长款
insert into tmp_balance_check_payee
(check_month, busno, classgroupno, netsum)

SELECT  p_check_month, a.busno, '09' AS classgroupno,round(sum(b.amt_confirm - b.netsum - b.rechargeamt - b.advance_payment_amt),2) AS netamt
FROM t_payee_check_h a
    join t_payee_check_d b on  a.checkno = b.checkno
    join d_check_computation c on a.busno=c.busno and c.check_month=p_check_month and to_char(a.CREATEDATE,'yyyymm') =c.longpay_month
where a.status=1
GROUP  BY a.busno;



--刷新盘点结算表  损益 ：DTP和冷藏商品按照差异赔付，其他的按欠款赔付
  MERGE INTO d_balance_check T1
  USING (select * from tmp_balance_check_abn) T2
  ON ( T1.busno=T2.busno and T1.classgroupno=T2.classgroupno and T1.accdate=p_check_month and T1.check_status <> 1)
  WHEN MATCHED THEN
      UPDATE SET T1.wareqtyb  = T2.wareqtyb ,
                 T1.wareqtya = T2.wareqtya,
                 T1.abnqty   = T2.abnqty,
                 T1.abnprice = T2.abnprice,
                 T1.jsprice  = T2.abnprice;

  update d_balance_check set jsprice=0 where accdate=p_check_month and classgroupno not in('02','03') and abnprice>0 and check_status <> 1;
  --物资恒为零
  update d_balance_check set jsprice=0 where accdate=p_check_month and classgroupno ='08' and check_status <> 1;

--销售
  MERGE INTO d_balance_check T1
  USING (select * from tmp_balance_check_sale) T2
  ON ( T1.busno=T2.busno and T1.classgroupno=T2.classgroupno and T1.accdate=p_check_month  and T1.check_status <> 1)
  WHEN MATCHED THEN
      UPDATE SET T1.gscdje  = T2.netsum*T1.pdpfbl;

--长款
  MERGE INTO d_balance_check T1
  USING (select * from tmp_balance_check_payee) T2
  ON ( T1.busno=T2.busno and T1.classgroupno=T2.classgroupno and T1.accdate=p_check_month  and T1.check_status <> 1)
  WHEN MATCHED THEN
      UPDATE SET T1.ckje   = T2.netsum;

--结算金额

  update d_balance_check set jsje=ckje+jsprice+gscdje   where accdate=p_check_month and check_status <> 1;

end ;
/

