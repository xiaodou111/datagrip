
     
     select a.wareid,a.warename,b1.classcode,c1.classname from t_ware_base a
     LEFT JOIN t_ware_class_base b1 ON a.wareid=b1.wareid AND b1.classgroupno=119 AND b1.compid=1000 
LEFT JOIN t_class_base c1 ON b1.classcode=c1.classcode 
where  b1.classcode between '119101' and '119126' order by a.wareid
