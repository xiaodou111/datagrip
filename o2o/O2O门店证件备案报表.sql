select o2o.busno,s.orgname,d.pzs_kc,kl.lks,c1.photo_no as ҩƷ��Ӫ���֤,c1.begindate as ҩƷ��Ӫ���֤��ʼ����,c1.invalidate as ҩƷ��Ӫ���֤����ʱ�� ,c2.photo_no as Ӫҵִ��,c2.begindate as Ӫҵִ����ʼ���ڣ�c2.invalidate as Ӫҵִ�յ���ʱ��,
c3.photo_no as ʳƷ��Ӫ���֤,c3.begindate as ʳƷ��Ӫ���֤��ʼ����,c3.invalidate as ʳƷ��Ӫ���֤����ʱ��,c4.photo_no as ����ҽ����е��Ӫ����ƾ֤,c4.begindate as ������е��Ӫƾ֤��ʼ���� ,c4.invalidate as ����ҽ����еƾ֤����ʱ��,
c5.photo_no as ҽ����е��Ӫ���֤,	c5.begindate as ҽ����е��Ӫ���֤��ʼ����,
c5.invalidate as ҽ����е��Ӫ���֤����ʱ�� ,o2o.mt,o2o.elm,o2o.jddj,o2o.pajk,o2o.txd,o2o.xcx
from d_o2o_mdzj o2o
left join  s_busi s on o2o.busno=s.busno
join D_O2O_DX_TJ d on s.busno=d.busno 
join (select busno,sum(lks) as lks from  d_busi_saler_tj where 
 accdate between trunc(ADD_MONTHS(SYSDATE,-1)) and trunc(sysdate)
 group by busno)kl on s.busno=kl.busno
left join S_BUSI_CERT_TEMP c1 on s.busno=c1.busno and c1.CERTIFICATEID=115
left join S_BUSI_CERT_TEMP c2 on s.busno=c2.busno and c2.CERTIFICATEID=100
left join S_BUSI_CERT_TEMP c3 on s.busno=c3.busno and c3.CERTIFICATEID=110
left join S_BUSI_CERT_TEMP c4 on s.busno=c4.busno and c4.CERTIFICATEID=118
left join S_BUSI_CERT_TEMP c5 on s.busno=c5.busno and c5.CERTIFICATEID=113
--left join s_busi_certificate c5 on s.busno=c5.busno and c5.CERTIFICATEID=113
