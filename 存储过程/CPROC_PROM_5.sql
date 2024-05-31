create or replace PROCEDURE cproc_prom_5

IS

v_rowno number(10);

begin
--202307管理类别院外商品改为 （ 12105DTP商品，12116 定向处方引流商品 ）

  /*<<<<<<<<<<< 温州 >>>>>>>>>>>
  促销调价单号：202202240000005(温州)
                202202240000006(乐清)
                202202240000007(泰顺)
                202202240000008(岩头) 20230204 岩头折扣改成85折

  温州逢5规则说明：
  1、集团管理类别为“院外商品”，“定向处方”不参与，功能主治大类剔除赠品、物资，
     商品名称剔除“包含换购”的商品
  2、温州维价商品不参与（维价目录6个品种），10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
     【此功能由外部数据导入 d_prom_noware（促销调价商品剔除目录）】
  3、折扣85折(岩石83折)，其中考核类别B2(功能主治参茸贵细不限购)，限购2盒
  
  20220825 新增34个商品限购数量2
  */

   for wz in (select promno,85 as zk  from t_prom_h
               where promno in('202202240000005','202202240000006','202202240000007','202202240000008') ) loop

      --删除原单明细
      delete from t_prom_d where promno = wz.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select wz.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,
              case when a.wareid in(10600399,10110252,10110446,10108964,10502331,10112014,10600542,
                        10502495,10500013,10100219,10502241,10100601,10107833,10303790,10100201,10107768,
                        10111858,10106329,10111664,10113021,10600273,10100819,10600271,10106220,10111668,
                        10108388,10502472,10500181,10100253,10106570,10112161,10106419,10222996,10100520,
                        10500154,10100475,10117880,10502291,10502381,10111322,10502254,10111682,10106711,10108932,
                        10500152,10502388,10300154,10224582,10502496,10500004,10101525,10502228,10113011,10502459,10117838,10105707,10100316,10503538) then  2
                   when (tbc.classcode='9019' and substring(tbc1.classcode,1,6)<>'011203') then 2 else 0 end as promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,wz.zk ,'全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'
      join t_ware_class_base tbc1 on a.compid=tbc1.compid and a.wareid=tbc1.wareid and tbc1.classgroupno='01'
      where a.compid=1030
      and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='810'and b.classcode in('81010')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno=wz.promno)
      and a.warename not like '%换购%'
      and a.status=1 and a.warekind=1;

   end loop wz;
commit;


/*<<<<<<<<<<< 温岭 >>>>>>>>>>>
促销调价单号：202202240000009(温岭)
              202204130000002(温岭次新店)

温岭逢5规则说明：
1、集团管理类别为“院外商品”不参与，
   功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品
2、考核类别为A、B、B1类，非药商品折扣85折，考核类别为C、D类，非药商品折扣95折
3、温岭慢病21个品种88折，商品名称包含“汤臣倍健”折扣75折
4、台州维价商品不参与（维价目录7个品种），10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
  【此功能由外部数据导入 d_prom_noware（促销调价商品剔除目录）】

*/
  --删除原单明细
  for wl in (select promno from t_prom_h where promno in('202202240000009') ) loop

      delete from t_prom_d where promno = wl.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select wl.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,
              case when a.warename like '%汤臣倍健%' then 75
                   else 85 end as 折扣,
              '全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a
           join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'and tbc.classcode in('9011','9012','9017')
           join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01'and substr(twc.classcode,1,4) not in ('0110','0111','0114','0115','0116')
      where a.compid=1000 
      and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base c1 where c1.classgroupno='810'and c1.classcode in('81010') and a.compid=c1.compid and a.wareid=c1.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno = wl.promno)
      and a.warename not like '%换购%'
      and a.status=1 and a.warekind=1;

  end loop wl;
commit;


