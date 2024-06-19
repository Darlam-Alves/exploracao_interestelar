import cx_Oracle

def execute_sql_script(file_path, connection):
    try:
        cursor = connection.cursor()
        with open(file_path, 'r') as file:
            sql_script = file.read()
        cursor.execute(sql_script)
        connection.commit()
    except cx_Oracle.Error as error:
        print(f"Erro ao executar o script SQL: {error}")
    finally:
        if cursor:
            cursor.close()
