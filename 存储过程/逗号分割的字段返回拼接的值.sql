CREATE OR REPLACE FUNCTION f_get_sjzl_pjzd(p_kk IN VARCHAR2, p_tablename IN VARCHAR2, p_zdname IN VARCHAR2, p_mbzd IN VARCHAR2)
RETURN VARCHAR2
IS
  input_values VARCHAR2(2000) := p_kk; -- ��ʼ��Ϊ����Ĳ���
  output_value VARCHAR2(2000);
  output_values VARCHAR2(2000) := NULL; -- ��ʼ��Ϊ��
  current_value VARCHAR2(2000);
  delimiter_position NUMBER;
  v_sql VARCHAR2(2000); -- ���ڴ洢��̬SQL���
BEGIN


  -- ʹ��ѭ��������ÿ�����ŷָ���ֵ
  WHILE (INSTR(input_values, ',') > 0) LOOP
    -- ��ȡ��һ�����ŵ�λ��
    delimiter_position := INSTR(input_values, ',');

    -- ��ȡ��ǰֵ
    current_value := SUBSTR(input_values, 1, delimiter_position - 1);
--     DBMS_OUTPUT.PUT_LINE(current_value);

    -- ������̬SQL���
    v_sql := 'SELECT ' || p_mbzd || '
            FROM ' || p_tablename || '
            WHERE ' || p_zdname || ' = '''||current_value||'''';
  EXECUTE IMMEDIATE v_sql
  into output_value;

    -- ����ѯ�����ӵ����ֵ�б���
    output_values := output_values || output_value || ',';

    -- ���������ַ����Դ�����һ��ֵ
    input_values := SUBSTR(input_values, delimiter_position + 1);
  END LOOP;

  -- �������һ��ֵ
  v_sql := 'SELECT ' || p_mbzd || '
            FROM ' || p_tablename || '
            WHERE ' || p_zdname || ' = '''||current_value||'''';
  EXECUTE IMMEDIATE v_sql
  into output_value; -- ע������ʹ��input_values��Ϊcurrent_value

  -- ����ѯ�����ӵ����ֵ�б���
  output_values := output_values || output_value;

  -- ������һ���ַ��Ƕ��ţ����Ƴ���
  IF (SUBSTR(output_values, -1) = ',') THEN
    output_values := SUBSTR(output_values, 1, LENGTH(output_values) - 1);
  END IF;

  RETURN output_values;
END;
/