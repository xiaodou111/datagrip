select sum(menge) from stock_out where trim(matnr)='10100767' and trim(ZGYSPH)='8139709' and zdate>=date'2023-08-01'
union all
select sum(menge) from stock_in  where trim(matnr)='10302726' and trim(ZGYSPH)='8139709' and zdate>=date'2023-08-01'
union all
select sum(menge) from stock where trim(matnr)='10302726' and trim(ZGYSPH)='8139709'
union all
select sum(menge+ZT_WAREQTY) from stock_history  where trim(matnr)='10302726' and trim(ZGYSPH)='8139709'
