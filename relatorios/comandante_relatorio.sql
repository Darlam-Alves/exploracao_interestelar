CREATE OR REPLACE FUNCTION verificar_cargo(
    cpi_lider LIDER.CPI%TYPE
) RETURN LIDER.NACAO%TYPE IS
    v_nacao LIDER.NACAO%TYPE;
BEGIN
    -- Verifica se o CPI corresponde a um comandante
    SELECT NACAO INTO v_nacao
    FROM LIDER
    WHERE CPI = cpi_lider AND CARGO = 'COMANDANTE';

    -- Se uma linha for encontrada, retorna a nação
    RETURN v_nacao;

EXCEPTION
    -- Se nenhuma linha for encontrada, captura a exceção NO_DATA_FOUND
    WHEN NO_DATA_FOUND THEN
        RETURN NULL; -- Retornar NULL se não for encontrado comandante
    -- Trata outras exceções, se necessário
    WHEN OTHERS THEN
        -- Log ou tratamento adicional pode ser adicionado aqui
        RETURN NULL;
END verificar_cargo;
/
CREATE OR REPLACE FUNCTION obter_informacoes_planeta(p_planeta IN VARCHAR2) 
RETURN SYS_REFCURSOR IS
    v_cur SYS_REFCURSOR;
BEGIN
    OPEN v_cur FOR
        SELECT 
            COUNT(DISTINCT H.COMUNIDADE) AS QTD_COMUNIDADES,
            COUNT(DISTINCT H.ESPECIE) AS QTD_ESPECIES,
            SUM(C.QTD_HABITANTES) AS TOTAL_HABITANTES
        FROM 
            HABITACAO H
        JOIN 
            COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        WHERE 
            H.PLANETA = p_planeta
            AND (H.DATA_FIM IS NULL OR H.DATA_FIM > SYSDATE);
    RETURN v_cur;
END obter_informacoes_planeta;
/
CREATE OR REPLACE PROCEDURE obter_faccoes_planeta(
    p_planeta IN VARCHAR2
) IS
    CURSOR faccoes_cur IS
        SELECT 
            P.FACCAO,
            SUM(C.QTD_HABITANTES) AS TOTAL_ADERENTES
        FROM 
            HABITACAO H
        JOIN 
            PARTICIPA P ON H.ESPECIE = P.ESPECIE AND H.COMUNIDADE = P.COMUNIDADE
        JOIN 
            COMUNIDADE C ON H.ESPECIE = C.ESPECIE AND H.COMUNIDADE = C.NOME
        WHERE 
            H.PLANETA = p_planeta
        GROUP BY 
            P.FACCAO
        ORDER BY 
            TOTAL_ADERENTES DESC;

    v_faccao_majoritaria VARCHAR2(15);
    v_max_aderentes NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Facções no Planeta ' || p_planeta || ':');
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    
    FOR faccao_rec IN faccoes_cur LOOP
        DBMS_OUTPUT.PUT_LINE('Facção: ' || faccao_rec.FACCAO || ', Total de Aderentes: ' || faccao_rec.TOTAL_ADERENTES);
        
        -- Verifica se esta facção tem o maior número de aderentes
        IF faccao_rec.TOTAL_ADERENTES > v_max_aderentes THEN
            v_max_aderentes := faccao_rec.TOTAL_ADERENTES;
            v_faccao_majoritaria := faccao_rec.FACCAO;
        END IF;
    END LOOP;
    
    -- Exibe a facção majoritária
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Facção Majoritária: ' || v_faccao_majoritaria || ' com ' || v_max_aderentes || ' aderentes');
END obter_faccoes_planeta;
/

