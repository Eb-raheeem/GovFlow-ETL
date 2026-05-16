//GOVFLOW  JOB (ACCT001),'PAYROLL GEN',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//*
//* ================================================
//* JOB:    GOVFLOW PAYROLL GENERATION
//* DESC:   RUNS COBOL PROGRAM TO GENERATE PAYROLL
//*         FLAT FILE FOR ETL PROCESSING
//* AUTHOR: GOVFLOW
//* DATE:   2024-01-01
//* ================================================
//*
//STEP010  EXEC PGM=GENERATE-PAYROLL
//*
//STEPLIB  DD DSN=GOVFLOW.LOADLIB,
//            DISP=SHR
//*
//PAYFILE  DD DSN=GOVFLOW.DATA.PAYROLL,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(CYL,(5,2),RLSE),
//            DCB=(RECFM=FB,LRECL=089,BLKSIZE=8990)
//*
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//*
//SYSPRINT DD SYSOUT=*