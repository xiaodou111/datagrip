 SELECT
        saleno,
        ACCDATE,
        FINALTIME,
        BUSNO,
        zdate,
        srcbusno,
        WAREID,
        makeno,
        SALER,
        STDPRICE,
        NETPRICE,
        卖出数量,
        调入数量,
        SUM(卖出数量) OVER (PARTITION BY zdate, srcbusno, busno, wareid, makeno ORDER BY rn) AS total_sales,
        rn
      FROM (
 SELECT
          h.saleno,
          h.accdate,
          FINALTIME,
          h.busno,
          dr.zdate,
          dr.srcbusno,
          d.wareid,
          d.makeno,
          d.saler,
          d.STDPRICE,
          d.netprice,
          d.wareqty 卖出数量,
          dr.wareqty 调入数量,
          row_number() OVER(partition BY dr.zdate, dr.srcbusno, h.busno, d.wareid, dr.makeno ORDER BY h.FINALTIME) rn
        FROM t_sale_d d
        JOIN t_sale_h h ON h.saleno = d.saleno AND h.accdate=d.accdate
        JOIN d_zddb_xqsp_dr dr ON dr.objbusno = d.busno AND d.makeno = dr.makeno AND d.wareid = dr.wareid
        WHERE h.accdate > dr.zdate
         
          AND h.accdate >= DATE'2023-04-01' AND h.accdate<DATE'2023-06-01'
          AND dr.objbusno=81179 AND dr.wareid=10114358 AND srcbusno=81059）
