--------------------- Definição create_star ---------------------------
CREATE OR REPLACE PROCEDURE create_star(
    p_id_estrela estrela.ID_ESTRELA%TYPE,
    p_nome estrela.NOME%TYPE,
    p_classificacao estrela.CLASSIFICACAO%TYPE,
    p_massa estrela.MASSA%TYPE,
    p_x estrela.X%TYPE,
    p_y estrela.Y%TYPE,
    p_z estrela.Z%TYPE
) IS
    v_count INTEGER;
    ex_estrela_ja_existente EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_estrela_ja_existente, -20002);
BEGIN
    -- Verificar se a estrela existe
    SELECT COUNT(*)
    INTO v_count
    FROM ESTRELA
    WHERE ID_ESTRELA = p_id_estrela;

    IF v_count > 0 THEN
        RAISE ex_estrela_ja_existente;
    END IF;

    -- Criar uma nova estrela
    INSERT INTO ESTRELA (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z)
    VALUES (p_id_estrela, p_nome, p_classificacao, p_massa, p_x, p_y, p_z);

    DBMS_OUTPUT.PUT_LINE('Estrela criada com sucesso.');
EXCEPTION
    WHEN ex_estrela_ja_existente THEN
        RAISE_APPLICATION_ERROR(-20002, 'Estrela já existe');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao criar estrela: ' || SQLERRM);
END create_star;
/
--------------------- Definição read_star ---------------------------
CREATE OR REPLACE PROCEDURE read_star(
    p_id_estrela estrela.ID_ESTRELA%TYPE,
    v_cursor OUT SYS_REFCURSOR
) IS
    v_count INTEGER;
    ex_estrela_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_estrela_nao_encontrada, -20001);
BEGIN
    -- Verificar se a estrela existe
    SELECT COUNT(*)
    INTO v_count
    FROM ESTRELA
    WHERE ID_ESTRELA = p_id_estrela;

    IF v_count = 0 THEN
        RAISE ex_estrela_nao_encontrada;
    END IF;

    OPEN v_cursor FOR
        SELECT NOME, CLASSIFICACAO, MASSA, X, Y, Z FROM ESTRELA
        WHERE ID_ESTRELA = p_id_estrela;
EXCEPTION
    WHEN ex_estrela_nao_encontrada THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhuma estrela encontrada');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao ler estrela: ' || SQLERRM);
END read_star;
/
--------------------- Definição update_star ---------------------------
CREATE OR REPLACE PROCEDURE update_star(
    p_id_estrela estrela.ID_ESTRELA%TYPE,
    p_nome estrela.NOME%TYPE,
    p_classificacao estrela.CLASSIFICACAO%TYPE,
    p_massa estrela.MASSA%TYPE,
    p_x estrela.X%TYPE,
    p_y estrela.Y%TYPE,
    p_z estrela.Z%TYPE
) IS
    v_count INTEGER;
    ex_estrela_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_estrela_nao_encontrada, -20001);
BEGIN
    -- Verificar se a estrela não existe
    SELECT COUNT(*)
    INTO v_count
    FROM ESTRELA
    WHERE ID_ESTRELA = p_id_estrela;

    IF v_count = 0 THEN
        RAISE ex_estrela_nao_encontrada;
    END IF;

    -- Atualizar informações de uma estrela
    UPDATE ESTRELA
    SET NOME = p_nome,
        CLASSIFICACAO = p_classificacao,
        MASSA = p_massa,
        X = p_x,
        Y = p_y,
        Z = p_z
    WHERE ID_ESTRELA = p_id_estrela;

    DBMS_OUTPUT.PUT_LINE('Estrela atualizada com sucesso.');
EXCEPTION
    WHEN ex_estrela_nao_encontrada THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhuma estrela encontrada com esse ID');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao atualizar estrela: ' || SQLERRM);
END update_star;
/
--------------------- Definição delete_star ---------------------------
CREATE OR REPLACE PROCEDURE delete_star(
    p_id_estrela estrela.ID_ESTRELA%TYPE
) IS
    v_count INTEGER;
    ex_estrela_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_estrela_nao_encontrada, -20001);
BEGIN
    -- Verificar se a estrela não existe
    SELECT COUNT(*)
    INTO v_count
    FROM ESTRELA
    WHERE ID_ESTRELA = p_id_estrela;

    IF v_count = 0 THEN
        RAISE ex_estrela_nao_encontrada;
    END IF;

    -- Deletar uma estrela
    DELETE FROM ESTRELA
    WHERE ID_ESTRELA = p_id_estrela;

    DBMS_OUTPUT.PUT_LINE('Estrela deletada com sucesso.');
EXCEPTION
    WHEN ex_estrela_nao_encontrada THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhuma estrela encontrada com esse ID');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao deletar estrela: ' || SQLERRM);
END delete_star;
/