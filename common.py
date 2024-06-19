import cx_Oracle

def execute_sql_script(file_path, connection):
    cursor = connection.cursor()
    
    with open(file_path, 'r') as file:
        sql_script = file.read()

    sql_commands = sql_script.split('/')
    
    for command in sql_commands:
        if command.strip():
            try:
                cursor.execute(command)
                connection.commit()
                print(f"Executed command: {command.strip()[:30]}...")
            except cx_Oracle.DatabaseError as e:
                error, = e.args
                print(f"Failed to execute command: {command.strip()[:30]}...\nError: {error.message}")
                connection.rollback()
