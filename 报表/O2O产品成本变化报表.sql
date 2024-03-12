


--O2O����ǰ��30�����  round( if ( saleqty=0, 0, netamt/saleqty), 4 )
--��ë����  netamt - puramt - yhq
-- ��ë���� if(jnetamt= 0 ,0,round(jmle / jnetamt, 4))  jnetamt= netamt - yhq

with a30 as (SELECT b.wareid as wareid,
                    sum(round(b.stdsum, 2)) as stdsum,
                    sum(round(b.netsum, 2)) as netamt,
                    sum(b.puramount) /*sum(round(nvl(b.puramount,0),6))*/ as puramt,
                    sum(b.yhq) as yhq,
                    sum(round(b.wareqty, 6)) as wareqty
             FROM d_rpt_sale_o2o b
             WHERE exists (select 1
                           from s_user_busi sub
                           where sub.compid = b.compid and sub.busno = b.busno and sub.userid = 50002418
                             and sub.status = 1)
               and b.accdate between trunc(sysdate) - 31 and trunc(sysdate) - 1
               and
                    b.WAREID = '10200025' and EXISTS(SELECT 1
                                                     FROM t_busno_class_set wc__
                                                     WHERE wc__.busno = b.busno AND wc__.classgroupno = '320'
                                                       AND wc__.classcode <> '320105')
             GROUP BY b.wareid),
     a365 as (SELECT b.wareid as wareid,
                     sum(round(b.stdsum, 2)) as stdsum,
                     sum(round(b.netsum, 2)) as netamt,
                     sum(b.puramount) /*sum(round(nvl(b.puramount,0),6))*/ as puramt,
                     sum(b.yhq) as yhq,
                     sum(round(b.wareqty, 6)) as wareqty
              FROM d_rpt_sale_o2o b


              WHERE exists (select 1
                            from s_user_busi sub
                            where sub.compid = b.compid and sub.busno = b.busno and sub.userid = 50002418
                              and sub.status = 1)
                and b.accdate between ADD_MONTHS(trunc(sysdate) - 1, -12) - 30 and ADD_MONTHS(trunc(sysdate) - 1, -12)
                and b.WAREID = '10200025' and EXISTS(SELECT 1
                                                     FROM t_busno_class_set wc__
                                                     WHERE wc__.busno = b.busno AND wc__.classgroupno = '320'
                                                       AND wc__.classcode <> '320105')
              GROUP BY b.wareid),
     hz as (select a30.wareid, w.WARENAME, w.WARESPEC, f.FACTORYNAME, a30.netamt, a30.puramt,
                   case when a30.wareqty = 0 then 0 else a30.netamt / a30.wareqty end as O2O����ǰ��30�����,
                   a30.wareqty as O2Oǰ��30��������,
                   case
                       when a30.netamt - a30.yhq = 0 then 0
                       else (a30.netamt - a30.puramt - a30.yhq) / (a30.netamt - a30.yhq) end as O2Oǰ��30��ë����,
                   case when a365.wareqty = 0 then 0 else a365.netamt / a365.wareqty end as O2Oͬ�����۾���,
                   a365.wareqty as O2Oͬ����������,
                   case
                       when a365.netamt - a365.yhq = 0 then 0
                       else (a365.netamt - a365.puramt - a365.yhq) / (a365.netamt - a365.yhq) end as O2Oͬ������ë����,
                   a30.netamt - a30.puramt - a30.yhq as O2Oǰ��30��ë����
            from a30
                     left join a365 on a30.wareid = a365.wareid
                     left join T_WARE_BASE w on a30.wareid = w.WAREID
                     left join t_factory f on w.FACTORYID = f.FACTORYID)
select hz.wareid, WARENAME, WARESPEC, FACTORYNAME, c107.CLASSNAME as O2O��Ʒ��Ӫ��������,
       c120.CLASSNAME as O2O��Ʒ�̻��ȼ�,
       cost.oldcost, cost.newcost, cost.rebate, cost.settlementprice,
       cf_get_saleprice_hz(hz.wareid,1000) as ��㷺���ۼ�,
       O2O����ǰ��30�����, O2Oǰ��30��������,
       O2Oǰ��30��ë����,
       O2Oͬ�����۾���, O2Oͬ����������, O2Oͬ������ë����,
       --(�³ɱ���-ԭ�ɱ���)/ԭ�ɱ��� as �ɱ�ͬ������
       case when cost.oldcost = 0 then 0 else (cost.newcost - cost.oldcost) / cost.oldcost end as �ɱ�ͬ������,
       case
           when O2Oͬ���������� = 0 then 0
           else (O2Oǰ��30�������� - O2Oͬ����������) / O2Oͬ���������� end as ����ͬ������,
       --(�³ɱ���-ԭ�ɱ���)*O2Oǰ��30�������� as ë������
       (cost.newcost - cost.oldcost) * O2Oǰ��30�������� as ë������,
       O2Oǰ��30��ë����,
       --ë������/O2Oǰ��30��ë���� as O2Oǰ��30�쵥Ʒë����Ӱ��
       case
           when O2Oǰ��30��ë���� = 0 then 0
           else
               (cost.newcost - cost.oldcost) * O2Oǰ��30�������� / O2Oǰ��30��ë���� end as O2Oǰ��30�쵥Ʒë����Ӱ��,
       --O2Oͬ����������/1 as O2Oë����Ӱ��
       O2Oͬ���������� / 1 as O2Oë����Ӱ��
from hz
         left join d_o2o_warecost cost on hz.wareid = cost.wareid
         left join t_ware_class_base wc107
                   on wc107.compid = 1000 and wc107.classgroupno = '107' and wc107.wareid = hz.wareid
         LEFT JOIN t_class_base c107 ON c107.classcode = wc107.classcode
         left join t_ware_class_base wc120
                   on wc120.compid = 1000 and wc120.classgroupno = '120' and wc120.wareid = hz.wareid
         LEFT JOIN t_class_base c120 ON c120.classcode = wc120.classcode;


select ADD_MONTHS(trunc(sysdate)-1, -12)-30 as time,ADD_MONTHS(trunc(sysdate)-1, -12),
       trunc(sysdate)-31, trunc(sysdate)-1
as time1
from dual;
