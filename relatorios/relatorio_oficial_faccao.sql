CREATE OR REPLACE PROCEDURE RELATORIO_OFICIAL_SISTEMA(
    p_cpi_lider CHAR,
    p_data_ini DATE,
    p_data_fim DATE
) AS
    v_nacao VARCHAR2(15);
    v_total_habitantes NUMBER := 0;
    v_media_habitantes NUMBER := 0;
    v_total_habitantes_sistema_atual NUMBER := 0;
    v_total_comunidades_sistema_atual NUMBER := 0;
    v_total_habitantes_sistema_periodo NUMBER := 0;
    v_total_habitantes_data_ini NUMBER := 0;
    v_total_habitantes_data_fim NUMBER := 0;
    v_total_habitantes_geral_atual NUMBER := 0;
    v_total_habitantes_geral_ini NUMBER := 0;
    v_total_habitantes_geral_fim NUMBER := 0;
    v_total_comunidades_geral NUMBER := 0;
BEGIN
    -- Verificar se a data inicial é menor que a data final
    IF p_data_ini >= p_data_fim THEN
        RAISE_APPLICATION_ERROR(-20001, 'A data inicial deve ser menor que a data final.');
    END IF;

    -- Obter a nação do líder
    SELECT NACAO INTO v_nacao
    FROM LIDER
    WHERE CPI = p_cpi_lider;

    -- Cabeçalho do relatório
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO DE HABITAÇÕES AGRUPADO POR SISTEMA PARA A NAÇÃO: ' || v_nacao);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Buscar sistemas, estrelas e planetas associados à nação do líder
    FOR sistema_rec IN (
        SELECT DISTINCT S.NOME AS SISTEMA, S.ESTRELA
        FROM SISTEMA S
        JOIN ORBITA_PLANETA OP ON S.ESTRELA = OP.ESTRELA
        JOIN DOMINANCIA D ON OP.PLANETA = D.PLANETA
        WHERE D.NACAO = v_nacao
        AND (D.DATA_FIM IS NULL OR D.DATA_FIM > SYSDATE)
    ) LOOP
        -- Resetar contadores para cada sistema
        v_total_habitantes_sistema_atual := 0;
        v_total_comunidades_sistema_atual := 0;
        v_total_habitantes_sistema_periodo := 0;
        v_total_habitantes_data_ini := 0;
        v_total_habitantes_data_fim := 0;

        DBMS_OUTPUT.PUT_LINE('Sistema: ' || sistema_rec.SISTEMA);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

        -- Buscar planetas que orbitam a estrela do sistema
        FOR planeta_rec IN (
            SELECT PLANETA
            FROM ORBITA_PLANETA
            WHERE ESTRELA = sistema_rec.ESTRELA
        ) LOOP
            -- Relatório para cada planeta encontrado
            DBMS_OUTPUT.PUT_LINE('Planeta: ' || planeta_rec.PLANETA);
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

            -- Consulta para obter habitações para o planeta encontrado
            FOR hab_rec IN (
                SELECT H.PLANETA, H.ESPECIE, H.COMUNIDADE, H.DATA_INI, H.DATA_FIM, C.QTD_HABITANTES
                FROM HABITACAO H
                JOIN COMUNIDADE C ON H.COMUNIDADE = C.NOME AND H.ESPECIE = C.ESPECIE
                WHERE H.PLANETA = planeta_rec.PLANETA
            ) LOOP
                IF hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > SYSDATE THEN
                    -- Incrementar contadores para habitações atuais
                    v_total_habitantes_sistema_atual := v_total_habitantes_sistema_atual + hab_rec.QTD_HABITANTES;
                    v_total_comunidades_sistema_atual := v_total_comunidades_sistema_atual + 1;
                END IF;

                -- Verificar a população no período especificado
                IF hab_rec.DATA_INI <= p_data_fim AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_ini) THEN
                    v_total_habitantes_sistema_periodo := v_total_habitantes_sistema_periodo + hab_rec.QTD_HABITANTES;
                END IF;

                -- Verificar a população na data inicial
                IF hab_rec.DATA_INI <= p_data_ini AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_ini) THEN
                    v_total_habitantes_data_ini := v_total_habitantes_data_ini + hab_rec.QTD_HABITANTES;
                END IF;

                -- Verificar a população na data final
                IF hab_rec.DATA_INI <= p_data_fim AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_fim) THEN
                    v_total_habitantes_data_fim := v_total_habitantes_data_fim + hab_rec.QTD_HABITANTES;
                END IF;

                -- Imprimir os atributos de cada habitação encontrada
                DBMS_OUTPUT.PUT_LINE('Espécie: ' || hab_rec.ESPECIE);
                DBMS_OUTPUT.PUT_LINE('Comunidade: ' || hab_rec.COMUNIDADE);
                DBMS_OUTPUT.PUT_LINE('Data de Início: ' || TO_CHAR(hab_rec.DATA_INI, 'DD-MON-YYYY'));
                DBMS_OUTPUT.PUT_LINE('Data de Fim: ' || COALESCE(TO_CHAR(hab_rec.DATA_FIM, 'DD-MON-YYYY'), 'Atualmente'));
                DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes: ' || hab_rec.QTD_HABITANTES);
                DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
            END LOOP;
        END LOOP;

        -- Acumular totais gerais
        v_total_habitantes_geral_atual := v_total_habitantes_geral_atual + v_total_habitantes_sistema_atual;
        v_total_comunidades_geral := v_total_comunidades_geral + v_total_comunidades_sistema_atual;
        v_total_habitantes_geral_ini := v_total_habitantes_geral_ini + v_total_habitantes_data_ini;
        v_total_habitantes_geral_fim := v_total_habitantes_geral_fim + v_total_habitantes_data_fim;

        -- Imprimir o total e a média de habitantes por sistema para atuais
        IF v_total_comunidades_sistema_atual > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Relatório geral do Sistema ' || sistema_rec.SISTEMA );
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes_sistema_atual);
            DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || ROUND(v_total_habitantes_sistema_atual / v_total_comunidades_sistema_atual, 2));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade atual encontrada para o sistema');
        END IF;

        -- Imprimir a diferença de habitantes desde a data inicial até a data final
        IF v_total_habitantes_data_ini > 0 OR v_total_habitantes_data_fim > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Quantidade de habitantes  em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_data_ini);
            DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || (v_total_habitantes_data_fim - v_total_habitantes_data_ini));
            DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND((v_total_habitantes_data_fim - v_total_habitantes_data_ini) * 100 / v_total_habitantes_data_ini, 2) || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada na data ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY'));
        END IF;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Dados sobre o Deslocamento populacional');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Relatório de deslocamento populacional para cada comunidade
    FOR comunidade_rec IN (
        SELECT H.ESPECIE, H.COMUNIDADE
        FROM HABITACAO H
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = v_nacao
        GROUP BY H.ESPECIE, H.COMUNIDADE
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Localidades da Espécie ' || comunidade_rec.ESPECIE || ', ' || comunidade_rec.COMUNIDADE || ':');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

        -- Contador para enumerar as localidades
        DECLARE
            v_contador INTEGER := 0;
        BEGIN
            FOR deslocamento_rec IN (
                SELECT H.PLANETA, 
                       CASE 
                           WHEN H.DATA_FIM IS NULL THEN 'Habitação atual' 
                           ELSE 'Habitação antiga' 
                       END AS TIPO_HABITACAO,
                       H.DATA_INI
                FROM HABITACAO H
                WHERE H.ESPECIE = comunidade_rec.ESPECIE
                AND H.COMUNIDADE = comunidade_rec.COMUNIDADE
                ORDER BY H.DATA_INI
            ) LOOP
                v_contador := v_contador + 1;
                DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || deslocamento_rec.PLANETA || '(' || deslocamento_rec.TIPO_HABITACAO || ') - data de início: ' || TO_CHAR(deslocamento_rec.DATA_INI, 'DD-MON-YYYY'));
            END LOOP;
        END;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;

    -- Calcular e imprimir o total e a média geral de habitantes
    IF v_total_comunidades_geral > 0 THEN
        v_total_habitantes := v_total_habitantes_geral_atual;
        v_media_habitantes := ROUND(v_total_habitantes_geral_atual / v_total_comunidades_geral, 2);
    END IF;

    -- Adicionar informações sobre a população na primeira data dada
    DBMS_OUTPUT.PUT_LINE('Relatório geral de todos os Sistemas da nação ' || v_nacao);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes);
    DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || v_media_habitantes);
    IF v_total_habitantes_geral_ini > 0 OR v_total_habitantes_geral_fim > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Total de habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_ini);
        DBMS_OUTPUT.PUT_LINE('Total de habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_fim);    
        DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || (v_total_habitantes_geral_fim - v_total_habitantes_geral_ini));
        DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND((v_total_habitantes - v_total_habitantes_geral_ini) * 100 / v_total_habitantes_geral_ini, 2) || '%');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY'));
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Líder não encontrado ou não pertence a uma nação.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro: um valor inválido foi fornecido.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END RELATORIO_OFICIAL_SISTEMA;











