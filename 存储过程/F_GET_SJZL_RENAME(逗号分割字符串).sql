create function f_get_sjzl_rename (f_kk in varchar2)
return varchar2
is
       f_oo varchar2(200):=null;
       v_cnt pls_integer ;
       v_kk varchar2(200);
       f_oo2 varchar2(200):=NULL;
       begin
         v_kk:=f_kk;
         while(instr(v_kk,',')>0) loop
             f_oo :=''''|| substr(v_kk,0,instr(v_kk,',')-1) || ''''||','; -- --'10101010',
             v_kk:=substr(v_kk,instr(v_kk,',')+1,length(v_kk)); --'20202020,30303030,456125411'
             f_oo2 :=f_oo2 || f_oo;
             end loop;
             f_oo2:=f_oo2||''''|| v_kk || '''';

         return f_oo2 ;

        end ;
/

