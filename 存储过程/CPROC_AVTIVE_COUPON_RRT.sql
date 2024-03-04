create PROCEDURE cproc_avtive_coupon_rrt(p_saleno VARCHAR2,p_wareid NUMBER,p_coupon_values NUMBER, p_compid INT,p_busno number,p_userid INT,p_memcardno VARCHAR2)
 AS

    V_COUPONNO t_cash_coupon_info.coupon_no%TYPE;
   -- v_coupon_type t_cash_coupon_info.coupon_type%type;
   v_cnt number(2);
   v_je t_sale_h.netsum%type;
   -- v_b number(2);
    v_i number;

BEGIN
   --p_coupon_values :=1 ;
   ----杭州3元无门槛   30-10




    if p_wareid = 50000728 then
     ---看看这单多少钱   满足了88 才送88元券 50+30+8
       begin
         SELECT netsum
         into   v_je
          FROM t_sale_h
          WHERE saleno=p_saleno;
       exception when no_data_found then
          v_je:=0;
             end ;


       --满足1288，送50*10+30+8

       if v_je >= 1288 then
           v_i := 0;
           --50元券10张
           while v_i < 10
               loop
                   v_i := v_i + 1;
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
                   INSERT INTO T_CASH_COUPON_INFO
                   (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC,
                    CARD_NO,
                    MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
                    CREATEUSER, CREATETIME, GIVE_SALENO,
                    COUPON_KIND, --1现金券 2折扣券 3礼品券
                    ADVANCE_PAYAMT, --预约金
                    CREATE_BUSNO,
                    CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                    BAK4,
                    BAK6,
                    BAK9 --券类型1折扣、2满减、3礼品券
                   )

                   values (V_COUPONNO, SYSDATE, p_compid, '全部', 50, 100, '全场ab满100-50', '全场ab满100-50', p_memcardno,
                           null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1,
                           '满1288得588元券:50元券,指定AB类原价商品,满100即可使用一张50元券',
                           p_userid, SYSDATE, p_saleno,
                           1,
                           0,
                           p_busno,
                           0,
                           p_wareid,
                           V_COUPONNO,
                           2);
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

               end loop;

           --30元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 30, 100, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满1288得588元券:30元券,全场满100即可使用一张30元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           --8元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 8, 20, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满1288得588元券:8元券,全场满20即可使用一张8元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);

       elsif v_je >= 888 and v_je <1288 then
           v_i := 0;
           --50元券10张
           while v_i < 10
               loop
                   v_i := v_i + 1;
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
                   INSERT INTO T_CASH_COUPON_INFO
                   (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC,
                    CARD_NO,
                    MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
                    CREATEUSER, CREATETIME, GIVE_SALENO,
                    COUPON_KIND, --1现金券 2折扣券 3礼品券
                    ADVANCE_PAYAMT, --预约金
                    CREATE_BUSNO,
                    CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                    BAK4,
                    BAK6,
                    BAK9 --券类型1折扣、2满减、3礼品券
                   )

                   values (V_COUPONNO, SYSDATE, p_compid, '全部', 50, 100, '全场ab满100-50', '全场ab满100-50', p_memcardno,
                           null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1,
                           '满888得588元券:50元券,指定AB类原价商品,满100即可使用一张50元券',
                           p_userid, SYSDATE, p_saleno,
                           1,
                           0,
                           p_busno,
                           0,
                           p_wareid,
                           V_COUPONNO,
                           2);
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

               end loop;

           --30元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 30, 100, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满888得588元券:30元券,全场满100即可使用一张30元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           --8元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 8, 20, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满888得588元券:8元券,全场满20即可使用一张8元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);

       elsif v_je >= 588 and v_je < 888 then
           v_i := 0;
           --50元券10张
           while v_i < 10
               loop
                   v_i := v_i + 1;
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
                   INSERT INTO T_CASH_COUPON_INFO
                   (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC,
                    CARD_NO,
                    MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
                    CREATEUSER, CREATETIME, GIVE_SALENO,
                    COUPON_KIND, --1现金券 2折扣券 3礼品券
                    ADVANCE_PAYAMT, --预约金
                    CREATE_BUSNO,
                    CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                    BAK4,
                    BAK6,
                    BAK9 --券类型1折扣、2满减、3礼品券
                   )

                   values (V_COUPONNO, SYSDATE, p_compid, '全部', 50, 100, '全场ab满100-50', '全场ab满100-50', p_memcardno,
                           null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1,
                           '满588得588元券:50元券,指定AB类原价商品,满100即可使用一张50元券',
                           p_userid, SYSDATE, p_saleno,
                           1,
                           0,
                           p_busno,
                           0,
                           p_wareid,
                           V_COUPONNO,
                           2);
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

               end loop;

           --30元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 30, 100, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满588得588元券:30元券,全场满100即可使用一张30元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           --8元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 8, 20, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满588得588元券:8元券,全场满20即可使用一张8元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);

       elsif v_je >= 388 and v_je < 588 then
           v_i := 0;
           --50元券7张
           while v_i < 7
               loop
                   v_i := v_i + 1;
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
                   INSERT INTO T_CASH_COUPON_INFO
                   (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC,
                    CARD_NO,
                    MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
                    CREATEUSER, CREATETIME, GIVE_SALENO,
                    COUPON_KIND, --1现金券 2折扣券 3礼品券
                    ADVANCE_PAYAMT, --预约金
                    CREATE_BUSNO,
                    CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                    BAK4,
                    BAK6,
                    BAK9 --券类型1折扣、2满减、3礼品券
                   )

                   values (V_COUPONNO, SYSDATE, p_compid, '全部', 50, 100, '全场ab满100-50', '全场ab满100-50', p_memcardno,
                           null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1,
                           '满388得388元券:50元券,指定AB类原价商品,满100即可使用一张50元券',
                           p_userid, SYSDATE, p_saleno,
                           1,
                           0,
                           p_busno,
                           0,
                           p_wareid,
                           V_COUPONNO,
                           2);
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

               end loop;

           --30元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 30, 100, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满388得388元券:30元券,全场满100即可使用一张30元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           --8元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 8, 20, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满388得388元券:8元券,全场满20即可使用一张8元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);

       elsif v_je >= 188 and v_je < 388 then
           v_i := 0;
           --50元券3张
           while v_i < 3
               loop
                   v_i := v_i + 1;
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
                   INSERT INTO T_CASH_COUPON_INFO
                   (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC,
                    CARD_NO,
                    MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
                    CREATEUSER, CREATETIME, GIVE_SALENO,
                    COUPON_KIND, --1现金券 2折扣券 3礼品券
                    ADVANCE_PAYAMT, --预约金
                    CREATE_BUSNO,
                    CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                    BAK4,
                    BAK6,
                    BAK9 --券类型1折扣、2满减、3礼品券
                   )

                   values (V_COUPONNO, SYSDATE, p_compid, '全部', 50, 100, '全场ab满100-50', '全场ab满100-50', p_memcardno,
                           null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1,
                           '满188得188元券:50元券,指定AB类原价商品,满100即可使用一张50元券',
                           p_userid, SYSDATE, p_saleno,
                           1,
                           0,
                           p_busno,
                           0,
                           p_wareid,
                           V_COUPONNO,
                           2);
                   V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

               end loop;

           --30元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 30, 100, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满188得188元券:30元券,全场满100即可使用一张30元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           --8元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 8, 20, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满188得188元券:8元券,全场满20即可使用一张8元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);


       elsif v_je >= 88 and v_je < 188 then
           v_i := 0;
           --50元券1张

           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC,
            CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 50, 100, '全场ab满100-50', '全场ab满100-50', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1,
                   '满88得88元券:50元券,指定AB类原价商品,满100即可使用一张50元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

           --30元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 30, 100, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满88得88元券:30元券,全场满100即可使用一张30元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);
           --8元券
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
           INSERT INTO T_CASH_COUPON_INFO
           (COUPON_NO, ISSUING_DATE, COMPID, BUSNOS, COUPON_VALUES, LEAST_SALES, COUPON_TYPE, COUPON_DESC, CARD_NO,
            MOBILE, START_DATE, END_DATE, USE_STATUS, STATUS, NOTES,
            CREATEUSER, CREATETIME, GIVE_SALENO,
            COUPON_KIND, --1现金券 2折扣券 3礼品券
            ADVANCE_PAYAMT, --预约金
            CREATE_BUSNO,
            CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
            BAK4,
            BAK6,
            BAK9 --券类型1折扣、2满减、3礼品券
           )

           values (V_COUPONNO, SYSDATE, p_compid, '全部', 8, 20, '3元无门槛', '3元无门槛', p_memcardno,
                   null, trunc(to_date('2024-02-23','yyyy-mm-dd')), trunc(to_date('2024-02-25','yyyy-mm-dd')), 0, 1, '满88得88元券:8元券,全场满20即可使用一张8元券',
                   p_userid, SYSDATE, p_saleno,
                   1,
                   0,
                   p_busno,
                   0,
                   p_wareid,
                   V_COUPONNO,
                   2);


       end if;
    end if;

   if  p_wareid = 50000729 then
    begin
         SELECT netsum
         into   v_je
          FROM t_sale_h
          WHERE saleno=p_saleno;
       exception when no_data_found then
          v_je:=100;
    end ;
    V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
    if v_je <168 then
       INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',5 ,5, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

   elsif   v_je<268 then
          --5元券
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',5 ,5, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,10, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
     elsif   v_je<368 then
          --5元券
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',5 ,5, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,10, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,20, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
     elsif   v_je<688 then
   --5元券
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',5 ,5, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,10, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,20, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
             V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',30 ,30, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
    else
         INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',5 ,5, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,10, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,20, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
             V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',30 ,30, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
         V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',80 ,80, '全场非药','全场非药',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
   end if ;
   end if;

   if p_wareid = 50001037 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --50元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '杭州10月送100元券2','杭州10月送100元券2',p_memcardno,
                         null,date'2023-10-27',date'2023-10-29',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --50元券
            INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '杭州10月送100元券2','杭州10月送100元券2',p_memcardno,
                         null,date'2023-10-27',date'2023-10-29',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

     end if ;
    if p_wareid = 50000872 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --50元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '50元非药券HZ','50元非药券HZ',p_memcardno,
                         null,date'2023-10-14',date'2023-10-16',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --50元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '50元非药券HZ','50元非药券HZ',p_memcardno,
                         null,date'2023-10-14',date'2023-10-16',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

     end if ;

 if p_wareid = 50000847 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --11元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',11 ,22, '杭州68领111','杭州68领111',p_memcardno,
                         null,date'2023-11-11',date'2023-11-11',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --20元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,66, '杭州68领111','杭州68领111',p_memcardno,
                         null,date'2023-11-11',date'2023-11-11',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --30元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',30 ,99, '杭州68领111','杭州68领111',p_memcardno,
                         null,date'2023-11-11',date'2023-11-11',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            --50元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,150, '杭州68领111','杭州68领111',p_memcardno,
                         null,date'2023-11-11',date'2023-11-11',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

   end if ;


    if p_wareid = 50000882 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

      --12元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',12 ,12.1, '无门槛','12元无门槛（双十二）',p_memcardno,
                         null,date'2023-12-12',date'2023-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --非药五折券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0.5 ,0, '非药5折券','非药5折券（双十二）',p_memcardno,
                         null,date'2023-12-12',date'2023-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         1);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --返场礼品券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券---礼品券实际应该为折扣券，此处写2
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0 ,0, '杭州礼品券','纸巾三包装(双十二）',p_memcardno,
                         null,date'2023-12-12',date'2023-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         3);


           V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

   /*
            --50元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '50元现金券','全场ab类非药商品原价使用（双十二）',p_memcardno,
                         null,date'2023-12-12',date'2023-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
        */

   end if ;

 if p_wareid = 50000885 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --10元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,10.1, '现金券满减','现金券满减',p_memcardno,
                         null,trunc(sysdate),trunc(sysdate)+13,0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --5折券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0.5 ,0, '杭州68领111','杭州68领111',p_memcardno,
                         null,trunc(sysdate),trunc(sysdate)+13,0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         1);

   end if ;

 if p_wareid = 50001036 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --20元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,58, '杭州10月送100元券','杭州10月送100元券',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --30元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',30 ,78, '杭州10月送100元券','杭州10月送100元券',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --50元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '杭州10月送100元券','杭州10月送100元券',p_memcardno,
                         null,date'2023-12-28',date'2023-12-30',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

   end if ;



   if p_wareid = 50000883 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --20元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,58, '杭州满68元送券','杭州满68元送券',p_memcardno,
                         null,date'2023-10-14',date'2023-10-29',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --30元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',30 ,78, '杭州满68元送券','杭州满68元送券',p_memcardno,
                         null,date'2023-10-14',date'2023-10-29',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --50元券
           INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '商品代金券','指定商品原价满减',p_memcardno,
                         null,date'2023-10-14',date'2023-10-29',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

   end if ;