/*<<<<<<<<<<< 外县市 >>>>>>>>>>>
促销调价单号：202202240000010(台州外县，慢病90个品种88折)
              202204130000003(台州外县次新店，和台州外县一样)
              202202240000011(弘德，慢病90个品种88折)20230809暂时作废

              202103051000003(天台，外县市慢病90个品种88折，天台6个品牌商品商品95折)
              202103051000004(天台)
              202103051000005(天台)
              202103051000006(天台)

台州外县市逢5规则说明：
1、集团管理类别为“院外商品”不参与，
   功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品
2、考核类别为A、B、B1类，非药商品折扣85折，考核类别为A、B、B1类，药品，及考核类别为C、D类，药品、非药商品折扣95折
3、商品名称包含“汤臣倍健”折扣75折
4、台州维价商品不参与（维价目录7个品种），10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
  【此功能由外部数据导入 d_prom_noware（促销调价商品剔除目录）】

*/

  for tt in (select 1000 as compid ,promno 
             from t_prom_h where promno in ('202202240000010', '202103051000003','202103051000004','202103051000005','202103051000006','202403150000001') ) loop

  --删除原单明细
  delete from t_prom_d where promno = tt.promno;
  --插入新明细
  INSERT INTO t_prom_d (promno,rowno,
      distype,wareid,batchno,disrate,promqty,
      promqty_c,promqty_c_flag,
      integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
      set_price_flag,profitrate_e,
      starttime,endtime,limitedtype,onedaypromqty)

  select  tt.promno,row_number() over( order by a.wareid ) as rowno,
          1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
          1 as integral_times,0 as promdays,
          case when a.warename like '%汤臣倍健%'  then 75
               when a.WARENAME like '%亿格海斯%'  then 85
               else case when tbc.classcode in('9011','9012','9017') and substr(twc.classcode,1,4) not in ('0110','0111') then 85
               else case when tbc.classcode in('9013','9014') and substr(twc.classcode,1,4) not in ('0110','0111') then 95
               else case when tbc.classcode in('9011','9012','9013','9014','9017') and substr(twc.classcode,1,4) in ('0110','0111') then 95
                 else  100 end end end end as 折扣,
          '全部' typeno,1 salegroupid,0 profitrate,
          0 as set_price_flag,9999 as profitrate_e,
          to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
          1 limitedtype,0 onedaypromqty
  from t_ware a
       join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'and tbc.classcode in('9011','9012','9013','9014','9017')
       join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01'
                                         --and substr(twc.classcode,1,4) not in ('0110','0111')
  where a.compid=tt.compid 
  and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
  and not exists(select 1 from t_ware_class_base c1 where c1.classgroupno='810'and c1.classcode in('81010') and a.compid=c1.compid and a.wareid=c1.wareid)
  and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
  and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno =tt.promno)
  and a.warename not like '%换购%'
  and a.status=1 and a.warekind=1;

  end loop tt;
commit;


