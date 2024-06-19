CREATE OR REPLACE TRIGGER trg_incrementar_qtd_planetas
AFTER INSERT ON DOMINANCIA
FOR EACH ROW
BEGIN
    UPDATE NACAO
    SET QTD_PLANETAS = QTD_PLANETAS + 1
    WHERE NOME = :NEW.NACAO;
END;

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






