with aaa as (select a.MEMBERCARDNO, a.SALENO
             from t_sale_h a
             where ACCDATE between date'2024-04-01' and date'2024-04-30'
               and exists(select 1
                          from d_memcard_mb_h b
                          where createtime < to_date('2024-04-01', 'yyyy-MM-dd')
                            and a.MEMBERCARDNO = b.MEMCARDNO)
             and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO=a.SALENO)
              and not exists(select 1 from T_SALE_RETURN_H rh1 where rh1.RETSALENO=a.SALENO))

--查出建档时间在2024-04-01之前 date'2024-04-01' 到date'2024-04-30'之间没有消费过的会员
select bbb.* from d_memcard_mb_h bbb where not  exists (select 1 from aaa where aaa.MEMBERCARDNO=bbb.MEMCARDNO)
and bbb.createtime < to_date('2024-04-01', 'yyyy-MM-dd')