CREATE OR REPLACE PROCEDURE RELATORIO_OFICIAL_PLANETA(
    p_cpi_lider CHAR,
    p_data_ini DATE,
    p_data_fim DATE
) AS
    v_nacao VARCHAR2(15);
    v_total_habitantes NUMBER := 0;
    v_media_habitantes NUMBER := 0;
    v_total_habitantes_planeta_atual NUMBER := 0;
    v_total_comunidades_planeta_atual NUMBER := 0;
    v_total_habitantes_planeta_periodo NUMBER := 0;
    v_total_habitantes_data_ini NUMBER := 0;
    v_total_habitantes_data_fim NUMBER := 0;
    v_total_habitantes_geral_atual NUMBER := 0;
    v_total_habitantes_geral_ini NUMBER := 0;
    v_total_habitantes_geral_fim NUMBER := 0;
    v_total_comunidades_geral NUMBER := 0;
    v_diferenca_habitantes NUMBER := 0;
    v_percentual_crescimento NUMBER := 0;
BEGIN
    -- Verificar se a data inicial é menor que a data final
    IF p_data_ini >= p_data_fim THEN
        RAISE_APPLICATION_ERROR(-20001, 'A data inicial deve ser menor que a data final.');
    END IF;

    -- Obter a nação do líder
    SELECT NACAO INTO v_nacao
    FROM LIDER
    WHERE CPI = p_cpi_lider;

    -- Cabeçalho do relatório
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO DE HABITAÇÕES AGRUPADO POR PLANETA PARA A NAÇÃO: ' || v_nacao);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Consulta para obter todas as habitações da nação do líder considerando dominâncias atuais e antigas, agrupando por planeta
    FOR planeta_rec IN (
        SELECT DISTINCT H.PLANETA
        FROM HABITACAO H
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = v_nacao
        ORDER BY H.PLANETA
    ) LOOP
        -- Resetar contadores para cada planeta
        v_total_habitantes_planeta_atual := 0;
        v_total_comunidades_planeta_atual := 0;
        v_total_habitantes_planeta_periodo := 0;
        v_total_habitantes_data_ini := 0;
        v_total_habitantes_data_fim := 0;

        DBMS_OUTPUT.PUT_LINE('Planeta: ' || planeta_rec.PLANETA);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

        FOR hab_rec IN (
            SELECT H.PLANETA, H.ESPECIE, H.COMUNIDADE, H.DATA_INI, H.DATA_FIM, C.QTD_HABITANTES
            FROM HABITACAO H
            JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
            JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
            WHERE D.NACAO = v_nacao
            AND H.PLANETA = planeta_rec.PLANETA
        ) LOOP
            IF hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > SYSDATE THEN
                -- Incrementar contadores para habitações atuais
                v_total_habitantes_planeta_atual := v_total_habitantes_planeta_atual + hab_rec.QTD_HABITANTES;
                v_total_comunidades_planeta_atual := v_total_comunidades_planeta_atual + 1;
            END IF;

            -- Verificar a população no período especificado
            IF hab_rec.DATA_INI <= p_data_fim AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_ini) THEN
                v_total_habitantes_planeta_periodo := v_total_habitantes_planeta_periodo + hab_rec.QTD_HABITANTES;
            END IF;

            -- Verificar a população na data inicial
            IF hab_rec.DATA_INI <= p_data_ini AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_ini) THEN
                v_total_habitantes_data_ini := v_total_habitantes_data_ini + hab_rec.QTD_HABITANTES;
            END IF;

            -- Verificar a população na data final
            IF hab_rec.DATA_INI <= p_data_fim AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_fim) THEN
                v_total_habitantes_data_fim := v_total_habitantes_data_fim + hab_rec.QTD_HABITANTES;
            END IF;

            -- Imprimir os atributos de cada habitação
            DBMS_OUTPUT.PUT_LINE('Espécie: ' || hab_rec.ESPECIE);
            DBMS_OUTPUT.PUT_LINE('Comunidade: ' || hab_rec.COMUNIDADE);
            DBMS_OUTPUT.PUT_LINE('Data de Início: ' || TO_CHAR(hab_rec.DATA_INI, 'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('Data de Fim: ' || COALESCE(TO_CHAR(hab_rec.DATA_FIM, 'DD-MON-YYYY'), 'Atualmente'));
            DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes: ' || hab_rec.QTD_HABITANTES);
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
        END LOOP;

        -- Calcular a diferença de habitantes e o percentual de crescimento/diminuição
        v_diferenca_habitantes := v_total_habitantes_data_fim - v_total_habitantes_data_ini;
        IF v_total_habitantes_data_ini > 0 THEN
            v_percentual_crescimento := (v_diferenca_habitantes / v_total_habitantes_data_ini) * 100;
        ELSE
            v_percentual_crescimento := 0;
        END IF;

        -- Acumular totais gerais
        v_total_habitantes_geral_atual := v_total_habitantes_geral_atual + v_total_habitantes_planeta_atual;
        v_total_comunidades_geral := v_total_comunidades_geral + v_total_comunidades_planeta_atual;
        v_total_habitantes_geral_ini := v_total_habitantes_geral_ini + v_total_habitantes_data_ini;
        v_total_habitantes_geral_fim := v_total_habitantes_geral_fim + v_total_habitantes_data_fim;

        -- Imprimir o total e a média de habitantes por planeta para atuais
        IF v_total_comunidades_planeta_atual > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Relatório geral do Planeta ' || planeta_rec.PLANETA );
            DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
            DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes_planeta_atual);
            DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || ROUND(v_total_habitantes_planeta_atual / v_total_comunidades_planeta_atual, 2));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade atual encontrada para o planeta: ' || planeta_rec.PLANETA);
        END IF;

        IF v_total_habitantes_data_ini > 0 OR v_total_habitantes_data_fim > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_data_ini);
            DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_data_fim);            
            DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_diferenca_habitantes);
            DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND(v_percentual_crescimento, 2) || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY'));
        END IF;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;

    -- Relatório de deslocamento populacional para cada comunidade
    FOR comunidade_rec IN (
        SELECT H.ESPECIE, H.COMUNIDADE
        FROM HABITACAO H
        JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
        WHERE D.NACAO = v_nacao
        GROUP BY H.ESPECIE, H.COMUNIDADE
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Localidades da Espécie ' || comunidade_rec.ESPECIE || ', ' || comunidade_rec.COMUNIDADE || ':');
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

        -- Contador para enumerar as localidades
        DECLARE
            v_contador INTEGER := 0;
        BEGIN
            FOR deslocamento_rec IN (
                SELECT H.PLANETA, 
                    CASE 
                        WHEN H.DATA_FIM IS NULL THEN 'Habitação atual' 
                        ELSE 'Habitação antiga' 
                    END AS TIPO_HABITACAO,
                    H.DATA_INI
                FROM HABITACAO H
                WHERE H.ESPECIE = comunidade_rec.ESPECIE
                AND H.COMUNIDADE = comunidade_rec.COMUNIDADE
                ORDER BY H.DATA_INI
            ) LOOP
                v_contador := v_contador + 1;
                DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || deslocamento_rec.PLANETA || '(' || deslocamento_rec.TIPO_HABITACAO || ') - data de início: ' || TO_CHAR(deslocamento_rec.DATA_INI, 'DD-MON-YYYY'));
            END LOOP;
        END;

        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;

    -- Calcular e imprimir o total e a média geral de habitantes
    IF v_total_comunidades_geral > 0 THEN
        v_total_habitantes := v_total_habitantes_geral_atual;
        v_media_habitantes := ROUND(v_total_habitantes_geral_atual / v_total_comunidades_geral, 2);
    END IF;

    DBMS_OUTPUT.PUT_LINE('Relatório geral de todos os Planetas da nação ' || v_nacao);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes);
    DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || v_media_habitantes);

    IF v_total_habitantes_geral_ini > 0 OR v_total_habitantes_geral_fim > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_ini);
        DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_fim);
        DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || (v_total_habitantes_geral_fim - v_total_habitantes_geral_ini));
        DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND((v_total_habitantes - v_total_habitantes_geral_ini) * 100 / v_total_habitantes_geral_ini, 2) || '%');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || '.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Líder não encontrado ou não pertence a uma nação.');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Erro: um valor inválido foi fornecido.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END RELATORIO_OFICIAL_PLANETA;









