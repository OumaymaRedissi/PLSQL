--exercice6
CREATE OR REPLACE TRIGGER T_MAJ_D AFTER UPDATE OF DATER ON PRET 
FOR EACH ROW 
BEGIN 
    IF :OLD.DATER IS NULL AND :NEW.DATER IS NOT NULL THEN 
            UPDATE COPIE SET ETAT='D' 
             WHERE IDC=:OLD.IDC;
    END IF;

END;
/