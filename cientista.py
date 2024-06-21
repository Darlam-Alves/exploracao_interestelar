import cx_Oracle
from common import execute_sql_script

def create_star(connection, id_estrela, nome, classificacao, massa, x, y, z):
    try:
        cursor = connection.cursor()

        # Habilita a saída do DBMS_OUTPUT
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Caminho do script do cientista (assumindo que existe)
        cientista_script_path = "funcionalidades/cientista.sql"
        execute_sql_script(cientista_script_path, connection)

        # Executa o procedimento criar_estrela diretamente
        cursor.callproc("create_star", (id_estrela, nome, classificacao, massa, x, y, z))

        # Variáveis para obter a saída do DBMS_OUTPUT
        status_var = cursor.var(cx_Oracle.NUMBER)
        line_var = cursor.var(cx_Oracle.STRING)

        # Obtém as linhas de saída do DBMS_OUTPUT
        while True:
            cursor.callproc("DBMS_OUTPUT.GET_LINE", (line_var, status_var))
            if status_var.getvalue() != 0:
                break
            if line_var.getvalue():
                print(line_var.getvalue())

        # Comita a transação
        connection.commit()

    except cx_Oracle.Error as error:
        print(f"Erro ao criar estrela: {error}")

    finally:
        if cursor:
            cursor.close()



def read_star(connection, id_estrela):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Variável para o cursor de saída
        v_cursor = connection.cursor()

        # Chamar a procedure read_star com o cursor de saída
        cursor.callproc("read_star", [id_estrela, v_cursor])

        # Ler os resultados do cursor de saída
        for row in v_cursor:
            print(row)

        connection.commit()
    except cx_Oracle.Error as error:
        print(f"Erro ao ler estrela: {error}")
    finally:
        if cursor:
            cursor.close()
        if v_cursor:
            v_cursor.close()


def update_star(connection, id_estrela, nome, classificacao, massa, x, y, z):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        cientista_script_path = "funcionalidades/cientista.sql"
        execute_sql_script(cientista_script_path, connection)
        cursor.callproc("update_star", [id_estrela, nome, classificacao, massa, x, y, z])
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
        print(f"Erro ao atualizar estrela: {error}")
    finally:
        if cursor:
            cursor.close()

def delete_star(connection, id_estrela):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        cientista_script_path = "funcionalidades/cientista.sql"
        execute_sql_script(cientista_script_path, connection)
        cursor.callproc("delete_star", [id_estrela])
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
        print(f"Erro ao remover estrela estrela: {error}")
    finally:
        if cursor:
            cursor.close()

            
def execute_relatorio_estrela(connection):
    try:
        cursor = connection.cursor()

        # Chama a procedure PL/SQL relatorio_estrela com um cursor de saída
        v_cursor = cursor.var(cx_Oracle.CURSOR)
        cursor.callproc("relatorio_estrela", (v_cursor,))
        
        # Lê os resultados do cursor de saída
        for row in v_cursor.getvalue():
            print(row)  # Aqui você pode processar cada linha conforme necessário

        connection.commit()  # Comita a transação, se necessário

    except cx_Oracle.Error as error:
        print(f"Erro ao executar relatório de estrelas: {error}")
    finally:
        if cursor:
            cursor.close()
        if 'v_cursor' in locals():
            v_cursor.close()