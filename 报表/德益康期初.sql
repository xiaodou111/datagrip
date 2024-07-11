--dtp������ a1��ȡ�� ������״ι�ҩʱ�����������ֶ�
with a1 as (select qy.NCOMPID, sc.COMPNAME, qy.NBUSNO as ����ҩ�����, s.ORGNAME as ����ҩ������,
                   th.IDCARDNO as �������֤, th.USERNAME as ��������, h.SALENO as POS������, null as ������,
                   h.STARTTIME as ����ʱ��,
                   case when rh.RETSALENO is null then 0 else 1 end as ��������,
                   rh.RETSALENO as ԭ���۵���, null as ���˻�����, null as ����ʽ, trunc(h.NETSUM, 2) as �ܽ��,
                   null as �շ���,
                   h.FINALTIME as �շ�ʱ��, trunc(h.NETSUM, 2) as �տ���,
                   case
                       when row_number() over (partition by th.IDCARDNO order by h.STARTTIME) = 1 then '��'
                       else '��' end as �Ƿ��״ζ���,
                   row_number() over (partition by th.IDCARDNO order by h.STARTTIME) �ڼ��ι�ҩ,
                   null as ������״ι�ҩʱ��,
--        count(distinct trunc(STARTTIME,'yyyy')) over ( partition by th.IDCARDNO) as  �ڼ����,
                   dense_rank() over (partition by th.IDCARDNO order by trunc(STARTTIME, 'yyyy')) as �ڼ����,
                   count(th.IDCARDNO) over (partition by th.IDCARDNO) as ��������,
                   case when cyb.ERP���۵��� is null then '��' else '��' end as �Ƿ�ҽ��,
                   cyb.�α���Ա���
            from t_sale_h h
                     left join s_busi s on h.BUSNO = s.BUSNO
                     left join S_COMPANY sc on s.COMPID = sc.COMPID
                     left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
                     LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                                    decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                                           instr(h.notes, ' ')) - 1) = th.cfno
                     left join T_SALE_RETURN_H rh on rh.SALENO = h.SALENO
                     left join D_ZHYB_HZ_CYB cyb on h.SALENO = cyb.ERP���۵���
            where exists(select 1
                         from t_sale_d d
                         where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
              and s.BUSNO < 89000),
     a2 as (select POS������, ����ʱ��, a1.�������֤, a1.��������,
                   rank() over (partition by �������֤ order by ����ʱ��) rank

            from a1
            where ����ʱ�� >= date'2024-01-01')
-- select NCOMPID, COMPNAME, ����ҩ�����, ����ҩ������, �������֤, ��������, POS������, ������, ����ʱ��, ��������, ԭ���۵���,
--        ���˻�����, ����ʽ, �ܽ��, �շ���, �շ�ʱ��, �տ���, �Ƿ��״ζ���, �ڼ��ι�ҩ,null as ������״ι�ҩʱ��, �ڼ����,
--        ��������, �Ƿ�ҽ��, �α���Ա���
-- from a1;
select POS������, ����ʱ��, �������֤, ��������, rank
from a2;

--��ϸ��
select d.SALENO as POS������, qy.NWAREID as ��̨ҩƷ����,
       round(((d.wareqty + (CASE
                                WHEN d.stdtomin = 0 THEN
                                    0
                                ELSE
                                    d.minqty / d.stdtomin
           END)) * d.times), 2) as ����, d.STDPRICE as ����, d.NETPRICE as �ۺ󵥼�,
       d.NETAMT as �ۺ��ܼ�,
       null as ����ID, d.MAKENO as ����, d.INVALIDATE as Ч��, d.BATID as ����ID,
       case when rh.RETSALENO is null then 0 else 1 end as ��������,
       case
           when rh.SALENO is not null then round(((d.wareqty + (CASE
                                                                    WHEN d.stdtomin = 0 THEN
                                                                        0
                                                                    ELSE
                                                                        d.minqty / d.stdtomin
               END)) * d.times), 2)
           else null end as �˻�����, d.SALER as ����Ա����,
       su.USERNAME as ����Ա����
