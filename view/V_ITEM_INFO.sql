create view V_ITEM_INFO as
SELECT unit.ITEM_NUM_ID as wareid,unit.CORT_NUM_ID,
 BASIC.ITEM_NAME as WARENAME,BASIC.STYLE_DESC as WARESPEC,BASIC.FACTORY as FACTORYNAME,
 case unit.SUB_PRO_STATUS
     when 1 then '新品'
     when 2 then '正常'
     when 3 then '新品'
     when 4 then '暂缺'
     when 5 then '停采'
     when 6 then '淘汰'
     when 7 then '清场'
     when 8 then '停用'
 end as SUB_PRO_STATUS,
         punit.units_name as WAREUNIT,
 de.POSITIONING_NAME,
 case BASIC.PRESCRIPTION_CLASS
     when 1 then '甲类OTC'
     when 2 then '乙类0TC'
     when 3 then 'DTP'
     when 4 then '双轨处方'
     when 5 then '单轨处方'
     when 6 then '处方'
end as PRESCRIPTION_CLASS,
   case  unit.PARTIAL_PRESCRIPT_CLASS
       when 1 then '甲类OTC'
       when 2 then '甲类OTC'
       when 4 then '双轨处方'
       when 5 then '单轨处方'
   end as PARTIAL_PRESCRIPT_CLASS,
    pty1.PTY1_NAME as big,pty2.PTY2_NAME as middle,pty3.PTY3_NAME as SMALL
FROM mdms_p_product_unit unit
LEFT JOIN MDMS_P_PRODUCT_BASIC BASIC  ON unit.ITEM_NUM_ID=BASIC.ITEM_NUM_ID
inner join mdms_p_units punit on basic.tenant_num_id=punit.tenant_num_id and basic.data_sign=punit.data_sign and basic.basic_unit_num_id=punit.units_num_id
LEFT JOIN mdms_p_catelog_pty1  pty1 on  pty1.PTY1_NUM_ID=BASIC.PTY1_NUM_ID
LEFT JOIN mdms_p_catelog_pty2  pty2 on  pty2.PTY2_NUM_ID=BASIC.PTY2_NUM_ID
LEFT JOIN mdms_p_catelog_pty3  pty3 on  pty3.PTY3_NUM_ID=BASIC.PTY3_NUM_ID
left join (select POSITIONING_NUM_ID,POSITIONING_NAME from mdms_p_positioning group by POSITIONING_NUM_ID, POSITIONING_NAME) de on de.POSITIONING_NUM_ID=unit.sub_pro_description
/

