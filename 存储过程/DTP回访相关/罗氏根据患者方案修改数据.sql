create or replace procedure proc_luoshi_prog

is
v_varcahr1   varchar2(100);
v_varcahr2   varchar2(100);
v_varcahr3   varchar2(100);
v_num        number;
v_num        number;
v_num        number;
v_begin      Date;
v_end        Date;


begin
--     根据用药方案重算数量字段,方案一只取10502445
  for res in
      (select IDCARDNO,WAREID,BEGINDATE from d_luoshi_prog where PROGRAMME=1)
   loop


   end loop;
--每个患者只能有一个方案
select
 h.IDCARDNO,
-- h.USERNAME,
sum(d.WAREQTY)
    over ( partition by h.IDCARDNO,d.WAREID order by a.ACCDATE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) m二二年1月以来本店累计购药支数,
count(distinct a.SALENO) over ( partition by a.busno,h.IDCARDNO) as q本店累计购药次数,
row_number() over (partition by h.IDCARDNO,d.WAREID order by a.ACCDATE desc) rn
              from t_remote_prescription_h h
                       join t_sale_h a on substr(a.notes, 0,
                                                 decode(instr(a.notes, ' '), 0, length(a.notes) + 1,
                                                        instr(a.notes, ' ')) - 1) =
                                          h.CFNO
                       join t_sale_d d on a.SALENO = d.SALENO
                       left join D_ZHYB_HZ_CYB cyb on cyb.ERP销售单号 = a.SALENO
                       left join d_patient_files fi on fi.IDCARDNO = h.IDCARDNO
                       join s_busi s on h.BUSNO = s.BUSNO
                       join t_busno_class_set ts on a.busno = ts.busno and ts.classgroupno = '322'
                       join t_busno_class_base tb on ts.classgroupno = tb.classgroupno and ts.classcode = tb.classcode
                       join t_busno_class_set ts1 on a.busno = ts1.busno and ts1.classgroupno = '323'
                       join t_busno_class_base tb1
                            on ts1.classgroupno = tb1.classgroupno and ts1.classcode = tb1.classcode
                       join t_ware_base w on w.WAREID = d.WAREID
              where a.ACCDATE >= date'2022-01-01' and d.WAREID in (10502445) ---10502445,
--                 and h.IDCARDNO = '330106196808190140'
                and a.SALENO not in (select saleno from T_SALE_RETURN_h)
                and a.SALENO not in (select RETSALENO from T_SALE_RETURN_h)
                and exists(select 1 from d_luoshi_prog p where p.IDCARDNO=h.IDCARDNO and a.ACCDATE>=p.BEGINDATE);
-- DBMS_OUTPUT.PUT_LINE(v_row_count);
exception
    when others then
RAISE_APPLICATION_ERROR(-20001, '单轨制更新(处方来源单号)没有行受到影响');

end ;