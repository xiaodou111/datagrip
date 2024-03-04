create PROCEDURE cproc_coupon_618_rsv(p_compid IN t_ware.compid%TYPE,
                                                    p_busno in s_busi.busno%type,
                                                    p_wareid in t_ware.wareid%type,
                                                    p_memcardno t_memcard_reg.memcardno%type,
                                                    p_saleno varchar2,
                                                    p_user s_user.userid%type,
                                                    p_reserve_type d_ware_coupon_rsv.reserve_type%type,
                                                    p_busnos t_cash_coupon_info.busnos%type,
                                                    p_pst_ware d_ware_coupon_rsv.pst_ware%type,
                                                    out_coupon_no OUT t_proc_rep.notes%TYPE)
 AS

    V_COUPONNO t_cash_coupon_info.coupon_no%TYPE;
    --v_reserve_amt d_ware_coupon_rsv.reserve_amt%TYPE;

    v_x pls_integer;
    v_y pls_integer;
    v_tel varchar2(11);

BEGIN

        --取会员联系电话
        BEGIN
           select tel into  v_tel from t_memcard_reg where memcardno=p_memcardno;
        EXCEPTION
          WHEN no_data_found THEN
            V_TEL := null;
        END;
   
   --2023年 中秋国庆预约
   if p_reserve_type = 26  then

          BEGIN
           --取券号 10元
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         10 as COUPON_VALUES,
                         30 as LEAST_SALES,
                         '现金券YJ',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,--1现金券，2折扣券，4定价券
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

           --插入券信息 AB类非药满减 医疗耗材不参与
                v_x := 1;
                
           while v_x <= 2 loop 
               --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
                         '国庆现金券',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                    
                    v_x := v_x + 1;
                    
              end loop;

      
             /* 如果有设置 预约后再赠送商品*/

             if  nvl(p_pst_ware,'空')<>'空' then

               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_pst_ware,
                         '礼品券'||p_pst_ware,
                         p_memcardno,
                         V_TEL,
                         nvl(pst_begindate,user_begindate),
                         nvl(pst_enddate,user_enddate),
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '礼品券'||p_pst_ware            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

              end if;
 
                
                        
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;
 
  --2023年 新店中秋国庆预约
   if p_reserve_type = 27  then

          BEGIN
           --取券号 10元
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         10 as COUPON_VALUES,
                         30 as LEAST_SALES,
                         '现金券YJ',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

           --插入券信息 AB类非药满减 医疗耗材不参与
                v_x := 1;
                
           while v_x <= 3 loop 
               --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
                         '国庆现金券',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                    
                    v_x := v_x + 1;
                    
              end loop;
              
              --取券号 10元
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 COUPON_VALUES,
                         0 LEAST_SALES,
                         '邀约大礼包贰',
                         '邀约大礼包贰',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2 as COUPON_KIND,
                         reserve_amt,--case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1,
                         wareid,
                         V_COUPONNO,
                         null,
                         1,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

      
             /* 如果有设置 预约后再赠送商品*/

             if  nvl(p_pst_ware,'空')<>'空' then

               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_pst_ware,
                         '礼品券'||p_pst_ware,
                         p_memcardno,
                         V_TEL,
                         nvl(pst_begindate,user_begindate),
                         nvl(pst_enddate,user_enddate),
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '礼品券'||p_pst_ware            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

              end if;
 
                
                        
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


      --12月保健品参茸预约
       if p_reserve_type  = 28  then

          BEGIN

            --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '保健品参茸券',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;
       end if;  
  
  --瑞人堂大厦店，1元邀约送20参茸券
        if p_reserve_type  = 31  then

          BEGIN

            --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '参茸券CJ',
                         '全场参茸满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;
                    
                                 --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);
/*
           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0,
                         0,
                         '抽奖券',
                         '抽奖券',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                    
*/           
           if  nvl(p_pst_ware,'空')<>'空' then

               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_pst_ware,
                         '礼品券'||p_pst_ware,
                         p_memcardno,
                         V_TEL,
                         nvl(pst_begindate,user_begindate),
                         nvl(pst_enddate,user_enddate),
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '礼品券'||p_pst_ware            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

              end if;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;
       end if;    
           

      --杭州9.9元邀约送券
       if p_reserve_type = 30  then

          BEGIN

            --取券号 10元
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         10 as COUPON_VALUES,
                         27 as LEAST_SALES,
                         '现金券YJ',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;


               --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         20 as COUPON_VALUES,
                         99 as LEAST_SALES,
                         '现金券YJ',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
             
              --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         20 as COUPON_VALUES,
                         99 as LEAST_SALES,
                         '现金券YJ',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
             
              --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 非药AB满减
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         50 as COUPON_VALUES,
                         99 as LEAST_SALES,
                         '商品代金券F',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
             
             --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 5折非药AB
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0.5 as COUPON_VALUES,
                         0.5 as LEAST_SALES,
                         '折扣券F',
                         '指定商品折扣',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                             
             /* 如果有设置 预约后再赠送商品*/

             if  nvl(p_pst_ware,'空')<>'空' then

               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '邀约券'||p_pst_ware,
                         '邀约券'||p_pst_ware,
                         p_memcardno,
                         V_TEL,
                         nvl(pst_begindate,user_begindate),
                         nvl(pst_enddate,user_enddate),
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '邀约券'||p_pst_ware            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

              end if;
              
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

