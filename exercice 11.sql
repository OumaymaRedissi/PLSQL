--exercice11
CREATE VIEW V_CTO AS SELECT E.CURSUS, O.THEME, O.TITRE, COUNT(*) AS NOMBRE 
FROM OUVRAGE O, ETUDIANT E, PRET P, COPIE C
WHERE O.IDO=C.IDO AND E.IDE=P.IDE AND P.IDC=C.IDC GROUP BY (E.CURSUS,O.THEME,O.TITRE);