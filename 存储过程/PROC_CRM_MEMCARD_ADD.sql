create procedure proc_crm_memcard_add

is
        v_cnt  pls_integer;
        v_no t_memcard_cash.cashno%type;
        v_sqlcode     VARCHAR2(4000);
        v_sqlerrm     VARCHAR2(4000);
 begin


   for res in (SELECT * FROM crm_in_memcard_add WHERE msg_status=0) loop
      begin
     SELECT COUNT(*)
     into v_cnt
     FROM t_memcard_reg
     WHERE memcardno=res .memcardno   ;


     if v_cnt>0 or  res.memcardno is null or res.memcardno='' then
       update crm_in_memcard_add set msg='会员卡号重复或者为空', msg_status=2 WHERE memcardno=res.memcardno  ;
       continue;
     end if ;

     IF res.mobile IS NULL OR res.mobile='' THEN
         update crm_in_memcard_add set msg='手机号不能为空', msg_status=2  WHERE memcardno=res.memcardno  ;
       continue;
     end if ;
  ----手机号重复了 把之前的手机号置空
     SELECT COUNT(*)
     into v_cnt
     FROM t_memcard_reg
     WHERE mobile =res.mobile ;

     if v_cnt>0 then
       update t_memcard_reg set mobile=null WHERE mobile=res.mobile ;
     end if ;

-----新办会员送500积分    SELECT * FROM   crm_in_memcard_add   WHERE  memcardno='16836128438639023'
-------- update  t_memcard_reg  set compid=1900 ,busno=86201  WHERE  memcardno='16836128438639023'
     insert into t_memcard_reg (
     compid,
     memcardno,
     busno,
     cardtype,cardlevel,cardstatus,saleamount,realamount,puramount,integral,createuser,
     createtime,applytime,
     cardholder,
     user_id,
     FROM_FLAG,invalidate,mobile,birthday,wechat_union_id,APPTYPE,allowintegral,tel)
     SELECT case when res.parent_id='1019517' then 1900 else nvl((select compid from s_busi WHERE to_char(busno)=res.encode),1000) end ,
     res.memcardno,
     case when res.parent_id='1019517' then 86402 else  nvl((select busno from s_busi WHERE to_char(busno)=res.encode),81001) end ,
     1,1,1,0,0,0,0,nvl(res.saler,168),
     sysdate,sysdate,
     case when nvl(res.username,'无') like '% %' then '无' else nvl(res.username,'无') end as cardholder ,
     res.user_id,
     '小程序',date'2100-01-01',res.mobile,to_date(res.birthday,'yyyy-mm-dd'),res.wechat_union_id,'小程序',1,res.mobile
     FROM dual;



select seq_cashno.nextval
into v_no
from dual ;
----送500积分
    INSERT INTO t_memcard_cash (cashno,memcardno,busno,cardlevel,integrala,integral,status,createuser,createtime,integral_pst,pstqty,
    lastmodify,lasttime,compid,ware_pst,smsverify_flag,isreset,checkbit1,checkbit2,checkbit3,checkbit4,checkbit5,handmade,notes)

SELECT to_char(sysdate,'yyyymmdd')||v_no,res.memcardno,decode(nvl(res.encode,81001),'P888','81001','81001'),1,500,500,0,168,sysdate,-500,NULL,
168,sysdate, nvl((select compid from s_busi WHERE to_char(busno)=res.encode),1000),2,0,0,0,0,0,0,0,0,'小程序办会员送500积分'
FROM dual;

UPDATE  t_memcard_cash SET status=1  WHERE cashno=to_char(sysdate,'yyyymmdd')||v_no ;

---新增储值卡
INSERT INTO t_card_info(cardno,compid,busno,begin_date,end_date,status,cardholder,rawamt,payamt,paytimes,recharge,balance,createuser,createtime)
VALUES(res.memcardno,1000,81001,sysdate,to_date('2099-12-31','yyyy-mm-dd'),1,
case when nvl(res.username,'无') like '% %' then '无' else nvl(res.username,'无') end,
  0,0,0,0,0,168,sysdate) ;


----送券
 CPROC_COUPON_INFO_88WX(1000,res.memcardno,'小程序新办会员送券') ;

 update crm_in_memcard_add set msg='插入会员表成功', msg_status=1 WHERE memcardno=res.memcardno  ;

 exception when others then
   v_sqlcode := to_char(SQLCODE);
   v_sqlerrm := to_char(SQLERRM);
   update crm_in_memcard_add set msg=substr(v_sqlcode || ' ' || v_sqlerrm, 1, 80), msg_status=2 WHERE memcardno=res.memcardno  ;
   continue ;
 end ;
  end loop ;
   merge into (SELECT * FROM   t_memcard_reg a  WHERE exists (select 1 from crm_in_memcard_add b WHERE a.memcardno=b.memcardno ) and mobile is null  ) a
using crm_in_memcard_add b
on (a.memcardno=b.memcardno)
 when matched then
   update set a.mobile=b.mobile   ;
    end ;
/

