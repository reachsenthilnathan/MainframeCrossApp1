       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTVAL.
      *****************************************************************
      * CUSTVAL - Validates a customer id and name.
      * Owned by App1. Called by App2 (ACCTMGR) and App3 (STMTGEN).
      *****************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY RETCODES.
       LINKAGE SECTION.
           COPY CUSTVLNK.
       PROCEDURE DIVISION USING CUSTVAL-PARMS.
       MAIN-PARA.
           MOVE RC-OK TO CV-RETURN-CODE
           IF CV-CUSTOMER-ID = ZERO
               MOVE RC-INVALID TO CV-RETURN-CODE
           END-IF
           IF CV-CUSTOMER-NAME = SPACES
               MOVE RC-INVALID TO CV-RETURN-CODE
           END-IF
           GOBACK.
