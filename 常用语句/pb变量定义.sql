
String ls_err,ls_sql[],ls_maxmsgno
str_exec_args lstr_args[]
string ls_flag
date ldt_date

ls_sql[1] = "select stored_flag,sysdate from t_mess_config where t_mess_config.compid =  "+String(gl_compid)+&
  " and (busnos = '%' Or busnos = '全部' Or  instr(',' ||busnos|| ',',',' || "+String($$is_busno)+" || ',') > 0) and rownum = 1"
  
lstr_args[1].DataType = {"string","date"}

If Not gnvo_datasource.of_exec(ls_sql,lstr_args,ls_err) Then
  MessageBox("获取业务机构短信设置出错！",ls_err,stopsign!,ok!,1)
  Return -1
End If

ls_flag = lstr_args[1].ReturnValue[1]
ldt_date = lstr_args[1].ReturnValue[2]
