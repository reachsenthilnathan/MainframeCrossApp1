//CUSTDEF  JOB (ACCT),'DEFINE CUSTMAST',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID
//*********************************************************************
//* CUSTDEF - App1. Defines the empty customer master KSDS (CUSTMAST).
//*           Re-runnable: deletes any existing cluster first.
//*           Record layout: copybook CUSTREC, 49 bytes, key = CUST-ID
//*           (offset 0, length 8).
//* Change HLQ below to your own high-level qualifier.
//*********************************************************************
//         SET HLQ=IBMUSER
//DEFINE   EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *,SYMBOLS=JCLONLY
  DELETE (&HLQ..CROSSAPP.CUSTMAST) CLUSTER PURGE
  SET MAXCC=0
  DEFINE CLUSTER (NAME(&HLQ..CROSSAPP.CUSTMAST) -
         INDEXED -
         KEYS(8 0) -
         RECORDSIZE(49 49) -
         FREESPACE(10 10) -
         SHAREOPTIONS(2 3) -
         TRACKS(1 1))
/*
