INSERT INTO t_needreturn_d
            (billno, wareid, makeno, busno,returnnum, 
             batid)

            SELECT  '110000000000000000000047537',w.wareid, temp.makeno, 
                          temp.busno,1,temp.batid
                  FROM   t_needreturn_d_temp temp
                  INNER  JOIN s_busi sb
                  ON     sb.busno = temp.busno
                  INNER  JOIN t_ware w
                  ON     w.warecode = temp.warecode AND w.compid = sb.compid
                  WHERE  temp.billno = 110000000000000000000047537 
                  
                  
                  
                  and batid=1461791
                  select * from t_needreturn_d where
                  
                  
                  select * from t_needreturn_d where batid=2155065 and busno=81001 and makeno=20200420 and wareid=10226392
                  
                  select * from t_needreturn_d_temp where batid=2155065 and busno=81008 and makeno=20200420 and WARECODE=30505549 
                  
select  batid,busno,makeno,warecode from t_needreturn_d_temp group by 
batid,busno,makeno,warecode having count(*) >1
                  
 --when others then
    --raise_application_error(-20001,res.wareid||','||res.makeno||'有问题',true);
--delete from d_thmxth  WHERE  wareid =10232668
 -- and busno not in (select busno from  t_needreturn_d  WHERE lcbh=202302271513291854 and wareid=10232668)

                  
            
  for update
                  
     T_NEEDRETURN_D_TEMP1   --用来查重 
              
select a.* from   T_NEEDRETURN_D_TEMP b inner join t_needreturn_d a on  trim(a.wareid)=trim(b.warecode) and a.makeno=b.makeno
and a.busno=b.busno and a.batid=b.batid 


 --查询要导入的和已导入的主键有没有重复
 select * from d_thmxth  a join
 (select LCBH, BUSNO, WAREID, MAKENO, BATID  from (
 select  LCBH, BUSNO, WAREID, MAKENO, BATID from d_thmxth 
 union all
 select  LCBH, BUSNO, WAREID, MAKENO, BATID  FROM t_needreturn_d  a
 WHERE   lxbz IS NULL  
 ) a  group by 
  LCBH, BUSNO, WAREID, MAKENO, BATID 
  having count(*)>1) b on a.LCBH=b.LCBH and a.BUSNO=b.BUSNO and a.WAREID=b.WAREID and a.MAKENO=b.makeno and a.batid=b.batid
  --查询要导入的和已导入的主键有没有重复
  select * from d_thmxth a join
  (select  LCBH, BUSNO, WAREID, MAKENO, BATID  FROM t_needreturn_d  a
 WHERE   lxbz IS NULL
 group by 
  LCBH, BUSNO, WAREID, MAKENO, BATID  ) b
  on a.LCBH=b.LCBH and a.BUSNO=b.BUSNO and a.WAREID=b.WAREID and a.MAKENO=b.makeno and a.batid=b.batid


--删除t_needreturn_d中和T_NEEDRETURN_D_TEMP重复的数据
delete from t_needreturn_d a where exists(
select 1 from T_NEEDRETURN_D_TEMP b where
trim(a.wareid)=trim(b.warecode) and a.makeno=b.makeno
and a.busno=b.busno and a.batid=b.batid 
)




select  batid,busno,makeno,warecode from t_needreturn_d_temp group by 
batid,busno,makeno,warecode having count(*) >1
select * from  t_needreturn_d_temp 




and b.billno=110000000000000000000047537