/*<<<<<<<<<<< 外县市 >>>>>>>>>>>
促销调价单号：202202240000012(保济堂，慢病90个品种85折)

台州外县市逢5规则说明：
1、集团管理类别为“院外商品”不参与，
   功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品
2、考核类别为A、B、B1类，非药商品折扣85折，考核类别为A、B、B1类，药品，及考核类别为C、D类，药品、非药商品折扣95折
3、商品名称包含“汤臣倍健”折扣75折
4、台州维价商品不参与（维价目录7个品种），10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
  【此功能由外部数据导入 d_prom_noware（促销调价商品剔除目录）】

*/

  for tt in (select compid as compid ,promno 
             from t_prom_h where promno in ('202202240000012') ) loop

  --删除原单明细
  delete from t_prom_d where promno = tt.promno;
  --插入新明细
  INSERT INTO t_prom_d (promno,rowno,
      distype,wareid,batchno,disrate,promqty,
      promqty_c,promqty_c_flag,
      integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
      set_price_flag,profitrate_e,
      starttime,endtime,limitedtype,onedaypromqty)

  select  tt.promno,row_number() over( order by a.wareid ) as rowno,
          1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
          1 as integral_times,0 as promdays,
          case when a.warename like '%汤臣倍健%' then 75
               when a.warename like '%亿格海斯%' then 85
               when tbc.classcode in('9011','9012','9017') and substr(twc.classcode,1,4) not in ('0110','0111') then 85
               else 100 end as 折扣,
          '全部' typeno,1 salegroupid,0 profitrate,
          0 as set_price_flag,9999 as profitrate_e,
          to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
          1 limitedtype,0 onedaypromqty
  from t_ware a
       join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'and tbc.classcode in('9011','9012','9017')
       join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01' and substr(twc.classcode,1,4) not in ('0114','0115','0116')
  where a.compid=tt.compid 
  and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
  and not exists(select 1 from t_ware_class_base c1 where c1.classgroupno='810'and c1.classcode in('81010') and a.compid=c1.compid and a.wareid=c1.wareid)
  and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
  and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno =tt.promno)
  and a.warename not like '%换购%'
  and a.status=1 and a.warekind=1;

  end loop tt;
commit;


/*<<<<<<<<<<< 慈溪弘德 >>>>>>>>>>>
促销调价单号：--202308090000001 27个品种88折
              202308090000002
               
              
1、集团管理类别为“院外商品”“DTP商品”、“定向处方引流商品”不参与
2、按功能主治中类，类别编码为011021,011120,011008,011107,011007,011106,011012,011111,011019,011118,011010,011109,011011,011110,011009,011108,011006,011105,011005,011104折扣95折，
                   类别编码为011017,011116,011121,011018,011117,011013,011112,011003,011102,011002,011101,011001,011014,011113,011020,011119,011015,011114,011004折扣97折
3、非药品 考核类别为A、B、B1类，折扣85折 ，C、D类，折扣95折
4、27个慢病商品88折，商品名称包含“汤臣倍健”折扣75折
5、功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品，10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与

促销调价单号： 202308090000003
1、集团管理类别为“院外商品”“DTP商品”、“定向处方引流商品”不参与
2、27个慢病商品88折，商品名称包含“汤臣倍健”折扣75折，其余商品88折
5、功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品，10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与

*/

  for wcx in (select compid ,promno from t_prom_h where promno in('202308090000002','202308090000003')) loop

  --删除原单明细
  delete from t_prom_d where promno = wcx.promno;
  --插入新明细
  INSERT INTO t_prom_d (promno,rowno,
      distype,wareid,batchno,disrate,promqty,
      promqty_c,promqty_c_flag,
      integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
      set_price_flag,profitrate_e,
      starttime,endtime,limitedtype,onedaypromqty)

  select  wcx.promno,row_number() over( order by a.wareid ) as rowno,
          1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
          1 as integral_times,0 as promdays,
          case when a.warename like '%汤臣倍健%' then 75
               when a.warename like '%亿格海斯%' then 85
               when wcx.promno='202308090000003' then 88
               when wcx.promno='202308090000002' then 
                   case when tbc.classcode in('9011','9012','9017') and substr(twc.classcode,1,4) not in ('0110','0111','0114','0115','0116') then 85
                        when substr(twc.classcode,1,6) in('011017','011116','011121','011018','011117','011013','011112','011003','011102','011002','011101','011001','011014','011113','011020','011119','011015','011114','011004') then 97
                        when  substr(twc.classcode,1,4)  in ('0110','0111') and  substr(twc.classcode,1,6) not in('011017','011116','011121','011018','011117','011013','011112','011003','011102','011002','011101','011001','011014','011113','011020','011119','011015','011114','011004') then 95
                       else 100 end
          else 95 end as 折扣,
          '全部' typeno,1 salegroupid,0 profitrate,
          0 as set_price_flag,9999 as profitrate_e,
          to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
          1 limitedtype,0 onedaypromqty
  from t_ware a
       join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'--and tbc.classcode in('9011','9012','9013','9014','9017')
       join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01'
  where a.compid=wcx.compid 
  and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
  and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
  and not exists(select 1 from t_ware_class_base c1 where c1.classgroupno='810'and c1.classcode in('81010') and a.compid=c1.compid and a.wareid=c1.wareid)
  and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno =wcx.promno)
  and a.warename not like '%换购%'
  and a.status=1 and a.warekind=1;

  end loop tt;
