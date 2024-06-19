import cx_Oracle
from config import get_db_config
from cientista import create_star,read_star, update_star, delete_star
from comandante import execute_comandante_report, insert_dominancia, incluir_nacao_federacao, excluir_nacao_federacao
from oficial import execute_oficial_report
from lider import alterar_nome_faccao

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
    print("4. Lider")
    choice = input("Digite o número correspondente ao cargo: ")
    return choice

if __name__ == "__main__":
    try:
        connection = connect_to_db()
        choice = main_menu()
        
        if choice == '1':
            print("1. Inserir nova estrela")
            print("2. ver estrela existente")
            print("3. atualizar estrela")
            print("4. excluir estrela")
            sub_choice = input("Digite o número correspondente à função: ")

            if sub_choice == '1':
                id_estrela = 'estrela1'
                nome = 'amanda'
                classificacao = 'GG'
                massa = 25.36
                x = 25.36
                y = 14.23
                z = 11.23
                create_star(connection, id_estrela, nome, classificacao, massa, x, y, z)
            elif sub_choice == '2':
                id_estrela = 'estrela1'
                read_star(connection, id_estrela)
            elif sub_choice == '3':
                id_estrela = 'estrela1'
                nome = 'darlam'
                classificacao = 'GG'
                massa = 25.36
                x = 25.36
                y = 14.23
                z = 11.23
                update_star(connection, id_estrela, nome, classificacao, massa, x, y, z)
            elif sub_choice == '4':
                id_estrela = 'estrela1'
                delete_star(connection, id_estrela)
        elif choice == '2':
            print("1. Executar relatório de comandante")
            print("2. Inserir dominância em planeta não dominado")
            print("3. Incluir federação em nação[n ta pronto]")
            print("4. Excluir federação em nação[n ta pronto]")
            cpi_lider = '000.000.000-08'
            sub_choice = input("Digite o número correspondente à função: ")
            
            if sub_choice == '1':
                execute_comandante_report(connection, cpi_lider)
            elif sub_choice == '2':
                planeta = input("Digite o nome do planeta: ")
                nacao = input("Digite o nome da nação: ")
                data_ini = input("Digite a data de início (DD/MM/YYYY): ")
                data_fim = input("Digite a data de fim (DD/MM/YYYY): ")
                insert_dominancia(connection, planeta, nacao, data_ini, data_fim)
            elif sub_choice == '3':
                nacao = 'Natus ut rem.'
                federacao = 'Eos ab quam.'
                incluir_nacao_federacao(connection, nacao, federacao)
            elif sub_choice == '4':
                nacao = 'Natus ut rem.'
                federacao = 'Eos ab quam.'
                excluir_nacao_federacao(connection, nacao)
            else:
                print("Opção inválida")

        elif choice == '3':
            cpi_lider = input("Digite o CPI do líder: ")
            data_inicio = input("Digite a data de início (DD/MM/YYYY): ")
            data_fim = input("Digite a data de fim (DD/MM/YYYY): ")
            execute_oficial_report(connection, cpi_lider, data_inicio, data_fim)
        
        elif choice == '4':
            faccao_atual = 'FACCAO1'
            novo_nome = 'minha faccao e boa'
            alterar_nome_faccao(connection, faccao_atual, novo_nome)
        else:
            print("Opção inválida")

    except cx_Oracle.Error as error:
        print(f"Erro ao conectar ao banco de dados: {error}")

    finally:
        if connection:
            connection.close()
