import cx_Oracle
from common import execute_sql_script

def execute_comandante_report(connection, p_cpi_lider):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        plsql_block = f"""
        DECLARE
            v_cpi_lider LIDER.CPI%TYPE := '{p_cpi_lider}';
        BEGIN
            gerar_relatorio(v_cpi_lider);
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
        print(f"Erro ao executar a procedure de comandante: {error}")
    finally:
        if cursor:
            cursor.close()

def insert_dominancia(connection, planeta, nacao, data_ini, data_fim):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        oficial_script_path = "funcionalidades/comandante.sql"
        execute_sql_script(oficial_script_path, connection)
        plsql_block = f"""
            BEGIN
                INSERT_DOMINANCIA('{planeta}', '{nacao}', TO_DATE('{data_ini}', 'DD/MM/YYYY'), TO_DATE('{data_fim}', 'DD/MM/YYYY'));
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
        print(f"Erro ao inserir dominância: {error}")
    finally:
        if cursor:
            cursor.close()
