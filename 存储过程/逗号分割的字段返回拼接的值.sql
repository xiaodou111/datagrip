CREATE OR REPLACE FUNCTION f_get_sjzl_pjzd(p_kk IN VARCHAR2, p_tablename IN VARCHAR2, p_zdname IN VARCHAR2, p_mbzd IN VARCHAR2)
RETURN VARCHAR2
IS
  input_values VARCHAR2(2000) := p_kk; -- 初始化为传入的参数
  output_value VARCHAR2(2000);
  output_values VARCHAR2(2000) := NULL; -- 初始化为空
  current_value VARCHAR2(2000);
  delimiter_position NUMBER;
  v_sql VARCHAR2(2000); -- 用于存储动态SQL语句
BEGIN


  -- 使用循环来处理每个逗号分隔的值
  WHILE (INSTR(input_values, ',') > 0) LOOP
    -- 获取下一个逗号的位置
    delimiter_position := INSTR(input_values, ',');

    -- 提取当前值
    current_value := SUBSTR(input_values, 1, delimiter_position - 1);
--     DBMS_OUTPUT.PUT_LINE(current_value);

    -- 构建动态SQL语句
    v_sql := 'SELECT ' || p_mbzd || '
            FROM ' || p_tablename || '
            WHERE ' || p_zdname || ' = '''||current_value||'''';
  EXECUTE IMMEDIATE v_sql
  into output_value;

    -- 将查询结果添加到输出值列表中
    output_values := output_values || output_value || ',';

    -- 更新输入字符串以处理下一个值
    input_values := SUBSTR(input_values, delimiter_position + 1);
  END LOOP;

  -- 处理最后一个值
  v_sql := 'SELECT ' || p_mbzd || '
            FROM ' || p_tablename || '
            WHERE ' || p_zdname || ' = '''||current_value||'''';
  EXECUTE IMMEDIATE v_sql
  into output_value; -- 注意这里使用input_values作为current_value

  -- 将查询结果添加到输出值列表中
  output_values := output_values || output_value;

  -- 如果最后一个字符是逗号，则移除它
  IF (SUBSTR(output_values, -1) = ',') THEN
    output_values := SUBSTR(output_values, 1, LENGTH(output_values) - 1);
  END IF;

  RETURN output_values;
END;
/