>>SOURCE FORMAT IS FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. GENERATE-PAYROLL.
AUTHOR. GOVFLOW.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT PAYROLL-FILE ASSIGN TO "data/payroll.dat"
        ORGANIZATION IS SEQUENTIAL.

DATA DIVISION.
FILE SECTION.
FD PAYROLL-FILE.
01 PAYROLL-RECORD.
    05 EMP-ID             PIC 9(6).
    05 FIRST-NAME         PIC X(10).
    05 LAST-NAME          PIC X(10).
    05 GRADE              PIC X(4).
    05 DEPARTMENT         PIC X(10).
    05 START-DATE         PIC X(8).
    05 GROSS-SALARY       PIC 9(8).
    05 TAX-DEDUCTION      PIC 9(7).
    05 PENSION-DEDUCTION  PIC 9(7).
    05 NET-SALARY         PIC 9(8).
    05 PAY-PERIOD         PIC X(6).
    05 TAX-CODE           PIC X(4).
    05 PAYMENT-STATUS     PIC X(1).

WORKING-STORAGE SECTION.
01 WS-GROSS              PIC 9(8).
01 WS-TAX                PIC 9(7).
01 WS-PENSION            PIC 9(7).
01 WS-NET                PIC 9(8).
01 WS-COUNTER            PIC 9(4) VALUE 0.
01 WS-MOD                PIC 9(1).
01 WS-EMP-ID             PIC 9(6).

PROCEDURE DIVISION.
MAIN-PARA.
    OPEN OUTPUT PAYROLL-FILE
    PERFORM VARYING WS-COUNTER FROM 1 BY 1
        UNTIL WS-COUNTER > 5000
        PERFORM WRITE-EMPLOYEE
    END-PERFORM
    CLOSE PAYROLL-FILE
    STOP RUN.

WRITE-EMPLOYEE.
    MOVE WS-COUNTER TO WS-EMP-ID
    MOVE WS-EMP-ID  TO EMP-ID
    COMPUTE WS-MOD = FUNCTION MOD(WS-COUNTER, 5)
    IF WS-MOD = 1
        MOVE "JOHN      " TO FIRST-NAME
        MOVE "SMITH     " TO LAST-NAME
        MOVE "GRD5"       TO GRADE
        MOVE "FINANCE   " TO DEPARTMENT
        MOVE "TX01"       TO TAX-CODE
        MOVE 45000        TO WS-GROSS
    ELSE
        IF WS-MOD = 2
            MOVE "MARY      " TO FIRST-NAME
            MOVE "JONES     " TO LAST-NAME
            MOVE "GRD3"       TO GRADE
            MOVE "HR        " TO DEPARTMENT
            MOVE "TX02"       TO TAX-CODE
            MOVE 62000        TO WS-GROSS
        ELSE
            IF WS-MOD = 3
                MOVE "JAMES     " TO FIRST-NAME
                MOVE "BROWN     " TO LAST-NAME
                MOVE "GRD7"       TO GRADE
                MOVE "IT        " TO DEPARTMENT
                MOVE "TX03"       TO TAX-CODE
                MOVE 78000        TO WS-GROSS
            ELSE
                IF WS-MOD = 4
                    MOVE "SARAH     " TO FIRST-NAME
                    MOVE "DAVIS     " TO LAST-NAME
                    MOVE "GRD2"       TO GRADE
                    MOVE "LEGAL     " TO DEPARTMENT
                    MOVE "TX01"       TO TAX-CODE
                    MOVE 38000        TO WS-GROSS
                ELSE
                    MOVE "PETER     " TO FIRST-NAME
                    MOVE "WILSON    " TO LAST-NAME
                    MOVE "GRD6"       TO GRADE
                    MOVE "FINANCE   " TO DEPARTMENT
                    MOVE "TX02"       TO TAX-CODE
                    MOVE 55000        TO WS-GROSS
                END-IF
            END-IF
        END-IF
    END-IF
    MOVE "20150101"   TO START-DATE
    COMPUTE WS-TAX     = WS-GROSS * 15 / 100
    COMPUTE WS-PENSION = WS-GROSS * 5 / 100
    COMPUTE WS-NET     = WS-GROSS - WS-TAX - WS-PENSION
    MOVE WS-GROSS     TO GROSS-SALARY
    MOVE WS-TAX       TO TAX-DEDUCTION
    MOVE WS-PENSION   TO PENSION-DEDUCTION
    MOVE WS-NET       TO NET-SALARY
    MOVE "202401"     TO PAY-PERIOD
    MOVE "A"          TO PAYMENT-STATUS
    WRITE PAYROLL-RECORD.
    