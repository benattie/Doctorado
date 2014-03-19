	PROGRAM CFHexagonales	
	IMPLICIT NONE
	REAL RAND,BA,RX,DA,RM,DMAX,R2,S1,S2,S3,R,RMIN,R2MIN
	REAL(4) A0,A1,P,CHK0,T,U,V,W,H,Q1,Q2
	REAL,DIMENSION(4):: X
	REAL,DIMENSION(10):: Y,ZX,C,B
	REAL,DIMENSION(10,10):: A
	INTEGER I,J,N,L,K
	OPEN(UNIT=1,STATUS='UNKNOWN',FILE='AZX.DAT')
	OPEN(UNIT=2,STATUS='UNKNOWN',FILE='Breadth.DAT')
	OPEN(UNIT=3,STATUS='UNKNOWN',FILE='ContrastFactors.DAT')
	OPEN(UNIT=4,STATUS='UNKNOWN',FILE='ContFactCUADRÁTICA.DAT')
	OPEN(UNIT=5,STATUS='UNKNOWN',FILE='XUngar.DAT')
	OPEN(UNIT=6,STATUS='UNKNOWN',FILE='CoefCF.DAT')
	OPEN(UNIT=7,STATUS='UNKNOWN',FILE='CUADRÁTICA.DAT')
	
	N=8
	DO I=1,N
		READ(1,*) ZX(I)
		READ(2,*) Y(I)
		READ(5,*) B(I)
	ENDDO
	CLOSE(UNIT=1)
	CLOSE(UNIT=2)
	CLOSE(UNIT=5)
	DA=0
	RMIN=0.615
	!R2MIN=0.882
	DMAX=2000
	DO WHILE (DA.LE.DMAX)
		R=0
		R2=0
		DO I=1,N
			C(I)=0
			A(I,1)=0
			A(I,2)=0
		ENDDO
		CALL CAMBIOC(N,B,C,CHK0,Q1,Q2)
		DO WHILE (C(1).LT.0.OR.C(2).LT.0.OR.C(3).LT.0.OR.C(4).LT.0.OR.C(5).LT.0.OR.C(6).LT.0.OR.C(7).LT.0.OR.C(8).LT.0)
			CALL CAMBIOC(N,B,C,CHK0,Q1,Q2)
		ENDDO
		DO K=1,N
			!A(K,1)=(ZX(K)*SQRT(C(K)))**2
			A(K,1)=ZX(K)*SQRT(C(K))
			A(K,2)=Y(K)
		ENDDO
		CALL MINCUA(A,C,N,R,A0,A1,R2,X)
		!IF (R.GT.RMIN.AND.R2.GT.R2MIN) THEN
		IF (R.GT.RMIN) THEN
			WRITE(7,*) 'Iteracion',DA
			WRITE(7,*) 'Los coeficientes de Williamson-Hall son:'
			WRITE(7,*) 'Ordenada:',A0
			X(2)=-1
			IF (X(2).GT.0) THEN
				WRITE(4,*) 'ESTE SÍ'
				WRITE(4,*) 'Iteracion',DA
				WRITE(4,*) 'Factores de contraste para R=',R
				WRITE(4,*) 'y para R2=',R2
				DO I=1,N
					WRITE(4,*) C(I)
				ENDDO
				WRITE(6,*) 'ESTEEEEEEEEE'
				WRITE(6,*) 'Los coeficientes CHK0, Q1 y Q2 son:'
				WRITE(6,*) CHK0,'',Q1,'',Q2
				WRITE(7,*) 'Los coeficientes de Williamson-Hall son:'
				WRITE(7,*) 'C:',X(1)
				WRITE(7,*) 'B:',X(2)
				WRITE(7,*) 'A:',X(3)
			ELSE
				WRITE(3,*) 'Iteracion',DA
				WRITE(3,*) 'Factores de contraste para R=',R
				WRITE(3,*) 'y para R2=',R2
				WRITE(6,*) 'Los coeficientes CHK0, Q1 y Q2 son:'
				WRITE(6,*) CHK0,'',Q1,'',Q2
				DO I=1,N
					WRITE(3,*) C(I)
				ENDDO
			ENDIF
		ENDIF
		WRITE(*,*) DA
		DA=DA+1
	ENDDO	
	WRITE(*,*) 'Listo!'
	CLOSE(UNIT=3)
	CLOSE(UNIT=4)
	CLOSE(UNIT=6)
	CLOSE(7)
	END

