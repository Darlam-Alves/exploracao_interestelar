-- Procedure alterar_nome_faccao
CREATE OR REPLACE PROCEDURE alterar_nome_faccao (
    p_faccao IN faccao.nome%TYPE,
    p_novo_nome IN faccao.nome%TYPE    
) AS
    e_faccao_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_faccao_nao_encontrada, -20001);
BEGIN  
    -- Atualizar o nome da faccao na tabela faccao
    UPDATE faccao SET NOME = p_novo_nome WHERE NOME = p_faccao;

    -- Verificar atualização
    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_faccao_nao_encontrada;
    END IF;

    -- Atualizar o nome da faccao na tabela nacao_faccao
    UPDATE nacao_faccao SET FACCAO = p_novo_nome WHERE FACCAO = p_faccao;

    -- Atualizar o nome da faccao na tabela participa
    UPDATE participa SET FACCAO = p_novo_nome WHERE FACCAO = p_faccao;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Nome da facção ' || p_faccao || ' alterado para ' || p_novo_nome);
EXCEPTION
    WHEN e_faccao_nao_encontrada THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erro: Facção não encontrada.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao alterar facção: ' || SQLERRM);
END alterar_nome_faccao;
/

-- Procedure indicar_lider
CREATE OR REPLACE PROCEDURE indicar_lider (
    p_lider_atual IN lider.CPI%TYPE,
    p_novo_lider IN lider.CPI%TYPE
) AS 
    e_lider_nao_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_lider_nao_encontrado, -20002);
BEGIN
    UPDATE faccao SET lider = p_novo_lider WHERE lider = p_lider_atual;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_lider_nao_encontrado;
    END IF;
EXCEPTION
    WHEN e_lider_nao_encontrado THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'O CPI informado não corresponde a nenhum líder atual.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, 'Erro: ' || SQLERRM);
END indicar_lider;
/

-- Procedure inserir_view_ger_comunidades
CREATE OR REPLACE PROCEDURE inserir_view_ger_comunidades(p_faccao IN faccao.nome%TYPE) AS
BEGIN
    FOR r_comunidade IN (
        SELECT nf.faccao, nf.nacao, d.planeta, c.especie, c.nome AS comunidade
        FROM nacao_faccao nf
        JOIN dominancia d ON nf.nacao = d.nacao AND (d.data_fim IS NULL OR d.data_fim > SYSDATE)
        JOIN habitacao h ON d.planeta = h.planeta
        JOIN comunidade c ON h.especie = c.especie AND h.comunidade = c.nome
        LEFT JOIN participa p ON nf.faccao = p.faccao AND c.especie = p.especie AND c.nome = p.comunidade
        WHERE nf.faccao = p_faccao AND p.faccao IS NULL
    ) LOOP
        INSERT INTO view_gerenciamento_comunidades (faccao, nacao, planeta, especie, comunidade)
            VALUES (r_comunidade.faccao, r_comunidade.nacao, r_comunidade.planeta, r_comunidade.especie, r_comunidade.comunidade);
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Comunidades inseridas com sucesso!');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, 'Erro: ' || SQLERRM);
END inserir_view_ger_comunidades;
/

-- Procedure remover_faccao
CREATE OR REPLACE PROCEDURE remover_faccao (
    p_faccao IN faccao.nome%TYPE,
    p_nacao IN nacao.nome%TYPE
) AS
    e_faccao_nao_encontrada EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_faccao_nao_encontrada, -20001);
BEGIN
    DELETE FROM nacao_faccao WHERE nacao = p_nacao AND faccao = p_faccao;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_faccao_nao_encontrada;
    END IF;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Facção ' || p_faccao || ' removida da nação ' || p_nacao);
EXCEPTION
    WHEN e_faccao_nao_encontrada THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Erro: Facção não encontrada para a nação informada.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao remover facção: ' || SQLERRM);
END remover_faccao;
/

-- Trigger trigger_view_gerenciamento_comunidades
CREATE OR REPLACE TRIGGER trigger_view_gerenciamento_comunidades
AFTER INSERT ON view_gerenciamento_comunidades
FOR EACH ROW
BEGIN
    INSERT INTO participa (faccao, especie, comunidade)
    VALUES (:NEW.faccao, :NEW.especie, :NEW.comunidade);
END;
/

-- Trigger trigger_faccao
CREATE OR REPLACE TRIGGER trigger_faccao
AFTER INSERT OR UPDATE OR DELETE ON faccao
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_nacao nacao.nome%TYPE;
BEGIN
    SELECT l.nacao INTO v_nacao FROM lider l WHERE l.CPI = :NEW.lider;

    IF v_nacao IS NULL THEN
        RAISE NO_DATA_FOUND;
    END IF;

    IF INSERTING THEN
        SELECT COUNT(*) INTO v_count FROM nacao_faccao WHERE nacao = v_nacao AND faccao = :NEW.nome;
        IF v_count = 0 THEN
            INSERT INTO nacao_faccao(NACAO, FACCAO) VALUES(v_nacao, :NEW.nome);
            DBMS_OUTPUT.PUT_LINE('Nova facção inserida e vinculada à nação do líder!');
        END IF;
    ELSIF UPDATING THEN
        SELECT COUNT(*) INTO v_count FROM nacao_faccao WHERE faccao = :OLD.nome;
        IF v_count > 0 THEN
            UPDATE nacao_faccao SET nacao = v_nacao WHERE faccao = :NEW.nome;
            DBMS_OUTPUT.PUT_LINE('Informações atualizadas!');
        ELSE
            INSERT INTO nacao_faccao (NACAO, FACCAO) VALUES (v_nacao, :NEW.nome);
            DBMS_OUTPUT.PUT_LINE('Nova facção inserida e vinculada à nação do líder!');
        END IF;
    ELSIF DELETING THEN
        SELECT COUNT(*) INTO v_count FROM nacao_faccao WHERE nacao = v_nacao AND faccao = :OLD.nome;
        IF v_count > 0 THEN
            DELETE FROM nacao_faccao WHERE faccao = :OLD.nome;
        END IF;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'O líder informado não está cadastrado!');
        ROLLBACK;
END;
/

-- Trigger trigger_nacao_faccao
CREATE OR REPLACE TRIGGER trigger_nacao_faccao
AFTER DELETE ON nacao_faccao
FOR EACH ROW
DECLARE
    v_count NUMBER;
    v_especie comunidade.especie%TYPE;
    v_comunidade comunidade.nome%TYPE;
BEGIN
    SELECT COUNT(*) INTO v_count FROM participa WHERE faccao = :OLD.faccao;

    IF v_count > 0 THEN
        SELECT p.especie, p.comunidade INTO v_especie, v_comunidade
        FROM participa p WHERE faccao = :OLD.faccao AND ROWNUM = 1;

        DELETE FROM participa WHERE faccao = :OLD.faccao AND especie = v_especie AND comunidade = v_comunidade;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Facção não credenciada!');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Facção não credenciada!');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erro: ' || SQLERRM);
END;
/
