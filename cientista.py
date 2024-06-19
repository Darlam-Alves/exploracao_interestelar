import cx_Oracle
from common import execute_sql_script

def create_star(connection, cpi_lider, id_estrela, nome, classificacao, massa, x, y, z):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        cientista_script_path = "funcionalidades/cientista.sql"
        execute_sql_script(cientista_script_path, connection)
        plsql_block = f"""
            BEGIN
                criar_estrela('{cpi_lider}', '{id_estrela}', '{nome}', '{classificacao}', '{massa}', '{x}', '{y}', '{z}');
                DBMS_OUTPUT.PUT_LINE('Estrela criada com sucesso.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Erro ao criar estrela: ' || SQLERRM);
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
        print(f"Erro ao criar estrela: {error}")
    finally:
        if cursor:
            cursor.close()