commit;


/*<<<<<<<<<<< 台州次新店 >>>>>>>>>>>
促销调价单号：202208100000006

台州次新店逢5规则说明：
1、集团管理类别为“院外商品”不参与，
   功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品
2、折扣88折，商品名称包含“汤臣倍健”折扣75折
4、台州维价商品不参与（维价目录7个品种），10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
  【此功能由外部数据导入 d_prom_noware（促销调价商品剔除目录）】

*/
  --删除原单明细
  for tcx in (select promno from t_prom_h where promno in ('202208100000006','202403120000006') ) loop

      delete from t_prom_d where promno = tcx.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select tcx.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,
              case when a.warename like '%汤臣倍健%' then 75 else 88 end as 折扣,
              '全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a
      where a.compid=1000 
      and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
      --and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base c1 where c1.classgroupno='810'and c1.classcode in('81010') and a.compid=c1.compid and a.wareid=c1.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno = tcx.promno)
      and a.warename not like '%换购%'
      and a.status=1 and a.warekind=1;

  end loop tcx;
commit;



/*<<<<<<<<<<< 台州外县次新店 >>>>>>>>>>>
促销调价单号：202208100000007
              202209150000002(B2、E类限购2盒) --20220915修改
台州外县次新店逢5规则说明：
1、集团管理类别为“院外商品”,“DTP商品”、“定向处方引流商品”不参与，
   功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品
2、折扣88折，商品名称包含“汤臣倍健”折扣75折
4、10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与


*/
  --删除原单明细
  for twcx in (select promno from t_prom_h where promno in('202208100000007','202209150000002','202311130000001','202311130000004','202401120000005','202402190000003') ) loop

      delete from t_prom_d where promno = twcx.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select twcx.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,
              case when a.warename like '%汤臣倍健%' then 75 else 88 end as 折扣,
              '全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a
      where a.compid=1000 
--       and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116','12114') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base c1 where c1.classgroupno='810'and c1.classcode in('81010') and a.compid=c1.compid and a.wareid=c1.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno = twcx.promno)
      and a.warename not like '%换购%' and a.wareid not in (10200297,10106916,10105796)
      and a.status=1 and a.warekind=1;

 --promqty_c限购数量
  if twcx.promno ='202209150000002' then
    update t_prom_d a set a.promqty_c =2 where a.promno=twcx.promno 
    and exists(select 1 from t_ware_class_base tbc where tbc.compid=1040
                             and tbc.classgroupno='90'and tbc.classcode in('9015','9019')and a.wareid=tbc.wareid );
  end if;
  
  end loop twcx;
commit;




/*<<<<<<<<<<< 新店临时活动 >>>>>>>>>>>
促销调价单号：202308160000001

1、集团管理类别为“院外商品”、“DTP商品”、“定向处方引流商品”不参与，功能主治大类剔除赠品、物资，商品名称剔除“包含换购”的商品，10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
2、135个慢病品种85折，非药AB类商品69折，其余88折

*/
  --删除原单明细
  for tcx in (select promno from t_prom_h where promno ='202308160000001' ) loop

      delete from t_prom_d where promno = tcx.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select tcx.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,
              case when tbc.classcode in('9011','9012') and substr(twc.classcode,1,4) not in ('0110','0111') then 69 else 88 end as 折扣,
              '全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2023-08-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2023-08-16 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a
           join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'
           join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01'
      where a.compid=1000 and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno = tcx.promno)
      and a.warename not like '%换购%'
      and a.status=1 and a.warekind=1;

  end loop tcx;
