      SUBROUTINE POSAPX(LUNXX)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    POSAPX
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1994-01-06
C
C ABSTRACT: THIS SUBROUTINE READS TO THE END OF THE FILE POINTED TO BY
C   ABS(LUNXX) AND POSITIONS IT FOR APPENDING.  THE FILE MUST HAVE
C   ALREADY BEEN OPENED FOR OUTPUT OPERATIONS.  IF LUNXX > 0, THE FILE
C   IS BACKSPACED BEFORE BEING POSITIONED FOR APPEND.
C
C PROGRAM HISTORY LOG:
C 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C                           ROUTINE "BORT"
C 2000-09-19  J. WOOLLEN -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C                           10,000 TO 20,000 BYTES
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C                           DOCUMENTATION (INCLUDING HISTORY); OUTPUTS
C                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C                           TERMINATES ABNORMALLY
C 2004-08-09  J. ATOR    -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C                           20,000 TO 50,000 BYTES
C 2009-03-23  J. ATOR    -- MODIFIED TO HANDLE EMBEDDED BUFR TABLE
C                           (DICTIONARY) MESSAGES; ADDED LUNXX < 0
C                           OPTION TO SIMULATE POSAPN
C 2010-05-11  J. ATOR    -- SET ISCODES TO -1 IF UNSUCCESSFUL
C 2012-09-15  J. WOOLLEN -- MODIFIED FOR C/I/O/BUFR INTERFACE;
C                           REPLACE FORTRAN BACKSPACE WITH C BACKBUFR
C                           REMOVE UNECESSARY ERROR CHECKING LOGIC    
C
C USAGE:    CALL POSAPX (LUNXX)
C   INPUT ARGUMENT LIST:
C     LUNXX    - INTEGER: ABSOLUTE VALUE IS FORTRAN LOGICAL UNIT NUMBER
C                FOR BUFR FILE (IF LUNXX < 0, THEN THE FILE IS NOT
C                BACKSPACED BEFORE POSITIONING FOR APPEND)
C
C   INPUT FILES:
C     UNIT "LUNIT" - BUFR FILE
C
C REMARKS:
C    THIS ROUTINE CALLS:        BORT     IDXMSG   RDBFDX   RDMSGW
C                               STATUS   BACKBUFR
C    THIS ROUTINE IS CALLED BY: OPENBF
C                               Normally not called by any application
C                               programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      INCLUDE 'bufrlib.prm'

      DIMENSION   MBAY(MXMSGLD4)

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

      LUNIT = ABS(LUNXX)

      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(IL.EQ.0) GOTO 901
      IF(IL.LT.0) GOTO 902

C  TRY TO READ TO THE END OF THE FILE
C  ----------------------------------

1     CALL RDMSGW(LUNIT,MBAY,IER)
      IF(IER.LT.0) RETURN
      IF(IDXMSG(MBAY).EQ.1) THEN

C	This is an internal dictionary message that was generated by the
C	BUFR archive library software.  Backspace the file pointer and
C	then read and store all such dictionary messages (they should be
C	stored consecutively!) and reset the internal tables.

	call backbufr(lun) !BACKSPACE LUNIT
	CALL RDBFDX(LUNIT,LUN)

      ENDIF
      GOTO 1

C  ERROR EXITS
C  -----------

901   CALL BORT('BUFRLIB: POSAPX - INPUT BUFR FILE IS CLOSED, IT MUST'//
     . ' BE OPEN FOR OUTPUT')
902   CALL BORT('BUFRLIB: POSAPX - INPUT BUFR FILE IS OPEN FOR INPUT'//
     . ', IT MUST BE OPEN FOR OUTPUT')
      END