!******************************************************************************

	SUBROUTINE MINCUA(A,C,N,R,A0,A1,R2,X)
	REAL SX,SY,SXY,SX2,SY2,BA,CA,R,A0,A1
	COMMON SX,SY,SX2,SX3,SX4,SX5,SX6,SXY,SX2Y,SX3Y
	DIMENSION A(10,2),X(4),F(10)
	
	SX=0
	SY=0
	SXY=0
	SX2=0
	SY2=0
	SX3=0
	SX4=0
	SX5=0
	SX6=0
	SX2Y=0
	SX3Y=0
	R=0
	R2=0
	BA=0
	CA=0
	A0=0
	A1=0
	DO I=1,N
		SX=SX+A(I,1)
		SY=SY+A(I,2)
		SXY=SXY+(A(I,1)*A(I,2))
		SX2=SX2+(A(I,1)**2)
		SY2=SY2+(A(I,2)**2)
		SX3=SX3+(A(I,1)**3)
		SX4=SX4+(A(I,1)**4)
		SX5=SX5+(A(I,1)**5)
		SX6=SX6+(A(I,1)**6)
		SX2Y=SX2Y+((A(I,1)**2)*A(I,2))
		SX3Y=SX3Y+((A(I,1)**3)*A(I,2))
		F(I)=0
	ENDDO
	A1=(N*SXY-SX*SY)/((N*SX2)-SX**2)
	A0=(SY-(A1*SX))/N
	BA=SQRT((N*SX2)-(SX**2))
	CA=SQRT((N*SY2)-(SY**2))
	R=((N*SXY-SX*SY)/(BA*CA))**2



    !CALL GS(N,X)
	!VE=0
	!VT=0
 	!DO I=1,N
	!		F(I)=X(1)+X(2)*A(I,1)+X(3)*(A(I,1)**2)
	!	VE=VE+(F(I)-(SY/N))**2
	!	VT=VT+(A(I,2)-(SY/N))**2
	!ENDDO
	!R2=VE/VT
	END

!******************************************************************************

	SUBROUTINE GS(N,X)
    COMMON SX,SY,SX2,SX3,SX4,SX5,SX6,SXY,SX2Y,SX3Y
	REAL VE,VT
    DIMENSION D(4,4),E(4),X(4)
    D(1,1)=N
    D(1,2)=SX
    D(1,3)=SX2
    D(1,4)=SX3
    D(2,1)=SX
    D(2,2)=SX2
    D(2,3)=SX3
    D(2,4)=SX4
    D(3,1)=SX2
    D(3,2)=SX3
    D(3,3)=SX4
    D(3,4)=SX5
    D(4,1)=SX3
    D(4,2)=SX4
    D(4,3)=SX5
    D(4,4)=SX6
    E(1)=SY
    E(2)=SXY
    E(3)=SX2Y
    E(4)=SX3Y
    M=10000
    DO I=1,4
		X(I)=0
    ENDDO
    DO K=1,M
		DO I=1,3
			X(I)=E(I)/D(I,I)
			DO J=1,3
				IF(I.NE.J) THEN
					X(I)=X(I)-D(I,J)*X(J)/D(I,I)
				ENDIF       
           ENDDO      
		ENDDO
	ENDDO
	
	END

!******************************************************************************

	SUBROUTINE CAMBIOC(N,B,C,CHK0,Q1,Q2)
	REAL CHK0,Q1,Q2,CQ1,CQ2
	REAL, DIMENSION(10):: C,B
	CHK0=0.46*RAND(0.0)
	CQ1=-0.42+1.016*RAND(0.0)
	CQ2=-0.39+0.125*RAND(0.0)
	DO K=1,N
		C(K)=CHK0+CQ1*B(K)+CQ2*(B(K)**2)
	ENDDO
	Q1=CQ1/CHK0
	Q2=CQ2/CHK0
	END