--1.先把d_hz_mdsp删掉再导入
select * from d_hz_mdsp;
delete from  d_hz_result;
--2.导出销售记录

insert into d_hz_result(sub_unit_id, item_num_id, sales_empe_num_id, sub_total_qty, empe_total_qty, blee, je, jj)
WITH a1 AS (SELECT hdr.sub_unit_num_id,
                   hdr.tml_num_id,
                   hdr.order_date,
                   hdr.last_updtme,
                   dtl.item_num_id,
                   hdr.sales_empe_num_id,
                   dtl.qty,
                   aa.je,
                   SUM(dtl.qty) OVER (PARTITION BY hdr.sub_unit_num_id, dtl.item_num_id)                        AS sub_total_qty,
                   SUM(dtl.qty)
                       OVER (PARTITION BY hdr.sub_unit_num_id, hdr.sales_empe_num_id, dtl.item_num_id)          AS empe_total_qty
            FROM sd_bl_so_tml_hdr hdr
                     INNER JOIN sd_bl_so_tml_lock_dtl dtl
                                ON hdr.tenant_num_id = dtl.tenant_num_id AND hdr.data_sign = dtl.data_sign AND
                                   hdr.order_date = dtl.order_date AND hdr.cort_num_id = dtl.cort_num_id AND
                                   hdr.sub_unit_num_id = dtl.sub_unit_num_id AND hdr.tml_num_id = dtl.tml_num_id
                     INNER JOIN d_hz_mdsp aa
                                ON aa.sub_unit_id = hdr.sub_unit_num_id AND aa.item_num_id = dtl.item_num_id
            WHERE hdr.order_date BETWEEN date'2024-08-01' AND date'2024-08-31'
--               AND hdr.sub_unit_num_id = '5002'
--                AND hdr.sales_empe_num_id IS  NULL
--              and dtl.item_num_id in (1015097,1126720)
              and TYPE_NUM_ID<>2
            and not exists(select 1  from sd_bl_so_tml_hdr re where TYPE_NUM_ID=2 and re.SOURCE_TML_NUM_ID=hdr.TML_NUM_ID)
            ),
     a2 AS (SELECT sub_unit_num_id,
                   tml_num_id,
                   order_date,
                   last_updtme,
                   item_num_id,
                   sales_empe_num_id,
                   qty,
                   sub_total_qty,
                   empe_total_qty,
                   je                                                                              AS 金额,
                   CASE WHEN sub_total_qty = 0 THEN 0 ELSE round(empe_total_qty / sub_total_qty,2) END      AS 比例,
                   CASE WHEN sub_total_qty = 0 THEN 0 ELSE round(empe_total_qty / sub_total_qty * je,2) END AS 奖金
            FROM a1)
SELECT sub_unit_num_id, item_num_id, sales_empe_num_id, sub_total_qty, empe_total_qty, 比例,金额, 奖金
FROM a2
GROUP BY sub_unit_num_id, item_num_id, sales_empe_num_id, sub_total_qty, empe_total_qty, 比例,金额, 奖金;

--
select SUB_UNIT_ID as 门店编码, ITEM_NUM_ID as 商品编码, SALES_EMPE_NUM_ID as 工号, SUB_TOTAL_QTY as 门店总数, EMPE_TOTAL_QTY as 员工总数, BLEE as 分配比例, JE as 含税金额,
       nvl(FTHJJ,JJ) as 补偿金额
--        JJ as 补偿金额,
--        FTHJJ as 销售员为空分配金额
from d_hz_result ;

select SUB_UNIT_ID,SALES_EMPE_NUM_ID,sum(SUB_TOTAL_QTY) from d_hz_result group by SUB_UNIT_ID, SALES_EMPE_NUM_ID;



select * from d_hz_result where SUB_UNIT_ID=5027 and ITEM_NUM_ID in (1180840,1060572);
--3.工号为空的销售记录分配金额
--直接删掉v_null>0 并且v_cnt=0的
declare
    v_null number;
    v_cnt number;
    i number:=0;
    v_je number;
    sum_je number:=0;
    sumnulljj number;

    begin
    for res in (select SUB_UNIT_ID,ITEM_NUM_ID from  d_hz_result where SALES_EMPE_NUM_ID is null group by SUB_UNIT_ID,ITEM_NUM_ID)
    loop
      select count(*)
      into v_cnt
      from d_hz_result q
      where q.SUB_UNIT_ID=res.SUB_UNIT_ID and q.ITEM_NUM_ID=res.ITEM_NUM_ID and SALES_EMPE_NUM_ID is not null;


      select count(*)
      into v_null
      from d_hz_result q
      where q.SUB_UNIT_ID=res.SUB_UNIT_ID and q.ITEM_NUM_ID=res.ITEM_NUM_ID and SALES_EMPE_NUM_ID is null;

      select sum(jj)
      into sumnulljj
      from d_hz_result q
      where q.SUB_UNIT_ID=res.SUB_UNIT_ID and q.ITEM_NUM_ID=res.ITEM_NUM_ID and SALES_EMPE_NUM_ID is null;
      if v_null>0 and v_cnt>0 then
