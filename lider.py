import cx_Oracle
from common import execute_sql_script


def alterar_nome_faccao(connection, faccao_atual, novo_nome):
    try:
        cursor = connection.cursor()
        lider_script_path = "funcionalidades/lider.sql"
        execute_sql_script(lider_script_path, connection)
        # Chamar o pacote antes de chamar a função
        cursor.callproc("pacote_lider.alterar_nome_faccao", [faccao_atual, novo_nome])

        # Capturar mensagens de output
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
        print(f"Erro ao alterar nome da facção: {error}")

    finally:
        if cursor:
            cursor.close()