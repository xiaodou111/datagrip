create or replace PROCEDURE CPROC_COUPON_INFO_RSV(p_compid in t_ware.compid%TYPE,
                                                   p_busno in s_busi.busno%type,
                                                   p_wareid in t_ware.wareid%type,
                                                   p_memcardno in t_memcard_reg.memcardno%type,
                                                   p_saleno in varchar2,
                                                   p_user in s_user.userid%type,
                                                   p_reserve_type in d_ware_coupon_rsv.reserve_type%type,
                                                   p_pst_ware  in varchar2,
                                                   out_coupon_no OUT t_proc_rep.notes%TYPE)

IS
  /*商品预约
    预约类型 1.送商品优惠券
             2.送礼品券，现金券
             3.送商品
  */
  V_COUPONNO T_CASH_COUPON_INFO.COUPON_NO%TYPE;

  V_TEL      T_MEMCARD_REG.TEL%TYPE;
  V_COUPON_KIND T_CASH_COUPON_INFO.COUPON_KIND%type;
  V_BAK9   T_CASH_COUPON_INFO.bak9%type;
  v_coupon_desc t_cash_coupon_info.coupon_desc%type;
  v_reserve_amt d_ware_coupon_rsv.reserve_amt%type;
  v_compid s_company.compid%type;

  v_busnos d_ware_coupon_rsv.busnos%type;
  v_cnt pls_integer;
  v_use_busno d_ware_coupon_rsv.use_busno%type;
  v_mem_limit d_ware_coupon_rsv.mem_limit%type;

  v_begindate d_ware_coupon_rsv.user_begindate%type;
  v_enddate d_ware_coupon_rsv.user_enddate%type;
  v_pst_begindate d_ware_coupon_rsv.pst_begindate%type;

  v_hddate d_ware_coupon_rsv.begindate%type;
  v_err_msg   varchar2(600);
  v_out_no t_proc_rep.notes%TYPE;

  v_x pls_integer;


BEGIN

       select reserve_amt,use_busno,mem_limit,user_begindate,begindate,pst_begindate
         into v_reserve_amt,v_use_busno,v_mem_limit,v_begindate,v_hddate,v_pst_begindate
       from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

       if v_use_busno = 2 then
         v_busnos :='全部';
       else
         v_busnos := p_busno;
       end if ;

      /*判断是否有会员限购*/
      if v_mem_limit > 0  then

          if nvl(p_memcardno,'AAA')='AAA' then
              RAISE_APPLICATION_ERROR(-20001, '会员不能空！', TRUE);
              RETURN;
          end if;

          select count(*) into v_cnt
          from (select row_number() over(partition by give_saleno order by coupon_no) as cnt
                from t_cash_coupon_info
                where start_date=trunc(nvl(v_pst_begindate,v_begindate)) and status=1 and card_no=p_memcardno and adv_type =p_reserve_type )
          where cnt=1 ;
          if v_cnt > v_mem_limit-1 then
              v_err_msg := '本券每个会员只能预约 '||v_mem_limit||' 次';
              RAISE_APPLICATION_ERROR(-20001, v_err_msg, TRUE);
              RETURN;
          end if;

      end if;

        --取会员联系电话
        BEGIN
           select tel into  v_tel from t_memcard_reg where memcardno=p_memcardno;
        EXCEPTION
          WHEN no_data_found THEN
            V_TEL := null;
        END;

        --取企业
        BEGIN
           select compid into v_compid from s_busi where busno=p_busno;
        EXCEPTION
          WHEN no_data_found THEN
            v_compid := p_compid;
        END;


        --判断礼品券是否存在，取代金券描述，类型4,参茸券 不参与判断
        if p_reserve_type not in(1,22,3,4,5,15,1,6,7,13,16,17,18,19,20,21,23,24,25,9,26,27,28,29,30,31,32) and p_wareid <>80301620 then

            BEGIN
                select coupon_type_desc into v_coupon_desc from t_cash_coupon_type where coupon_type='礼品券'||p_wareid;
            EXCEPTION
              WHEN no_data_found THEN
                RAISE_APPLICATION_ERROR(-20001, '代金券类型：礼品券'||p_wareid||'，不存在！', TRUE);
                RETURN;
            END;

        end if;

       if p_reserve_type in (1,22)  then
       /*商品定价券*/
          --代金券类型
          V_COUPON_KIND := 4;
          V_BAK9 := 2;

          BEGIN
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         0 as LEAST_SALES,
                         '定价券'||p_wareid,
                         v_coupon_desc,
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
                         V_COUPON_KIND,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := '''' || V_COUPONNO || '''' ;

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
                         v_compid,
                         v_busnos,
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

          --送鸿茅药酒一瓶
         if p_wareid =10226060 and p_compid <>1060 then
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '鸿茅药酒壹瓶',
                         '价值298鸿茅药酒壹瓶',
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
                         2,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '鸿茅药酒壹瓶'   AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

         end if;
