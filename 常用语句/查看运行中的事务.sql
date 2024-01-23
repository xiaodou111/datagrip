select b.sid,b.serial#,b.machine,b.status,b.event,b.program,a.start_date, a.start_scn, a.status, c.sql_id,c.sql_text
    from v$transaction a, v$session b, v$sqlarea c
    where b.saddr=a.ses_addr and c.address=b.sql_address
    and b.sql_hash_value=c.hash_value;
alter system kill session '2283,52489';
SELECT * from v_who

