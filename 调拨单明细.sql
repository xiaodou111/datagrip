SELECT b.srcbusno as �����ŵ�,b.objbusno as �����ŵ�,a.wareid as ��Ʒ����,
                        a.wareqty as ��Ʒ����,c.sap_batid as sap���� 
                         FROM   t_dist_d a 
                        inner join t_dist_h b on a.distno=b.distno
                        left join t_store_i c on a.wareid=c.wareid and a.batid=c.batid
                        WHERE a.distno='23040300003312'
                        
                        
