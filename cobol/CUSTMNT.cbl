       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTMNT.
      *****************************************************************
      * CUSTMNT - Customer maintenance. Adds and closes customers on
      * the customer master (VSAM KSDS, DD CUSTMAST), driven by the
      * request file CUSTIN (action A=add, C=close).
      * Owned by App1.
      * Static CALL  : CUSTVAL, DATEUTIL (App1).
      * Dynamic CALL : ACCTCHK (App2), called by data name and
      *                resolved at run time from STEPLIB. Build-time
      *                dependency analysis cannot see this link.
      *****************************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTIN   ASSIGN TO CUSTIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-IN-FS.
           SELECT CUSTMAST ASSIGN TO CUSTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CUST-ID
               FILE STATUS IS WS-CUST-FS.
       DATA DIVISION.
       FILE SECTION.
       FD  CUSTIN.
       01  CUSTIN-REC.
           05  CI-ACTION               PIC X(1).
               88  CI-ADD              VALUE 'A'.
               88  CI-CLOSE            VALUE 'C'.
           05  CI-ID                   PIC 9(8).
           05  CI-NAME                 PIC X(30).
       FD  CUSTMAST.
           COPY CUSTREC.
       WORKING-STORAGE SECTION.
           COPY RETCODES.
           COPY CUSTVLNK.
           COPY CLOSELNK.
           COPY DATELNK.
       01  WS-ACCTCHK-NAME             PIC X(8) VALUE 'ACCTCHK'.
       01  WS-IN-FS                    PIC X(2).
       01  WS-CUST-FS                  PIC X(2).
       01  WS-EOF-SW                   PIC X(1) VALUE 'N'.
           88  WS-EOF                  VALUE 'Y'.
       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE RC-OK TO RETURN-CODE
           OPEN INPUT CUSTIN
           OPEN I-O CUSTMAST
           IF WS-IN-FS NOT = '00' OR WS-CUST-FS NOT = '00'
               DISPLAY 'CUSTMNT: OPEN FAILED, STATUS ' WS-IN-FS
                       ' ' WS-CUST-FS
               MOVE RC-ERROR TO RETURN-CODE
               GOBACK
           END-IF

           CALL 'DATEUTIL' USING DATE-PARMS

           PERFORM UNTIL WS-EOF
               READ CUSTIN
                   AT END
                       SET WS-EOF TO TRUE
                   NOT AT END
                       PERFORM PROCESS-REQUEST
               END-READ
               IF WS-IN-FS NOT = '00' AND WS-IN-FS NOT = '10'
                   DISPLAY 'CUSTMNT: READ FAILED, STATUS ' WS-IN-FS
                   PERFORM RAISE-ERROR
                   SET WS-EOF TO TRUE
               END-IF
           END-PERFORM

           CLOSE CUSTIN
           CLOSE CUSTMAST
           GOBACK.

       PROCESS-REQUEST.
           EVALUATE TRUE
               WHEN CI-ADD
                   PERFORM ADD-REQUEST
               WHEN CI-CLOSE
                   PERFORM CLOSE-REQUEST
               WHEN OTHER
                   DISPLAY 'CUSTMNT: UNKNOWN ACTION ' CI-ACTION
                   PERFORM RAISE-INVALID
           END-EVALUATE.

       ADD-REQUEST.
           MOVE CI-ID   TO CV-CUSTOMER-ID
           MOVE CI-NAME TO CV-CUSTOMER-NAME
           CALL 'CUSTVAL' USING CUSTVAL-PARMS
           IF CV-RETURN-CODE NOT = RC-OK
               DISPLAY 'CUSTMNT: INVALID CUSTOMER ' CI-ID
               PERFORM RAISE-INVALID
           ELSE
               MOVE CI-ID   TO CUST-ID
               MOVE CI-NAME TO CUST-NAME
               SET CUST-ACTIVE TO TRUE
               MOVE DL-FORMATTED-DATE TO CUST-OPEN-DATE
               WRITE CUSTOMER-RECORD
                   INVALID KEY
                       DISPLAY 'CUSTMNT: DUPLICATE CUSTOMER ' CI-ID
                       PERFORM RAISE-INVALID
                   NOT INVALID KEY
                       DISPLAY 'CUSTMNT: ADDED CUSTOMER ' CI-ID
               END-WRITE
           END-IF.

       CLOSE-REQUEST.
           MOVE CI-ID TO CUST-ID
           READ CUSTMAST
               INVALID KEY
                   DISPLAY 'CUSTMNT: CUSTOMER NOT FOUND ' CI-ID
                   PERFORM RAISE-INVALID
               NOT INVALID KEY
                   PERFORM CHECK-AND-CLOSE
           END-READ.

       CHECK-AND-CLOSE.
           MOVE CUST-ID TO CL-CUSTOMER-ID
           MOVE ZERO    TO CL-OPEN-ACCT-COUNT
           CALL WS-ACCTCHK-NAME USING CLOSE-PARMS
               ON EXCEPTION
                   DISPLAY 'CUSTMNT: ACCTCHK NOT AVAILABLE'
                   MOVE RC-ERROR TO CL-RETURN-CODE
           END-CALL
           IF CL-RETURN-CODE NOT = RC-OK
               DISPLAY 'CUSTMNT: ACCOUNT CHECK FAILED, RC='
                       CL-RETURN-CODE
               PERFORM RAISE-ERROR
           ELSE
               IF CL-OPEN-ACCT-COUNT > ZERO
                   DISPLAY 'CUSTMNT: CANNOT CLOSE ' CUST-ID
                           ', OPEN ACCOUNTS=' CL-OPEN-ACCT-COUNT
                   PERFORM RAISE-WARNING
               ELSE
                   SET CUST-CLOSED TO TRUE
                   REWRITE CUSTOMER-RECORD
                       INVALID KEY
                           DISPLAY 'CUSTMNT: REWRITE FAILED ' CUST-ID
                           PERFORM RAISE-ERROR
                       NOT INVALID KEY
                           DISPLAY 'CUSTMNT: CLOSED CUSTOMER ' CUST-ID
                   END-REWRITE
               END-IF
           END-IF.

       RAISE-WARNING.
           IF RETURN-CODE < RC-WARNING
               MOVE RC-WARNING TO RETURN-CODE
           END-IF.

       RAISE-INVALID.
           IF RETURN-CODE < RC-INVALID
               MOVE RC-INVALID TO RETURN-CODE
           END-IF.

       RAISE-ERROR.
           IF RETURN-CODE < RC-ERROR
               MOVE RC-ERROR TO RETURN-CODE
           END-IF.
