CREATE OR REPLACE FUNCTION verificar_cientista(p_cpi LIDER.CPI%TYPE) RETURN BOOLEAN IS
    v_cargo LIDER.CARGO%TYPE;
BEGIN
    SELECT CARGO INTO v_cargo
    FROM LIDER
    WHERE CPI = p_cpi;

    RETURN v_cargo = 'CIENTISTA';
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erro: ' || SQLERRM);
END verificar_cientista;
/
CREATE OR REPLACE PROCEDURE criar_estrela (
    p_cpi IN LIDER.CPI%TYPE,
    p_id_estrela IN ESTRELA.ID_ESTRELA%TYPE,
    p_nome IN ESTRELA.NOME%TYPE,
    p_classificacao IN ESTRELA.CLASSIFICACAO%TYPE,
    p_massa IN ESTRELA.MASSA%TYPE,
    p_x IN ESTRELA.X%TYPE,
    p_y IN ESTRELA.Y%TYPE,
    p_z IN ESTRELA.Z%TYPE
) IS
BEGIN
    IF verificar_cientista(p_cpi) THEN
        INSERT INTO ESTRELA (ID_ESTRELA, NOME, CLASSIFICACAO, MASSA, X, Y, Z)
        VALUES (
            TO_CHAR(p_id_estrela),
            TO_CHAR(p_nome),
            TO_CHAR(p_classificacao),
            TO_NUMBER(p_massa),
            TO_NUMBER(p_x),
            TO_NUMBER(p_y),
            TO_NUMBER(p_z)
        );
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Acesso negado: O usuário não é um cientista.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Usuário não encontrado.');
    WHEN DUP_VAL_ON_INDEX THEN
        RAISE_APPLICATION_ERROR(-20003, 'Estrela já existe com o ID fornecido ou coordenadas duplicadas.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erro: ' || SQLERRM);
END criar_estrela;

