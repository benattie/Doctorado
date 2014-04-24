	PROGRAM CFCubicas	
	IMPLICIT NONE
	REAL RAND,BA,RX,DA,RM,DMAX,R2,S1,S2,S3,R,BETA,BETAMIN,BUR,DS,MRho
	REAL(4) A0,A1,P,CH00,T,U,V,W,G,H,Q
	REAL,DIMENSION(4):: X
	REAL,DIMENSION(10):: F,E
	REAL,DIMENSION(10):: Y,ZX,C,B,Wg
	REAL,DIMENSION(10000,20):: RESU
	REAL,DIMENSION(10,10):: A
	REAL,DIMENSION(10,20):: MAS
	INTEGER I,J,N,L,K,IN
	OPEN(UNIT=1,STATUS='UNKNOWN',FILE='AZX.DAT')
	OPEN(UNIT=2,STATUS='UNKNOWN',FILE='Breadth.DAT')
!	OPEN(UNIT=3,STATUS='UNKNOWN',FILE='ContrastFactors.DAT')
	OPEN(UNIT=4,STATUS='UNKNOWN',FILE='H2.DAT')
	OPEN(UNIT=5,STATUS='UNKNOWN',FILE='WarrenConstants.DAT')
	OPEN(UNIT=6,STATUS='UNKNOWN',FILE='Resultados.DAT')
	OPEN(UNIT=7,STATUS='UNKNOWN',FILE='R.DAT')
	N=4
	DO I=1,N
		READ(1,*) ZX(I)
		READ(2,*) Y(I)
		READ(4,*) B(I)
		READ(5,*) Wg(I)
	ENDDO
	CLOSE(UNIT=1)
	CLOSE(UNIT=2)
	CLOSE(UNIT=4)
	CLOSE(UNIT=5)
	DA=0
	DMAX=100
	BETAMIN=0.001
	BETA=0.09
!	BETAMIN=0.000
!	BETA=0.00
	BUR=0.25577
	P=0
	DA=0
	DO K=1,8
		A(K,2)=0
		C(I)=1
	ENDDO
	DO WHILE (BETA.GE.BETAMIN)
		DA=0
		DO WHILE (DA.LE.DMAX)
			R=0
			R2=0
			DO I=1,N
				C(I)=0
			ENDDO
			CALL CAMBIOC(N,B,C,CH00,Q)
			DO WHILE (C(1).LT.0.OR.C(2).LT.0.OR.C(3).LT.0.OR.C(4).LT.0.OR.C(5).LT.0.OR.C(6).LT.0.OR.C(7).LT.0.OR.C(8).LT.0)
				CALL CAMBIOC(N,B,C,CH00,Q)
			ENDDO
			DO K=1,N
				A(K,1)=(ZX(K)*SQRT(C(K)))**2		
				A(K,2)=Y(K)-BETA*Wg(K)
			ENDDO
			IF (A(1,2).GE.0.AND.A(2,2).GE.0.AND.A(3,2).GE.0.AND.A(4,2).GE.0.AND.A(5,2).GE.0.AND.A(6,2).GE.0.AND.A(7,2).GE.0.AND.A(8,2).GE.0) THEN
				CALL MINCUA(A,C,N,R,A0,A1)
!				WRITE(*,*) A0,A1
					IF (A0.GT.0.AND.A1.GT.0) THEN
						P=P+1
						RESU(P,1)=R
						RESU(P,2)=A0
						RESU(P,3)=A1
						RESU(P,4)=CH00
						RESU(P,5)=Q
						RESU(P,6)=BETA
						DO I=1,N
							RESU(P,6+I)=C(I)
						ENDDO
					ENDIF
			ENDIF
			DA=DA+1
		ENDDO
		WRITE(*,*) BETA
		BETA=BETA-0.001
	ENDDO	
	CALL ORDEN(RESU,F,E,P)
	DO I=1,10
		IN=E(I)
		DO J=1,6+N
			MAS(I,J)=RESU(IN,J)
		ENDDO
