import cx_Oracle
from common import execute_sql_script

def execute_oficial_report(connection, p_cpi_lider, data_inicio, data_fim):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        oficial_script_path = "relatorios/relatorio_oficial_faccao.sql"
        execute_sql_script(oficial_script_path, connection)
        plsql_block = f"""
            DECLARE
                v_cpi_lider LIDER.CPI%TYPE := '{p_cpi_lider}';
                v_data_inicio DATE := TO_DATE('{data_inicio}', 'DD/MM/YYYY');
                v_data_fim DATE := TO_DATE('{data_fim}', 'DD/MM/YYYY');
            BEGIN
                RELATORIO_OFICIAL_FACCAO(v_cpi_lider, v_data_inicio, v_data_fim);
            END;
        """
        cursor.execute(plsql_block)
        status_var = cursor.var(cx_Oracle.NUMBER)
        line_var = cursor.var(cx_Oracle.STRING)
        while True:
            cursor.callproc("DBMS_OUTPUT.GET_LINE", (line_var, status_var))
            if status_var.getvalue() != 0:
                break
            if line_var.getvalue():
                print(line_var.getvalue())
        connection.commit()
    except cx_Oracle.Error as error:
        print(f"Erro ao executar a procedure de oficial: {error}")
    finally:
        if cursor:
            cursor.close()
