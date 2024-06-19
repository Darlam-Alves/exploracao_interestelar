CREATE OR REPLACE PROCEDURE listar_dominancia_planetas(
    p_cpi_lider LIDER.CPI%TYPE
) IS
    v_nacao_comandante LIDER.NACAO%TYPE;
    v_nacao_dominante DOMINANCIA.NACAO%TYPE;
    v_data_ini DOMINANCIA.DATA_INI%TYPE;
    v_data_fim DOMINANCIA.DATA_FIM%TYPE;
    v_total_ativos NUMBER := 0;
    v_total_historico NUMBER := 0;
    CURSOR planetas_cur IS
        SELECT DISTINCT PLANETA
        FROM DOMINANCIA
        WHERE DATA_FIM IS NULL OR DATA_FIM > SYSDATE;
    CURSOR planetas_cur_antigos IS
        SELECT PLANETA
        FROM DOMINANCIA
        WHERE DATA_FIM < SYSDATE;
    TYPE planeta_table IS TABLE OF DOMINANCIA.PLANETA%TYPE INDEX BY PLS_INTEGER;
    planetas_ativos planeta_table;
    planeta_index PLS_INTEGER := 0;

    v_qtd_comunidades NUMBER;
    v_qtd_especies NUMBER;
    v_total_habitantes NUMBER;
    v_planeta_informacoes SYS_REFCURSOR;
BEGIN

    FOR planeta_rec IN planetas_cur LOOP
        BEGIN
            v_nacao_dominante := NULL;
            v_data_ini := NULL;
            v_data_FIM := NULL;
            BEGIN
                SELECT NACAO, DATA_INI, DATA_FIM
                INTO v_nacao_dominante, v_data_ini, v_data_fim
                FROM DOMINANCIA
                WHERE PLANETA = planeta_rec.PLANETA
                FETCH FIRST 1 ROW ONLY;

                v_total_ativos := v_total_ativos + 1;
                planeta_index := planeta_index + 1;
                planetas_ativos(planeta_index) := planeta_rec.PLANETA;

                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('PLANETA: ' || planeta_rec.PLANETA);
                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('Nação Dominante: ' || v_nacao_dominante);
                DBMS_OUTPUT.PUT_LINE('Data de Início da Vigência: ' || TO_CHAR(v_data_ini, 'DD-MM-YYYY'));
               IF v_data_fim IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: Ativo');
               ELSE
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: ' || TO_CHAR(v_data_fim, 'DD-MM-YYYY'));
               END IF;

                v_planeta_informacoes := obter_informacoes_planeta(planeta_rec.PLANETA);
                FETCH v_planeta_informacoes INTO 
                    v_qtd_comunidades, v_qtd_especies, v_total_habitantes;
                CLOSE v_planeta_informacoes;

                DBMS_OUTPUT.PUT_LINE('Quantidade de Comunidades: ' || v_qtd_comunidades);
                DBMS_OUTPUT.PUT_LINE('Quantidade de Espécies: ' || v_qtd_especies);
                DBMS_OUTPUT.PUT_LINE('Total de Habitantes: ' || v_total_habitantes);
                DBMS_OUTPUT.PUT_LINE('');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END;
    END LOOP;
    
    FOR planeta_rec IN planetas_cur_antigos LOOP
        BEGIN
            v_nacao_dominante := NULL;
            v_data_ini := NULL;
            v_data_FIM := NULL;
            BEGIN
                SELECT NACAO, DATA_INI, DATA_FIM
                INTO v_nacao_dominante, v_data_ini, v_data_fim
                FROM DOMINANCIA
                WHERE PLANETA = planeta_rec.PLANETA
                FETCH FIRST 1 ROW ONLY;

                v_total_ativos := v_total_ativos + 1;
                planeta_index := planeta_index + 1;
                planetas_ativos(planeta_index) := planeta_rec.PLANETA;

                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('PLANETA: ' || planeta_rec.PLANETA);
                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('Nação Dominante: ' || v_nacao_dominante);
                DBMS_OUTPUT.PUT_LINE('Data de Início da Vigência: ' || TO_CHAR(v_data_ini, 'DD-MM-YYYY'));
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: Ativo');
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: ' || TO_CHAR(v_data_fim, 'DD-MM-YYYY'));

                v_planeta_informacoes := obter_informacoes_planeta(planeta_rec.PLANETA);
                FETCH v_planeta_informacoes INTO 
                    v_qtd_comunidades, v_qtd_especies, v_total_habitantes;
                CLOSE v_planeta_informacoes;

                DBMS_OUTPUT.PUT_LINE('Quantidade de Comunidades: ' || v_qtd_comunidades);
                DBMS_OUTPUT.PUT_LINE('Quantidade de Espécies: ' || v_qtd_especies);
                DBMS_OUTPUT.PUT_LINE('Total de Habitantes: ' || v_total_habitantes);
                DBMS_OUTPUT.PUT_LINE('');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total de Planetas com Dominação Ativa: ' || v_total_ativos);

END listar_dominancia_planetas;
/
CREATE OR REPLACE PROCEDURE relatorio_estrategico(
    p_cpi_lider LIDER.CPI%TYPE,
    p_nacao_comandante LIDER.NACAO%TYPE
) IS
    v_cur SYS_REFCURSOR;
    v_planeta DOMINANCIA.PLANETA%TYPE;
    v_nacao DOMINANCIA.NACAO%TYPE;
    v_data_ini DOMINANCIA.DATA_INI%TYPE;
    v_data_fim DOMINANCIA.DATA_FIM%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Relatório Estratégico para Comandante ' || p_cpi_lider || ' da Nação ' || p_nacao_comandante);
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    
    OPEN v_cur FOR
        SELECT PLANETA, NACAO, DATA_INI, DATA_FIM
        FROM DOMINANCIA
        WHERE NACAO = p_nacao_comandante
        ORDER BY DATA_INI DESC;
    
    LOOP
        FETCH v_cur INTO v_planeta, v_nacao, v_data_ini, v_data_fim;
        EXIT WHEN v_cur%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('PLANETA: ' || v_planeta);
        DBMS_OUTPUT.PUT_LINE('------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Nação Dominante: ' || v_nacao);
        DBMS_OUTPUT.PUT_LINE('Data de Início da Vigência: ' || TO_CHAR(v_data_ini, 'DD-MM-YYYY'));
        IF v_data_fim IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: Ativo');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: ' || TO_CHAR(v_data_fim, 'DD-MM-YYYY'));
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    CLOSE v_cur;
END relatorio_estrategico;
/
CREATE OR REPLACE PROCEDURE gerar_relatorio(
    p_cpi_lider LIDER.CPI%TYPE
) IS
    v_nacao_comandante LIDER.NACAO%TYPE;
BEGIN
    v_nacao_comandante := verificar_cargo(p_cpi_lider);
    DBMS_OUTPUT.PUT_LINE('nacao_comandante: '|| v_nacao_comandante);

    IF v_nacao_comandante IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('O CPI fornecido não pertence a um comandante.');
        RETURN;
    END IF;

    relatorio_estrategico(p_cpi_lider, v_nacao_comandante);
    DBMS_OUTPUT.PUT_LINE('');
    listar_dominancia_planetas(p_cpi_lider);
END gerar_relatorio;
/
