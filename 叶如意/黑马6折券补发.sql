declare
 v_qh1 t_cash_coupon_info.coupon_no%type;
 v_cnt integer ;
   v_begin date;
  v_end date;
    v_mobile t_memcard_reg.mobile%type;
begin
for res in (
  --varchar2����,ȯ�źͻ�Ա���Ŷ�������ֶ�
  select memcard from t_cash_coupon_info_temp)
  loop
  
  SELECT seq_memcard_ymh_cashno.nextval
    into  v_qh1
     FROM  dual ;   ---6yuan
     v_begin:=date'2023-12-28' ;
     v_end:=date'2024-12-28';
  SELECT nvl(mobile ,tel)
     into v_mobile
     FROM t_memcard_reg
     WHERE memcardno=res.memcard ;
  
  
  INSERT INTO T_CASH_COUPON_INFO
        (COUPON_NO,ISSUING_DATE,COMPID,BUSNOS,COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,
         CARD_NO, MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,CREATEUSER,CREATETIME,COUPON_KIND,
         ADVANCE_PAYAMT, --ԤԼ��
         CREATE_BUSNO,
         CREATE_TPYE, --���ŷ�ʽ��0������ȯ��1�ֹ���ȯ��2���Ϸ�ȯ
         BAK4, BAK6,BAK7,BAK9 --ȯ����1�ۿۡ�2������3��Ʒȯ
         )
        SELECT v_qh1,SYSDATE,0,BUSNOS,COUPON_VALUES,LEAST_SALES,
             COUPON_TYPE,COUPON_TYPE_DESC,res.memcard,v_mobile,
       v_begin as  starttime,
       v_end as  endtime, 0,1,'����100Ԫ����ȯ����','168',SYSDATE,
             COUPON_KIND,0,null,2,CLASSCODES,null,COUPON_TYPE_DESC,2
       FROM T_CASH_COUPON_TYPE    WHERE COUPON_TYPE='����100Ԫ����ȯ' ;
  end loop;
end;

select *
from T_CASH_COUPON_INFO where NOTES='����100Ԫ����ȯ����';

delete from T_CASH_COUPON_INFO where NOTES='���ݺ����Ա6��ȯ����';