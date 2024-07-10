set serveroutput on
--drop sequences
DROP SEQUENCE seq_potencial;
DROP SEQUENCE seq_agua;
DROP SEQUENCE seq_credencial;
DROP SEQUENCE seq_usuario;
DROP SEQUENCE seq_checagem;
DROP SEQUENCE seq_error;


--create sequences
CREATE SEQUENCE seq_potencial
start with 1
increment by 1
minvalue 1
maxvalue 1000
nocycle;
    
CREATE SEQUENCE seq_agua
start with 1
increment by 1
minvalue 1
maxvalue 1000
nocycle;

CREATE SEQUENCE seq_credencial
start with 1
increment by 1
minvalue 1
maxvalue 1000
nocycle;
    
CREATE SEQUENCE seq_usuario
start with 1
increment by 1
minvalue 1
maxvalue 1000
nocycle;
    
CREATE SEQUENCE seq_checagem
start with 1
increment by 1
minvalue 1
maxvalue 1000
nocycle;
    
CREATE SEQUENCE seq_error
start with 1
increment by 1
minvalue 1
maxvalue 1000
nocycle;



--DROPS TABLES

DROP TABLE T_BH_CHECAGEM;
DROP TABLE T_BH_USUARIO;
DROP TABLE T_BH_CREDENCIAL;
DROP TABLE T_BH_AGUA;
DROP TABLE T_BH_POTENCIAL;
DROP TABLE T_BH_ERROR;


--TABLES
CREATE TABLE T_BH_POTENCIAL(
id_potencial CHAR (9) PRIMARY KEY,
nm_cidade VARCHAR2 (50) NOT NULL UNIQUE,
nr_escala NUMBER NOT NULL,
dt_data DATE
);

CREATE TABLE T_BH_CREDENCIAL(
id_credencial CHAR (9) PRIMARY KEY,
ds_email VARCHAR2 (255) NOT NULL UNIQUE,
cd_senha VARCHAR2 (255) NOT NULL
);

CREATE TABLE T_BH_AGUA(
id_agua CHAR (9) PRIMARY KEY,
nm_cidade VARCHAR2 (255) NOT NULL ,
nr_ph VARCHAR2 (255) NOT NULL,
nr_oxigenio VARCHAR2 (255) NOT NULL,
nr_nitrato VARCHAR2(255) NOT NULL,
nr_fosfato VARCHAR2(255) NOT NULL,
nr_microplastico VARCHAR2(255) NOT NULL,
nr_salinidade VARCHAR2(255) NOT NULL UNIQUE,
st_qualidade_agua CHAR (1) NOT NULL,
id_potencial CHAR (9) NOT NULL,
FOREIGN KEY(id_potencial) REFERENCES T_BH_POTENCIAL(id_potencial)
);


CREATE TABLE T_BH_USUARIO(
id_usuario CHAR (9) PRIMARY KEY,
st_denominacao CHAR (1) NOT NULL,
dt_nascimento DATE NOT NULL,
id_credencial CHAR (9) NOT NULL UNIQUE,
FOREIGN KEY(id_credencial) REFERENCES T_BH_CREDENCIAL(id_credencial)
);

CREATE TABLE T_BH_CHECAGEM(
id_checagem CHAR (9),
dt_data DATE not null,
id_usuario CHAR (9) NOT NULL,
id_agua CHAR (9) NOT NULL,
FOREIGN KEY(id_usuario) REFERENCES T_BH_USUARIO(id_usuario),
FOREIGN KEY(id_agua) REFERENCES T_BH_AGUA(id_agua),
PRIMARY KEY (id_checagem, id_usuario)
);

CREATE TABLE T_BH_ERROR(
id_erro CHAR (9) PRIMARY KEY,
nm_usuario VARCHAR2 (255) NOT NULL,
nm_procedure VARCHAR2 (255) NOT NULL,
dt_ocorrencia DATE NOT NULL,
cd_error integer NOT NULL,
ds_error VARCHAR2 (255) NOT NULL
);



