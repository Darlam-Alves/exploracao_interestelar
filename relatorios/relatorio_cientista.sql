-- Procedimento para gerar relatório de estrelas
CREATE OR REPLACE PROCEDURE relatorio_estrela(p_cursor OUT SYS_REFCURSOR) IS
    v_count INTEGER := 0;
BEGIN
    -- Contar o número de registros
    SELECT COUNT(*) INTO v_count FROM ESTRELA;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhum dado no relatório de estrelas');
    END IF;

    -- Abrir o cursor
    OPEN p_cursor FOR
        SELECT ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z
        FROM ESTRELA;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao gerar relatório de estrelas: ' || SQLERRM);
END relatorio_estrela;
/
-- Procedimento para gerar relatório de planetas
CREATE OR REPLACE PROCEDURE relatorio_planeta(p_cursor OUT SYS_REFCURSOR) IS
    v_count INTEGER := 0;
BEGIN
    -- Contar o número de registros
    SELECT COUNT(*) INTO v_count FROM PLANETA;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhum dado no relatório de planetas');
    END IF;

    -- Abrir o cursor
    OPEN p_cursor FOR
        SELECT ID_ASTRO, MASSA, RAIO, CLASSIFICACAO
        FROM PLANETA;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao gerar relatório de planetas: ' || SQLERRM);
END relatorio_planeta;
/
-- Procedimento para gerar relatório de sistemas
CREATE OR REPLACE PROCEDURE relatorio_sistema(p_cursor OUT SYS_REFCURSOR) IS
    v_count INTEGER := 0;
BEGIN
    -- Contar o número de registros
    SELECT COUNT(*) INTO v_count FROM SISTEMA;
    
    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nenhum dado no relatório de sistemas');
    END IF;

    -- Abrir o cursor
    OPEN p_cursor FOR
        SELECT ESTRELA, NOME
        FROM SISTEMA;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Erro ao gerar relatório de sistemas: ' || SQLERRM);
END relatorio_sistema;