CREATE OR REPLACE PROCEDURE RELATORIO_OFICIAL_FACCAO(
    p_cpi_lider CHAR,
    p_data_ini DATE,
    p_data_fim DATE
) AS
    v_nacao VARCHAR2(15);
    v_especie VARCHAR2(15);
    v_comunidade VARCHAR2(15);
    v_total_habitantes_atual NUMBER := 0;
    v_total_comunidades_atual NUMBER := 0;
    v_total_habitantes_ini NUMBER := 0;
    v_total_habitantes_fim NUMBER := 0;
    v_diferenca_habitantes NUMBER := 0;
    v_percentual_crescimento NUMBER := 0;
    v_planeta_atual VARCHAR2(30);
    v_total_habitantes_geral_atual NUMBER := 0;
    v_total_comunidades_geral NUMBER := 0;
    v_total_habitantes_geral_ini NUMBER := 0;
    v_total_habitantes_geral_fim NUMBER := 0;
    v_diferenca_habitantes_geral NUMBER := 0;
    v_percentual_crescimento_geral NUMBER := 0;
BEGIN
    -- Verificar se a data inicial é menor que a data final
    IF p_data_ini >= p_data_fim THEN
        RAISE_APPLICATION_ERROR(-20001, 'A data inicial deve ser menor que a data final.');
    END IF;

    -- Obter a nação do líder
    SELECT NACAO INTO v_nacao
    FROM LIDER
    WHERE CPI = p_cpi_lider;

    -- Cabeçalho do relatório
    DBMS_OUTPUT.PUT_LINE('RELATÓRIO DE HABITAÇÕES AGRUPADO POR FACÇÃO PARA A NAÇÃO: ' || v_nacao);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Relatório Geral
    FOR faccao_rec IN (
        SELECT FACCAO
        FROM NACAO_FACCAO
        WHERE NACAO = v_nacao
    ) LOOP
        -- Cabeçalho para cada facção encontrada
        DBMS_OUTPUT.PUT_LINE('Facção: ' || faccao_rec.FACCAO);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

        v_total_habitantes_atual := 0;
        v_total_comunidades_atual := 0;
        v_total_habitantes_ini := 0;
        v_total_habitantes_fim := 0;

        -- Busca das espécies e comunidades associadas à facção
        FOR rec IN (
            SELECT DISTINCT ESPECIE, COMUNIDADE
            FROM PARTICIPA
            WHERE FACCAO = faccao_rec.FACCAO
        ) LOOP
            v_especie := rec.ESPECIE;
            v_comunidade := rec.COMUNIDADE;

            -- Variáveis para rastrear deslocamento
            v_planeta_atual := NULL;

            -- Consulta para obter habitações para a espécie e comunidade encontradas
            FOR hab_rec IN (
                SELECT H.PLANETA, H.ESPECIE, H.COMUNIDADE, H.DATA_INI, H.DATA_FIM, C.QTD_HABITANTES
                FROM HABITACAO H
                JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
                WHERE H.ESPECIE = v_especie
                AND H.COMUNIDADE = v_comunidade
                ORDER BY H.DATA_INI
            ) LOOP
                IF hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > SYSDATE THEN
                    -- Incrementar contadores para habitações atuais
                    v_total_habitantes_atual := v_total_habitantes_atual + hab_rec.QTD_HABITANTES;
                    v_total_comunidades_atual := v_total_comunidades_atual + 1;
                    v_planeta_atual := hab_rec.PLANETA;
                END IF;

                -- Incrementar contadores para habitações durante o período inicial e final
                IF hab_rec.DATA_INI <= p_data_ini AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_ini) THEN
                    v_total_habitantes_ini := v_total_habitantes_ini + hab_rec.QTD_HABITANTES;
                END IF;

                IF hab_rec.DATA_INI <= p_data_fim AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_fim) THEN
                    v_total_habitantes_fim := v_total_habitantes_fim + hab_rec.QTD_HABITANTES;
                END IF;

                -- Imprimir os atributos de cada habitação encontrada
                DBMS_OUTPUT.PUT_LINE(CASE WHEN hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > SYSDATE THEN '' ELSE '(Habitação Antiga)' END);
                DBMS_OUTPUT.PUT_LINE('Planeta: ' || hab_rec.PLANETA );
                DBMS_OUTPUT.PUT_LINE('Espécie: ' || hab_rec.ESPECIE);
                DBMS_OUTPUT.PUT_LINE('Comunidade: ' || hab_rec.COMUNIDADE);
                DBMS_OUTPUT.PUT_LINE('Data de Início: ' || TO_CHAR(hab_rec.DATA_INI, 'DD-MON-YYYY'));
                DBMS_OUTPUT.PUT_LINE('Data de Fim: ' || COALESCE(TO_CHAR(hab_rec.DATA_FIM, 'DD-MON-YYYY'), 'Atualmente'));
                DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes: ' || hab_rec.QTD_HABITANTES);
                DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
            END LOOP;

        END LOOP;

        -- Calcular a diferença de habitantes e o percentual de crescimento/diminuição
        v_diferenca_habitantes := v_total_habitantes_fim - v_total_habitantes_ini;
        IF v_total_habitantes_ini > 0 THEN
            v_percentual_crescimento := (v_diferenca_habitantes / v_total_habitantes_ini) * 100;
        ELSE
            v_percentual_crescimento := 0;
        END IF;

        -- Imprimir o total e a média de habitantes por facção
        IF v_total_comunidades_atual > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Relatório geral da Facção ' || faccao_rec.FACCAO );
            DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes_atual);
            DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || ROUND(v_total_habitantes_atual / v_total_comunidades_atual, 2));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade atual encontrada para a facção: ' || faccao_rec.FACCAO);
        END IF;
        IF v_total_habitantes_ini > 0 OR v_total_habitantes_fim > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_ini);
            DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_fim);            
            DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') ||': ' || v_diferenca_habitantes);
            DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND(v_percentual_crescimento, 2) || '%');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY'));
        END IF;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

        -- Atualizar os contadores gerais
        v_total_habitantes_geral_atual := v_total_habitantes_geral_atual + v_total_habitantes_atual;
        v_total_comunidades_geral := v_total_comunidades_geral + v_total_comunidades_atual;
        v_total_habitantes_geral_ini := v_total_habitantes_geral_ini + v_total_habitantes_ini;
        v_total_habitantes_geral_fim := v_total_habitantes_geral_fim + v_total_habitantes_fim;
    END LOOP;

    -- Relatório de deslocamento populacional para cada comunidade
    FOR comunidade_rec IN (
      SELECT H.ESPECIE, H.COMUNIDADE
      FROM HABITACAO H
      JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
      WHERE D.NACAO = v_nacao
      GROUP BY H.ESPECIE, H.COMUNIDADE
    ) LOOP
      DBMS_OUTPUT.PUT_LINE('Localidades da Espécie ' || comunidade_rec.ESPECIE || ', ' || comunidade_rec.COMUNIDADE || ':');
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

      -- Contador para enumerar as localidades
      DECLARE
        v_contador INTEGER := 0;
      BEGIN
        FOR deslocamento_rec IN (
          SELECT H.PLANETA, 
                 CASE 
                   WHEN H.DATA_FIM IS NULL THEN 'Habitação atual' 
                   ELSE 'Habitação antiga' 
                 END AS TIPO_HABITACAO,
                 H.DATA_INI
          FROM HABITACAO H
          WHERE H.ESPECIE = comunidade_rec.ESPECIE
            AND H.COMUNIDADE = comunidade_rec.COMUNIDADE
          ORDER BY H.DATA_INI
        ) LOOP
          v_contador := v_contador + 1;
          DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || deslocamento_rec.PLANETA || '(' || deslocamento_rec.TIPO_HABITACAO || ') - data de início: ' || TO_CHAR(deslocamento_rec.DATA_INI, 'DD-MON-YYYY'));
        END LOOP;
      END;
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
    END LOOP;

    -- Calcular a diferença de habitantes geral e o percentual de crescimento/diminuição geral
    v_diferenca_habitantes_geral := v_total_habitantes_geral_fim - v_total_habitantes_geral_ini;
    IF v_total_habitantes_geral_ini > 0 THEN
        v_percentual_crescimento_geral := (v_diferenca_habitantes_geral / v_total_habitantes_geral_ini) * 100;
    ELSE
        v_percentual_crescimento_geral := 0;
    END IF;

    -- Imprimir os totais gerais
    IF v_total_comunidades_geral > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Relatório geral de todas as Facções da nação ' || v_nacao);
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes_geral_atual);
        DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || ROUND(v_total_habitantes_geral_atual / v_total_comunidades_geral, 2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade atual encontrada nas facções da nação do líder.');
    END IF;
    IF v_total_habitantes_geral_ini > 0 OR v_total_habitantes_geral_fim > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_ini);
        DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_fim);
        DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_diferenca_habitantes_geral);
        DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND(v_percentual_crescimento_geral, 2) || '%');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || '.');
    END IF;
