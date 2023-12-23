select o2o.busno,s.orgname,d.pzs_kc,kl.lks,c1.photo_no as 药品经营许可证,c1.begindate as 药品经营许可证起始日期,c1.invalidate as 药品经营许可证到期时间 ,c2.photo_no as 营业执照,c2.begindate as 营业执照起始日期，c2.invalidate as 营业执照到期时间,
c3.photo_no as 食品经营许可证,c3.begindate as 食品经营许可证起始日期,c3.invalidate as 食品经营许可证到期时间,c4.photo_no as 二类医疗器械经营备案凭证,c4.begindate as 二类器械经营凭证起始日期 ,c4.invalidate as 二类医疗器械凭证到期时间,
c5.photo_no as 医疗器械经营许可证,	c5.begindate as 医疗器械经营许可证起始日期,
c5.invalidate as 医疗器械经营许可证到期时间 ,o2o.mt,o2o.elm,o2o.jddj,o2o.pajk,o2o.txd,o2o.xcx
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
