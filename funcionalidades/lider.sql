CREATE OR REPLACE PACKAGE pacote_lider AS
   
	PROCEDURE alterar_nome_faccao(p_faccao faccao.nome%TYPE, p_novo_nome faccao.nome%TYPE);
	PROCEDURE indicar_lider(p_lider_atual lider.cpi%TYPE, p_novo_lider lider.cpi%TYPE);
	PROCEDURE inserir_view_ger_comunidades(p_faccao faccao.nome%TYPE);
	PROCEDURE remover_faccao(p_faccao faccao.nome%TYPE, p_nacao nacao.nome%TYPE);

END pacote_lider;
/
CREATE OR REPLACE PACKAGE BODY pacote_lider AS
	PROCEDURE alterar_nome_faccao (
	    p_faccao IN faccao.nome%TYPE,
	    p_novo_nome IN faccao.nome%TYPE    
	) AS
	
	    e_faccao_nao_encontrada EXCEPTION;
	    pragma exception_init(e_faccao_nao_encontrada, -20001);
	
	BEGIN  
	   
	    UPDATE faccao SET NOME = p_novo_nome WHERE NOME = p_faccao;
		
	    IF SQL%ROWCOUNT = 0 THEN
	        raise e_faccao_nao_encontrada;
	    END IF;
	   
	    UPDATE nacao_faccao SET FACCAO = p_novo_nome WHERE FACCAO = p_faccao;
	
	   	UPDATE participa SET FACCAO = p_novo_nome WHERE FACCAO = p_faccao;
	   
	    COMMIT;
	  
	    dbms_output.put_line('Nome da facção ' || p_faccao || ' alterado para ' || p_novo_nome);
	
	EXCEPTION
	    WHEN e_faccao_nao_encontrada THEN
	        raise_application_error(-20001, 'Erro: Facção não encontrada.');
	    	ROLLBACK;
		WHEN OTHERS THEN
		    raise_application_error(-20000, 'Erro ao alterar facção: ' || SQLERRM);
		    ROLLBACK;
		    raise;
	
	END alterar_nome_faccao;

	PROCEDURE indicar_lider (
		p_lider_atual IN lider.CPI%TYPE,
	    p_novo_lider IN lider.CPI%TYPE
	    ) AS 
	    
	 	e_lider_nao_encontrado EXCEPTION;
	    pragma exception_init(e_lider_nao_encontrado, -20002);
	
	BEGIN
		
	    UPDATE faccao SET lider = p_novo_lider WHERE lider = p_lider_atual;
		
	    IF SQL%ROWCOUNT = 0 THEN
	        raise e_lider_nao_encontrado;
	    END IF;
	  
	EXCEPTION
		WHEN e_lider_nao_encontrado THEN
			raise_application_error(-20002, 'O CPI informado não corresponde a nenhum líder atual.');
			ROLLBACK;
		WHEN OTHERS THEN
		    raise_application_error(-20000, 'Erro: ' || SQLERRM);
		    ROLLBACK;	   
	END indicar_lider;	
    
	PROCEDURE inserir_view_ger_comunidades(p_faccao IN faccao.nome%TYPE) AS
	BEGIN
	    FOR r_comunidade IN (
	        SELECT nf.faccao, nf.nacao, d.planeta, c.especie, c.nome AS comunidade
	        FROM
	            nacao_faccao nf
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
	        
	        dbms_output.put_line('Comunidades inseridas com sucesso!');
	   
	EXCEPTION
	    WHEN OTHERS THEN
	        ROLLBACK;
	        raise_application_error(-20000, 'Erro: ' || SQLERRM);
	END inserir_view_ger_comunidades;

	PROCEDURE remover_faccao (
	    p_faccao IN faccao.nome%TYPE,
	    p_nacao IN nacao.nome%TYPE
	) AS
	
	    e_faccao_nao_encontrada EXCEPTION;
	    pragma exception_init(e_faccao_nao_encontrada, -20001);
	
	BEGIN
	        
	    DELETE FROM nacao_faccao WHERE nacao = p_nacao AND faccao = p_faccao;
	    
	    IF SQL%ROWCOUNT = 0 THEN
	        raise e_faccao_nao_encontrada;
	    END IF;
	
	    COMMIT;
	  
	    dbms_output.put_line('Facção ' || p_faccao || ' removida da nação ' || p_nacao);
	
	EXCEPTION
	    WHEN e_faccao_nao_encontrada THEN
	        ROLLBACK;
	       	raise_application_error(-20001, 'Erro: Facção não encontrada para a nação informada.');
	    WHEN OTHERS THEN
	        ROLLBACK;
	       	raise_application_error(-20000, 'Erro ao remover facção: ' || SQLERRM);
	        raise;
	
	END remover_faccao;

END pacote_lider;
/
CREATE OR REPLACE TRIGGER trigger_view_gerenciamento_comunidades
AFTER INSERT ON view_gerenciamento_comunidades
FOR EACH ROW
BEGIN
    INSERT INTO participa (faccao, especie, comunidade)
    VALUES (:NEW.faccao, :NEW.especie, :NEW.comunidade);
END;
/
CREATE OR REPLACE TRIGGER trigger_faccao
  	AFTER INSERT OR UPDATE OR DELETE ON faccao
  	FOR EACH ROW
  	
DECLARE
  	v_count NUMBER;
  	v_nacao nacao.nome%TYPE;
  
BEGIN

	SELECT l.nacao INTO v_nacao FROM lider l WHERE l.CPI = :NEW.lider;

	IF v_nacao IS NULL THEN
		raise no_data_found;
	END IF;
  
	IF INSERTING THEN
		SELECT COUNT(*) INTO v_count FROM nacao_faccao WHERE nacao = v_nacao AND faccao = :NEW.nome;
	  	IF v_count = 0 THEN
	  		INSERT INTO nacao_faccao(NACAO, FACCAO) VALUES(v_nacao, :NEW.nome);
		  	dbms_output.put_line('Nova facção inserida e vinculada à nação do líder!');
	   	END IF;
   	ELSIF UPDATING THEN
   	        SELECT COUNT(*) INTO v_count FROM nacao_faccao WHERE faccao = :OLD.nome;
        IF v_count > 0 THEN
            UPDATE nacao_faccao SET nacao = v_nacao WHERE faccao = :NEW.nome;
            dbms_output.put_line('Informações atualizadas!');
        ELSE
            INSERT INTO nacao_faccao (NACAO, FACCAO) VALUES (v_nacao, :NEW.nome);
            dbms_output.put_line('Nova facção inserida e vinculada à nação do líder!');
        END IF;
	ELSIF DELETING THEN
		SELECT COUNT(*) INTO v_count FROM nacao_faccao WHERE nacao = v_nacao AND faccao = :OLD.nome;
		IF v_count > 0 THEN
  			DELETE FROM nacao_faccao WHERE faccao = :OLD.nome;
  		END IF;
	END IF;
   
EXCEPTION
	WHEN no_data_found THEN
		raise_application_error(-20001, 'O líder informado não está cadastrado!');
		ROLLBACK;
END;
/
CREATE OR REPLACE TRIGGER trigger_nacao_faccao
    AFTER DELETE ON nacao_faccao
    FOR EACH ROW

DECLARE
    v_count NUMBER;
    v_especie comunidade.especie%TYPE;
    v_comunidade comunidade.nome%TYPE;

BEGIN
    SELECT COUNT(*) INTO v_count FROM PARTICIPA WHERE faccao = :OLD.faccao;

    IF v_count > 0 THEN
        SELECT p.especie, p.comunidade INTO v_especie, v_comunidade
        FROM PARTICIPA p WHERE faccao = :OLD.faccao
        AND ROWNUM = 1; -- adicionado ROWNUM = 1 para evitar mais de um resultado

        DELETE FROM PARTICIPA WHERE faccao = :OLD.faccao
        AND especie = v_especie AND comunidade = v_comunidade;
    ELSE
        raise_application_error(-20001, 'Facção não credenciada!');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001, 'Facção não credenciada!');
    WHEN OTHERS THEN
        raise_application_error(-20002, 'Erro: ' || SQLERRM);
END;
/