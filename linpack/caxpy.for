C***********************************************************************
c*CAXPY - Complex constant times a vector, plus a vector.
c:BLAS
c+
      SUBROUTINE CAXPY(N,CA,CX,INCX,CY,INCY)
C
C     CONSTANT TIMES A VECTOR PLUS A VECTOR.
C     JACK DONGARRA, LINPACK, 3/11/78.
C
C--
      COMPLEX CX(1),CY(1),CA
      INTEGER I,INCX,INCY,IX,IY,N
C
      IF(N.LE.0)RETURN
      IF (ABS(REAL(CA)) + ABS(AIMAG(CA)) .EQ. 0.0 ) RETURN
      IF(INCX.EQ.1.AND.INCY.EQ.1)GO TO 20
C
C	 CODE FOR UNEQUAL INCREMENTS OR EQUAL INCREMENTS
C	   NOT EQUAL TO 1
C
      IX = 1
      IY = 1
      IF(INCX.LT.0)IX = (-N+1)*INCX + 1
      IF(INCY.LT.0)IY = (-N+1)*INCY + 1
      DO 10 I = 1,N
	CY(IY) = CY(IY) + CA*CX(IX)
	IX = IX + INCX
	IY = IY + INCY
   10 CONTINUE
      RETURN
C
C	 CODE FOR BOTH INCREMENTS EQUAL TO 1
C
   20 DO 30 I = 1,N
	CY(I) = CY(I) + CA*CX(I)
   30 CONTINUE
      RETURN
      END
