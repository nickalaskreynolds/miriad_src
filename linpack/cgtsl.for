C**********************************************************************
c*CGTSL -- Solve complex tridiagonal matrix.
c:LINPACK
c+
      SUBROUTINE CGTSL(N,C,D,E,B,INFO)
      INTEGER N,INFO
      COMPLEX C(1),D(1),E(1),B(1)
C
C     CGTSL GIVEN A GENERAL TRIDIAGONAL MATRIX AND A RIGHT HAND
C     SIDE WILL FIND THE SOLUTION.
C
C     ON ENTRY
C
C	 N	 INTEGER
C		 IS THE ORDER OF THE TRIDIAGONAL MATRIX.
C
C	 C	 COMPLEX(N)
C		 IS THE SUBDIAGONAL OF THE TRIDIAGONAL MATRIX.
C		 C(2) THROUGH C(N) SHOULD CONTAIN THE SUBDIAGONAL.
C		 ON OUTPUT C IS DESTROYED.
C
C	 D	 COMPLEX(N)
C		 IS THE DIAGONAL OF THE TRIDIAGONAL MATRIX.
C		 ON OUTPUT D IS DESTROYED.
C
C	 E	 COMPLEX(N)
C		 IS THE SUPERDIAGONAL OF THE TRIDIAGONAL MATRIX.
C		 E(1) THROUGH E(N-1) SHOULD CONTAIN THE SUPERDIAGONAL.
C		 ON OUTPUT E IS DESTROYED.
C
C	 B	 COMPLEX(N)
C		 IS THE RIGHT HAND SIDE VECTOR.
C
C     ON RETURN
C
C	 B	 IS THE SOLUTION VECTOR.
C
C	 INFO	 INTEGER
C		 = 0 NORMAL VALUE.
C		 = K IF THE K-TH ELEMENT OF THE DIAGONAL BECOMES
C		     EXACTLY ZERO.  THE SUBROUTINE RETURNS WHEN
C		     THIS IS DETECTED.
C
C--
C     LINPACK. THIS VERSION DATED 08/14/78 .
C     JACK DONGARRA, ARGONNE NATIONAL LABORATORY.
C
C     NO EXTERNALS
C     FORTRAN ABS,AIMAG,REAL
C
C     INTERNAL VARIABLES
C
      INTEGER K,KB,KP1,NM1,NM2
      COMPLEX T
      COMPLEX ZDUM
      REAL CABS1
      CABS1(ZDUM) = ABS(REAL(ZDUM)) + ABS(AIMAG(ZDUM))
C     BEGIN BLOCK PERMITTING ...EXITS TO 100
C
	 INFO = 0
	 C(1) = D(1)
	 NM1 = N - 1
	 IF (NM1 .LT. 1) GO TO 40
	    D(1) = E(1)
	    E(1) = (0.0E0,0.0E0)
	    E(N) = (0.0E0,0.0E0)
C
	    DO 30 K = 1, NM1
	       KP1 = K + 1
C
C	       FIND THE LARGEST OF THE TWO ROWS
C
	       IF (CABS1(C(KP1)) .LT. CABS1(C(K))) GO TO 10
C
C		  INTERCHANGE ROW
C
		  T = C(KP1)
		  C(KP1) = C(K)
		  C(K) = T
		  T = D(KP1)
		  D(KP1) = D(K)
		  D(K) = T
		  T = E(KP1)
		  E(KP1) = E(K)
		  E(K) = T
		  T = B(KP1)
		  B(KP1) = B(K)
		  B(K) = T
   10	       CONTINUE
C
C	       ZERO ELEMENTS
C
	       IF (CABS1(C(K)) .NE. 0.0E0) GO TO 20
		  INFO = K
C     ............EXIT
		  GO TO 100
   20	       CONTINUE
	       T = -C(KP1)/C(K)
	       C(KP1) = D(KP1) + T*D(K)
	       D(KP1) = E(KP1) + T*E(K)
	       E(KP1) = (0.0E0,0.0E0)
	       B(KP1) = B(KP1) + T*B(K)
   30	    CONTINUE
   40	 CONTINUE
	 IF (CABS1(C(N)) .NE. 0.0E0) GO TO 50
	    INFO = N
	 GO TO 90
   50	 CONTINUE
C
C	    BACK SOLVE
C
	    NM2 = N - 2
	    B(N) = B(N)/C(N)
	    IF (N .EQ. 1) GO TO 80
	       B(NM1) = (B(NM1) - D(NM1)*B(N))/C(NM1)
	       IF (NM2 .LT. 1) GO TO 70
	       DO 60 KB = 1, NM2
		  K = NM2 - KB + 1
		  B(K) = (B(K) - D(K)*B(K+1) - E(K)*B(K+2))/C(K)
   60	       CONTINUE
   70	       CONTINUE
   80	    CONTINUE
   90	 CONTINUE
  100 CONTINUE
C
      RETURN
      END
