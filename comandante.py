import cx_Oracle
from common import execute_sql_script

def execute_comandante_report(connection, p_cpi_lider):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        
        # Execute the script to create or replace necessary procedures and packages
        comandante_script_path = "relatorios/comandante_relatorio.sql"
        execute_sql_script(comandante_script_path, connection)

        # Call the procedure directly
        cursor.callproc("gerar_relatorio", [p_cpi_lider])

        # Capture and print DBMS_OUTPUT messages
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
        cursor.callproc("pacote_comandante.inserir_dominancia", (planeta, nacao, data_ini, data_fim))
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

def incluir_nacao_federacao(connection, nacao, federacao):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        
        # Chamada ao procedimento IncluirNacaoFederacao
        cursor.callproc("IncluirNacaoFederacao", (nacao, federacao))
        
        # Capturando a saída DBMS_OUTPUT
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
        print(f"Erro ao inserir nação com federação: {error}")
    finally:
        if cursor:
            cursor.close()
def excluir_nacao_federacao(connection, nacao):
    try:
        cursor = connection.cursor()
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        # Caminho para o script PL/SQL
        script_path = "funcionalidades/comandante.sql"
        execute_sql_script(script_path, connection)
        
        # Construindo o bloco PL/SQL para excluir a nação da federação
        plsql_block = f"""
        BEGIN
            ExcluirNacaoFederacao('{nacao}');
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


