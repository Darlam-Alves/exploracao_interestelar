    -- TABELA DE USUARIOS

    -- ========================= TABELA =========================

    -- ========================= PROCEDURE PARA INSERCAO DE USUARIOS =========================
CREATE OR REPLACE PROCEDURE inserir_usuario(p_password IN users.password%TYPE, p_id_lider IN users.id_lider%TYPE)
    AS
        v_hash_password varchar2(32);
    
        e_password_null EXCEPTION;
    
        PRAGMA EXCEPTION_INIT(e_password_null, -20007);

    BEGIN
        IF p_password IS NULL OR p_password = '' THEN
            raise e_password_null;
        END IF;
        
        SELECT UPPER(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input_string => p_password)))
        INTO v_hash_password
        FROM dual;
        
        INSERT INTO users (password, id_lider) VALUES (v_hash_password, p_id_lider);
    
    EXCEPTION
        WHEN e_password_null THEN
            raise_application_error(-20007, 'Senha não informada!');
        WHEN OTHERS THEN
            raise_application_error(-20000, 'Erro: ' || SQLERRM);
    END;

    -- ========================= TRIGGER AUTOMATIZAR INSERCAO =========================
    CREATE OR REPLACE TRIGGER trigger_lider_user
    AFTER INSERT ON lider
    FOR EACH ROW
    BEGIN
        INSERT INTO users(password, id_lider)
                VALUES (RAWTOHEX(UTL_RAW.CAST_TO_RAW(DBMS_OBFUSCATION_TOOLKIT.MD5(input_string => 'default_password'))), :NEW.cpi);
    END;
/
CREATE OR REPLACE PROCEDURE validate_user_login (
    p_id_lider IN users.id_lider%TYPE,
    p_password IN users.password%TYPE,
    p_is_valid OUT BOOLEAN
) AS
    v_stored_password users.password%TYPE;
    v_hashed_password users.password%TYPE;
BEGIN
    -- Buscar a senha armazenada no banco de dados
    SELECT password INTO v_stored_password
    FROM users
    WHERE id_lider = p_id_lider;

    -- Gerar o hash da senha fornecida
    SELECT UPPER(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input_string => p_password)))
    INTO v_hashed_password
    FROM dual;

    -- Comparar as senhas
    IF v_stored_password = v_hashed_password THEN
        p_is_valid := TRUE;
    ELSE
        p_is_valid := FALSE;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_is_valid := FALSE;
    WHEN OTHERS THEN
        p_is_valid := FALSE;
        -- Gerenciar outros erros conforme necessário
END validate_user_login;
/