/*
          --送鸿茅药酒一瓶 2023年3月活动到
         if p_wareid =10223587 then
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '鸿茅药酒壹瓶',
                         '价值298鸿茅药酒壹瓶',
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
                         2,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '鸿茅药酒壹瓶'   AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


         end if;
*/
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


       if p_reserve_type in (2,24,35)  then
           if p_reserve_type = 35 then
            v_busnos:='81559';
           end if;
          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN
           --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           --插入券信息 礼品券
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_wareid,
                         v_coupon_desc,
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
                         V_COUPON_KIND,
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                out_coupon_no := '''' || V_COUPONNO || '''' ;

             if p_reserve_type = 35 then
             --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           --插入券信息 礼品券
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
                         v_compid,
                         v_busnos,
                         10,
                         30,
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
                         '现金券满减'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;
                end if;

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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '现金券满减',
                         '全场满减',
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
                         v_coupon_desc AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

       --送商品
       if p_reserve_type = 3  then

          --代金券类型
          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN

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
                         v_compid,
                         v_busnos,
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

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

           else

            --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);
           --插入券信息 礼品券
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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         0 coupon_values ,
                         0 least_sales ,
                         '礼品券'||p_wareid,
                         v_coupon_desc,
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
                         V_COUPON_KIND,
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

                 end if;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

       --现金券YJ(全场原价满减)
       if p_reserve_type = 4  then

          --代金券类型
          V_COUPON_KIND := 1;
          V_BAK9 := 2;

          BEGIN
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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         coupon_values ,
                         least_sales ,
                         '现金券YJ' as coupon_type,
                         '全场原价满减' as coupon_desc,
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
                         V_COUPON_KIND,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end ,
                         p_busno,
                         1 ,
                         null,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

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
                         v_compid,
                         v_busnos,
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

       --邀约送商品（消费满金额再用)
        if p_reserve_type = 5  then
          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN

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
                         v_compid,
                         v_busnos,
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

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

          else

           --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           --插入券信息 邀约券
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '邀约券'||p_wareid,
                         v_coupon_desc,
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
                         V_COUPON_KIND,
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                out_coupon_no := '''' || V_COUPONNO || '''' ;

            end if;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

       --送现金券，原价使用,可再送商品
       if p_reserve_type = 6  then

           --代金券类型
          V_COUPON_KIND := 1;
          V_BAK9 := 2;

          BEGIN
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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         coupon_values ,
                         least_sales ,
                         '现金券YJ' as coupon_type,
                         '全场原价满减' as coupon_desc,
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
                         V_COUPON_KIND,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end ,
                         p_busno,
                         1 ,
                         null,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

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
                         v_compid,
                         v_busnos,
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

       --自定义活动送邀约券
       if p_reserve_type = 7 then

          V_COUPON_KIND := 1;
          V_BAK9 := 2;

          BEGIN

                --取券号 5元 1
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
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
                         V_COUPON_KIND,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := '''' || V_COUPONNO || '''' ;



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
                         v_compid,
                         v_busnos,
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



       --参茸满减券 +送商品 20230523奖预约金放到参茸券上
      if p_reserve_type in(8,12)  then
          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN
           --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           --插入券信息 礼品券
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_wareid,
                         v_coupon_desc,
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
                         V_COUPON_KIND,
                         0 reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                out_coupon_no := '''' || V_COUPONNO || '''' ;

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 满减券
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '参茸满减券',
                         '参茸全场使用',
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
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '参茸满减券'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

       --1元邀约送30元券
       if p_reserve_type = 9  then

          V_COUPON_KIND := 2;  --折扣券
          V_BAK9 := 3;

          BEGIN

           v_x :=1;

           while v_x<=6 loop

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 6张5元原价满减券
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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         5 as COUPON_VALUES,
                         10 as LEAST_SALES,
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
                         '全场原价满减'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    v_x := v_x+1 ;

                    if v_x = 1 then
                       out_coupon_no := '''' || V_COUPONNO || '''' ;
                    else
                        out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                    end if;

              end loop;

             /* 如果有设置 预约后再赠送商品*/

             if  nvl(p_pst_ware,'空')<>'空' then
                  dbms_output.put_line('1');
               --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);
                dbms_output.put_line('V_COUPONNO:'||V_COUPONNO);
                dbms_output.put_line('v_compid:'||v_compid);
                dbms_output.put_line('v_busnos:'||v_busnos);
                dbms_output.put_line('p_pst_ware:'||p_pst_ware);
                dbms_output.put_line('p_memcardno:'||p_memcardno);
                dbms_output.put_line('V_TEL:'||V_TEL);
                --dbms_output.put_line('pst_begindate:'||pst_begindate);
                --dbms_output.put_line('user_begindate:'||user_begindate);
                --dbms_output.put_line('pst_enddate:'||pst_enddate);
                --dbms_output.put_line('user_enddate:'||user_enddate);
                dbms_output.put_line('p_user:'||p_user);
                dbms_output.put_line('p_saleno:'||p_saleno);
                dbms_output.put_line('p_busno:'||p_busno);
                dbms_output.put_line('V_COUPONNO:'||V_COUPONNO);
                dbms_output.put_line('p_reserve_type:'||p_reserve_type);
                --dbms_output.put_line('p_saleno',p_saleno);
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
                         v_compid,
                         v_busnos,
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

       --出渔节
       if p_reserve_type = 10  then

          V_COUPON_KIND := 2;  --折扣券
          V_BAK9 := 3;

          if nvl(p_memcardno,'AAA')='AAA' then
            RAISE_APPLICATION_ERROR(-20001, '会员不能空！', TRUE);
              RETURN;
          end if;
