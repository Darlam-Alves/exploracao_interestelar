import cx_Oracle
from common import execute_sql_script

def execute_oficial_report(connection, cpi_lider, data_ini, data_fim):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Chamar a procedure RELATORIO_OFICIAL_SISTEMA diretamente
        cursor.callproc("RELATORIO_OFICIAL_SISTEMA", [
                        cpi_lider, data_ini, data_fim])

        # Verificar a saída do DBMS_OUTPUT
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
        print(f"Erro ao executar o relatório: {error}")
    finally:
        if cursor:
            cursor.close()


def relatorio_oficial_planeta(connection, cpi_lider, data_ini, data_fim):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Chamar a procedure RELATORIO_OFICIAL_PLANETA diretamente
        cursor.callproc("RELATORIO_OFICIAL_PLANETA", [
                        cpi_lider, data_ini, data_fim])

        # Verificar a saída do DBMS_OUTPUT
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
        print(f"Erro ao executar o relatório: {error}")
    finally:
        if cursor:
            cursor.close()


def relatorio_oficial_faccao(connection, cpi_lider, data_ini, data_fim):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Chamar a procedure RELATORIO_OFICIAL_FACCAO diretamente
        cursor.callproc("RELATORIO_OFICIAL_FACCAO", [
                        cpi_lider, data_ini, data_fim])

        # Verificar a saída do DBMS_OUTPUT
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
        print(f"Erro ao executar o relatório: {error}")
    finally:
        if cursor:
            cursor.close()


def relatorio_oficial_especie(connection, cpi_lider, data_ini, data_fim):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Chamar a procedure RELATORIO_OFICIAL_ESPECIE diretamente
        cursor.callproc("RELATORIO_OFICIAL_ESPECIE", [
                        cpi_lider, data_ini, data_fim])

        # Verificar a saída do DBMS_OUTPUT
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
        print(f"Erro ao executar o relatório: {error}")
    finally:
        if cursor:
            cursor.close()