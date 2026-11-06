      *****************************************************************
      * CLOSELNK - Parameter block for the customer-closure check
      * (owned by App1). Used by CUSTMNT (caller, App1) and by
      * ACCTCHK (callee, App2).
      *****************************************************************
       01  CLOSE-PARMS.
           05  CL-CUSTOMER-ID          PIC 9(8).
           05  CL-OPEN-ACCT-COUNT      PIC 9(4) COMP.
           05  CL-RETURN-CODE          PIC S9(4) COMP.