--           select count(*) into v_cnt from d_ware_coupon_rsv where card_no=p_memcardno
--           select count(*) into v_cnt from t_cash_coupon_info where START_DATE=date'2021-07-26' and card_no=p_memcardno and coupon_type='商品代金券' and adv_type =p_reserve_type;
--           if v_cnt >5 then
--               RAISE_APPLICATION_ERROR(-20001, '本券每个会员只能预约5次', TRUE);
--               RETURN;
--           end if;


          BEGIN
           --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           --插入券信息 礼品券
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_wareid,
                         v_coupon_desc,
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
                         V_COUPON_KIND,
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                out_coupon_no := '''' || V_COUPONNO || '''' ;

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 满减券
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
                         v_compid,
                         v_busnos,
                         30  as COUPON_VALUES,
                         180 as LEAST_SALES,
                         '商品代金券D',
                         '春节30元抵用券',
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
                         'AB类原价使用'  AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);
            --现金券
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
                         v_compid,
                         v_busnos,
                         50  as COUPON_VALUES,
                         120 as LEAST_SALES,
                         '商品代金券F',
                         '春节非药AB抵用券',
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
                         'AB类原价使用'  AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
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
                         v_compid,
                         v_busnos,
                         100  as COUPON_VALUES,
                         200 as LEAST_SALES,
                         '商品代金券F',
                         '春节非药AB抵用券',
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
                         'AB类原价使用'  AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '现金券YJA',
                         '春节10元抵用券',
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
                         'AB类原价使用'  AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
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
                         v_compid,
                         v_busnos,
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


          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


       --1元办会员送30元券
       if p_reserve_type = 11  then

          V_COUPON_KIND := 2;
          V_BAK9 := 3;

    /*判断是否有会员限购*/
      if v_mem_limit > 0  then

          if nvl(p_memcardno,'AAA')='AAA' then
              RAISE_APPLICATION_ERROR(-20001, '会员不能空！', TRUE);
              RETURN;
          end if;

          select count(*) into v_cnt from t_cash_coupon_info where START_DATE>=trunc(v_begindate) and card_no=p_memcardno and advance_payamt > 0 and adv_type =p_reserve_type;
          if v_cnt > v_mem_limit-1 then
              v_err_msg := '本券每个会员只能预约 '||v_mem_limit||' 次';
              RAISE_APPLICATION_ERROR(-20001, v_err_msg, TRUE);
              RETURN;
          end if;

      end if;


          BEGIN
           --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           v_begindate := trunc(sysdate);
           v_enddate := trunc(sysdate+10);

           --插入券信息 礼品券
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_wareid,
                         v_coupon_desc,
                         p_memcardno,
                         V_TEL,
                         v_begindate,
                         v_enddate,
                         0,
                         1,
                         notes,
                         p_user,
                         SYSDATE,
                         p_saleno,
                         V_COUPON_KIND,
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                out_coupon_no := '''' || V_COUPONNO || '''' ;

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 5满减券
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
                         v_compid,
                         v_busnos,
                         5,
                         5,
                         '现金券YJ',
                         '全场原价使用',
                         p_memcardno,
                         V_TEL,
                         v_begindate,
                         v_enddate,
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
                         '全场原价使用'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           v_begindate := trunc(sysdate+11);
           v_enddate := trunc(sysdate+40);
           --插入券信息 10满减券
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
                         v_compid,
                         v_busnos,
                         10,
                         28,
                         '现金券YJ',
                         '全场原价使用',
                         p_memcardno,
                         V_TEL,
                         v_begindate,
                         v_enddate,
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
                         '全场原价使用'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           v_begindate := trunc(sysdate+41);
           v_enddate := trunc(sysdate+70);

           --插入券信息 15满减券
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
                         v_compid,
                         v_busnos,
                         15,
                         38,
                         '现金券YJ',
                         '全场原价使用',
                         p_memcardno,
                         V_TEL,
                         v_begindate,
                         v_enddate,
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
                         '全场原价使用'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


      /*自定义邀约券活动 ：715超级会员日 */
       if p_reserve_type = 13  then

          BEGIN

             --10元券
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
                         v_compid,
                         v_busnos,
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
                         1,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end,
                         p_busno,
                         1,
                         wareid,
                         V_COUPONNO,
                         null,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := '''' || V_COUPONNO || '''' ;


               --50元券 AB类非药品原价使用
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
                         v_compid,
                         v_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
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
                         1,
                         0,
                         p_busno,
                         1,
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
                         v_compid,
                         v_busnos,
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
                         '邀约券'||p_pst_ware,
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

       --虫草现金券活动
       if p_reserve_type = 14 then

          --代金券类型
          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN
            --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);
           --插入券信息 礼品券
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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         coupon_values  ,
                         least_sales  ,
                         '虫草现金券',
                         '指定商品满减',
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
                         1,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '指定商品满减'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;


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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         0 coupon_values ,
                         0 least_sales ,
                         '礼品券30701213',
                         '礼品券30701213',
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
                         V_COUPON_KIND,
                         reserve_amt,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         '礼品券30701213' AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

      if p_reserve_type = 15 then
         cproc_coupon_person_rsv(v_compid,p_busno,p_wareid,p_memcardno,p_saleno,p_user,p_reserve_type,v_busnos,p_pst_ware,v_out_no);

         if nvl(v_out_no,'空')<>'空' then
           out_coupon_no :=v_out_no;

         end if;

      end if;

      --1元邀约送120元券豪礼
      if p_reserve_type = 16  then

          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN

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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '逢5邀约礼包',
                         '逢5邀约礼包',
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
                         '逢5邀约礼包',
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

            --10元券2张
            v_x := 1;
            while v_x<=2 loop
                 --取券号
                  V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                             IN_ORG_CODE => p_busno);

                 --插入券信息 满减券
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
                               v_compid,
                               v_busnos,
                               10 as COUPON_VALUES,
                               88 as LEAST_SALES,
                               '商品代金券D',
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
                               0,
                               p_busno,
                               1 ,
                               null,
                               V_COUPONNO,
                               '指定商品原价满减'            AS BAK7,
                               2,
                               p_reserve_type
                          from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                         out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';
                         v_x := v_x+1;

               end loop;

            --50元券2张
            v_x := 1;
            while v_x<=2 loop
           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 满减券
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
                         v_compid,
                         v_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
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
                         0,
                         p_busno,
                         1 ,
                         null,
                         V_COUPONNO,
                         '指定商品原价满减'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

                    v_x := v_x+1;

               end loop;


          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


       if p_reserve_type in(17,18,19,20,21) then

          BEGIN

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 满减券
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '参茸满减券',
                         '参茸全场使用',
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
                         reserve_amt ,
                         p_busno,
                         1 ,
                         null,
                         V_COUPONNO,
                         '参茸满减券'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

       --逢5慢病活动券
       if p_reserve_type =23 then

          BEGIN

           --取券号
            V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                       IN_ORG_CODE => p_busno);

           --插入券信息 满减券
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         '逢5活动券',
                         '指定商品原价使用',
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
                         reserve_amt ,
                         p_busno,
                         1 ,
                         null,
                         V_COUPONNO,
                         '逢5活动券'            AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;

       if p_reserve_type = 25  then
          V_COUPON_KIND := 2;
          V_BAK9 := 3;

          BEGIN
           --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

           --插入券信息 礼品券
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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         case when p_wareid='50000903'then '礼品券龙宝花茶'else'礼品券'||p_wareid end,
                         case when p_wareid='50000903'then '礼品券龙宝花茶'else'礼品券'||p_wareid end,
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
                         reserve_amt ,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         null BAK7,
                         V_BAK9,
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
                         v_compid,
                         v_busnos,
                         COUPON_VALUES,
                         LEAST_SALES,
                         case when compid=1060 then '代金券FY' else '鲜人参现金券' end,
                         '指定商品满减',
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
                         case when compid=1060 then '代金券FY' else '鲜人参现金券' end     AS BAK7,
                         2,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


       --10元预约有礼 7月杭州活动
       if p_reserve_type = 32 then

          V_COUPON_KIND := 1;
          V_BAK9 := 2;

          BEGIN

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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_wareid,
                         '礼品券'||p_wareid,
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
                         '礼品'||p_wareid            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

                --取券号 10元 第一张
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
                         v_compid,
                         v_busnos,
                         10 as COUPON_VALUES,
                         28 as LEAST_SALES,
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                  out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

                --取券号 40元 第二张
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
                         v_compid,
                         v_busnos,
                         40 as COUPON_VALUES,
                         128 as LEAST_SALES,
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc            AS BAK7,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                  out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


                 --取券号
                V_COUPONNO := F_GET_SERIAL(IN_BILLCODE => 'COUPON',
                                           IN_ORG_CODE => p_busno);

                --插入券信息 50元
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
                         v_compid,
                         v_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
                         '商品代金券',
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


                --取券号 5折非药券
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
                         v_compid,
                         v_busnos,
                         0.5 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '代金券FY',
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;

       end if ;


      --618活动
      if p_reserve_type in (26,27,28,30,31,33,34) then
         dbms_output.put_line('2');
         dbms_output.put_line('v_compid:'||v_compid);
                dbms_output.put_line('p_busno:'||p_busno);
                dbms_output.put_line('p_wareid:'||p_wareid);
                dbms_output.put_line('p_memcardno:'||p_memcardno);
                dbms_output.put_line('p_saleno:'||p_saleno);
                dbms_output.put_line('p_user:'||p_user);
                --dbms_output.put_line('pst_begindate:'||pst_begindate);
                --dbms_output.put_line('user_begindate:'||user_begindate);
                --dbms_output.put_line('pst_enddate:'||pst_enddate);
                --dbms_output.put_line('user_enddate:'||user_enddate);
                dbms_output.put_line('p_reserve_type:'||p_reserve_type);
                dbms_output.put_line('v_busnos:'||v_busnos);
                dbms_output.put_line('p_pst_ware:'||p_pst_ware);
                dbms_output.put_line('v_out_no:'||v_out_no);

         cproc_coupon_618_rsv(v_compid,p_busno,p_wareid,p_memcardno,p_saleno,p_user,p_reserve_type,v_busnos,p_pst_ware,v_out_no);

         if nvl(v_out_no,'空')<>'空' then
           out_coupon_no :=v_out_no;

         end if;

      end if;

       if p_reserve_type = 36 then

          V_COUPON_KIND := 1;
          V_BAK9 := 2;

          BEGIN

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
                         v_compid,
                         v_busnos,
                         8 as COUPON_VALUES,
                         20 as LEAST_SALES,
                         '购物券',
                         '8元购物券(全场原价)',
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

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
                         v_compid,
                         v_busnos,
                         30 as COUPON_VALUES,
                         100 as LEAST_SALES,
                         '购物券',
                         '30元购物券(全场原价)',
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

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
                         v_compid,
                         v_busnos,
                         50 as COUPON_VALUES,
                         100 as LEAST_SALES,
                         '全场ab满100-50',
                         '全场ab满100-50',
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';


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
                         v_compid,
                         v_busnos,
                         100 as COUPON_VALUES,
                         200 as LEAST_SALES,
                         '全场ab满100-50',
                         '全场ab满100-50',
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
                         V_COUPON_KIND,
                         0,
                         p_busno,
                         1 ,
                         wareid,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                 out_coupon_no := out_coupon_no || ',' || '''' || V_COUPONNO || '''';

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
                         v_compid,
                         v_busnos,
                         0 as COUPON_VALUES,
                         0 as LEAST_SALES,
                         '礼品券'||p_wareid,
                         '礼品券'||p_wareid,
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
                         '礼品'||p_wareid            AS BAK7,
                         3,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

                EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20001, '赠送代金券失败!', TRUE);
              RETURN;
          END;
   end if;

       if p_reserve_type = 29  then

          --代金券类型
          V_COUPON_KIND := 1;
          V_BAK9 := 2;

          BEGIN
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
                   adv_type )

                  SELECT V_COUPONNO,
                         SYSDATE,
                         v_compid,
                         v_busnos,
                         coupon_values ,
                         least_sales ,
                         '现金抵用券ZH' as coupon_type,
                         '全场满减' as coupon_desc,
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
                         V_COUPON_KIND,
                         case when  nvl(p_pst_ware,'空')<>'空' then 0 else reserve_amt end ,
                         p_busno,
                         1 ,
                         null,
                         V_COUPONNO,
                         v_coupon_desc,
                         V_BAK9,
                         p_reserve_type
                    from d_ware_coupon_rsv where compid=p_compid and wareid=p_wareid and reserve_type=p_reserve_type;

                    out_coupon_no := '''' || V_COUPONNO || '''' ;

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
                         v_compid,
                         v_busnos,
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
END
;
/

