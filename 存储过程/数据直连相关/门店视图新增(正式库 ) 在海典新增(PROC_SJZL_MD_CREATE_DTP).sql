create or replace procedure proc_sjzl_md_create_dtp(p_name in varchar2,
                                                p_busno  in    varchar2,
                                               p_waretable in VARCHAR2
                                             )
    is

       
        v_kk   varchar2(3000);
        v_kk1   varchar2(3000);
        v_kk2   varchar2(3000);
       -- v_busno  varchar2(300);
        v_accept VARCHAR2(50);
        v_kc VARCHAR2(50);
        v_sale VARCHAR2(50);
        
     begin

  --  f_get_sjzl_rename

     /*  SELECT f_get_sjzl_rename(p_wareids)
      into v_wareids
       FROM dual ;
       SELECT f_get_sjzl_rename(p_busno)
      into v_busnos
       FROM dual ;

       SELECT instr(p_name,'accept')
       INTO v_accept
       FROM dual;
       SELECT instr(p_name,'kc')
       INTO v_kc
       FROM dual;
       SELECT instr(p_name,'sale')
       INTO v_sale
       FROM dual;*/
        v_accept := 'V_ACCEPT_' || p_name || '_'||p_busno;
       v_kc := 'V_KC_' || p_name || '_'||p_busno;
       v_sale := 'V_SALE_' || p_name || '_'||p_busno;
       --创建accept视图
      --IF v_accept>0 AND v_kc+v_sale=0 THEN
       v_kk:='CREATE   VIEW '|| v_accept ||' AS
select b1.compid as xsfdm,case when h.billcode = ''DIS'' then b1.orgname else b2.orgname end as xsfmc,'''' as cgfdm,
case when h.billcode = ''DIS'' then b2.orgname else b1.orgname end as cgfmc,d.wareid as cpdm,w.warename as cpmc,
  w.warespec as cpgg,d.makeno as ph,case when h.billcode = ''DIR'' then -d.wareqty else d.wareqty end as sl,w.wareunit as dw,d.purprice as dj,
       (case when h.billcode = ''DIR'' then -d.wareqty else d.wareqty end) * d.purprice as je,h.execdate as cjsj,h.billcode,h.distno,d.invalidate
       ,f.factoryname,w.fileno
       from t_dist_d d join t_dist_h h on h.distno = d.distno and h.status = 1 and h.billcode in (''DIS'',''DIR'') and (h.objbusno IN ('|| p_busno ||') or h.srcbusno IN('|| p_busno ||'))
                left join s_busi b1 on b1.compid = h.compid and b1.busno = h.srcbusno
                left join s_busi b2 on b2.compid = h.compid and b2.busno = h.objbusno
                left join t_ware w on w.compid = h.compid and w.wareid = d.wareid
                left JOIN t_factory f ON w.factoryid=f.factoryid
where d.wareid in (select wareid from '||p_waretable||')  and to_char(h.execdate,''yyyy-mm-dd'') >=''2024-01-01''';
       dbms_output.put_line(v_kk);
       execute immediate  v_kk ;
       --END IF;
       --创建kc视图
      --IF  v_kc>0 AND v_accept+v_sale=0 THEN
        v_kk1:='CREATE  VIEW '|| v_kc ||' AS
select sysdate as kcrq,''''as gsdm,b.orgname as gsmc,d.wareid as cpdm,w.warename as cpmc,w.warespec as cpgg,i.makeno as ph,sum(d.wareqty) as sl,
       i.purprice as dj,sum(d.wareqty * i.purprice) as je,w.wareunit as dw,i.createtime as cjsj,f.factoryname,i.invalidate,w.fileno
       from t_store_d d join t_store_h h on h.compid = d.compid and h.busno = d.busno and h.wareid = d.wareid
                 join t_store_i i on i.wareid = d.wareid and i.batid = d.batid
                 join s_busi b on b.compid = h.compid and b.busno = h.busno
                 left join t_ware w on w.compid = h.compid and w.wareid = d.wareid
                 LEFT join t_factory f ON w.factoryid=f.factoryid
               where d.wareid in (select wareid from '||p_waretable||')
               and d.busno in ('|| p_busno ||')
group by b.orgname,d.wareid,w.warename,w.warespec,w.wareunit,i.makeno,i.purprice,i.createtime,f.factoryname,i.invalidate,w.fileno
having sum(d.wareqty) > 0';

       dbms_output.put_line(v_kk1);
       execute immediate  v_kk1 ;
      --END IF;
      --创建sale视图
      --IF v_sale>0 AND v_accept+v_kc=0 THEN
        v_kk2:='CREATE  VIEW '|| v_sale ||' AS
SELECT a.saleno,a.compid as xsfdm,''浙江瑞人堂医药连锁有限公司'' as xsfmc,a.busno cgfdm,nvl(a.ext_str1,d.doctorname) as cgfmc,
b.wareid as cpdm,c.warename as cpmc,c.warespec as cpgg,c.wareunit as dw,b.makeno as ph,b.wareqty*b.times as sl,b.netprice as dj,b.wareqty*b.times * b.netprice as je,
b.accdate as cjsj,CASE when b.wareqty >=0 then ''纯销'' else ''退货'' end as 销售类型,''P001''库位,b.invalidate  有效日期,null AS syz,b.invalidate as yxq,null as billno
,f.factoryname,c.fileno,d.zdcont,d.kb
FROM t_sale_h a
LEFT JOIN t_remote_prescription_h d ON  substr(a.notes,0,decode(instr(a.notes,'' ''),0,length(a.notes)+1,instr(a.notes,'' ''))-1)=d.cfno
 ,t_sale_d b ,t_ware_base c,t_factory f
 where a.saleno=b.saleno and b.wareid=c.wareid AND c.factoryid=f.factoryid
and b.wareid in(select wareid from '||p_waretable||')
AND a.busno in ('|| p_busno ||')  and a.accdate>=date''2024-01-01''  and  a.accdate< trunc(sysdate)
union all
SELECT a.ABNORMITYNO,s.COMPID,''浙江瑞人堂医药连锁有限公司'',c.busno as cgfdm,case when WAREQTYA-WAREQTYB>0 then ''报溢'' else ''报损'' end,
a.wareid,b.warename,b.warespec,b.wareunit,a.makeno,WAREQTYB-WAREQTYA,a.saleprice,
(WAREQTYA-WAREQTYB) * a.saleprice,trunc(c.LASTTIME),case when WAREQTYA-WAREQTYB>0 then ''报溢'' else ''报损'' end ,''P001'',a.invalidate,a.SALETAX,a.invalidate,null
,f.FACTORYNAME,b.FILENO,null,null
FROM t_abnormity_d   a
inner join t_abnormity_h c on a.ABNORMITYNO=c.ABNORMITYNO
left join s_busi s on c.BUSNO=s.BUSNO
left join t_ware_base b   on  a.wareid=b.wareid
left join t_factory f on b.FACTORYID=f.FACTORYID
 WHERE c.BUSNO in ('|| p_busno ||')  and a.wareid in (select wareid from '||p_waretable||')
and  WAREQTYA<>WAREQTYB';

--sc.compname s_company sc  a.compid=sc.compid
       dbms_output.put_line(v_kk2);
        execute immediate  v_kk2 ;
        --END IF;

     end ;
/