--PROCEDURE DE INSERT
CREATE OR REPLACE PROCEDURE insert_t_bh_potencial (
    p_nm_cidade            IN VARCHAR2,
    p_nr_escala            IN NUMBER,
    p_dt_data              IN DATE
) AS
    v_id_potencial CHAR(9);
    v_id_erro CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Gera um novo ID usando a sequência
    v_id_potencial := seq_potencial.NEXTVAL;
    
    INSERT INTO t_bh_potencial (id_potencial, nm_cidade, nr_escala, dt_data)
    VALUES (v_id_potencial, p_nm_cidade, p_nr_escala, p_dt_data);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_potencial', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_potencial', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_potencial', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
END;

BEGIN
    insert_t_bh_potencial('São Paulo', 5, TO_DATE('2022-01-01', 'YYYY-MM-DD'));
    insert_t_bh_potencial('São Paulo', 5, TO_DATE('2022-01-01', 'YYYY-MM-DD')); --simular exception
    insert_t_bh_potencial('Rio de janeiro', 4, TO_DATE('2022-02-02', 'YYYY-MM-DD'));
    insert_t_bh_potencial('Santos', 3, TO_DATE('2022-03-03', 'YYYY-MM-DD'));
    insert_t_bh_potencial('Santa Catarina', 2, TO_DATE('2022-04-04', 'YYYY-MM-DD'));
    insert_t_bh_potencial('Pernambuco', 1, TO_DATE('2022-05-05', 'YYYY-MM-DD'));
END;
/

--select*from t_bh_potencial
--select*from t_bh_error

CREATE OR REPLACE PROCEDURE insert_t_bh_credencial (
    p_ds_email            IN VARCHAR2,
    p_cd_senha            IN VARCHAR2
) AS
    v_id_credencial CHAR(9);
    v_id_erro CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Gera um novo ID usando a sequência
    v_id_credencial := seq_credencial.NEXTVAL;
    
    INSERT INTO t_bh_credencial (id_credencial, ds_email, cd_senha)
    VALUES (v_id_credencial, p_ds_email, p_cd_senha);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_credencial', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_credencial', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_credencial', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
END;


BEGIN
    insert_t_bh_credencial('exemplo1@email.com', 'senha123');
    insert_t_bh_credencial('exemplo1@email.com', 'senha123'); --simular insert
    insert_t_bh_credencial('exemplo2@email.com', 'senha124');
    insert_t_bh_credencial('exemplo3@email.com', 'senha125');
    insert_t_bh_credencial('exemplo4@email.com', 'senha126');
    insert_t_bh_credencial('exemplo5@email.com', 'senha127');
        
END;
/


CREATE OR REPLACE PROCEDURE insert_t_bh_usuario (
    p_st_denominacao   IN CHAR,
    p_dt_nascimento    IN DATE,
    p_id_credencial    IN CHAR
) AS
    v_id_usuario CHAR(9);
    v_id_erro CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Gera um novo ID usando a sequência
    v_id_usuario := seq_usuario.NEXTVAL;
    
    INSERT INTO t_bh_usuario (id_usuario, st_denominacao, dt_nascimento, id_credencial)
    VALUES (v_id_usuario, p_st_denominacao, p_dt_nascimento, p_id_credencial);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_usuario', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_usuario', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_usuario', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
END;

BEGIN
    insert_t_bh_usuario('A', TO_DATE('1980-01-01', 'YYYY-MM-DD'), '1');
    insert_t_bh_usuario('A', TO_DATE('1980-01-01', 'YYYY-MM-DD'), '1'); --simular insert
    insert_t_bh_usuario('B', TO_DATE('1980-02-02', 'YYYY-MM-DD'), '2');
    insert_t_bh_usuario('C', TO_DATE('1980-03-03', 'YYYY-MM-DD'), '3');
    insert_t_bh_usuario('D', TO_DATE('1980-04-04', 'YYYY-MM-DD'), '4');
    insert_t_bh_usuario('E', TO_DATE('1980-05-05', 'YYYY-MM-DD'), '5');
