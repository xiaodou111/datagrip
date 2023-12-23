SELECT * from hd_out_distapply_rap_h WHERE msg_id='10100000000156670426' --10100000000156651317 10100000000156675983 10100000000156685380 10100000000156738998
SELECT * from hd_out_distapply_rap_d WHERE msg_id='10100000000156670426' applyqty=0 

SELECT * from hd_msg_out WHERE msg_id='10100000000156670426'
SELECT * FROM t_distapply_d WHERE  applyno='2211270078251'
SELECT * from t_distapply_h WHERE   applyno='2211270078251'

SELECT srcbusno,wareid,batid,max(zzthsl) from d_zxkt_import 
group by srcbusno,wareid,batid HAVING max(zzthsl)=0
