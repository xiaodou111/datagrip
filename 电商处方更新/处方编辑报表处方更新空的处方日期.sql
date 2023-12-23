SELECT t_remote_prescription_h.cfno,
       DOCTORTIME
       
 
 FROM t_remote_prescription_h t_remote_prescription_h
 WHERE cfno=21030508700284
 delete from 
 --处方编辑报表处方更新空的处方日期
update t_remote_prescription_h set DOCTORTIME=TO_DATE(SUBSTR(cfno, 1, 6), 'YYMMDD') where DOCTORTIME is null
--电商处方编辑报表处方更新空的处方日期
update d_oms_sgcf_h set DOCTORTIME=TO_DATE(SUBSTR(cfno, 1, 6), 'YYMMDD') where DOCTORTIME is null


update t_remote_prescription_h set DOCTORTIME=null where cfno='21030508700284';

select TO_DATE(SUBSTR(cfno, 1, 6), 'YYMMDD') from t_remote_prescription_h where cfno='21030508700284';
select * from t_remote_prescription_h where DOCTORTIME is null;


select TO_DATE(SUBSTR(cfno, 1, 6), 'YYMMDD'),cfno,DOCTORTIME
from t_remote_prescription_h WHERE t_remote_prescription_h.cftype > 0 AND nvl(t_remote_prescription_h.saleno,'1')<>'2210211282081588'
                               AND compid=1000 AND t_remote_prescription_h.busno in (SELECT busno FROM v_user_busi
                                                                                                  WHERE compid =1000 AND userid =50002418
                                                                                                    and status = 1) AND (status = 1 or status = 4)
                               and (  t_remote_prescription_h.createtime >= to_date('2023-12-13', 'yyyy-MM-dd')
                                          and t_remote_prescription_h.createtime < to_date('2023-12-18', 'yyyy-MM-dd')
                                          and  t_remote_prescription_h.cfno = '2312151059003778'  );