END;
/

CREATE OR REPLACE PROCEDURE insert_t_bh_agua (
    p_nm_cidade            IN VARCHAR2,
    p_nr_ph                 IN VARCHAR2,
    p_nr_oxigenio           IN VARCHAR2,
    p_nr_nitrato            IN VARCHAR2,
    p_nr_fosfato            IN VARCHAR2,
    p_nr_microplastico      IN VARCHAR2,
    p_nr_salinidade        IN VARCHAR2,
    p_st_qualidade_agua    IN CHAR,
    p_id_potencial         IN CHAR
) AS
    v_id_agua CHAR(9);
    v_id_erro CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Gera um novo ID usando a sequência
    v_id_agua := seq_agua.NEXTVAL;
    
    INSERT INTO t_bh_agua (id_agua, nm_cidade, nr_ph, nr_oxigenio, nr_nitrato, nr_fosfato, nr_microplastico, nr_salinidade, st_qualidade_agua, id_potencial)
    VALUES (v_id_agua, p_nm_cidade, p_nr_ph, p_nr_oxigenio, p_nr_nitrato, p_nr_fosfato, p_nr_microplastico, p_nr_salinidade, p_st_qualidade_agua, p_id_potencial);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_agua', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_agua', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_agua', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
END;


BEGIN
     insert_t_bh_agua('São Paulo', '7.0', '8.0', '1.0', '0.5', '0.1', '35.0', 'A', '1');
     insert_t_bh_agua('São Paulo', '7.0', '8.0', '1.0', '0.5', '0.1', '35.0', 'A', '1'); --simular insert
     insert_t_bh_agua('Rio de Janeiro', '6.8', '7.5', '1.2', '0.6', '0.2', '36.0', 'B', '2');
     insert_t_bh_agua('Salvador', '7.2', '7.8', '1.1', '0.4', '0.15', '34.0', 'A', '3');
     insert_t_bh_agua('Brasília', '7.1', '7.9', '1.3', '0.7', '0.25', '33.0', 'B', '4');
     insert_t_bh_agua('Fortaleza', '7.3', '8.1', '1.0', '0.3', '0.05', '32.0', 'A', '5');
END;



--SELECT*FROM T_BH_AGUA


CREATE OR REPLACE PROCEDURE insert_t_bh_checagem (
    p_dt_data              IN DATE,
    p_id_usuario           IN CHAR,
    p_id_agua              IN CHAR
) AS
    v_id_checagem CHAR(9);
    v_id_erro CHAR(9);
    v_dt_ocorrencia DATE;
    v_cd_erro INTEGER;
    v_ds_erro VARCHAR2(255);
BEGIN
    -- Gera um novo ID usando a sequência
    v_id_checagem := seq_checagem.NEXTVAL;
    
    INSERT INTO t_bh_checagem (id_checagem, dt_data, id_usuario, id_agua)
    VALUES (v_id_checagem, p_dt_data, p_id_usuario, p_id_agua);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_checagem', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro DUP_VAL_ON_INDEX capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN VALUE_ERROR THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_checagem', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro VALUE_ERROR capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
    WHEN OTHERS THEN
        -- Gera um novo ID para o erro usando a sequência
        v_id_erro := LPAD(seq_error.NEXTVAL, 9, '0');
        v_dt_ocorrencia := SYSDATE;
        v_cd_erro := SQLCODE;
        v_ds_erro := SQLERRM;
        -- Insere o erro no log
        INSERT INTO t_bh_error (id_erro, nm_procedure, nm_usuario, dt_ocorrencia, cd_error, ds_error)
        VALUES (v_id_erro, 'insert_t_bh_checagem', USER, v_dt_ocorrencia, v_cd_erro, v_ds_erro);
        DBMS_OUTPUT.PUT_LINE('Erro OTHERS capturado, cheque T_BH_ERROR para mais detalhes: ' || v_ds_erro);
END;


