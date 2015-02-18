	PROGRAM MINCUA
    REAL SX,SY,SXY,SX2,SY2,B,C,R,A0,A1
    COMMON SX,SY,SX2,SX3,SX4,SX5,SX6,SXY,SX2Y,SX3Y
    DIMENSION A(10,2),S(4),X(4)
	
	OPEN(UNIT=1,STATUS='UNKNOWN',FILE='Z.DAT')
	OPEN(UNIT=2,STATUS='UNKNOWN',FILE='BREADTH.DAT')

	N=8

	DO I=1,N
		READ(1,*) A(I,1)
		READ(2,*) A(I,2)
	ENDDO

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
    B=0
    C=0
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
    B=SQRT((N*SX2)-(SX**2))
    C=SQRT((N*SY2)-(SY**2))
    R=(N*SXY-SX*SY)/(B*C)
    WRITE(*,*) 'La recta que mejor aproxima a los datos es:'
    WRITE(*,*) 'Y=',A1,'X +',A0
    WRITE(*,*) 'El coeficiente de correlaci¢n es:',R

	CLOSE(UNIT=1)
	CLOSE(UNIT=2)

	END