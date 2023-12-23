SELECT b.srcbusno as 调出门店,b.objbusno as 调入门店,a.wareid as 商品编码,
                        a.wareqty as 商品数量,c.sap_batid as sap批次 
                         FROM   t_dist_d a 
                        inner join t_dist_h b on a.distno=b.distno
                        left join t_store_i c on a.wareid=c.wareid and a.batid=c.batid
                        WHERE a.distno='23040300003312'
                        
                        