BEGIN
    insert_t_bh_checagem(TO_DATE('2022-01-01', 'YYYY-MM-DD'), '1', '1');
    insert_t_bh_checagem(TO_DATE('2022-01-01', 'YYYY-MM-DD'), '1', '1');--simular insert
    insert_t_bh_checagem(TO_DATE('2022-02-02', 'YYYY-MM-DD'), '2', '2');
    insert_t_bh_checagem(TO_DATE('2022-03-03', 'YYYY-MM-DD'), '3', '3');
    insert_t_bh_checagem(TO_DATE('2022-04-04', 'YYYY-MM-DD'), '4', '4');
    insert_t_bh_checagem(TO_DATE('2022-05-05', 'YYYY-MM-DD'), '5', '5');
END;
/

                 
                 
                 
 --blocos anonimos POTENCIAL
 DECLARE
    v_total NUMBER := 0;
    v_subtotal NUMBER := 0;
    v_current_city VARCHAR2(50);
BEGIN
    FOR r IN (SELECT nm_cidade, nr_escala
              FROM t_bh_potencial
              ORDER BY nm_cidade) LOOP
        IF v_current_city IS NULL THEN
            v_current_city := r.nm_cidade;
        ELSIF v_current_city != r.nm_cidade THEN
            DBMS_OUTPUT.PUT_LINE('Subtotal para ' || v_current_city || ': ' || v_subtotal);
            v_subtotal := 0;
            v_current_city := r.nm_cidade;
        END IF;
        v_subtotal := v_subtotal + r.nr_escala;
        v_total := v_total + r.nr_escala;
        DBMS_OUTPUT.PUT_LINE('Cidade: ' || r.nm_cidade || ', Escala: ' || r.nr_escala);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Subtotal para ' || v_current_city || ': ' || v_subtotal);
    DBMS_OUTPUT.PUT_LINE('Total Geral: ' || v_total);
END;
/

-- blocos anonimos CHECAGEM
DECLARE
    CURSOR c_checagem IS
        SELECT id_checagem, dt_data, id_usuario, id_agua
        FROM t_bh_checagem;
    v_record c_checagem%ROWTYPE;
BEGIN
    OPEN c_checagem;
    DBMS_OUTPUT.PUT_LINE('ID Checagem | Data | ID Usuário | ID Água');
    LOOP
        FETCH c_checagem INTO v_record;
        EXIT WHEN c_checagem%NOTFOUND;
        
        -- Tomada de decisão baseada no ID do usuário
        IF v_record.id_usuario = '1' THEN
            DBMS_OUTPUT.PUT_LINE(v_record.id_checagem || ' | ' || TO_CHAR(v_record.dt_data, 'YYYY-MM-DD') || ' | ' || v_record.id_usuario || ' | ' || v_record.id_agua || ' - Usuário 1');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_record.id_checagem || ' | ' || TO_CHAR(v_record.dt_data, 'YYYY-MM-DD') || ' | ' || v_record.id_usuario || ' | ' || v_record.id_agua);
        END IF;
    END LOOP;
    CLOSE c_checagem;
END;
/

                 
-- blocos anonimos CREDENCIAL
                 
   DECLARE
    CURSOR c_credencial IS
        SELECT id_credencial, ds_email, cd_senha
        FROM t_bh_credencial;
    v_record c_credencial%ROWTYPE;
BEGIN
    OPEN c_credencial;
    DBMS_OUTPUT.PUT_LINE('ID Credencial | Email | Senha');
    LOOP
        FETCH c_credencial INTO v_record;
        EXIT WHEN c_credencial%NOTFOUND;
        
        -- Tomada de decisão baseada no email
        IF v_record.ds_email = 'exemplo1@email.com' THEN
            DBMS_OUTPUT.PUT_LINE(v_record.id_credencial || ' | ' || v_record.ds_email || ' | ' || v_record.cd_senha || ' - Email Duplicado');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_record.id_credencial || ' | ' || v_record.ds_email || ' | ' || v_record.cd_senha);
        END IF;
    END LOOP;
    CLOSE c_credencial;
END;
/
              
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 




