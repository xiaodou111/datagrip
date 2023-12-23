declare
 v_date date:=date'2023-12-07';
begin
    --获取销售明细
    insert into tmp_sale_mx_o2o
    (compid,accdate,finaltime,saleno, busno, wareid, batid, wareqty, stdsum, netsum, puramount, netsum_no, puramount_no, saler)
    select h.compid,d.accdate,h.finaltime,d.saleno,d.busno,d.wareid,d.batid,
           round(((d.wareqty + (case when nvl(d.stdtomin,1) = 0 then 0 else d.minqty / nvl(d.stdtomin,1) end)) * d.times),4) as wareqty,
           round(d.stdprice * d.wareqty * d.times + nvl(d.stdminprice,0) * d.minqty * d.times,2) as stdsum,
           round(nvl(d.netamt,(d.netprice * d.wareqty * d.times + d.minqty * d.times * d.minprice)),2) as netamt,
           round((d.purprice * (d.wareqty + (case when nvl(d.stdtomin,1) = 0 then 0 else d.minqty / nvl(d.stdtomin,1) end)) * d.times),2) as puramt,
           round(nvl(d.netamt,round(d.netprice * d.wareqty * d.times + d.minqty * d.times * d.minprice,2)) / (1 + (d.saletax) / 100),2) as netsum_no,
           round((d.purprice * (d.wareqty + (case when nvl(d.stdtomin,1) = 0 then 0 else d.minqty / nvl(d.stdtomin,1) end)) * d.times) / (1 + (d.purtax) / 100),2) as pursum_no,
           nvl(d.saler,0) as saler
    from t_sale_d d join t_sale_h h on h.saleno = d.saleno
    where exists(select 1
                 from t_sale_pay p
                 where p.saleno = h.saleno and p.paytype in ('Z022','Z025','Z027','Z030','Z032','Z034','Z077','Z081','Z098','Z100','Z101','Z084','Z102') and p.netsum <> 0)
          and h.busno not in (89014,89017,89018,89065,89054,89068,89070,89073,89078) and d.accdate=v_date    ----Z084 拼多多 也算O2O   jxh
    union all
    select h.compid,d.accdate,h.finaltime,d.saleno,d.busno,d.wareid,d.batid,
           round(((d.wareqty + (case when nvl(d.stdtomin,1) = 0 then 0 else d.minqty / nvl(d.stdtomin,1) end)) * d.times),4) as wareqty,
           round(d.stdprice * d.wareqty * d.times + nvl(d.stdminprice,0) * d.minqty * d.times,2) as stdsum,
           round(nvl(d.netamt,(d.netprice * d.wareqty * d.times + d.minqty * d.times * d.minprice)),2) as netamt,
           round((d.purprice * (d.wareqty + (case when nvl(d.stdtomin,1) = 0 then 0 else d.minqty / nvl(d.stdtomin,1) end)) * d.times),2) as puramt,
           round(nvl(d.netamt,round(d.netprice * d.wareqty * d.times + d.minqty * d.times * d.minprice,2)) / (1 + nvl(d.saletax,d.purtax) / 100),2) as netsum_no,
           round((d.purprice * (d.wareqty + (case when nvl(d.stdtomin,1) = 0 then 0 else d.minqty / nvl(d.stdtomin,1) end)) * d.times) / (1 + (d.purtax) / 100),2) as pursum_no,
           nvl(d.saler,0) as saler
    from t_sale_d d join t_sale_h h on h.saleno = d.saleno and h.busno in (89014,89017,89018,89065,89054,89068,89070,89073,89078)
    where d.accdate=v_date;
    --获取每单金额
    insert into tmp_sale_hz_o2o
    (saleno, netsum)
    select saleno,sum(netsum) as netsum
    from tmp_sale_mx_o2o
    group by saleno;
    --获取o2o优惠券金额
    insert into tmp_sale_yhq_o2o
    (saleno, yhq)
    select p.saleno,p.netsum
    from t_sale_pay p join t_sale_h h on h.saleno = p.saleno and h.accdate =v_date
    where p.paytype = 'Z016';
    --获取付款方式
    insert into tmp_sale_pay_o2o
    (saleno, paytype)
    select p.saleno,max(p.paytype) as paytype
    from t_sale_pay p join t_sale_h h on h.saleno = p.saleno and h.accdate =v_date
    where h.busno not in (89014,89017,89018,89065,89054,89068,89070,89073,89078) and p.paytype in ('Z022','Z025','Z027','Z030','Z032','Z034','Z077','Z081','Z098','Z100','Z101','Z084','Z102') and p.netsum <> 0
    group by p.saleno
    union all
    select saleno,case when busno = 89014 then 'Z027' when busno in (89017,89068,89078) then 'Z101' else 'Z100' end as paytype
    from tmp_sale_mx_o2o
    where busno in (89014,89017,89018,89065,89054,89068,89070,89073,89078)
    group by saleno,case when busno = 89014 then 'Z027' when busno in (89017,89068,89078) then 'Z101' else 'Z100' end;
    --统计
    --删除原有数据
    delete
    from d_rpt_sale_o2o
    where accdate =v_date;

    insert into d_rpt_sale_o2o
    (accdate, busno, compid, wareid, batid, saler, paytype, wareqty,stdsum, netsum, puramount, netsum_no, puramount_no,yhq,countrow)
    select o.accdate,o.busno,o.compid,o.wareid,o.batid,o.saler,p.paytype,sum(o.wareqty) as wareqty,sum(o.stdsum),sum(o.netsum) as netsum,
           sum(o.puramount) as puramount,
           sum(o.netsum_no) as netsum_no,sum(o.puramount_no) as puramount_no,
           sum(decode(h.netsum,0,0,round(o.netsum / h.netsum * nvl(y.yhq,0),2))) as yhq,count(*) as countrow
    from tmp_sale_mx_o2o o join tmp_sale_hz_o2o h on h.saleno = o.saleno
                           join tmp_sale_pay_o2o p on p.saleno = o.saleno
                           left join tmp_sale_yhq_o2o y on y.saleno = o.saleno
    group by o.accdate,o.busno,o.compid,o.wareid,o.batid,o.saler,p.paytype;
    --POS
    --删除原有数据
    delete
    from d_rpt_sale_pos_o2o
    where accdate =v_date;

    insert into d_rpt_sale_pos_o2o
    (accdate, thour, busno, compid, paytype,stdsum, netsum, puramount, netsum_no, puramount_no, yhq, countrow, salecount)
    select o.accdate,to_number(to_char(o.finaltime,'HH24')) as thour,o.busno,o.compid,p.paytype,sum(o.stdsum),sum(o.netsum) as netsum,
           sum(o.puramount) as puramount,sum(o.netsum_no) as netsum_no,sum(o.puramount_no) as puramount_no,
           sum(decode(h.netsum,0,0,round(o.netsum / h.netsum * nvl(y.yhq,0),2))) as yhq,count(*) as countrow,count(distinct o.saleno) as sale_count
    from tmp_sale_mx_o2o o join tmp_sale_hz_o2o h on h.saleno = o.saleno
                           join tmp_sale_pay_o2o p on p.saleno = o.saleno
                           left join tmp_sale_yhq_o2o y on y.saleno = o.saleno
    group by o.accdate,to_number(to_char(o.finaltime,'HH24')),o.busno,o.compid,p.paytype;
    
end;





