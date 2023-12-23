SELECT t_ware_class_base.wareid AS wareid,
       t_ware_class_base.classgroupno AS classgroupno,
       t_classgroup.classname AS groupname,
       tc.isnullable AS isnullable,
       t_ware_class_base.classcode AS classcode,
       case
         when t_ware_class_base.PARENT_CLASSCODE = 'Î´»®·Ö;' then
          ''
         else
          replace(substr(t_ware_class_base.PARENT_CLASSCODE,
                         2,
                         length(t_ware_class_base.PARENT_CLASSCODE) - 2),
                  ';',
                  ' - ')
       end as classname,
       t_classgroup.levels
 
       t_ware_class_base.compid
 FROM t_ware_class_base t_ware_class_base
  LEFT JOIN t_class_base t_classgroup
    ON t_ware_class_base.classgroupno = t_classgroup.classcode
  LEFT JOIN t_class tc
    ON t_classgroup.classcode = tc.classcode
   AND tc.status = 1
 WHERE t_ware_class_base.compid = (CASE
         WHEN EXISTS (SELECT 1
                 FROM t_ware_class_base twcb
                WHERE twcb.compid = tc.compid
                  AND twcb.wareid = t_ware_class_base.wareid
            AND twcb.classgroupno = t_ware_class_base.classgroupno ) THEN
          tc.compid
         ELSE
          0
       END) AND tc.compid=0  and wareid>=30000000
