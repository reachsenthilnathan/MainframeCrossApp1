       IDENTIFICATION DIVISION.
       PROGRAM-ID. DATEUTIL.
      *****************************************************************
      * DATEUTIL - Returns the current date as YYYY-MM-DD.
      * Owned by App1. Called by App3 (STMTGEN).
      *****************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY RETCODES.
       01  WS-DATE.
           05  WS-YYYY                 PIC X(4).
           05  WS-MM                   PIC X(2).
           05  WS-DD                   PIC X(2).
       LINKAGE SECTION.
           COPY DATELNK.
       PROCEDURE DIVISION USING DATE-PARMS.
       MAIN-PARA.
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           STRING WS-YYYY '-' WS-MM '-' WS-DD
               DELIMITED BY SIZE INTO DL-FORMATTED-DATE
           MOVE RC-OK TO DL-RETURN-CODE
           GOBACK.
