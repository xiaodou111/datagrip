declare   
p_userid1 s_user_func.userid%TYPE:=10005716;
p_userid2  s_user_func.userid%TYPE:=10001148;
p_compid  s_user_func.compid%TYPE:=3370;

begin
DELETE FROM s_user_func
     WHERE userid = p_userid1
       and compid = p_compid;  
INSERT INTO s_user_func
      (userid,
       isenabled,
       isadd,
       isdel,
       ismodify,
       isreset,
       isdesign,
       isquery,
       isprint,
       issaveas,
       ischeck1,
       ischeck2,
       ischeck3,
       ischeck4,
       ischeck5,
       modobjname,
       compid)
      SELECT p_userid1,
             e.isenabled,
             e.isadd,
             e.isdel,
             e.ismodify,
             e.isreset,
             e.isdesign,
             e.isquery,
             e.isprint,
             e.issaveas,
             e.ischeck1,
             e.ischeck2,
             e.ischeck3,
             e.ischeck4,
             e.ischeck5,
             e.modobjname,
             p_compid
        FROM s_user_func e
       WHERE e.userid = p_userid2
         and e.compid = 1000;
 for rec in (select inicode, compid
                  from s_sys_ini_user
                 where compid = p_compid) loop
      delete from s_sys_ini_user
       where inicode = rec.inicode
         and userid = p_userid1
         and compid = p_compid;
      insert into s_sys_ini_user
        (compid, inicode, userid, inipara, stamp, lastmodify, lasttime)
        select compid,
               inicode,
               p_userid1,
               inipara,
               stamp,
               lastmodify,
               sysdate
          from s_sys_ini_user
         where inicode = rec.inicode
           and userid = p_userid2
           and compid = p_compid;
    end loop;
end ;

/*select * from s_user_func
WHERE userid = 10005716
       and compid = 3370; */
