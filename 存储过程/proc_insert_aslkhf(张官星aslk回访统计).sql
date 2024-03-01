create or replace procedure proc_insert_aslkhf
is
v_row_count        number;
begin

    --每天插入排序后新的saleno的信息
  merge into d_aslk_revisit1  t1
using (select MEMBERCARDNO, SALENO, BUSNO, ACCDATE, WAREID, WAREQTY, buyorder, firstday, lastday, lastqty, last2day,
              last2qty,
              syz, wfgyy, ycyy, sfblfy
       from (select h.MEMBERCARDNO, h.SALENO, h.BUSNO, h.ACCDATE, d.WAREID, d.WAREQTY,
                    ROW_NUMBER() OVER (PARTITION BY h.MEMBERCARDNO, h.BUSNO,d.WAREID ORDER BY h.ACCDATE) AS buyorder,
                    MIN(h.ACCDATE) OVER (PARTITION BY h.MEMBERCARDNO, h.BUSNO ,d.WAREID ) AS firstday,
                    Max(h.ACCDATE) OVER (PARTITION BY h.MEMBERCARDNO, h.BUSNO ,d.WAREID ) AS lastday,
                    Max(d.WAREQTY) OVER (PARTITION BY h.MEMBERCARDNO, h.BUSNO ,d.WAREID ) AS lastqty,
                    LAG(h.ACCDATE, 1)
                        OVER (PARTITION BY h.MEMBERCARDNO,h.BUSNO,d.WAREID ORDER BY h.ACCDATE asc) AS last2day,
                    LAG(d.WAREQTY, 1)
                        OVER (PARTITION BY h.MEMBERCARDNO,h.BUSNO,d.WAREID ORDER BY h.ACCDATE asc) AS last2qty,
                    null as syz, null as wfgyy, null as ycyy, null as sfblfy
             from t_sale_h h
                      join (select saleno, wareid, sum(WAREQTY) as WAREQTY
                            from t_sale_d
                            group by saleno, wareid) d
                           on h.SALENO = d.SALENO
                      left join d_aslk_revisit z on h.SALENO = z.SALENO
             where d.WAREID in (10601840, 10110908, 10113537)
--   and h.ACCDATE >= date'2024-01-01'
               and h.MEMBERCARDNO is not null
               and not exists(select 1 from T_SALE_RETURN_h th where th.SALENO = h.SALENO)
               and not exists(select 1 from T_SALE_RETURN_h th2 where th2.RETSALENO = h.SALENO)) a
       where not exists(select 1
                        from d_aslk_revisit1 old
                        where old.SALENO=a.SALENO)
      ) t2
    ON ( T1.saleno=t2.SALENO)
    WHEN MATCHED THEN
  UPDATE SET T1.LASTDAY= T2.LASTDAY,T1.LASTQTY=T2.lastqty
  WHEN NOT MATCHED THEN
  INSERT (MEMBERCARDNO, SALENO, BUSNO, ACCDATE, WAREID, WAREQTY, buyorder, firstday, lastday, lastqty, last2day,
              last2qty,syz, wfgyy, ycyy, sfblfy)
  VALUES(
         T2.membercardno,
         T2.saleno,
         T2.busno,
         T2.accdate,
         T2.wareid,
         T2.wareqty,
         T2.buyorder,
         T2.firstday,
         T2.lastday,
         T2.lastqty,
         T2.last2day,
         T2.last2qty,
         T2.syz,
         T2.wfgyy,
         T2.ycyy,
         T2.sfblfy
        );

  v_row_count:=SQL%ROWCOUNT;
   insert into d_aslk_hfrecord(accdate,countnum) values(trunc(sysdate),v_row_count);
--       DBMS_OUTPUT.PUT_LINE(v_row_count);
-- exception
--     when others then
-- RAISE_APPLICATION_ERROR(-20001, '单轨制更新(处方来源单号)没有行受到影响');

end ;


