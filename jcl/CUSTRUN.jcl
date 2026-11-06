//CUSTRUN  JOB (ACCT),'RUN CUSTMNT ADD',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID
//*********************************************************************
//* CUSTRUN - App1. Runs CUSTMNT with ADD requests (action A).
//*           Run after CUSTDEF. Expected return code: 0.
//* Request layout (CUSTIN): col 1 action, cols 2-9 customer id,
//* cols 10-39 name. DFSORT trims the 80-byte instream records to the
//* 39-byte record that the CUSTIN FD expects.
//* CUSTMNT static-calls CUSTVAL and DATEUTIL, which are link-edited
//* into its load module, so only the App1 load library is needed.
//* Change HLQ below to your own high-level qualifier.
//*********************************************************************
//         SET HLQ=IBMUSER
//BLDIN    EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD *
A10000001ALICE EXAMPLE
A10000002BOB EXAMPLE
A10000003CAROL EXAMPLE
/*
//SORTOUT  DD DSN=&&CUSTIN,DISP=(NEW,PASS),
//             RECFM=FB,LRECL=39,SPACE=(TRK,(1,1))
//SYSIN    DD *
  SORT FIELDS=COPY
  OUTREC BUILD=(1,39)
/*
//RUN      EXEC PGM=CUSTMNT
//STEPLIB  DD DISP=SHR,DSN=&HLQ..APP1.LOAD
//SYSOUT   DD SYSOUT=*
//CUSTIN   DD DSN=&&CUSTIN,DISP=(OLD,DELETE)
//CUSTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.CUSTMAST
