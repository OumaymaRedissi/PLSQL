-- OUVRAGE(IDO,TITRE,ANNEE,THEME,LIKES,DISLIKES)
-- COPIE(IDC,ETAT,IDO#)
-- ETUDIANT(IDE,CIN,NOM,CURSUS)
-- PRET(IDC#,IDE#,DATEP,DATER,AVIS,IDB#)
-- BIBLIO(IDB,NOM)
DROP USER BIBLIO CASCADE;
DROP USER TAREK;
DROP USER JIHED;
-- Création de l'utilisateur BIBLIO password sgbd tablespace USERS
CREATE USER BIBLIO IDENTIFIED BY sgbd
DEFAULT TABLESPACE USERS
QUOTA 10M ON USERS;
--Affecter à projet les privilèges qu'il faut pour se connecter, créer des tables, des vues, des indexes, des synonymes, des procédures, des séquences et des triggers.
GRANT CREATE SESSION, CREATE USER, CREATE TABLE, CREATE VIEW, CREATE SYNONYM, CREATE SEQUENCE, CREATE PROCEDURE, CREATE TRIGGER TO BIBLIO;
--Se connecter en tant que projet
CONNECT biblio/sgbd;
--création base
CREATE TABLE OUVRAGE(IDO VARCHAR2(10) PRIMARY KEY,TITRE VARCHAR2(100),ANNEE NUMBER,THEME VARCHAR2(30),LIKES NUMBER,DISLIKES NUMBER);
CREATE TABLE COPIE(IDC VARCHAR2(10) PRIMARY KEY,ETAT CHAR(1) CHECK (ETAT IN ('M','P','D')), IDO VARCHAR2(10) REFERENCES OUVRAGE(IDO));
CREATE TABLE ETUDIANT(IDE VARCHAR2(10) PRIMARY KEY,CIN VARCHAR2(8) UNIQUE, NOM VARCHAR2(30),CURSUS VARCHAR2(20));
CREATE TABLE BIBLIO(IDB VARCHAR2(10) PRIMARY KEY,NOM VARCHAR2(30));
CREATE TABLE PRET(IDC VARCHAR2(10) REFERENCES COPIE(IDC),IDE REFERENCES ETUDIANT(IDE),DATEP DATE,DATER DATE, AVIS VARCHAR2(7) CHECK (AVIS IN ('LIKE','DISLIKE')),IDB VARCHAR2(10) REFERENCES BIBLIO(IDB),PRIMARY KEY(IDC,IDE,DATEP));
--Création d'une séquence pour chacune des tables ouvrages, copie et etudiant
CREATE SEQUENCE ouv_pk MINVALUE 1 MAXVALUE 100
START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE cop_pk MINVALUE 1 MAXVALUE 100
START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE et_pk MINVALUE 1 MAXVALUE 100
START WITH 1 INCREMENT BY 1 NOCYCLE;
CREATE SEQUENCE bib_pk MINVALUE 1 MAXVALUE 100
START WITH 1 INCREMENT BY 1 NOCYCLE;
--Insertion de lignes échantillons
----Insertion de 10 ouvrages
DECLARE
  TYPE tab_titres IS VARRAY(10) OF VARCHAR2(100);
  titres tab_titres := tab_titres('Bases de données','Systèmes exploitation','Systèmes informations', 'Réseaux informatiques','Business Intelligence','A new IS architecture','Digital Marketing','A comparative study of customer behavior analysis methods','Comptabilité','Principes de gestion');
  TYPE tab_themes IS VARRAY(3) OF VARCHAR2(15);
  themes tab_themes := tab_themes('Informatique','Gestion');
BEGIN
  FOR i IN 1..6 LOOP
    INSERT INTO OUVRAGE VALUES('O'||ouv_pk.NEXTVAL, titres(i), ROUND(DBMS_RANDOM.VALUE(2000,2010)),'Informatique',0,0);
  END LOOP;
  FOR i IN 7..10 LOOP
    INSERT INTO OUVRAGE VALUES('O'||ouv_pk.NEXTVAL, titres(i), ROUND(DBMS_RANDOM.VALUE(2000,2010)),'Gestion',0,0);
  END LOOP;
END;
/
----Insertion de deux copies disponibles pour chaque ouvrage
BEGIN
	FOR rec_ouv IN (SELECT * FROM ouvrage) LOOP
		FOR i IN 1..5 LOOP
			INSERT INTO COPIE VALUES('C'||cop_pk.NEXTVAL,'D',rec_ouv.ido);
		END LOOP;
	END LOOP;
END;
/
----Insertion d'étudiants
DECLARE
	TYPE tab_noms IS VARRAY(10) OF VARCHAR2(10);
	noms tab_noms := tab_noms('ALI','MONIA','SAMI','KHADIJA','MOURAD','KARIMA','RAMI','SONIA','KHALIL','LINA');
	TYPE tab_cursus IS VARRAY(3) OF VARCHAR2(10);
	cursus tab_cursus := tab_cursus('DSSD','E-BUSINESS','VIC');
BEGIN
	FOR i IN 1..50 LOOP
		INSERT INTO ETUDIANT VALUES('E'||et_pk.NEXTVAL,
		TO_CHAR(ROUND(DBMS_RANDOM.VALUE(10000000,90000000))),
		noms(ROUND(DBMS_RANDOM.VALUE(1,10))),
		cursus(ROUND(DBMS_RANDOM.VALUE(1,3))));
	END LOOP;
END;
/

----Insertion de bibliothécaires
INSERT INTO BIBLIO VALUES('B'||bib_pk.NEXTVAL,'TAREK');
INSERT INTO BIBLIO VALUES('B'||bib_pk.NEXTVAL,'JIHED');
INSERT INTO BIBLIO VALUES('B'||bib_pk.NEXTVAL,'BIBLIO');

----Insertion de prêts
DECLARE
	TYPE tab_avis IS VARRAY(2) OF VARCHAR2(10);
	avis tab_avis := tab_avis('LIKE','DISLIKE');
	v_idc COPIE.IDC%TYPE;
	v_ide ETUDIANT.IDE%TYPE;
	v_idb BIBLIO.IDB%TYPE;
	v_datep DATE;
	v_dater DATE;
BEGIN
	FOR i IN 1..50 LOOP
		SELECT IDC INTO v_idc FROM (SELECT IDC FROM COPIE
			WHERE IDC NOT IN(SELECT IDC FROM PRET)
			ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1;
		SELECT IDE INTO v_ide FROM (SELECT IDE FROM ETUDIANT ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1;
		SELECT IDB INTO v_idb FROM (SELECT IDB FROM BIBLIO ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1;
		v_datep:= SYSDATE - ROUND(DBMS_RANDOM.VALUE(1,60));
		v_dater:= SYSDATE - ROUND(DBMS_RANDOM.VALUE(1,60));
		IF v_dater < v_datep THEN
			v_dater:=NULL;
		END IF;
		INSERT INTO PRET VALUES(v_idc,v_ide,v_datep,v_dater,avis(ROUND(DBMS_RANDOM.VALUE(1,2))),v_idb);
	END LOOP;
END;
/
COMMIT;

--Création des utilisateurs TAREK et JIHED avec le password sgbd
CREATE USER TAREK IDENTIFIED BY sgbd
DEFAULT TABLESPACE USERS
QUOTA 10M ON USERS;

CREATE USER JIHED IDENTIFIED BY sgbd
DEFAULT TABLESPACE USERS
QUOTA 10M ON USERS;