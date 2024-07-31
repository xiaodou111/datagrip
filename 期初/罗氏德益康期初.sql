--dtp������
with a1 as (select 'RT' as ��������������, '������' as ����������������, qy.NBUSNO as ����ҩ�����,
                   s.ORGNAME as ����ҩ������,
                   th.IDCARDNO as �������֤,  trim(th.USERNAME) as ��������,trim(th.phone) as �����ֻ���, h.SALENO as POS������, null as ������,
                   h.STARTTIME as ����ʱ��,
                   case when rh.RETSALENO is null then 0 else 1 end as ��������,
                   rh.RETSALENO as ԭ���۵���, null as ���˻�����, null as ����ʽ, trunc(h.NETSUM, 2) as �ܽ��,
                   null as �շ���,
                   h.FINALTIME as �շ�ʱ��, trunc(h.NETSUM, 2) as �տ���,
                   case
                       when row_number() over (partition by trim(th.USERNAME),trim(th.phone) order by h.STARTTIME) = 1 then '��'
                       else '��' end as �Ƿ��״ζ���,
                   row_number() over (partition by trim(th.USERNAME),trim(th.phone) order by h.STARTTIME) �ڼ��ι�ҩ,
                   null as ������״ι�ҩʱ��,
--        count(distinct trunc(STARTTIME,'yyyy')) over ( partition by th.IDCARDNO) as  �ڼ����,
                   dense_rank() over (partition by trim(th.USERNAME),trim(th.phone) order by trunc(STARTTIME, 'yyyy')) as �ڼ����,
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
                         where d.WAREID in (10601875,10502445,10600308)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����' and th.PHONE is not null
              and s.BUSNO < 89000),
     a2 as (select POS������, ����ʱ��,  a1.��������,�����ֻ���,
                   rank() over (partition by ��������,�����ֻ��� order by ����ʱ��) as ����ȵڼ��ι�ҩ
            from a1
            where ����ʱ�� >= date'2024-01-01')
 select ��������������, ����������������, ����ҩ�����, ����ҩ������,  a1.��������,a1.�����ֻ���,�������֤,a1.POS������, ������, a1.����ʱ��, ��������, ԭ���۵���,
       ���˻�����, ����ʽ, �ܽ��, �շ���, �շ�ʱ��, �տ���, �Ƿ��״ζ���, �ڼ��ι�ҩ,
       a2.����ȵڼ��ι�ҩ,
--        null as ������״ι�ҩʱ��,
       �ڼ����,
       ��������, �Ƿ�ҽ��, �α���Ա���
from a1 left join a2 on a1.��������=a2.�������� and a1.POS������=a2.POS������ ;
--������ϸ��
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
         left join t_sale_h h on d.SALENO = h.SALENO
         left join s_busi s on h.BUSNO = s.BUSNO
         left join t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where d.WAREID in (10601875,10502445,10600308)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����' and th.PHONE is not null
  and s.BUSNO < 89000;
--������
select h.SALENO, th.CFNO, null as ����ǩ��, th.DOCTORNAME as ҽԺ����, null as ����, DOCTOR as ҽ������,
       th.DOCTORTIME as ����ʱ��,
       th.ZDCONT as ����, CHECKER_YISHI as ���ҽʦ, th.CHECKTIME_YISHI as ҽʦ���ʱ��, CHECKER_YAOSHI as ���ҩʦ,
       th.CHECKTIME_YAOSHI as ҩʦ���ʱ��, DEPLOYER as ������, null as ����ʱ��, th.CHECKUSER as ������,
       null as ����ʱ��,
       th.CREATETIME as ����ʱ��
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
             where d.WAREID in (10601875,10502445,10600308)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
              and th.PHONE is not null
  and s.BUSNO < 89000
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
             where d.WAREID in (10601875,10502445,10600308)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����' and th.PHONE is not null
  and s.BUSNO < 89000;

--������ҩ��ϸ��,�÷�������phcƥ��
select d.SALENO as POS������, qy.NWAREID as ��̨ҩƷ����, d.WAREQTY as ��Ʒ����, trim(th.USERNAME) as ��������,
       trim(th.PHONE) as �����ֻ���, null as �÷�����,
       w.HFTS as ��ҩ����,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) AS ��ʼ��ҩʱ��,
       min(h.ACCDATE) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID ) + d.WAREQTY * w.HFTS as ������ҩʱ��,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) AS �ϴο�ʼ��ҩʱ��,
       LAG(h.ACCDATE, 1) OVER (PARTITION BY th.USERNAME,th.PHONE,qy.NWAREID order by h.ACCDATE) +
       d.WAREQTY * w.HFTS as �ϴν�����ҩʱ��,th.CFNO as POS��������
