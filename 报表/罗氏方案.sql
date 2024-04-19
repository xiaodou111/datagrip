--todo 罗氏修改方案时间
select BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE, ENDDATE
from D_LUOSHI_PROG;

select a.busno, s.ORGNAME, a.idcardno, a.username, a.programme, a.wareid, w.WARENAME, a.begindate, a.ENDDATE
from d_luoshi_prog a
         left join s_busi s on a.busno = s.BUSNO
         left join t_ware_base w on a.wareid = w.WAREID
-- 单靶(单曲妥珠单抗)~t1/双靶(帕妥珠单抗)~t2/双靶(曲妥珠单抗)~t3/其他方案(含曲妥珠单抗)~t4/其他方案(含帕妥珠单抗)~t5/单靶(曲妥珠单抗HSC)~t6/双靶(含曲妥珠单抗HSC)~t7/双靶(帕妥珠单抗)~t8/其他方案(曲妥珠单抗HSC+吡咯替尼)~t9/~t /

alter table D_LUOSHI_PROG
    add enddate date;
--插入时不指定ENDDATE字段会使用默认值
insert into D_LUOSHI_PROG(BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE)
values (null, 332623195005301346, '里斯', 9, 10502445, DATE'2023-12-31');
ALTER TABLE D_LUOSHI_PROG
    MODIFY (enddate DATE DEFAULT TO_DATE('9999-12-31', 'YYYY-MM-DD'));

select h.IDCARDNO,a.busno,cyb.参保地,cyb.异地标志,h.USERNAME,h.CAGE,h.SEX,d.WAREID,d.WAREQTY,a.ACCDATE
                    from t_remote_prescription_h h
                        join t_sale_h a on substr(a.notes, 0,
                                                  decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                         instr(a.notes, ' ')) -
                                                  1) =
                                           h.CFNO
                        join t_sale_d d on a.SALENO = d.SALENO
      left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
      where
          IDCARDNO='332623195005301346' AND
          a.ACCDATE between date'2023-01-01' and date'2023-09-01' and
d.WAREID in (10502445);

--方案一
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY
from t_remote_prescription_h h
         join t_sale_h a
              on SUBSTR(a.notes, 0, DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1, INSTR(a.notes, ' ')) - 1) =
                 h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where EXISTS(select 1
             from D_LUOSHI_PROG p
             where h.IDCARDNO = p.IDCARDNO
               and p.PROGRAMME = 1
               and a.ACCDATE between p.BEGINDATE and p.ENDDATE)
  and d.WAREID IN (10502445);

-- select BEGINDATE, LEAD(BEGINDATE, 1) OVER (PARTITION BY IDCARDNO ORDER BY BEGINDATE) enddate
-- from D_LUOSHI_PROG;

--方案一

select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) - 1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where d.WAREID in (10502445) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
  and a.SALENO not in (select saleno from T_SALE_RETURN_h)
  and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);

--方案二,三

select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) - 1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where d.WAREID in (10600308) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
  and a.SALENO not in (select saleno from T_SALE_RETURN_h)
  and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);

--方案四
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) - 1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where d.WAREID in (10502445) ---10502445,

--                 and h.IDCARDNO = '330106196808190140'
  and a.SALENO not in (select saleno from T_SALE_RETURN_h)
  and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);
--方案五
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) - 1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where d.WAREID in (10601875) ---10502445,

--                 and h.IDCARDNO = '330106196808190140'
  and a.SALENO not in (select saleno from T_SALE_RETURN_h)
  and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);
--方案六
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) - 1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where d.WAREID in (10601875) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
  and a.SALENO not in (select saleno from T_SALE_RETURN_h)
  and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);
--方案5
select d.WAREID, h.IDCARDNO, a.ACCDATE, d.WAREQTY,
       ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE ) rn
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) - 1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
where d.WAREID in (10601875, 10600308) ---10502445,
  and a.ACCDATE >= date'2024-01-01'
