create PROCEDURE CPROC_COUPON_INFO_JYBYHQ(p_card_no in t_cash_coupon_info.card_no%type,
                                                     p_coupon_no in t_cash_coupon_info.coupon_no%type,
                                                     p_coupon_desc in t_cash_coupon_info.coupon_desc%type,
                                                     p_bak4 in t_cash_coupon_info.bak4%type,
                                                     p_coupon_values in t_cash_coupon_info.coupon_values%type,
                                                     p_start_date in varchar2,
                                                     p_end_date in varchar2)
is


  /*
    健易宝出券
  */

  V_COUPONNO T_CASH_COUPON_INFO.COUPON_NO%TYPE;
  V_BUSNO    T_MEMCARD_REG.BUSNO%TYPE;
  V_TEL      T_MEMCARD_REG.TEL%TYPE;
  v_compid   T_MEMCARD_REG.Compid%type;
  
  v_cnt number(10);
  
BEGIN

      begin
        --取机构,联系电话
        SELECT BUSNO, TEL,compid INTO V_BUSNO, V_TEL,v_compid  FROM T_MEMCARD_REG WHERE MEMCARDNO = p_card_no;
      exception
        when NO_DATA_FOUND then
          v_tel :=null;
      end;

      --不重复生券
      select count(*) into v_cnt from t_cash_coupon_info where start_date=to_date(p_start_date,'yyyy-mm-dd') and bak6=p_coupon_no;
      if v_cnt > 0 then 
        return;
      end if;


      --开始生成券
      BEGIN

        --取券号  礼品券
        V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                   IN_ORG_CODE => V_BUSNO);

        --插入券信息
        INSERT INTO T_CASH_COUPON_INFO
          (COUPON_NO,
           ISSUING_DATE,
           COMPID,
           BUSNOS,
           COUPON_VALUES,
           LEAST_SALES,
           COUPON_TYPE,
           COUPON_DESC,
           CARD_NO,
           MOBILE,
           START_DATE,
           END_DATE,
           USE_STATUS,
           STATUS,
           NOTES,
           CREATEUSER,
           CREATETIME,
           COUPON_KIND,
           ADVANCE_PAYAMT, --预约金
           CREATE_BUSNO,
           CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
           BAK4,
           BAK6,
           BAK7,
           BAK9 --券类型1折扣、2满减、3礼品券
           )

          SELECT V_COUPONNO,
                 SYSDATE,
                 nvl(v_compid,1000),
                 BUSNOS,
                 p_coupon_values,
                 least_sales,
                 COUPON_TYPE,
                 p_coupon_desc,
                 p_card_no,
                 V_TEL,
                 to_date(p_start_date,'yyyy-mm-dd'),
                 to_date(p_end_date,'yyyy-mm-dd'),
                 0,
                 1,
                 '健易宝出券',
                 '168',
                 SYSDATE,
                 coupon_kind,
                 0,
                 V_BUSNO,
                 2,
                 p_bak4,
                 p_coupon_no,
                 COUPON_TYPE_DESC            AS BAK7,
                 2                           AS BAK9
            FROM T_CASH_COUPON_TYPE
           WHERE COUPON_TYPE = '健易宝'||to_char(trim(p_bak4));

      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20001, '赠送券失败!', TRUE);
          RETURN;
      END;

END ;
/

