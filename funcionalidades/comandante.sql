------------------------------------------------------- 3.b Inserir nova dominancia ---------------------------------------------
CREATE OR REPLACE PROCEDURE INSERT_DOMINANCIA (
    p_planeta dominancia.PLANETA%TYPE,
    p_nacao dominancia.NACAO%TYPE,
    p_data_ini dominancia.DATA_INI%TYPE,
    p_data_fim dominancia.DATA_FIM%TYPE
) AS
    v_count NUMBER;

    -- Exceções personalizadas
    ex_planeta_nao_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_planeta_nao_encontrado, -20001);
  
    ex_planeta_ja_dominado EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_planeta_ja_dominado, -20002);
   
    ex_nacao_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_nacao_nao_encontrada, -20003);
BEGIN
    -- Verificar se o planeta existe
    SELECT COUNT(*)
    INTO v_count
    FROM PLANETA
    WHERE ID_ASTRO = p_planeta;

    IF v_count = 0 THEN
        RAISE ex_planeta_nao_encontrado;
    END IF;
   
       -- Verificar se a nação existe
    SELECT COUNT(*)
    INTO v_count
    FROM NACAO
    WHERE NOME = p_nacao;

    IF v_count = 0 THEN
        RAISE ex_nacao_nao_encontrada;
    END IF;

    -- Verificar se o planeta não está sendo dominado por ninguém
    SELECT COUNT(*)
    INTO v_count
    FROM DOMINANCIA
    WHERE PLANETA = p_planeta AND (DATA_FIM IS NULL OR DATA_FIM >= SYSDATE);

    IF v_count > 0 THEN
        RAISE ex_planeta_ja_dominado;
    END IF;

    -- Inserir a nova dominância
    INSERT INTO DOMINANCIA (PLANETA, NACAO, DATA_INI, DATA_FIM)
    VALUES (p_planeta, p_nacao, p_data_ini, p_data_fim);
    DBMS_OUTPUT.PUT_LINE('Dominância inserida com sucesso.');

EXCEPTION
    WHEN ex_planeta_nao_encontrado THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erro: O planeta especificado não existe.');
    WHEN ex_planeta_ja_dominado THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro: O planeta já está sendo dominado.');
    WHEN ex_nacao_nao_encontrada THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro: A nação especificada não existe.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erro desconhecido: ' || SQLERRM);
END;
/
------------------------------------------------------- 3.a.i Incluir propria nação de uma federação existente ---------------------------------------------
CREATE OR REPLACE PROCEDURE IncluirNacaoFederacao(
    v_nacao nacao.NOME%TYPE,
    v_federacao federacao.NOME%TYPE
) AS
    ex_nacao_nao_encontrada EXCEPTION;
    ex_federacao_nao_encontrada EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(ex_nacao_nao_encontrada, -20002);
    PRAGMA EXCEPTION_INIT(ex_federacao_nao_encontrada, -20003);

    v_count NUMBER;
BEGIN
    -- Verificar se a nação existe
    SELECT COUNT(*)
    INTO v_count
    FROM NACAO
    WHERE NOME = v_nacao;
    DBMS_OUTPUT.PUT_LINE('estou aqui ');
    
    IF v_count = 0 THEN
        RAISE ex_nacao_nao_encontrada;
    END IF;

    -- Verificar se a federação existe
    SELECT COUNT(*)
    INTO v_count
    FROM FEDERACAO
    WHERE NOME = v_federacao;
    
    IF v_count = 0 THEN
        RAISE ex_federacao_nao_encontrada;
    END IF;

    -- Incluir a nação na federação
    UPDATE NACAO
    SET FEDERACAO = v_federacao
    WHERE NOME = v_nacao;

    DBMS_OUTPUT.PUT_LINE('Nação incluída na federação com sucesso.');
EXCEPTION
    WHEN ex_nacao_nao_encontrada THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Nação não encontrada.');
    WHEN ex_federacao_nao_encontrada THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Federação não encontrada.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END IncluirNacaoFederacao;
/
------------------------------------------------------- 3.a.i Excluir propria nação de uma federação existente ---------------------------------------------


CREATE OR REPLACE PROCEDURE ExcluirNacaoFederacao(
    v_nacao nacao.NOME%TYPE
) AS
    ex_nacao_nao_encontrada EXCEPTION;

    PRAGMA EXCEPTION_INIT(ex_nacao_nao_encontrada, -20002);

    v_count NUMBER;
BEGIN
    -- Verificar se a nação existe
    SELECT COUNT(*)
    INTO v_count
    FROM NACAO
    WHERE NOME = v_nacao;
    
    IF v_count = 0 THEN
        RAISE ex_nacao_nao_encontrada;
    END IF;

    -- Excluir a nação da federação
    UPDATE NACAO
    SET FEDERACAO = NULL
    WHERE NOME = v_nacao;

    DBMS_OUTPUT.PUT_LINE('Nação excluída da federação com sucesso.');
EXCEPTION
    WHEN ex_nacao_nao_encontrada THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Nação não encontrada.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END ExcluirNacaoFederacao;
/
------------------------------------------------------- 3.a.ii Criar nova federação com sua prpria nação ---------------------------------------------


CREATE OR REPLACE PROCEDURE ManageFederation(
    v_nacao nacao.NOME%TYPE,
    v_federacao federacao.NOME%TYPE
) AS
    -- Exceções personalizadas
    ex_nacao_nao_encontrada EXCEPTION;
    ex_federacao_ja_existe EXCEPTION;

    PRAGMA EXCEPTION_INIT(ex_nacao_nao_encontrada, -20002);
    PRAGMA EXCEPTION_INIT(ex_federacao_ja_existe, -20005);

    v_count NUMBER;
BEGIN
    -- Verificar se a nação existe
    SELECT COUNT(*)
    INTO v_count
    FROM NACAO
    WHERE NOME = v_nacao;
    
    IF v_count = 0 THEN
        RAISE ex_nacao_nao_encontrada;
    END IF;

  
    -- Verificar se a federação já existe
    SELECT COUNT(*)
    INTO v_count
    FROM FEDERACAO
    WHERE NOME = v_federacao;
        
    IF v_count > 0 THEN
       RAISE ex_federacao_ja_existe;
    END IF;

    -- Criar nova federação
     INSERT INTO FEDERACAO (NOME, DATA_FUND)
     VALUES (v_federacao, SYSDATE);

    -- Incluir a nação na nova federação
    UPDATE NACAO
    SET FEDERACAO = v_federacao
    WHERE NOME = v_nacao;

    DBMS_OUTPUT.PUT_LINE('Operação realizada com sucesso.');
   
EXCEPTION
    WHEN ex_nacao_nao_encontrada THEN
        Raise appl('Erro: Nação não encontrada.');
    WHEN ex_federacao_ja_existe THEN
        DBMS_OUTPUT.PUT_LINE('Erro: Federação já existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END ManageFederation;
/