commit;


--统一处理 特价折扣商品折率
--更新

  MERGE INTO t_prom_d T1
  USING (SELECT * FROM d_prom_spcdisrate) T2
  ON ( T1.promno=T2.promno and T1.wareid=T2.wareid)
  WHEN MATCHED THEN
      UPDATE SET T1.memdisrate = T2.zk;

/*<<<<<<<<<<< 新店临时活动 >>>>>>>>>>>
促销调价单号：202311090000012

1、集团管理类别为“院外商品”、“DTP商品”、“定向处方引流商品”不参与，功能主治大类剔除赠品、物资，
商品名称剔除“包含换购”的商品，10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
2、135个慢病品种85折，非药AB类商品69折，其余88折

*/
  --删除原单明细
  for tcx in (select promno from t_prom_h where promno ='202311090000012' ) loop

      delete from t_prom_d where promno = tcx.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select tcx.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,
              case when tbc.classcode in('9011','9012') and a.warename not like '%汤臣倍健%'
                   and substr(twc.classcode,1,4) not in ('0110','0111') then 69
                when a.warename like '%汤臣倍健%' then 75  else 88 end as 折扣,
              '全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2023-08-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2023-08-16 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a
           join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'
           join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01'
      where a.compid=1000 and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno = tcx.promno)
      and a.warename not like '%换购%'
      and a.status=1 and a.warekind=1;

  end loop tcx;
commit;


--统一处理 特价折扣商品折率
--更新

  MERGE INTO t_prom_d T1
  USING (SELECT * FROM d_prom_spcdisrate) T2
  ON ( T1.promno=T2.promno and T1.wareid=T2.wareid)
  WHEN MATCHED THEN
      UPDATE SET T1.memdisrate = T2.zk,
      t1.promqty_c=t2.promqty;


