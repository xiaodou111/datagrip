
create table d_tzld_zb
(
  period         CHAR(6) not null,
  busno          NUMBER(10) not null,
  zb NUMBER(16,4)
)
create table d_tzld_zb_temp
(
  period         CHAR(6) not null,
  busno          NUMBER(10) not null,
  zb NUMBER(16,4)
)

CREATE OR REPLACE PROCEDURE proc_tzld_import IS

    v_conde PLS_INTEGER;
    --v_wareid t_ware.wareid%TYPE;

BEGIN


    BEGIN
        SELECT COUNT(*) INTO v_conde FROM  d_tzld_zb_temp b;
       IF v_conde = 0 THEN
            raise_application_error(-20001, '提示，导入数据获取失败！请重新导入！', TRUE);
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20001, '提示，导入数据获取失败！请重新导入！', TRUE);
    END;

    MERGE INTO  d_tzld_zb a
    USING (SELECT b.PERIOD,b.BUSNO,b.ZB
           FROM  d_tzld_zb_temp b
           ) b
    ON (a.PERIOD = b.PERIOD and a.busno=b.BUSNO )
    WHEN MATCHED THEN
        UPDATE SET a.ZB=b.ZB
    WHEN NOT MATCHED THEN
        INSERT
            (PERIOD,BUSNO,ZB)
        VALUES
            (b.PERIOD,b.BUSNO,b.ZB);

    COMMIT;
END proc_tzld_import;

select period, 
busno, 
zb
from d_tzld_zb
alter table d_tzld_zb
add constraint d_tzld_zb_pk primary key (PERIOD, BUSNO)