!		WRITE(3,*) '************************************************************'
!		WRITE(3,*) 'Solucion N°',I
!		WRITE(3,*) 'Resultados para R2=',MAS(I,1)
!		WRITE(3,*) 'La parábola de ajuste correspondiente es:'
!		WRITE(3,*) 'Y=',MAS(I,2),'+',MAS(I,3),'X^2'
!		WRITE(3,*) 'Los coeficientes CH00 y Q son:','',MAS(I,4),'',MAS(I,5)
		WRITE(7,*) MAS(I,1)
!		WRITE(3,*) 'Los factores de contraste son:'
!		DO J=1,N
!			WRITE(3,*) MAS(I,6+J)
!		ENDDO
!		WRITE(3,*) 'Y las caracteristicas microestructurales son las siguientes:'
		DS=1.0/MAS(I,2)
		MRho=1E18*(2*MAS(I,3)/(3.14*BUR**2))**2
		WRITE(6,*) MAS(I,5),MAS(I,4),DS,MRho,'',MAS(I,6)
!		WRITE(3,*) 'Tamaño de dominio:',DS
!		WRITE(3,*) 'M4Rho:',MRho
!		WRITE(3,*) 'Densidad de maclas:',MAS(I,6)
		IN=0
	ENDDO
	WRITE(*,*) 'Listo!'
	DO J=1,6+N
		DO I=1,10
			MAS(I,J)=0
		ENDDO
		DO K=1,P
			RESU(P,J)=0
		ENDDO
	ENDDO
!	CLOSE(UNIT=3)
	CLOSE(UNIT=6)
	CLOSE(UNIT=7)
	END

!******************************************************************************

	SUBROUTINE MINCUA(A,C,N,R,A0,A1)
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
	ENDDO
	A1=(N*SXY-SX*SY)/((N*SX2)-SX**2)
	A0=(SY-(A1*SX))/N
	BA=SQRT((N*SX2)-(SX**2))
	CA=SQRT((N*SY2)-(SY**2))
	R=((N*SXY-SX*SY)/(BA*CA))**2
	END

!******************************************************************************

	SUBROUTINE CAMBIOC(N,B,C,CH00,Q)
	REAL CH00,Q,QCH00
	REAL, DIMENSION(10):: C,B
	Q=-4.0+6.0*RAND(0.0)
	CH00=0.1+0.2*RAND(0.0)
	QCH00=CH00*Q
	DO K=1,N
		C(K)=CH00-QCH00*B(K)
	ENDDO
	END

!******************************************************************************

	SUBROUTINE ORDEN(RESU,F,E,P)
	REAL,DIMENSION(10000,20):: RESU
	REAL,DIMENSION(10):: F,E
	DO J=1,10
		F(J)=0
		E(J)=0
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(1)) THEN
			F(1)=RESU(I,1)
			E(1)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(2).AND.RESU(I,1).LT.F(1)) THEN
			F(2)=RESU(I,1)
			E(2)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(3).AND.RESU(I,1).LT.F(2)) THEN
			F(3)=RESU(I,1)
			E(3)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(4).AND.RESU(I,1).LT.F(3)) THEN
			F(4)=RESU(I,1)
			E(4)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(5).AND.RESU(I,1).LT.F(4)) THEN
			F(5)=RESU(I,1)
			E(5)=I
		ENDIF
	ENDDO
	
	DO I=1,P
		IF (RESU(I,1).GT.F(6).AND.RESU(I,1).LT.F(5)) THEN
			F(6)=RESU(I,1)
			E(6)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(7).AND.RESU(I,1).LT.F(6)) THEN
			F(7)=RESU(I,1)
			E(7)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(8).AND.RESU(I,1).LT.F(7)) THEN
			F(8)=RESU(I,1)
			E(8)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(9).AND.RESU(I,1).LT.F(8)) THEN
			F(9)=RESU(I,1)
			E(9)=I
		ENDIF
	ENDDO
	DO I=1,P
		IF (RESU(I,1).GT.F(10).AND.RESU(I,1).LT.F(9)) THEN
			F(10)=RESU(I,1)
			E(10)=I
		ENDIF
	ENDDO
	END