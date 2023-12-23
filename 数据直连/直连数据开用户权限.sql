CREATE VIEW v_accept_nh_86235
AS 
SELECT * from v_accept_nh_86235@hydee_zy
;


create or replace trigger tr_t_sjzl_wh
before insert or update of cgy on t_sjzl_wh
for each row
  begin
    if :new.sfyw=1 then

    :new.watch_user:='10013898,10003937,50002418'|| :new.cgy ;  ----我.杨仁.莫小慧

    else
       :new.watch_user:='10013898,10002456,50002418'|| :new.cgy ;  ----我.杨仁.莫小慧
    end if ;
  end ;



SELECT * from t_sjzl_wh
UPDATE t_sjzl_wh SET WATCH_USER=WATCH_USER||',50002418'