from t_sale_d d
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID);

--�����շѱ�
select h.SALENO as POS������, s_dddw_list.DDDWLISTDISPLAY as �շѷ�ʽ, pay.NETSUM as �շѽ��
from t_sale_h h
         left join s_busi s on h.BUSNO = s.BUSNO
         left join S_COMPANY sc on s.COMPID = sc.COMPID
         left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
         left join T_SALE_RETURN_H rh on rh.SALENO = h.SALENO
         left join t_sale_pay pay on h.SALENO = pay.SALENO
--          left join s_dddw_list on pay.PAYTYPE = s_dddw_list.dddwlistdata and s_dddw_list.dddwliststatus = 1 AND
--                                   s_dddw_list.dddwname = '222'
          left join (select dddwlistdata, DDDWLISTDISPLAY
                    from s_dddw_list
                    where dddwname = '222'
                    group by dddwlistdata, DDDWLISTDISPLAY) s_dddw_list on pay.PAYTYPE = s_dddw_list.dddwlistdata
where exists(select 1
             from t_sale_d d
             where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
  and s.BUSNO < 89000;


--������ҩ��ϸ��
select d.SALENO as POS������, qy.NWAREID as ��̨ҩƷ����, d.WAREQTY as ��Ʒ����, th.USERNAME as ��������,
       th.PHONE as �����ֻ���,
       w.HF_DAY as ��ҩ����,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) AS ��ʼ��ҩʱ��,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) + d.WAREQTY * w.HF_DAY as ������ҩʱ��,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) AS �ϴο�ʼ��ҩʱ��,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) +
       d.WAREQTY * w.HF_DAY as �ϴν�����ҩʱ��
from t_sale_d d
         left join t_sale_h h on d.SALENO = h.SALENO
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
         left join D_SJZL_DB_WARE w on d.WAREID = w.WAREID
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = d.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO = d.SALENO)
and h.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
              and h.BUSNO < 89000;


--������
select qy.NCOMPID, sc.COMPNAME, qy.NBUSNO as ����ҩ�����, s.ORGNAME as ����ҩ������,
                   th.IDCARDNO as �������֤, th.USERNAME as ��������, h.SALENO as POS������, null as ������,
                   h.STARTTIME as ����ʱ��,
                   case when rh.RETSALENO is null then 0 else 1 end as ��������,
                   rh.RETSALENO as ԭ���۵���, null as ���˻�����, null as ����ʽ, trunc(h.NETSUM, 2) as �ܽ��,
                   null as �շ���,
                   h.FINALTIME as �շ�ʱ��, trunc(h.NETSUM, 2) as �տ���,
                   case
                       when row_number() over (partition by th.IDCARDNO order by h.STARTTIME) = 1 then '��'
                       else '��' end as �Ƿ��״ζ���,
                   row_number() over (partition by th.IDCARDNO order by h.STARTTIME) �ڼ��ι�ҩ,
                   null as ������״ι�ҩʱ��,
--        count(distinct trunc(STARTTIME,'yyyy')) over ( partition by th.IDCARDNO) as  �ڼ����,
                   dense_rank() over (partition by th.IDCARDNO order by trunc(STARTTIME, 'yyyy')) as �ڼ����,
                   count(th.IDCARDNO) over (partition by th.IDCARDNO) as ��������,
                   case when cyb.ERP���۵��� is null then '��' else '��' end as �Ƿ�ҽ��,
                   cyb.�α���Ա���
            from t_sale_h h
                     left join s_busi s on h.BUSNO = s.BUSNO
                     left join S_COMPANY sc on s.COMPID = sc.COMPID
                     left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
                     LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                                    decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                                           instr(h.notes, ' ')) - 1) = th.cfno
                     left join T_SALE_RETURN_H rh on rh.SALENO = h.SALENO
                     left join D_ZHYB_HZ_CYB cyb on h.SALENO = cyb.ERP���۵���
            where exists(select 1
                         from t_sale_d d
                         where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
              and s.BUSNO < 89000







