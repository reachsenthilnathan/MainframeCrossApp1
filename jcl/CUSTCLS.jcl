//CUSTCLS  JOB (ACCT),'RUN CUSTMNT CLOSE',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID
//*********************************************************************
//* CUSTCLS - App1. Runs CUSTMNT with CLOSE requests (action C).
//*           Run after ACCTDEF and TXNRUN.
//* Each close calls ACCTCHK (App2) DYNAMICALLY, so this job needs:
//*   - the App2 load library on STEPLIB, and
//*   - the App2 account master DDs (ACCTMAST and its alternate-index
//*     path ACCTMAS1), which ACCTCHK opens inside this job step.
//* Neither is needed by CUSTRUN, which only adds customers.
//* If the programs are compiled with DYNAM, the static CALLs also
//* become dynamic and the App1 load library alone is not enough for
//* them; keep both libraries on STEPLIB in that case.
//*
//* Expected results:
//*   C10000003  customer has no accounts          -> closed
//*   C10000001  customer has 2 open accounts      -> not closed, RC=4
//* Expected job return code: 4.
//* Change HLQ below to your own high-level qualifier.
//*********************************************************************
//         SET HLQ=IBMUSER
//BLDIN    EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD *
C10000003
C10000001
/*
//SORTOUT  DD DSN=&&CUSTIN,DISP=(NEW,PASS),
//             RECFM=FB,LRECL=39,SPACE=(TRK,(1,1))
//SYSIN    DD *
  SORT FIELDS=COPY
  OUTREC BUILD=(1,39)
/*
//RUN      EXEC PGM=CUSTMNT
//STEPLIB  DD DISP=SHR,DSN=&HLQ..APP1.LOAD
//         DD DISP=SHR,DSN=&HLQ..APP2.LOAD
//SYSOUT   DD SYSOUT=*
//CUSTIN   DD DSN=&&CUSTIN,DISP=(OLD,DELETE)
//CUSTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.CUSTMAST
//ACCTMAST DD DISP=SHR,DSN=&HLQ..CROSSAPP.ACCTMAST
//ACCTMAS1 DD DISP=SHR,DSN=&HLQ..CROSSAPP.ACCTMAST.PATH
