import cx_Oracle
from config import get_db_config
from cientista import create_star, read_star, update_star, delete_star, execute_relatorio_estrela
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

def login(connection):
    id_lider = '000.000.000-10'  # Remove espaços em branco antes e depois
    password = '87E897E3B54A405DA144968B2CA19B45'  # Remove espaços em branco antes e depois

    cursor = connection.cursor()
    try:
        is_valid = cursor.callfunc("validate_user_login", cx_Oracle.NUMBER, [id_lider, password])
        
        if is_valid == 1:
            print("Login bem-sucedido!")
            return id_lider  # Retorna o ID de líder para determinar o cargo posteriormente
        else:
            print("ID de Líder ou senha incorretos.")
            return None
    except cx_Oracle.Error as error:
        print(f"Erro ao validar login: {error}")
    finally:
        if cursor:
            cursor.close()

def get_cargo_lider(connection, cpi_lider):
    cursor = connection.cursor()
    try:
        cargo = cursor.callfunc("get_lider_cargo", cx_Oracle.STRING, [cpi_lider])
        return cargo
    except cx_Oracle.Error as error:
        print(f"Erro ao obter o cargo do líder: {error}")
        return None
    finally:
        if cursor:
            cursor.close()

if __name__ == "__main__":
    try:
        connection = connect_to_db()

        id_lider = login(connection)
        if id_lider:
            while True:
                cargo = get_cargo_lider(connection, id_lider)
                print(f"Cargo do líder: {cargo}")

                if cargo and cargo.strip().upper() == 'CIENTISTA':
                    print("Menu CIENTISTA:")
                    print("1. Funcionalidades")
                    print("2. Relatórios")
                    print("0. Voltar para o menu anterior")
                    op = input("Digite o número correspondente à função: ")

                    if op == '1':
                        while True:
                            print("1. Inserir nova estrela")
                            print("2. Ver estrela existente")
                            print("3. Atualizar estrela")
                            print("4. Excluir estrela")
                            print("0. Voltar para o menu anterior")
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
                            elif sub_choice == '0':
                                break
                            else:
                                print("Opção inválida")

                    elif op == '2':
                        while True:
                            print("1. Relatório de estrela")
                            print("2. Relatório de sistema")
                            print("3. Relatório de planeta")
                            print("0. Voltar para o menu anterior")
                            sub_choice = input("Digite o número correspondente à função: ")

                            if sub_choice == '1':
                                execute_relatorio_estrela(connection)
                            elif sub_choice == '2':
                                execute_relatorio_sistema(connection)
                            elif sub_choice == '3':
                                execute_relatorio_planeta(connection)
                            elif sub_choice == '0':
                                break
                            else:
                                print("Opção inválida")

                    elif op == '0':
                        break  # Sair do loop do menu CIENTISTA

                    else:
                        print("Opção inválida")

                elif cargo and cargo.strip().upper() == 'COMANDANTE':
                    print("Menu COMANDANTE:")
                    while True:
                        print("1. Executar relatório de comandante")
                        print("2. Inserir dominância em planeta não dominado")
                        print("3. Incluir federação em nação [não está pronto]")
                        print("4. Excluir federação em nação [não está pronto]")
                        print("0. Voltar para o menu anterior")
                        sub_choice = input("Digite o número correspondente à função: ")

                        if sub_choice == '1':
                            execute_comandante_report(connection, '000.000.000-08')
                        elif sub_choice == '2':
                            planeta = input("Digite o nome do planeta: ").strip()
                            nacao = input("Digite o nome da nação: ").strip()
                            data_ini = input("Digite a data de início (DD/MM/YYYY): ").strip()
                            data_fim = input("Digite a data de fim (DD/MM/YYYY): ").strip()
                            insert_dominancia(connection, planeta, nacao, data_ini, data_fim)
                        elif sub_choice == '3':
                            nacao = 'Natus ut rem.'
                            federacao = 'Eos ab quam.'
                            incluir_nacao_federacao(connection, nacao, federacao)
                        elif sub_choice == '4':
                            nacao = 'Natus ut rem.'
                            federacao = 'Eos ab quam.'
                            excluir_nacao_federacao(connection, nacao)
                        elif sub_choice == '0':
                            break
                        else:
                            print("Opção inválida")

                elif cargo and cargo.strip().upper() == 'OFICIAL':
                    print("Menu OFICIAL:")
                    choice = main_menu()
                    if choice == '3':
                        while True:
                            cpi_lider = input("Digite o CPI do líder: ").strip()
                            data_inicio = input("Digite a data de início (DD/MM/YYYY): ").strip()
                            data_fim = input("Digite a data de fim (DD/MM/YYYY): ").strip()
                            execute_oficial_report(connection, cpi_lider, data_inicio, data_fim)
                            print("0. Voltar para o menu anterior")
                            sub_choice = input("Digite o número correspondente à função: ")

                            if sub_choice == '0':
                                break
                            else:
                                print("Opção inválida")

                else:
                    print(f"Cargo não reconhecido: {cargo}")

        else:
            print("Falha no login. Encerrando o programa.")

    except cx_Oracle.Error as error:
        print(f"Erro ao conectar ao banco de dados: {error}")

    finally:
        if connection:
            connection.close()
