alter table t_zdcllwh_import drop primary key 
alter table t_zdcllwh_import rename column compid to compid_tmp;
alter table t_zdcllwh_import add compid varchar2(40);
update t_zdcllwh_import set compid=trim(compid_tmp);
alter table t_zdcllwh_import drop column compid_tmp;
alter table t_zdcllwh_import add constraint pk_zdcllwh_import primary key(compid,wareid);