/*购物满减 每单限送500元券
12元现金券+非药5折券+30701294礼品券  每个会员限送2套*/
  if p_wareid = 50000884 then
        /*2张50元*/
          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --50元券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '商品代金券','指定商品原价满减',p_memcardno,
                         null,date'2022-12-12',date'2022-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --50元券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100, '商品代金券','指定商品原价满减',p_memcardno,
                         null,date'2022-12-12',date'2022-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

        select count(*) into v_cnt from t_cash_coupon_info
        where coupon_type='折扣券F' and card_no=p_memcardno and trunc(createtime)>=date'2022-12-01';
        if v_cnt < 2 then

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --12元券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',12 ,12, '现金券满减','全场满减',p_memcardno,
                         null,date'2022-12-12',date'2022-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

           --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --5折券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0.5 ,0.5 , '折扣券F','指定商品5折',p_memcardno,
                         null,date'2022-12-12',date'2022-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         1);

         --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --礼品券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0,0, '礼品券30701294','礼品券30701294',p_memcardno,
                         null,date'2022-12-12',date'2022-12-12',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         1);

         end if;




      end if;

    --杭州618活动套券
    if p_wareid = 50000996 then
        /*1元纸巾特价券 20元券 99元 199元 299元*/

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --1元纸巾特价券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',1 ,0 , '定价券30701294','特价30701294',p_memcardno,
                         null,date'2023-06-16',date'2023-06-18',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         4,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 5折非药券
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --1元纸巾特价券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0.5 ,0 , '代金券FY','指定商品原价满减',p_memcardno,
                         null,date'2023-06-16',date'2023-06-18',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --20元券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',15 ,38 , '618现金券','指定商品原价满减',p_memcardno,
                         null,date'2023-06-16',date'2023-06-18',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --99元券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',99 ,399 , '618现金券','指定商品原价满减',p_memcardno,
                         null,date'2023-06-16',date'2023-06-18',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --199元券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',199 ,599 , '618现金券','指定商品原价满减',p_memcardno,
                         null,date'2023-06-16',date'2023-06-18',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
            --生成券号
            V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
            --299元券
                  INSERT INTO T_CASH_COUPON_INFO
                    (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                     MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                     CREATEUSER,CREATETIME,GIVE_SALENO,
                     COUPON_KIND,    --1现金券 2折扣券 3礼品券
                     ADVANCE_PAYAMT, --预约金
                     CREATE_BUSNO,
                     CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                     BAK4,
                     BAK6,
                     BAK9 --券类型1折扣、2满减、3礼品券
                     )

                   values (V_COUPONNO,SYSDATE,p_compid,'全部',299 ,799 , '618现金券','指定商品原价满减',p_memcardno,
                           null,date'2023-06-16',date'2023-06-18',0,1,null,
                           p_userid,SYSDATE,p_saleno,
                           1,
                           0 ,
                           p_busno,
                           0,
                           p_wareid,
                           V_COUPONNO,
                           2);
      end if;

   --杭州100活动套券
    if p_wareid = 50000880 then
        /*50元AB类代金券 2张，8元现金券 ，1张5折券*/

          --生成券号  10元券
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,28 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-07-21',date'2023-07-24',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 40元券
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',40 ,128 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-07-21',date'2023-07-24',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 50元券
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100 , '商品代金券','指定商品原价满减',p_memcardno,
                         null,date'2023-07-21',date'2023-07-24',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --5折非药券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0.5 ,0 , '代金券FY','指定商品原价满减',p_memcardno,
                         null,date'2023-07-21',date'2023-07-24',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

      end if;


   --杭州280活动套券
    if p_wareid = 50000869 then
        /*10 20(2) 40(2)元现金券YJ 50元AB类代金券 3张，1张5折券*/

          --生成券号  10元券
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,28 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 20元券 1
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,120 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 20元券 2
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',20 ,120 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 40元券 1
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',40 ,180 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 40元券 2
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 4定价券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',40 ,180 , '现金券YJ','全场原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号 50元券
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);

                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,100 , '商品代金券','指定商品原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

          --生成券号
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
          --5折非药券
                INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',0.5 ,0 , '代金券FY','指定商品原价满减',p_memcardno,
                         null,date'2023-08-25',date'2023-08-27',0,1,null,
                         p_userid,SYSDATE,p_saleno,
                         2,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);

      end if;
   
  if p_wareid = 50000851 then
      V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
      --28-9元券
      INSERT INTO T_CASH_COUPON_INFO
                  (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                   MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                   CREATEUSER,CREATETIME,GIVE_SALENO,
                   COUPON_KIND,    --1现金券 2折扣券 3礼品券
                   ADVANCE_PAYAMT, --预约金
                   CREATE_BUSNO,
                   CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                   BAK4,
                   BAK6,
                   BAK9 --券类型1折扣、2满减、3礼品券
                   )

                 values (V_COUPONNO,SYSDATE,p_compid,'全部',9 ,28, '现金券YJA','满28-9',p_memcardno,
                         null,date'2024-03-23',date'2024-03-25',0,1,'99元大礼包',
                         p_userid,SYSDATE,p_saleno,
                         1,
                         0 ,
                         p_busno,
                         0,
                         p_wareid,
                         V_COUPONNO,
                         2);
      

          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
       --30-10元券
          INSERT INTO T_CASH_COUPON_INFO
                      (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                       MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                       CREATEUSER,CREATETIME,GIVE_SALENO,
                       COUPON_KIND,    --1现金券 2折扣券 3礼品券
                       ADVANCE_PAYAMT, --预约金
                       CREATE_BUSNO,
                       CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                       BAK4,
                       BAK6,
                       BAK9 --券类型1折扣、2满减、3礼品券
                       )
    
                     values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,30, '现金券YJA','满30-10',p_memcardno,
                             null,date'2024-04-01',date'2024-04-15',0,1,'99元大礼包',
                             p_userid,SYSDATE,p_saleno,
                             1,
                             0 ,
                             p_busno,
                             0,
                             p_wareid,
                             V_COUPONNO,
                             2);
      
      
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
       --30-10元券
          INSERT INTO T_CASH_COUPON_INFO
                      (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                       MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                       CREATEUSER,CREATETIME,GIVE_SALENO,
                       COUPON_KIND,    --1现金券 2折扣券 3礼品券
                       ADVANCE_PAYAMT, --预约金
                       CREATE_BUSNO,
                       CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                       BAK4,
                       BAK6,
                       BAK9 --券类型1折扣、2满减、3礼品券
                       )
    
                     values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,30, '现金券YJA','满30-10',p_memcardno,
                             null,date'2024-04-16',date'2024-04-30',0,1,'99元大礼包',
                             p_userid,SYSDATE,p_saleno,
                             1,
                             0 ,
                             p_busno,
                             0,
                             p_wareid,
                             V_COUPONNO,
                             2);
      
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
       --30-10元券
          INSERT INTO T_CASH_COUPON_INFO
                      (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                       MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                       CREATEUSER,CREATETIME,GIVE_SALENO,
                       COUPON_KIND,    --1现金券 2折扣券 3礼品券
                       ADVANCE_PAYAMT, --预约金
                       CREATE_BUSNO,
                       CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                       BAK4,
                       BAK6,
                       BAK9 --券类型1折扣、2满减、3礼品券
                       )
    
                     values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,30, '现金券YJA','满30-10',p_memcardno,
                             null,date'2024-05-01',date'2024-05-15',0,1,'99元大礼包',
                             p_userid,SYSDATE,p_saleno,
                             1,
                             0 ,
                             p_busno,
                             0,
                             p_wareid,
                             V_COUPONNO,
                             2);
      
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
       --30-10元券
          INSERT INTO T_CASH_COUPON_INFO
                      (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                       MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                       CREATEUSER,CREATETIME,GIVE_SALENO,
                       COUPON_KIND,    --1现金券 2折扣券 3礼品券
                       ADVANCE_PAYAMT, --预约金
                       CREATE_BUSNO,
                       CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                       BAK4,
                       BAK6,
                       BAK9 --券类型1折扣、2满减、3礼品券
                       )
    
                     values (V_COUPONNO,SYSDATE,p_compid,'全部',10 ,30, '现金券YJA','满30-10',p_memcardno,
                             null,date'2024-05-16',date'2024-05-31',0,1,'99元大礼包',
                             p_userid,SYSDATE,p_saleno,
                             1,
                             0 ,
                             p_busno,
                             0,
                             p_wareid,
                             V_COUPONNO,
                             2);
      
          V_COUPONNO := f_get_serial(in_billcode => 'COUPON', in_org_code => p_busno);
       --120-50元券
          INSERT INTO T_CASH_COUPON_INFO
                      (COUPON_NO,ISSUING_DATE, COMPID,BUSNOS, COUPON_VALUES,LEAST_SALES,COUPON_TYPE,COUPON_DESC,CARD_NO,
                       MOBILE,START_DATE,END_DATE,USE_STATUS,STATUS,NOTES,
                       CREATEUSER,CREATETIME,GIVE_SALENO,
                       COUPON_KIND,    --1现金券 2折扣券 3礼品券
                       ADVANCE_PAYAMT, --预约金
                       CREATE_BUSNO,
                       CREATE_TPYE, --发放方式；0促销发券，1手工发券，2线上发券
                       BAK4,
                       BAK6,
                       BAK9 --券类型1折扣、2满减、3礼品券
                       )
    
                     values (V_COUPONNO,SYSDATE,p_compid,'全部',50 ,120, '商品代金券F','满120-50',p_memcardno,
                             null,date'2024-03-23',date'2024-03-25',0,1,'99元大礼包',
                             p_userid,SYSDATE,p_saleno,
                             1,
                             0 ,
                             p_busno,
                             0,
                             p_wareid,
                             V_COUPONNO,
                             2);
    
  end if;

END;
/

