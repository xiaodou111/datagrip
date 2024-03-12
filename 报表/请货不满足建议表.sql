insert into tmp_apply_needdb
WITH RankedRecords AS (select a.*, ROW_NUMBER() OVER (PARTITION BY busno ORDER BY LASTTIME desc ) rn
                       from d_distapply_sap a
                       where
                           --busno in ('81325','81001') and
                         LASTTIME >= date'2024-01-01' and trim(APPLYNO) is not null),
    busnoapplyno as (
        SELECT busno,
       applyno,
       lasttime,
       rn
FROM RankedRecords
WHERE rn = 1
    ),
--�ҳ�������Ҫ�����ĵ��ݺ�,�ŵ�,��Ʒ,
need_dbmx as (
select d_distapply_sap.*,tb.CLASSNAME from d_distapply_sap
join busnoapplyno on d_distapply_sap.APPLYNO=busnoapplyno.APPLYNO
join t_busno_class_set ts on d_distapply_sap.busno=to_char(ts.busno) and ts.classgroupno ='309'
join t_busno_class_base tb on ts.classgroupno=tb.classgroupno and ts.classcode=tb.classcode
)
select busno,wareid,CLASSNAME,sum(APPLQTY) APPLQTY
from need_dbmx
group by busno,wareid,CLASSNAME
order by
    CASE CLASSNAME
    WHEN '��A' THEN 1
    WHEN 'A'    THEN 2
    WHEN 'B'    THEN 3
    WHEN 'C'    THEN 4
    WHEN 'D'    THEN 5
    WHEN 'E'    THEN 6
    WHEN 'F'    THEN 7
END;

-- �ҳ���Щ�ŵ�����Щ��Ʒ�Ŀ��
select p.WAREID,p.BUSNO,p.WAREQTY,p.BATID,s1.INVALIDATE
from T_STORE_D  p
inner join t_store_i s1
                    on p.WAREID = s1.WAREID
                    and p.BATID =s1.BATID
where p.WAREQTY<>0
and p.WAREID in (select wareid from tmp_apply_needdb);
--��a�ȼ����ŵ���Ҫ�������Ʒ
select busno,WAREID,sum(APPLQTY) APPLQTY
from tmp_apply_needdb where MDDJ='��A' group by busno,WAREID;
--������a�ȼ����ŵ���Ҫ�������Ʒ,�ҳ����е��ŵ�Ŀ��
with a1 as ( 
    select busno,WAREID,sum(APPLQTY) APPLQTY
from tmp_apply_needdb where MDDJ='��A' group by busno,WAREID
),
a2 as ( select  p.WAREID,p.BUSNO,p.WAREQTY,p.BATID,s1.INVALIDATE
from T_STORE_D  p
inner join t_store_i s1
                    on p.WAREID = s1.WAREID
                    and p.BATID =s1.BATID
inner join a1 on a1.WAREID=p.WAREID
where p.WAREQTY<>0 )
select *
from a2;
;


declare

begin
    for res in (select busno,WAREID,sum(APPLQTY) APPLQTY
from tmp_apply_needdb where MDDJ='��A' group by busno,WAREID)
    loop
        select p.WAREID,p.BUSNO,p.WAREQTY,p.BATID,s1.INVALIDATE
from T_STORE_D  p
inner join t_store_i s1
                    on p.WAREID = s1.WAREID
                    and p.BATID =s1.BATID
where p.WAREQTY<>0 and p.WAREID=res.WAREID;
    end loop;

end;


-- create global temporary table tmp_apply_needdb(
--   busno number,
--   wareid number,
--   mddj   varchar2(40),
--   APPLQTY number
-- )on commit preserve rows