--2023年双11预约活动
  if p_reserve_type = 33  then

          BEGIN
                       --插入券信息 AB类非药满减 医疗耗材不参与
--            v_x := 1;
--            v_y :=15;
                
--            while v_x <= 10 loop
           --满29-8
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '现金券YJA',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         USER_BEGINDATE,
                         USER_ENDDATE,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,--1现金券，2折扣券，4定价券
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;
--                     v_x := v_x + 1;
                    
--               end loop;

          --满ABC类满99-15

            for i in 1..2 loop
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         15 as COUPON_VALUES,
                         99 as LEAST_SALES,
                         '商品代金券C',
                         'ABC类满99-15',
                         p_memcardno,
                         V_TEL,
                         USER_BEGINDATE,
                         USER_ENDDATE,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,--1现金券，2折扣券，4定价券
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' ||'''' || V_COUPONNO || '''' ;
            end loop;



           --满150-60
             for i in 1..2 loop
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         60 as COUPON_VALUES,
                         150 as LEAST_SALES,
                         '商品代金券F',
                         '全场ab非药满150-60',
                         p_memcardno,
                         V_TEL,
                         USER_BEGINDATE,
                         USER_ENDDATE,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,--1现金券，2折扣券，4定价券
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' ||'''' || V_COUPONNO || '''' ;
            end loop;
/*
           --插入券信息 AB类非药满减 医疗耗材不参与
                v_x := 1;
                
           while v_x <= 2 loop 
               --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
                         '国庆现金券',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                    
                    v_x := v_x + 1;
                    
              end loop;

    */  
             /* 如果有设置 预约后再赠送商品*/

             if  nvl(p_pst_ware,'空')<>'空' then

               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_pst_ware,
                         '礼品券'||p_pst_ware,
                         p_memcardno,
                         V_TEL,
                         --nvl(pst_begindate,user_begindate),
                         --nvl(pst_enddate,user_enddate),
                         nvl(pst_begindate,user_begindate),
                         nvl(pst_enddate,user_enddate),
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '礼品券'||p_pst_ware            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

              end if;
 
                
                        
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;
 
--2023年 双十二活动
   if p_reserve_type = 34  then

          BEGIN
           --取券号 10元
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);
             dbms_output.put_line('1V_COUPONNO:'||V_COUPONNO);
           --插入券信息 原价满减券
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         12 as COUPON_VALUES,
                         30 as LEAST_SALES,
                         '现金券YJ',
                         '全场原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,--1现金券，2折扣券，4定价券
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

           --插入券信息 AB类非药满减 医疗耗材不参与
                v_x := 1;
                
           while v_x <= 2 loop 
               --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);
            dbms_output.put_line('2V_COUPONNO:'||V_COUPONNO);
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         50 as COUPON_VALUES,
                         110 as LEAST_SALES,
                         '商品代金券F',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                    
                    v_x := v_x + 1;
                    
              end loop;
              
              V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);
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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE)

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         100 as COUPON_VALUES,
                         200 as LEAST_SALES,
                         '商品代金券F',
                         '指定商品原价满减',
                         p_memcardno,
                         V_TEL,
                         user_begindate,
                         user_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         1 as COUPON_KIND,
                         0 ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

      
             /* 如果有设置 预约后再赠送商品*/

             if  nvl(p_pst_ware,'空')<>'空' then

               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

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
                   GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4特价券(指定价格使用)
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK7,
                   BAK9, --券类型1折扣、2满减、4特价券(指定价格使用)
                   ADV_TYPE )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         p_compid,
                         p_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_pst_ware,
                         '礼品券'||p_pst_ware,
                         p_memcardno,
                         V_TEL,
                         nvl(pst_begindate,user_begindate),
                         nvl(pst_enddate,user_enddate),
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         2,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '礼品券'||p_pst_ware            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

              end if;
 
                
                        
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;
END;
/

