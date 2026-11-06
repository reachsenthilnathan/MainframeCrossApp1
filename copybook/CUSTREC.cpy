      *****************************************************************
      * CUSTREC - Customer master record, VSAM KSDS key CUST-ID
      * (owned by App1). Read-only for App2 and App3.
      *****************************************************************
       01  CUSTOMER-RECORD.
           05  CUST-ID                 PIC 9(8).
           05  CUST-NAME               PIC X(30).
           05  CUST-STATUS             PIC X(1).
               88  CUST-ACTIVE         VALUE 'A'.
               88  CUST-CLOSED         VALUE 'C'.
           05  CUST-OPEN-DATE          PIC X(10).
