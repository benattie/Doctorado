	PROGRAM CFCubTot	
	IMPLICIT NONE
	REAL RAND,BA,RX,DA,RM,DMAX,R2,S1,S2,S3,R,RMIN,R2MIN,Aord,Alin,Acuad
	REAL(4) A0,A1,P,CH00,T,U,V,W,G,H,Q,BETA,BETAMIN
	REAL,DIMENSION(4):: X
	REAL,DIMENSION(10):: Y,ZX,C,B,Wg
	REAL,DIMENSION(10,10):: A
	INTEGER I,J,N,L,K
	OPEN(UNIT=1,STATUS='UNKNOWN',FILE='AZX.DAT')
	OPEN(UNIT=2,STATUS='UNKNOWN',FILE='Breadth.DAT')
	OPEN(UNIT=3,STATUS='UNKNOWN',FILE='ContrastFactors.DAT')
	OPEN(UNIT=4,STATUS='UNKNOWN',FILE='Coeficientes.DAT')
	OPEN(UNIT=5,STATUS='UNKNOWN',FILE='H2mod.DAT')
	OPEN(UNIT=6,STATUS='UNKNOWN',FILE='CoefCF.DAT')
	OPEN(UNIT=7,STATUS='UNKNOWN',FILE='WarrenConstantsmod.DAT')
	N=5
	DO I=1,N
		READ(1,*) ZX(I)
		READ(2,*) Y(I)
		READ(5,*) B(I)
		READ(7,*) Wg(I)
	ENDDO
	CLOSE(UNIT=1)
	CLOSE(UNIT=2)
	CLOSE(UNIT=5)
	CLOSE(UNIT=7)
	DA=0
	RMIN=0.92
	DMAX=50
	BETAMIN=0.00098
	BETA=0.01	
	DO WHILE (BETA.GE.BETAMIN)
		DA=0
		DO WHILE (DA.LE.DMAX)
			R=0
			R2=0
			DO I=1,N
				C(I)=0
			ENDDO
			CALL CAMBIOC(N,B,C,CH00,Q)
			!DO WHILE (C(1).LT.0.OR.C(2).LT.0.OR.C(3).LT.0.OR.C(4).LT.0.OR.C(5).LT.0.OR.C(6).LT.0.OR.C(7).LT.0.OR.C(8).LT.0)
			!DO WHILE (C(1).LT.0.OR.C(2).LT.0.OR.C(3).LT.0.OR.C(4).LT.0.OR.C(5).LT.0.OR.C(6).LT.0.OR.C(7).LT.0)
			!DO WHILE (C(1).LT.0.OR.C(2).LT.0.OR.C(3).LT.0.OR.C(4).LT.0.OR.C(5).LT.0.OR.C(6).LT.0)
			DO WHILE (C(1).LT.0.OR.C(2).LT.0.OR.C(3).LT.0.OR.C(4).LT.0.OR.C(5).LT.0)
				DO I=1,N
					C(I)=0
				ENDDO
				CALL CAMBIOC(N,B,C,CH00,Q)
				
			ENDDO
			DO K=1,N
				A(K,1)=(ZX(K)*SQRT(C(K)))**2		
				A(K,2)=Y(K)-BETA*Wg(K)
			ENDDO
			!IF (A(1,2).LT.0.OR.A(2,2).LT.0.OR.A(3,2).LT.0.OR.A(4,2).LT.0.OR.A(5,2).LT.0.OR.A(6,2).LT.0.OR.A(7,2).LT.0.OR.A(8,2).LT.0) THEN
			!IF (A(1,2).LT.0.OR.A(2,2).LT.0.OR.A(3,2).LT.0.OR.A(4,2).LT.0.OR.A(5,2).LT.0.OR.A(6,2).LT.0.OR.A(7,2).LT.0) THEN
			!IF (A(1,2).LT.0.OR.A(2,2).LT.0.OR.A(3,2).LT.0.OR.A(4,2).LT.0.OR.A(5,2).LT.0.OR.A(6,2).LT.0) THEN
			IF (A(1,2).LT.0.OR.A(2,2).LT.0.OR.A(3,2).LT.0.OR.A(4,2).LT.0.OR.A(5,2).LT.0) THEN
				WRITE(*,*) 'No me sirve'
			ELSE
				!DO K=1,N
				!	A(K,1)=(ZX(K)*SQRT(C(K)))**2		
				!	A(K,2)=Y(K)-BETA*Wg(K)
				!ENDDO
			CALL MINCUA(A,C,N,R2,Aord,Alin,Acuad)
				IF (R2.GT.RMIN) THEN
					IF (Aord.GT.0.AND.Alin.GT.0) THEN
						IF (BETA.GE.BETAMIN) THEN
							WRITE(3,*) 'Iteracion',DA
							WRITE(3,*) 'Factores de contraste para R2=',R2
							WRITE(3,*) 'Valor de BETA:',BETA
							WRITE(6,*) 'Los coeficientes CH00 y Q son:'
							WRITE(6,*) CH00,'',Q
							WRITE(6,*) 'Y el valor de BETA obtenido es:',BETA
							DO I=1,N
								WRITE(3,*) C(I)
							ENDDO
							WRITE(4,*) 'La parábola de ajuste correspondiente es:'
							WRITE(4,*) 'Y=',Aord,'+',Alin,'X','+',Acuad,'X^2'
						ENDIF
					ENDIF
				ENDIF
			ENDIF
			DA=DA+1
			WRITE(*,*) DA, BETA
		ENDDO
		BETA=BETA-0.001
	ENDDO	
	WRITE(*,*) 'Listo!'
	CLOSE(UNIT=3)
	CLOSE(UNIT=4)
	CLOSE(UNIT=6)
	END

!******************************************************************************

	SUBROUTINE MINCUA(A,C,N,R,Aord,Alin,Acuad)
	REAL SX,SY,SXY,SX2,SY2,BA,CA,R,A0,A1,Aord,Alin,Acuad
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
	Aord=0
	Alin=0
	Acuad=0
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
	
	
    !CALL GS(N,X)
	!VE=0
	!VT=0
	!Aord=X(1)
	!Alin=X(2)
	!Acuad=X(3)
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

	SUBROUTINE CAMBIOC(N,B,C,CH00,Q)
	REAL CH00,Q,QCH00
	REAL, DIMENSION(10):: C,B
	CH00=0.3+0.2*RAND(0.0)
	QCH00=CH00*(1.5+1.5*RAND(0.0))
	Q=QCH00/CH00
	DO K=1,N
		C(K)=CH00-QCH00*B(K)
	ENDDO
	END
