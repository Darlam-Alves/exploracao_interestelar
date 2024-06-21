-- Criação do pacote pacote_comandante
CREATE OR REPLACE PACKAGE pacote_comandante AS
    -- Procedure para buscar a nação de um comandante pelo CPI
    PROCEDURE buscar_nacao_comandante(
        p_cpi IN LIDER.CPI%TYPE,
        p_nacao OUT LIDER.NACAO%TYPE
    );

    -- Procedure para remover a federação de uma nação
    PROCEDURE remover_federacao (
        p_nacao IN NACAO.NOME%TYPE
    );

    -- Procedure para inserir dominância de um planeta por uma nação
    PROCEDURE inserir_dominancia (
        p_planeta IN PLANETA.ID_ASTRO%TYPE,
        p_nacao IN NACAO.NOME%TYPE
    );
    
    PROCEDURE adicionar_federacao (
        p_nacao IN NACAO.NOME%TYPE,
        p_federacao IN FEDERACAO.NOME%TYPE
    );

END pacote_comandante;
/

-- Criação do corpo do pacote pacote_comandante
CREATE OR REPLACE PACKAGE BODY pacote_comandante AS

    -- Procedure buscar_nacao_comandante
    PROCEDURE buscar_nacao_comandante (
        p_cpi IN LIDER.CPI%TYPE,
        p_nacao OUT LIDER.NACAO%TYPE
    )
    IS
    BEGIN
        SELECT NACAO
        INTO p_nacao
        FROM LIDER
        WHERE CPI = p_cpi
            AND CARGO = 'COMANDANTE'; -- Filtra apenas os líderes com cargo de 'COMANDANTE'
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_nacao := NULL; -- Se nenhum dado for encontrado, retorna NULL
    END buscar_nacao_comandante;

    -- Procedure remover_federacao
    PROCEDURE remover_federacao (
        p_nacao IN NACAO.NOME%TYPE
    )
    IS
    BEGIN
        UPDATE NACAO
        SET FEDERACAO = NULL
        WHERE NOME = p_nacao;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END remover_federacao;

    -- Procedure adicionar_federacao
    PROCEDURE adicionar_federacao (
        p_nacao IN NACAO.NOME%TYPE,
        p_federacao IN FEDERACAO.NOME%TYPE
    )
    IS
        v_count NUMBER;
    BEGIN
        -- Verifica se a federação existe na tabela FEDERACAO
        SELECT COUNT(*)
        INTO v_count
        FROM FEDERACAO
        WHERE NOME = p_federacao;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'A federação especificada não existe.');
        ELSE
            UPDATE NACAO
            SET FEDERACAO = p_federacao
            WHERE NOME = p_nacao;

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END adicionar_federacao;

    -- Procedure inserir_dominancia
    PROCEDURE inserir_dominancia (
        p_planeta IN PLANETA.ID_ASTRO%TYPE,
        p_nacao IN NACAO.NOME%TYPE
    )
    IS
        v_count NUMBER;
    BEGIN
        -- Verifica se já existe dominância ativa para o planeta
        SELECT COUNT(*)
        INTO v_count
        FROM DOMINANCIA
        WHERE PLANETA = p_planeta
          AND DATA_FIM > SYSDATE;

        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Já existe dominância ativa para este planeta.');
        ELSE
            -- Insere novo registro de dominância
            INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI, DATA_FIM)
            VALUES (p_planeta, p_nacao, SYSDATE, NULL);

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END inserir_dominancia;

END pacote_comandante;
/