/*<<<<<<<<<<< 新店临时活动 >>>>>>>>>>>
促销调价单号：202311090000012

1、集团管理类别为“院外商品”、“DTP商品”、“定向处方引流商品”不参与，功能主治大类剔除赠品、物资，
商品名称剔除“包含换购”的商品，10200297立钻、10106916丁苯酞软胶囊、10105796片仔癀不参与
2、特价目录85折，全场考核AB类商品88折，其余95折

*/
  --删除原单明细
  for tcxx in (select promno from t_prom_h where promno ='202403220000001' ) loop

      delete from t_prom_d where promno = tcxx.promno;
      --插入新明细
      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,
          promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

      select tcxx.promno,row_number() over( order by a.wareid ) as rowno,
              1 as distype,a.wareid,'全部'as batchno,100 as disrate,0 promqty,0 promqty_c,2 promqty_c_flag,
              1 as integral_times,0 as promdays,
              case when tbc.classcode in('9011','9012') and a.warename not like '%汤臣倍健%'
                    then 88
                when a.warename like '%汤臣倍健%' then 75
                  else 95 end as 折扣,
              '全部' typeno,1 salegroupid,0 profitrate,
              0 as set_price_flag,9999 as profitrate_e,
              to_date('2023-08-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2023-08-16 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
              1 limitedtype,0 onedaypromqty
      from t_ware a
           join t_ware_class_base tbc on a.compid=tbc.compid and a.wareid=tbc.wareid and tbc.classgroupno='90'
           join t_ware_class_base twc on a.compid=twc.compid and a.wareid=twc.wareid and twc.classgroupno='01'
      where a.compid=1000 and not exists(select 1 from t_ware_class_base c where c.classgroupno='12'and c.classcode in('12105','12116') and a.compid=c.compid and a.wareid=c.wareid)
      and not exists(select 1 from t_ware_class_base b where b.classgroupno='01'and substr(b.classcode,1,4) in('0118','0119')and a.compid=b.compid and a.wareid=b.wareid)
      and not exists(select 1 from d_prom_noware dno where a.wareid=dno.wareid and dno.promno = tcxx.promno)
      and a.warename not like '%换购%'
      and a.status=1 and a.warekind=1;

  end loop tcxx;
commit;

--统一处理 特价折扣商品折率
--更新

  MERGE INTO t_prom_d T1
  USING (SELECT * FROM d_prom_spcdisrate) T2
  ON ( T1.promno=T2.promno and T1.wareid=T2.wareid)
  WHEN MATCHED THEN
      UPDATE SET T1.memdisrate = T2.zk,
      t1.promqty_c=t2.promqty;


--插入
  for mb in (select distinct promno  from d_prom_spcdisrate a where exists(select 1 from t_prom_h b where a.promno=b.promno)
             group by promno)loop
    
      select nvl(max(rowno),0) into v_rowno from t_prom_d where promno = mb.promno;
      
      
      INSERT INTO t_prom_d (promno,rowno,
            distype,wareid,batchno,disrate,promqty,
            promqty_c,promqty_c_flag,
            integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
            set_price_flag,profitrate_e,
            starttime,endtime,limitedtype,onedaypromqty)

       select a.promno as promno,row_number() over( order by wareid )+v_rowno as rowno,
       1 as distype,wareid,'全部'as batchno,100 as disrate,0 promqty,promqty as promqty_c,2 promqty_c_flag,
       1 as integral_times,0 as promdays,zk,'全部' typeno,1 salegroupid,0 profitrate,
       0 as set_price_flag,9999 as profitrate_e,
       to_date('2021-03-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS') as starttime,to_date('2021-03-05 23:59:59', 'YYYY-MM-DD HH24:MI:SS') as endtime,
       1 limitedtype,0 onedaypromqty
       from d_prom_spcdisrate a 
       where a.promno=mb.promno and not exists(select 1 from t_prom_d b where a.wareid=b.wareid and b.promno=mb.promno) ;
      
  end loop;
commit;

--删除没有购进记录的商品
delete from t_prom_d a 
where a.promno in ('202202240000005','202202240000006','202202240000008','202202240000007','202202240000009','202202240000010',
'202202240000012','202204130000002','202204130000003','202103051000003','202103051000004','202103051000005','202103051000006',
'202308090000001','202308090000002','202308090000003','202308160000001','202403150000001','202403120000006')
and not exists(select 1 from t_store_i ii where a.wareid=ii.wareid and ii.compid=0);

--删除202202240000012中折率100的商品
delete from t_prom_d where promno = '202202240000012' and memdisrate=100;
delete from t_prom_d where promno = '202308090000002' and memdisrate=100;
 
--将集团的订单下发更新连锁的单子
  for xf in (select promno,parentno from t_prom_h where parentno in ('202202240000005','202202240000006','202202240000008',
                 '202202240000007','202202240000009','202202240000010','202202240000012',
                 '202204130000002','202204130000003','202103051000003','202103051000004','202103051000005','202103051000006',
                 '202308090000001','202308090000002','202308090000003','202308160000001','202311130000001','202311130000004','202402190000003','202401120000005','202403150000001','202403120000006') ) loop

      delete from t_prom_d where promno= xf.promno;

      INSERT INTO t_prom_d (promno,rowno,
          distype,wareid,batchno,disrate,promqty,promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty)

       select xf.promno,rowno,
          distype,wareid,batchno,disrate,promqty,promqty_c,promqty_c_flag,
          integral_times,promdays,memdisrate,typeno,salegroupid,profitrate,
          set_price_flag,profitrate_e,
          starttime,endtime,limitedtype,onedaypromqty
       from t_prom_d where promno = xf.parentno;

  end loop xf;
commit;

end;
/