from t_sale_d d
         left join t_sale_h h on d.SALENO = h.SALENO
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
         left join d_dtp_yysj w on d.WAREID = w.WAREID
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where d.WAREID in (10601875,10502445,10600308)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = d.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO = d.SALENO)
  and h.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����' and th.PHONE is not null
  and h.BUSNO < 89000;

--������ҩ���ڱ�
with first as (
select th.cfno as �״δ�����, trim(th.USERNAME) as ��������,th.IDCARDNO,
       trim(th.PHONE) as �����ֻ���,qy.NBUSNO as ��̨�ŵ����,td.WAREID, h.ACCDATE as �״ι�ҩʱ��, th.DOCTORNAME as �״δ���ҽԺ,
       null as �״δ�������, th.DOCTOR as �״�ҽ��, th.CREATETIME as ����ʱ��
from t_remote_prescription_h th
-- left join t_remote_prescription_d td on th.CFNO = td.CFNO
         left join s_busi s on th.BUSNO = s.BUSNO
         left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
-- left join d_rrt_qy_ware qyw  on qyw.owareid=td.wareid
         left join t_sale_h h ON substr(h.notes, 0,
                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                               instr(h.notes, ' ')) - 1) = th.cfno
         join t_remote_prescription_d td on th.CFNO = td.CFNO
where exists(select 1 from D_HZ_firstwareCFNO a1 where a1.cfno = th.cfno)),
-- and td.WAREID in (10601875,10502445,10600308)),
--USERNAME,PHONE,NWAREID �ۼƹ�ҩ����	�ۼƹ�ҩ���
sum as (   select
    trim(th.USERNAME) as ��������,
       trim(th.PHONE) as �����ֻ���,
       td.WAREID,
       sum(td.WAREQTY) as �ۼƹ�ҩ����,
       sum(td.NETPRICE*td.WAREQTY)  as �ۼƹ�ҩ���,
       nvl(max(th.EXT_STR4),max(f.EXT_STR4)) as δ���ƻ�ԭ��,
       max(th.IDCARDNO) as idcardno
from t_remote_prescription_d td

         LEFT JOIN t_remote_prescription_h th ON td.CFNO = th.cfno
         left join t_sale_h h ON substr(h.notes, 0,
                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                               instr(h.notes, ' ')) - 1) = th.cfno
         left join d_sjzl_db_cfxx f on h.saleno=f.saleno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = td.WAREID)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = h.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh2 where rh2.SALENO = h.SALENO)
  and th.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
  and th.BUSNO < 89000 group by trim(th.USERNAME),trim(th.PHONE),td.WAREID )
select �״δ�����, first.�������� as ��������, sum.IDCARDNO as ���֤, first.�����ֻ��� as �����ֻ���, ��̨�ŵ���� ,qy.NWAREID as ��̨ҩƷ����,�״ι�ҩʱ��,
       �ۼƹ�ҩ����,�ۼƹ�ҩ���,null as ������ҩ״̬,NVL(NVL(px.CFSF, jm.CFSF), δ���ƻ�ԭ��) as δ���ƻ�ԭ��,
       �״δ���ҽԺ, �״δ�������, �״�ҽ��, ����ʱ��
from first
left join sum on first.��������=sum.�������� and first.�����ֻ���=sum.�����ֻ��� and first.WAREID=sum.WAREID
left join d_rrt_qy_ware qy on first.WAREID = qy.OWAREID
left join d_luoshi_px_hf px on px.IDCARD= sum.idcardno
left join d_luoshi_jm_hf jm on jm.IDCARD=sum.idcardno
where qy.OWAREID in (10601875,10502445,10600308);

 -- ������ҩ���ڱ�  ������������������������������������������������������������������������������������

select * from d_rrt_qy_ware where OWAREID in (10601875,10502445,10600308);
select * from T_REMOTE_PRESCRIPTION_d where CFNO='240118112402026';