END;













CREATE OR REPLACE PROCEDURE RELATORIO_OFICIAL_ESPECIE(
    p_cpi_lider CHAR,
    p_data_ini DATE,
    p_data_fim DATE
) AS
  v_nacao VARCHAR2(15);
  v_total_habitantes_atual NUMBER := 0;
  v_total_comunidades_atual NUMBER := 0;
  v_total_habitantes_data_ini NUMBER := 0;
  v_total_habitantes_data_fim NUMBER := 0;
  v_total_habitantes_geral_atual NUMBER := 0;
  v_total_comunidades_geral NUMBER := 0;
  v_total_habitantes_geral_ini NUMBER := 0;
  v_total_habitantes_geral_fim NUMBER := 0;
  v_especie VARCHAR2(15);
  v_percentual_crescimento NUMBER := 0;
  v_diferenca_habitantes NUMBER := 0;
BEGIN
    -- Verificar se a data inicial é menor que a data final
    IF p_data_ini >= p_data_fim THEN
        RAISE_APPLICATION_ERROR(-20001, 'A data inicial deve ser menor que a data final.');
    END IF;

  -- Obter a nação do líder
  SELECT NACAO INTO v_nacao
  FROM LIDER
  WHERE CPI = p_cpi_lider;

  -- Cabeçalho do relatório
  DBMS_OUTPUT.PUT_LINE('RELATÓRIO DE HABITAÇÕES AGRUPADO POR ESPÉCIE PARA A NAÇÃO: ' || v_nacao);
  DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

  -- Obter informações gerais sobre as habitações
  FOR especie_rec IN (
      SELECT DISTINCT C.ESPECIE
      FROM COMUNIDADE C
      JOIN HABITACAO H ON C.ESPECIE = H.ESPECIE AND C.NOME = H.COMUNIDADE
      JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
      WHERE D.NACAO = v_nacao
  ) LOOP
      -- Cabeçalho para cada espécie encontrada
      v_especie := especie_rec.ESPECIE;
      DBMS_OUTPUT.PUT_LINE('Espécie: ' || v_especie);
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

      v_total_habitantes_atual := 0;
      v_total_comunidades_atual := 0;
      v_total_habitantes_data_ini := 0;
      v_total_habitantes_data_fim := 0;

      -- Consulta para obter habitações para a espécie encontrada
      FOR hab_rec IN (
          SELECT DISTINCT H.PLANETA, H.ESPECIE, H.COMUNIDADE, H.DATA_INI, H.DATA_FIM, C.QTD_HABITANTES
          FROM HABITACAO H
          JOIN COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
          JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
          WHERE D.NACAO = v_nacao
            AND H.ESPECIE = v_especie
            AND (H.DATA_FIM IS NULL OR H.DATA_FIM > p_data_ini)
      ) LOOP
          -- Incrementar contadores para as habitações atuais e antigas
          IF hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > SYSDATE THEN
              v_total_habitantes_atual := v_total_habitantes_atual + hab_rec.QTD_HABITANTES;
              v_total_comunidades_atual := v_total_comunidades_atual + 1;
          END IF;

         -- Incrementar contadores para habitações durante o período inicial e final
          IF hab_rec.DATA_INI <= p_data_ini AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_ini) THEN
              v_total_habitantes_data_ini := v_total_habitantes_data_ini + hab_rec.QTD_HABITANTES;
          END IF;

          IF hab_rec.DATA_INI <= p_data_fim AND (hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > p_data_fim) THEN
              v_total_habitantes_data_fim := v_total_habitantes_data_fim + hab_rec.QTD_HABITANTES;
          END IF;          

          -- Imprimir habitações
          DBMS_OUTPUT.PUT_LINE(CASE WHEN hab_rec.DATA_FIM IS NULL OR hab_rec.DATA_FIM > SYSDATE THEN '' ELSE '(Habitação Antiga)' END);
          DBMS_OUTPUT.PUT_LINE('Planeta: ' || hab_rec.PLANETA);
          DBMS_OUTPUT.PUT_LINE('Comunidade: ' || hab_rec.COMUNIDADE);
          DBMS_OUTPUT.PUT_LINE('Data de Início: ' || TO_CHAR(hab_rec.DATA_INI, 'DD-MON-YYYY'));
          DBMS_OUTPUT.PUT_LINE('Data de Fim: ' || COALESCE(TO_CHAR(hab_rec.DATA_FIM, 'DD-MON-YYYY'), 'Atualmente'));
          DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes: ' || hab_rec.QTD_HABITANTES);
          DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
      END LOOP;

      -- Calcular e imprimir a diferença e o percentual de crescimento/diminuição
      v_diferenca_habitantes := v_total_habitantes_data_fim - v_total_habitantes_data_ini;
      IF v_total_habitantes_data_ini > 0 THEN
          v_percentual_crescimento := (v_diferenca_habitantes / v_total_habitantes_data_ini) * 100;
      ELSE
          v_percentual_crescimento := 100; -- Crescimento total se não havia habitantes anteriormente
      END IF;

      -- Acumular totais gerais
      v_total_habitantes_geral_atual := v_total_habitantes_geral_atual + v_total_habitantes_atual;
      v_total_comunidades_geral := v_total_comunidades_geral + v_total_comunidades_atual;
      v_total_habitantes_geral_ini := v_total_habitantes_geral_ini + v_total_habitantes_data_ini;
      v_total_habitantes_geral_fim := v_total_habitantes_geral_fim + v_total_habitantes_data_fim;
  END LOOP;

      -- Imprimir o total e a média de habitantes por espécie
      IF v_total_comunidades_atual > 0 THEN
          DBMS_OUTPUT.PUT_LINE('Total de Habitantes atualmente: ' || v_total_habitantes_atual);
          DBMS_OUTPUT.PUT_LINE('Média de Habitantes por Comunidade atualmente: ' || ROUND(v_total_habitantes_atual / v_total_comunidades_atual, 2));
      ELSE
          DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade atual encontrada para a espécie: ' || v_especie);
      END IF;
      IF v_total_habitantes_data_ini > 0 OR v_total_habitantes_data_fim > 0 THEN
          DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_data_ini);
          DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_data_fim);            
          DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_diferenca_habitantes);
          DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND(v_percentual_crescimento, 2) || '%');
      ELSE
          DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY'));
      END IF;
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');


  -- Relatório de deslocamento populacional para cada comunidade
  FOR comunidade_rec IN (
    SELECT H.ESPECIE, H.COMUNIDADE
    FROM HABITACAO H
    JOIN DOMINANCIA D ON H.PLANETA = D.PLANETA
    WHERE D.NACAO = v_nacao
    GROUP BY H.ESPECIE, H.COMUNIDADE
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('Localidades da Espécie ' || comunidade_rec.ESPECIE || ', ' || comunidade_rec.COMUNIDADE || ':');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');

    -- Contador para enumerar as localidades
    DECLARE
      v_contador INTEGER := 0;
    BEGIN
      FOR deslocamento_rec IN (
        SELECT H.PLANETA, 
               CASE 
                 WHEN H.DATA_FIM IS NULL THEN 'Habitação atual' 
                 ELSE 'Habitação antiga' 
               END AS TIPO_HABITACAO,
               H.DATA_INI
        FROM HABITACAO H
        WHERE H.ESPECIE = comunidade_rec.ESPECIE
          AND H.COMUNIDADE = comunidade_rec.COMUNIDADE
        ORDER BY H.DATA_INI
      ) LOOP
        v_contador := v_contador + 1;
        DBMS_OUTPUT.PUT_LINE(v_contador || '. ' || deslocamento_rec.PLANETA || '(' || deslocamento_rec.TIPO_HABITACAO || ') - data de início: ' || TO_CHAR(deslocamento_rec.DATA_INI, 'DD-MON-YYYY'));
      END LOOP;
    END;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
  END LOOP;

  v_diferenca_habitantes := v_total_habitantes_geral_fim - v_total_habitantes_geral_ini;
  IF v_total_habitantes_geral_ini > 0 THEN
      v_percentual_crescimento := (v_diferenca_habitantes / v_total_habitantes_geral_fim) * 100;
  ELSE
      v_percentual_crescimento := 0;
  END IF;

  -- Imprimir totais gerais
  IF v_total_comunidades_geral > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Relatório geral de todas as Espécies da nação ' || v_nacao);
      DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('Total geral de Habitantes atualmente: ' || v_total_habitantes_geral_atual);
      DBMS_OUTPUT.PUT_LINE('Média geral de Habitantes por Comunidade atualmente: ' || ROUND(v_total_habitantes_geral_atual / v_total_comunidades_geral, 2));
  ELSE
      DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada para a nação do líder: ' || v_nacao);
  END IF;
  IF v_total_habitantes_geral_ini > 0 OR v_total_habitantes_geral_fim > 0 THEN
      DBMS_OUTPUT.PUT_LINE('Total de habitantes em ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_ini);
      DBMS_OUTPUT.PUT_LINE('Quantidade de Habitantes em ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_total_habitantes_geral_fim);
      DBMS_OUTPUT.PUT_LINE('Diferença de Habitantes desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || v_diferenca_habitantes);
      DBMS_OUTPUT.PUT_LINE('Percentual de Crescimento/Diminuição desde ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' até ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || ': ' || ROUND(v_percentual_crescimento, 2) || '%');
  ELSE
      DBMS_OUTPUT.PUT_LINE('Nenhuma comunidade encontrada nas datas ' || TO_CHAR(p_data_ini, 'DD-MON-YYYY') || ' e ' || TO_CHAR(p_data_fim, 'DD-MON-YYYY') || '.');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Líder não encontrado ou não pertence a uma nação.');
  WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;