-- Procedure para listar a dominação dos planetas
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

    -- Loop pelos planetas presentes na tabela de dominância
    FOR planeta_rec IN planetas_cur LOOP
        BEGIN
            -- Inicializa as variáveis
            v_nacao_dominante := NULL;
            v_data_ini := NULL;
            v_data_FIM := NULL;
            -- Tenta encontrar uma dominação vigente para o planeta
            BEGIN
                SELECT NACAO, DATA_INI, DATA_FIM
                INTO v_nacao_dominante, v_data_ini, v_data_fim
                FROM DOMINANCIA
                WHERE PLANETA = planeta_rec.PLANETA
                FETCH FIRST 1 ROW ONLY;

                -- Contabiliza dominação ativa
                v_total_ativos := v_total_ativos + 1;

                -- Armazena o planeta na tabela de ativos
                planeta_index := planeta_index + 1;
                planetas_ativos(planeta_index) := planeta_rec.PLANETA;

                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('PLANETA: ' || planeta_rec.PLANETA);
                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('Nação Dominante: ' || v_nacao_dominante);
                DBMS_OUTPUT.PUT_LINE('Data de Início da Vigência: ' || TO_CHAR(v_data_ini, 'DD/MM/YYYY'));
               IF v_data_fim IS NULL THEN
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: Ativo');
               ELSE
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: ' || TO_CHAR(v_data_fim, 'DD/MM/YYYY'));
               END IF;

                -- Obter informações adicionais do planeta
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
            -- Inicializa as variáveis
            v_nacao_dominante := NULL;
            v_data_ini := NULL;
            v_data_FIM := NULL;
            -- Tenta encontrar uma dominação vigente para o planeta
            BEGIN
                SELECT NACAO, DATA_INI, DATA_FIM
                INTO v_nacao_dominante, v_data_ini, v_data_fim
                FROM DOMINANCIA
                WHERE PLANETA = planeta_rec.PLANETA
                FETCH FIRST 1 ROW ONLY;

                -- Contabiliza dominação ativa
                v_total_ativos := v_total_ativos + 1;

                -- Armazena o planeta na tabela de ativos
                planeta_index := planeta_index + 1;
                planetas_ativos(planeta_index) := planeta_rec.PLANETA;

                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('PLANETA: ' || planeta_rec.PLANETA);
                DBMS_OUTPUT.PUT_LINE('------------------------------------');
                DBMS_OUTPUT.PUT_LINE('Nação Dominante: ' || v_nacao_dominante);
                DBMS_OUTPUT.PUT_LINE('Data de Início da Vigência: ' || TO_CHAR(v_data_ini, 'DD/MM/YYYY'));
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: Ativo');
                DBMS_OUTPUT.PUT_LINE('Data de Fim da Vigência: ' || TO_CHAR(v_data_fim, 'DD/MM/YYYY'));

                -- Obter informações adicionais do planeta
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

    -- Exibe o resumo
    DBMS_OUTPUT.PUT_LINE('Total de Planetas com Dominação Ativa: ' || v_total_ativos);

END listar_dominancia_planetas;
/

-- Procedure para relatar informações estratégicas
CREATE OR REPLACE PROCEDURE relatorio_estrategico(
    p_cpi_lider LIDER.CPI%TYPE,
    p_nacao LIDER.NACAO%TYPE
) IS
    v_qtd_planetas NACAO.QTD_PLANETAS%TYPE;
    v_federacao NACAO.FEDERACAO%TYPE;
    v_convencionais NUMBER := 0;
    v_errantes NUMBER := 0;
    v_maior_planeta PLANETA.ID_ASTRO%TYPE;
    v_maior_massa NUMBER;
    v_maior_raio NUMBER;
BEGIN
    -- Busca os atributos quantidade de planetas e federação da nação do líder
    SELECT QTD_PLANETAS, FEDERACAO
    INTO v_qtd_planetas, v_federacao
    FROM NACAO
    WHERE NOME = p_nacao;

    -- Imprime os atributos da nação
    DBMS_OUTPUT.PUT_LINE('Quantidade de planetas dominados: ' || v_qtd_planetas);
    DBMS_OUTPUT.PUT_LINE('Federação: ' || v_federacao);

    -- Conta quantos planetas dominados orbitam estrelas (convencionais) e quantos não orbitam (errantes)
    SELECT 
        COUNT(CASE WHEN op.ESTRELA IS NOT NULL THEN 1 END) AS convencionais,
        COUNT(CASE WHEN op.ESTRELA IS NULL THEN 1 END) AS errantes
    INTO 
        v_convencionais, 
        v_errantes
    FROM 
        DOMINANCIA d
        LEFT JOIN ORBITA_PLANETA op ON d.PLANETA = op.PLANETA
    WHERE 
        d.NACAO = p_nacao
        AND d.DATA_FIM IS NULL;

    -- Imprime os resultados
    DBMS_OUTPUT.PUT_LINE('Planetas convencionais: ' || v_convencionais);
    DBMS_OUTPUT.PUT_LINE('Planetas errantes: ' || v_errantes);
    
 SELECT
    d.PLANETA,
    p.RAIO
  INTO
    v_maior_planeta,
    v_maior_raio
  FROM
    DOMINANCIA d
    JOIN PLANETA p ON d.PLANETA = p.ID_ASTRO
  WHERE
    d.NACAO = p_nacao
    AND d.DATA_FIM IS NULL
  ORDER BY p.RAIO DESC
  FETCH FIRST 1 ROWS ONLY;

  -- Imprime o resultado do maior planeta
  IF v_maior_planeta IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Planeta com maior raio: ' || v_maior_planeta || ' -> raio: ' || v_maior_raio || '');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nenhum planeta encontrado para a nação ' || p_nacao);
  END IF;
END relatorio_estrategico;
/

CREATE OR REPLACE PROCEDURE gerar_relatorio(
    p_cpi_lider LIDER.CPI%TYPE
) IS
    v_nacao_comandante LIDER.NACAO%TYPE;
BEGIN
    -- Verifica se o CPI corresponde a um comandante e obtém a nação
    v_nacao_comandante := verificar_cargo(p_cpi_lider);
    DBMS_OUTPUT.PUT_LINE('nacao_comandante: '|| v_nacao_comandante);

    IF v_nacao_comandante IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('O CPI fornecido não pertence a um comandante.');
        RETURN;
    END IF;

    -- Executa a operação baseada no tipo de operação
      
        relatorio_estrategico(p_cpi_lider, v_nacao_comandante);
        listar_dominancia_planetas(p_cpi_lider);     
END gerar_relatorio;
/