--                 and h.IDCARDNO = '330106196808190140'
  and a.SALENO not in (select saleno from T_SALE_RETURN_h)
  and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h);

create or replace procedure proc_luoshi_update
    is
    v_varcahr1 varchar2(100);
    v_varcahr2 varchar2(100);
    v_varcahr3 varchar2(100);
    v_num      number;
    v_num      number;
    v_num      number;
    v_begin    Date;
    v_end      Date;


begin

    DBMS_OUTPUT.PUT_LINE(v_row_count);
exception
    when others then
        RAISE_APPLICATION_ERROR(-20001, '单轨制更新(处方来源单号)没有行受到影响');

end ;
insert into D_LUOSHI_PROG
values (81001, '123456789012345678', '张三', '方案1', 10502445, date'2024-04-01');
select BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE
from D_LUOSHI_PROG;



update D_LUOSHI_PROG
set PROGRAMME='方案2',
    BEGINDATE=date'2024-04-15'
where IDCARDNO = '123456789012345678';


select *
from D_LUOSHI_PROG_HISTORY;
CREATE OR REPLACE TRIGGER trg_d_luoshi_prog
    AFTER UPDATE
    ON D_LUOSHI_PROG
    FOR EACH ROW
BEGIN

    INSERT INTO D_LUOSHI_PROG_HISTORY (HISTORY_ID, BUSNO, IDCARDNO, USERNAME, PROGRAMME, WAREID, BEGINDATE, ACTION,
                                       ACTION_DATE)
    VALUES (D_LUOSHI_PROG_HISTORY_SEQ.NEXTVAL, :NEW.BUSNO, :NEW.IDCARDNO, :NEW.USERNAME, :NEW.PROGRAMME, :NEW.WAREID,
            :NEW.BEGINDATE, 'UPDATE', SYSDATE);


END;
/



select IDCARDNO, COUNT(*)
FROM (select IDCARDNO, busno, rn, lastbuytime, 参保地, 异地标志, USERNAME, CAGE, SEX
      from (select h.IDCARDNO, a.busno, cyb.参保地, cyb.异地标志, h.USERNAME, h.CAGE, h.SEX,
                   ROW_NUMBER() over (partition by h.IDCARDNO order by a.ACCDATE desc) rn,
                   MAX(a.ACCDATE) OVER (PARTITION BY h.IDCARDNO,d.WAREID ) AS lastbuytime
            from t_remote_prescription_h h
                     join t_sale_h a on SUBSTR(a.notes, 0,
                                               DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                                      INSTR(a.notes, ' ')) -
                                               1) =
                                        h.CFNO
                     join t_sale_d d on a.SALENO = d.SALENO
                     left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
            where

--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308))
      where lastbuytime > date'2023-01-01'
        and IDCARDNO is not null)
GROUP BY IDCARDNO;



select h.IDCARDNO, d.WAREID
from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
where

--           a.ACCDATE >= date'2023-01-01' and
d.WAREID in (10502445, 10601875, 10600308)
GROUP BY h.IDCARDNO, d.WAREID
HAVING COUNT(DISTINCT d.WAREID) = 2;



select h.IDCARDNO, a.busno, cyb.参保地, cyb.异地标志, h.USERNAME, h.CAGE, h.SEX, d.WAREID, d.WAREQTY, a.ACCDATE


from t_remote_prescription_h h
         join t_sale_h a on SUBSTR(a.notes, 0,
                                   DECODE(INSTR(a.notes, ' '), 0, LENGTH(a.notes) + 1,
                                          INSTR(a.notes, ' ')) -
                                   1) =
                            h.CFNO
         join t_sale_d d on a.SALENO = d.SALENO
         left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
where IDCARDNO = '332623195005301346'
  AND
--           a.ACCDATE >= date'2023-01-01' and
    d.WAREID in (10502445, 10601875, 10600308);