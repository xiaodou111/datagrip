--dtp������ a1��ȡ�� ������״ι�ҩʱ�����������ֶ�
--���˻�����,����ʽ,�շ��� ��Ҫȥ��ϸ���￴,������״ι�ҩʱ��a2����excel����
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
                         where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
                           and d.SALENO = h.SALENO)
              and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����' and th.PHONE is not null
              and s.BUSNO < 89000),
     a2 as (select POS������, ����ʱ��,  a1.��������,�����ֻ���,
                   rank() over (partition by ��������,�����ֻ��� order by ����ʱ��) as ����ȵڼ��ι�ҩ
            from a1
            where ����ʱ�� >= date'2024-01-01')
 select ��������������, ����������������, ����ҩ�����, ����ҩ������,  ��������,�����ֻ���,�������֤, POS������, ������, ����ʱ��, ��������, ԭ���۵���,
       ���˻�����, ����ʽ, �ܽ��, �շ���, �շ�ʱ��, �տ���, �Ƿ��״ζ���, �ڼ��ι�ҩ,null as ������״ι�ҩʱ��, �ڼ����,
       ��������, �Ƿ�ҽ��, �α���Ա���
from a1  ;
-- select POS������, ����ʱ��, ��������,�����ֻ���, ����ȵڼ��ι�ҩ
-- from a2 where ����ȵڼ��ι�ҩ=1;

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
         left join t_sale_h h on d.SALENO = h.SALENO
         left join s_busi s on h.BUSNO = s.BUSNO
         left join t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
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
             where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
               and d.SALENO = h.SALENO)
  and s.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����'
              and th.PHONE is not null
  and s.BUSNO < 89000;

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
       d.WAREQTY * w.HFTS as �ϴν�����ҩʱ��
from t_sale_d d
         left join t_sale_h h on d.SALENO = h.SALENO
         left join d_rrt_qy_ware qy on d.WAREID = qy.OWAREID
         left join T_SALE_RETURN_H rh on rh.SALENO = d.SALENO
         left join S_USER_BASE su on d.SALER = su.USERID
         left join d_dtp_yysj w on d.WAREID = w.WAREID
         LEFT JOIN t_remote_prescription_h th ON substr(h.notes, 0,
                                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                                               instr(h.notes, ' ')) - 1) = th.cfno
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.RETSALENO = d.SALENO)
  and not exists(select 1 from T_SALE_RETURN_H rh where rh.SALENO = d.SALENO)
  and h.COMPID <> 1900 and th.USERNAME is not null and th.USERNAME <> '����' and th.PHONE is not null
  and h.BUSNO < 89000;



--���߱� �ֶζ�ȡ��һ�Ρ���������������������������������������������������������������������������������������
delete
from d_hz_firstcfno;
insert into d_hz_firstcfno
select trim(th1.USERNAME) as USERNAME, trim(th1.PHONE) as PHONE, min(th1.CFNO) as cfno
from t_remote_prescription_h th1
         join t_remote_prescription_d td on th1.CFNO = td.CFNO
         left join s_busi s on th1.BUSNO = s.BUSNO
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = td.WAREID) and th1.USERNAME is not null
  and th1.USERNAME <> '����' and th1.PHONE is not null and s.COMPID <> 1900 and s.BUSNO < 89000
group by trim(th1.USERNAME), trim(th1.PHONE);


select 'RT' as ��������������, '������' as ����������������, qy.NBUSNO as ����ҩ�����, s.ORGNAME as ����ҩ������,
       th.USERNAME, th.SEX as �Ա�, th.IDCARDNO as ���֤��, th.BIRTHDAY as ����,
       TRUNC(MONTHS_BETWEEN(SYSDATE, birthday) / 12) AS ����, th.PHONE as �ֻ���, th.ADDRESS as ��ַ, th.ZDCONT as ����,
       cyb.���� as ҽ������,nvl(th.EXT_STR6,f.EXT_STR6) as ������Ӧ
from t_remote_prescription_h th
         left join s_busi s on th.BUSNO = s.BUSNO
         left join S_COMPANY sc on s.COMPID = sc.COMPID
         left join D_RRT_QY_COMPID_BUSNO qy on s.BUSNO = qy.OBUSNO
         left join t_sale_h h ON substr(h.notes, 0,
                                        decode(instr(h.notes, ' '), 0, length(h.notes) + 1,
                                               instr(h.notes, ' ')) - 1) = th.cfno
         left join D_ZHYB_HZ_CYB cyb on h.SALENO = cyb.ERP���۵���
         left join  d_sjzl_db_cfxx f on h.saleno=f.saleno
where exists(select 1 from d_hz_firstcfno a1 where a1.cfno = th.cfno);
--���߱� �ֶζ�ȡ��һ�Ρ�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������



 -- ������ҩ���ڱ�  ����������������������������������������������������������������������������������������
--����ÿ��ҩ��һ�ι���Ĵ�����
drop table D_HZ_firstwareCFNO;
create table D_HZ_firstwareCFNO
(
    USERNAME VARCHAR2(200),
    PHONE    VARCHAR2(200),
    wareid   number,
    CFNO     VARCHAR2(40) not null
);

