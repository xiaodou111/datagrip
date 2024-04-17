CREATE OR REPLACE TRIGGER trg_delete_notzs
AFTER DELETE ON d_zhyb_year_2022_notzs
FOR EACH ROW
     begin
INSERT INTO d_notzs_hfjl (EXECDATE, CUSTOMER, IDCARD, CBDID, BUSNO, SALENO, TYPE, HFRY, accdate)
VALUES (:OLD.EXECDATE, :OLD.CUSTOMER, :OLD.IDCARD, :OLD.CBDID, :OLD.BUSNO, :OLD.SALENO, :OLD.TYPE,:OLD.HFRY,TRUNC(SYSDATE) - 1);
end;

CREATE OR REPLACE TRIGGER trg_delete_notyd
AFTER DELETE ON d_zhyb_year_2022_notyd
FOR EACH ROW
    begin
INSERT INTO d_notyd_hfjl (EXECDATE, CUSTOMER, IDCARD, CBDID, BUSNO, SALENO, TYPE, HFRY, accdate)
VALUES (:OLD.EXECDATE, :OLD.CUSTOMER, :OLD.IDCARD, :OLD.CBDID, :OLD.BUSNO, :OLD.SALENO, :OLD.TYPE,OLD.HFRY, TRUNC(SYSDATE) - 1);
   end;