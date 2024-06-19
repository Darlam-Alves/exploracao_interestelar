import cx_Oracle
from config import get_db_config
from cientista import create_star
from comandante import execute_comandante_report, insert_dominancia
from oficial import execute_oficial_report

def connect_to_db():
    db_config = get_db_config()
    conn_str = f"{db_config['user']}/{db_config['password']}@{db_config['host']}:{db_config['port']}/{db_config['service_name']}"
    connection = cx_Oracle.connect(conn_str)
    return connection

def main_menu():
    print("Selecione o cargo:")
    print("1. Cientista")
    print("2. Comandante")
    print("3. Oficial")
    choice = input("Digite o número correspondente ao cargo: ")
    return choice

if __name__ == "__main__":
    try:
        connection = connect_to_db()
        choice = main_menu()
        
        if choice == '1':
            #cpi_lider = '000.000.000-08'
            #id_estrela = input("Digite o ID da estrela: ")
            #nome = input("Digite o nome da estrela: ")
            #classificacao = input("Digite a classificação da estrela: ")
            #massa = input("Digite a massa da estrela: ")
            #x = input("Digite a coordenada X: ")
            #y = input("Digite a coordenada Y: ")
            #z = input("Digite a coordenada Z: ")
            create_star(connection, cpi_lider, id_estrela, nome, classificacao, massa, x, y, z)

        elif choice == '2':
            print("1. Executar relatório de comandante")
            print("2. Inserir dominância")
            sub_choice = input("Digite o número correspondente à função: ")
            if sub_choice == '1':
                cpi_lider = '000.000.000-08'
                execute_comandante_report(connection, cpi_lider)
            elif sub_choice == '2':
                planeta = input("Digite o nome do planeta: ")
                nacao = input("Digite o nome da nação: ")
                data_ini = input("Digite a data de início (DD/MM/YYYY): ")
                data_fim = input("Digite a data de fim (DD/MM/YYYY): ")
                insert_dominancia(connection, planeta, nacao, data_ini, data_fim)

        elif choice == '3':
            cpi_lider = input("Digite o CPI do líder: ")
            data_inicio = input("Digite a data de início (DD/MM/YYYY): ")
            data_fim = input("Digite a data de fim (DD/MM/YYYY): ")
            execute_oficial_report(connection, cpi_lider, data_inicio, data_fim)
        
        else:
            print("Opção inválida")

        # Valores comentados
        # connection = connect_to_db()
        # cpi_lider = '000.000.000-08'
        # execute_comandante_report(connection, cpi_lider)
        # Exemplo para executar relatório de oficial
        # cpi_lider = '000.000.000-03'
        # data_inicio = '10/10/2000'
        # data_fim = '10/10/2022'
        # id_estrela = 'estrelsa1520'
        # nome = 'darlam alves'
        # classificacao = 'alo_galera'
        # massa = 2536.56
        # x = 258.21
        # y = 152.12
        # z = 115.12
        # create_star(connection, cpi_lider, id_estrela, nome, classificacao, massa, x, y, z)
        # planeta = 'Eos at aliquid.'
        # nacao = 'Sit id ipsam.'
        # data_ini = '01/01/2020'
        # data_fim = '01/01/2026'
        # insert_dominancia(connection, planeta, nacao, data_ini, data_fim)
        # execute_oficial_report(connection, cpi_lider, data_inicio, data_fim)

    except cx_Oracle.Error as error:
        print(f"Erro ao conectar ao banco de dados: {error}")

    finally:
        if connection:
            connection.close()