--       DBMS_OUTPUT.PUT_LINE('res:'||res.ITEM_NUM_ID||','||res.SUB_UNIT_ID);
--       DBMS_OUTPUT.PUT_LINE('v_cnt:'||v_cnt);
--       DBMS_OUTPUT.PUT_LINE('v_null:'||v_null);
      update d_hz_result set fthjj=JJ+sumnulljj*(1/v_cnt)   where ITEM_NUM_ID=res.ITEM_NUM_ID and SUB_UNIT_ID=res.SUB_UNIT_ID and SALES_EMPE_NUM_ID is not null;
      end if;
--       if v_cnt=0 and v_null<>0 then
--           i:=i+1;
--           select JE
--           into v_je
--           from d_hz_result q
--       where q.SUB_UNIT_ID=res.SUB_UNIT_ID and q.ITEM_NUM_ID=res.ITEM_NUM_ID ;
--           sum_je:=sum_je+v_je;
--           DBMS_OUTPUT.PUT_LINE('v_je:'||v_je);
--       end if;
    end loop;
--     DBMS_OUTPUT.PUT_LINE('i:'||i);
--     DBMS_OUTPUT.PUT_LINE('sum_je:'||sum_je);
    end;

--4.导出分配金额
select SUB_UNIT_ID as 门店编码, ITEM_NUM_ID as 商品编码, SALES_EMPE_NUM_ID as 工号, SUB_TOTAL_QTY as 门店总数, EMPE_TOTAL_QTY as 员工总数, BLEE as 分配比例, JE as 含税金额,
       nvl(FTHJJ,JJ) as 补偿金额
--        JJ as 补偿金额,
--        FTHJJ as 销售员为空分配金额
from d_hz_result ;

select * from d_hz_mdsp where SUB_UNIT_ID=5020;
select count(*) from d_hz_result;
----未销售的导出
select  a.SUB_UNIT_ID as 门店编码, a.ITEM_NUM_ID as  商品编码,JE as 金额 from d_hz_mdsp a where not exists(select 1 from (

                                                      select SUB_UNIT_ID,ITEM_NUM_ID from d_hz_result a  group by SUB_UNIT_ID, ITEM_NUM_ID) b
                                                       where a.ITEM_NUM_ID=b.ITEM_NUM_ID and a.SUB_UNIT_ID=b.SUB_UNIT_ID);


-- create table d_hz_wfp as
--5.导出未售出商品员工分配的金额
with a1 as (
select SUB_UNIT_ID,SALES_EMPE_NUM_ID,sum(SUB_TOTAL_QTY) as pertotal from d_hz_result
--                                                                     where SALES_EMPE_NUM_ID is not null
                                                                    group by SUB_UNIT_ID, SALES_EMPE_NUM_ID),
a2 as (
select SUB_UNIT_ID,SALES_EMPE_NUM_ID,pertotal,sum(pertotal) over (partition by SUB_UNIT_ID order by SUB_UNIT_ID) as mdtotal
from a1),
to_fp as (
  select 门店编码,sum(金额) je from (
select  a.SUB_UNIT_ID as 门店编码, a.ITEM_NUM_ID as  商品编码,JE as 金额 from d_hz_mdsp a where not exists(select 1 from (

                                                      select SUB_UNIT_ID,ITEM_NUM_ID from d_hz_result a  group by SUB_UNIT_ID, ITEM_NUM_ID) b
                                                       where a.ITEM_NUM_ID=b.ITEM_NUM_ID and a.SUB_UNIT_ID=b.SUB_UNIT_ID) ) group by 门店编码
)
-- select *
-- from to_fp where 门店编码 not in (select SUB_UNIT_ID from a2)  ;
select nvl(SUB_UNIT_ID,门店编码) as 门店编码, SALES_EMPE_NUM_ID as  工号 , pertotal 员工总销量, mdtotal 门店总销量,pertotal/mdtotal as 占比,to_fp.je 该店待分配金额,round(pertotal/mdtotal* to_fp.je,2) as 员工分配金额
from to_fp
left join a2 on a2.SUB_UNIT_ID=to_fp.门店编码;

select 门店编码, 工号, 员工总销量, 门店总销量, 占比, 该店待分配金额, 员工分配金额,员工分配金额+1/5*
from d_hz_wfp where 门店编码=5027  ;
--未销售的进行分配还没好
declare
    v_null number;
    v_cnt number;
    i number:=0;
    v_je number;
    sum_je number:=0;
    sumnulljj number;

    begin
    for res in (select 门店编码,工号 from  d_hz_wfp where 工号 is null and 门店总销量 is not null group by 门店编码,工号)
    loop
      select count(distinct 工号)
      into v_cnt
      from d_hz_wfp q
      where q.门店编码=res.门店编码  and 工号 is not null;