insert into D_HZ_firstwareCFNO
select trim(th1.USERNAME) as USERNAME, trim(th1.PHONE) as PHONE,td.WAREID, min(th1.CFNO) as cfno
from t_remote_prescription_h th1
         join t_remote_prescription_d td on th1.CFNO = td.CFNO
         left join s_busi s on th1.BUSNO = s.BUSNO
where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = td.WAREID) and th1.USERNAME is not null
  and th1.USERNAME <> '����' and th1.PHONE is not null and s.COMPID <> 1900 and s.BUSNO < 89000
group by trim(th1.USERNAME), trim(th1.PHONE),td.WAREID;




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
left join d_luoshi_jm_hf jm on jm.IDCARD=sum.idcardno;

 -- ������ҩ���ڱ�  ������������������������������������������������������������������������������������



--23��֮����Ҫ���ֻ��ŵĴ���
-- select h.CFNO, h.BUSNO, s.ORGNAME, h.USERNAME, d.WAREID, w.WARENAME
-- from t_remote_prescription_h h
--          left join t_remote_prescription_d d on h.CFNO = d.CFNO
--          left join s_busi s on h.BUSNO = s.BUSNO
--          left join t_ware_base w on d.WAREID = w.WAREID
-- where CREATETIME >= date'2023-01-01' and PHONE is null
--   and exists(select 1
--              from t_remote_prescription_d d
--              where exists(select 1 from V_DTP_WARE dtp where dtp.WAREID = d.WAREID)
--                and d.CFNO = h.CFNO);
-- select EXT_STR4 from t_remote_prescription_h ;
-- select * from d_sjzl_db_cfxx;

-- SELECT to_char(a.accdate,'yyyymm') as amonth,a.accdate ,a.saleno,a.wareid,d.warename,d.warespec,e.factoryname,
-- a.saler,su.username as salername,a.wareqty,a.netprice,a.netamt,a.invalidate,th.membercardno,tr.cfno,
-- nvl(tr.ext_str4,f.ext_str4) as ext_str4,nvl(tr.ext_str5,f.ext_str5) as ext_str5,
-- nvl(nvl(th.ext_str1,tr.doctorname),f.cfyy) as cfyy,nvl(tr.DOCTOR,f.doctor) as doctor,nvl(tr.ZDCONT,f.syz) as ZDCONT,
-- nvl(tr.allergy,f.gms) as gms,nvl(tr.ext_str6,f.ext_str6) as ext_str6,
-- nvl(tr.ext_str7,f.ext_str7) as ext_str7,
--  a.accdate+b.hf_day*sum(a.WAREQTY) over ( partition by a.SALENO,a.WAREID)-3  as next_sfday,
-- nvl(tr.USERNAME,f.uname) as USERNAME,nvl(tr.address,f.address) as address,nvl(tr.SEX,f.sex) as sex,nvl(tr.CAGE,f.age) as cage,nvl(tr.PHONE,f.mobile) as phone,
-- nvl(tr.IDCARDNO,f.idcard) as IDCARDNO,a.busno,c.orgname,--tb.classname as syb,tb1.classname as pq,
-- oo.rn,
-- b.hf_day,
--  a.accdate+b.hf_day*sum(a.WAREQTY) over ( partition by a.SALENO,a.WAREID)  as next_day,a.makeno,a.rowno,
-- nvl(tr.lastmodify,f.lastmodify) as lastmodify,nvl(tr.lasttime,f.lasttime) as lasttime,case when  pay.saleno is null then 0 else 1 end as ifyb,nvl(tr.iffugou,f.iffugou) as iffugou,
-- nvl(tr.NOFG_REASON,f.NOFG_REASON) as  NOFG_REASON,tr.syz FROM t_sale_d a
-- inner join t_sale_h th on a.saleno=th.saleno
-- inner join d_sjzl_db_ware b on a.wareid=b.wareid
-- left join s_busi c on a.busno=c.busno
-- left join t_ware_base d on a.wareid=d.wareid
-- left join t_factory e on d.factoryid=e.factoryid
-- left join  t_remote_prescription_h tr ON substr(th.notes,0,decode(instr(th.notes,' '),0,length(th.notes)+1,instr(th.notes,' '))-1)=tr.cfno
-- left join d_sjzl_db_cfxx f on a.saleno=f.saleno
-- left join s_user_base su on a.saler=su.userid
-- left join   t_sale_pay pay on a.saleno=pay.saleno and pay.paytype in('Z064','Z062','Z060','Z061','Z063','Z066','809084','Z089')
-- left join ( SELECT a.cfno,a.createtime,trim(a.username) as kk,row_number() over(partition by trim(a.username) order by a.createtime) as rn FROM t_remote_prescription_h  a
-- inner join t_remote_prescription_d b on a.cfno=b.cfno
-- WHERE  exists (select 1 from d_sjzl_db_ware c WHERE b.wareid=c.wareid) and username is not null and status=4 and trim(username)<>'����' and b.wareqty>0
-- group by a.cfno,a.createtime,trim(a.username) ) oo
-- on  trim(tr.username)=oo.kk and tr.cfno=oo.cfno WHERE a.saleno = '2406101030047339' AND EXISTS (SELECT 1 FROM S_USER_BUSI WHERE S_USER_BUSI.STATUS=1 AND S_USER_BUSI.USERID=50002418 AND S_USER_BUSI.BUSNO=th.busno)
--






