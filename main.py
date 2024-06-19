import cx_Oracle
from config import get_db_config

# Função para conectar ao banco de dados Oracle
def connect_to_db():
    db_config = get_db_config()
    conn_str = f"{db_config['user']}/{db_config['password']}@{db_config['host']}:{db_config['port']}/{db_config['service_name']}"
    connection = cx_Oracle.connect(conn_str)
    return connection

# Função para executar relatório de comandante
def execute_comandante_report(connection, p_cpi_lider):
    try:
        cursor = connection.cursor()

        # Habilitar a captura de DBMS_OUTPUT
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Montar o bloco PL/SQL anônimo para relatório de comandante
        plsql_block = f"""
        DECLARE
            v_cpi_lider LIDER.CPI%TYPE := '{p_cpi_lider}';
        BEGIN
            gerar_relatorio(v_cpi_lider);
        END;
        """

        # Executar o bloco PL/SQL anônimo
        cursor.execute(plsql_block)

        # Capturar e exibir as saídas do DBMS_OUTPUT
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

def execute_sql_script(file_path, connection):
    try:
        cursor = connection.cursor()

        # Leitura do arquivo SQL
        with open(file_path, 'r') as file:
            sql_script = file.read()

        # Executar o script SQL
        cursor.execute(sql_script)

        connection.commit()

    except cx_Oracle.Error as error:
        print(f"Erro ao executar o script SQL: {error}")

    finally:
        if cursor:
            cursor.close()

# Função para executar relatório de oficial
def execute_oficial_report(connection, p_cpi_lider, data_inicio, data_fim):
    try:
        cursor = connection.cursor()

        # Habilitar a captura de DBMS_OUTPUT
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Executar o script SQL para oficial
        oficial_script_path = "relatorios/relatorio_oficial_faccao.sql"
        execute_sql_script(oficial_script_path, connection)

        # Montar o bloco PL/SQL anônimo para relatório de oficial
        plsql_block = f"""
            DECLARE
                v_cpi_lider LIDER.CPI%TYPE := '{p_cpi_lider}';
                v_data_inicio DATE := TO_DATE('{data_inicio}', 'DD/MM/YYYY');
                v_data_fim DATE := TO_DATE('{data_fim}', 'DD/MM/YYYY');
            BEGIN
                RELATORIO_OFICIAL_FACCAO(v_cpi_lider, v_data_inicio, v_data_fim);
            END;
        """

        # Executar o bloco PL/SQL anônimo
        cursor.execute(plsql_block)

        # Capturar e exibir as saídas do DBMS_OUTPUT
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


def insert_dominancia(connection, planeta, nacao, data_ini, data_fim):
    try:
        cursor = connection.cursor()

        # Habilitar a captura de DBMS_OUTPUT
        cursor.callproc("DBMS_OUTPUT.ENABLE")
        oficial_script_path = "funcionalidades/comandante.sql"
        execute_sql_script(oficial_script_path, connection)
        # Montar o bloco PL/SQL anônimo para inserir dominância
        plsql_block = f"""
            BEGIN
                INSERT_DOMINANCIA('{planeta}', '{nacao}', TO_DATE('{data_ini}', 'DD/MM/YYYY'), TO_DATE('{data_fim}', 'DD/MM/YYYY'));
            END;
        """

        # Executar o bloco PL/SQL anônimo
        cursor.execute(plsql_block)

        # Capturar e exibir as saídas do DBMS_OUTPUT
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


def create_star(connection, cpi_lider, id_estrela, nome, classificacao, massa, x, y, z):
    try:
        cursor = connection.cursor()

        # Habilitar a captura de DBMS_OUTPUT
        cursor.callproc("DBMS_OUTPUT.ENABLE")

        # Executar o script SQL para a funcionalidade do cientista
        cientista_script_path = "funcionalidades/cientista.sql"
        execute_sql_script(cientista_script_path, connection)

        # Montar o bloco PL/SQL anônimo para criar uma estrela
        plsql_block = f"""
            BEGIN
                criar_estrela('{cpi_lider}', '{id_estrela}', '{nome}', '{classificacao}', '{massa}', '{x}', '{y}', '{z}');
                DBMS_OUTPUT.PUT_LINE('Estrela criada com sucesso.');
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Erro ao criar estrela: ' || SQLERRM);
            END;
        """

        # Executar o bloco PL/SQL anônimo
        cursor.execute(plsql_block)

        # Capturar e exibir as saídas do DBMS_OUTPUT
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

if __name__ == "__main__":
    try:
        connection = connect_to_db()


        #cpi_lider = '000.000.000-08'
        #execute_comandante_report(connection,cpi_lider )
        # Exemplo para executar relatório de oficial
        cpi_lider = '000.000.000-03'
        #data_inicio = '10/10/2000'
        #data_fim = '10/10/2022'
        id_estrela = 'estrelsa1520'
        nome = 'darlam alves'
        classificacao = 'alo_galera'
        massa = 2536.56
        x = 258.21
        y = 152.12
        z = 115.12

        create_star(connection, cpi_lider, id_estrela, nome, classificacao, massa, x, y, z)
        #planeta = 'Eos at aliquid.'
        #nacao = 'Sit id ipsam.'
        #data_ini = '01/01/2020'
        #data_fim = '01/01/2026'
        #insert_dominancia(connection, planeta, nacao, data_ini, data_fim)

        #execute_oficial_report(connection, cpi_lider, data_inicio, data_fim)



    except cx_Oracle.Error as error:
        print(f"Erro ao conectar ao banco de dados: {error}")

    finally:
        if connection:
            connection.close()


