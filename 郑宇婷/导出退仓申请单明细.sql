SELECT (t_distapply_d.applyno) AS applyno,
       (t_distapply_d.wareid) AS wareid,
       
       (t_distapply_d.checkqty) AS checkqty,
       (v_ware_base.warecode) AS warecode,
       (v_ware_base.warename) AS warename,
       (t_distapply_d.batid) AS 批次号,
       (t_distapply_d.makeno) AS 生产批号,
  
       (t_distapply_d.invalidate) AS invalidate

 FROM t_distapply_d
  JOIN t_distapply_h
    ON t_distapply_d.applyno = t_distapply_h.applyno
  LEFT JOIN t_ware v_ware_base
    ON t_distapply_d.wareid = v_ware_base.wareid
   AND t_distapply_h.compid = v_ware_base.compid
  LEFT JOIN t_store_i sti
    ON t_distapply_d.wareid = sti.wareid
   AND t_distapply_d.batid = sti.batid WHERE t_distapply_d.applyno in('231111138042','231111085839','231111108519','231114041743','231114064929',
   '231111152145','231111179929','231111181429','231111168613','231111142609')
   





   
   
