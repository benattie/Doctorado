        program gee2la2
c       Written to transform Geestach format to Los Alamos format by REB
C
        implicit integer*2 (i-n)
        integer*4 icount(19,72),ic(10)
        real THSYM(0:19),ring(19)
        integer*2 J,K,JMAX,NPF,N
        integer*4 IBGY
        CHARACTER MNAME*16,FNAME*20,CNAME*20,TITLE*42
        CHARACTER HKL*3,TITLE1*72,TITLE2*72
C
C
          PRINT *, 'Enter name of DAT data file (ext .DAT assumed) '
          READ '(A)',MNAME
        FNAME=MNAME//'.DAT'
        OPEN (UNIT=3,FILE=FNAME,STATUS='OLD',err=35)
c
9000    FORMAT(1X,A,A)
        READ(3,'(A)',END=35) TITLE
        READ(3,'(A)',END=35) TITLE1
        READ(3,9001) NPF
9001    FORMAT(1X,I2)
        PRINT 9000
        PRINT 9000, TITLE
        N=0
170     N=N+1
        READ(3,1001) HKL,F1,F2,F3
        READ(3,'(A)',END=35) TITLE2
        write(*,*) title1
1001    FORMAT(1X,A3,3F4.0)
        F1 = 90./F1
        F2 = F2*5./4.
        F3 = 90./F3
        F4 = F2*4.
        I1 = 1
        I2 = 1
        I3 = 1
        I4 = 2
        I5 = 3
        I6 = 100
        IBGY = 0
        k=1
        j=1
        write(*,1001) hkl,f1,f2,f3
        do while (j.le.19)
          READ(3,*)(IC(K1),K1=1,10)
          k1=1
          do i=k,k+9
            if (k.eq.73) then
              k=1
              j=j+1
            endif
            if(j.eq.20) goto 20
            icount(j,k)=ic(k1)
            k1=k1+1
            k=k+1
          enddo
        enddo
20      read(3,*) ibgy
        write(*,*) ibgy
C       ....................................................................
C
C
C-------------------------------------------------------------
C       Set up normalization weights
C
        DO 199 J=2,18
199     THSYM(J)=-COS(3.1415926*(2*J-1)*2.5/180.)+
     #           COS(3.1415926*(2*J-3)*2.5/180.)
        THSYM(1)=0.00095178
        THSYM(19)=0.0436194
C       ....................................................................
C
C        routine for normalizing data (100 = 1 m.r.d.)
C
C       ....................................................................
        SUM1 = 0
        FI = 100
        JMAX=19
C      THIS WILL NORMALIZE MEASURED DATA AS LOS ALAMOS FORMAT
C
        DO 200 J = 1, 19
        ring(J)=0.
        DO 209 IAZ = 1, 72
        ICOUNT(J,IAZ)=ICOUNT(J,IAZ)-IBGY
        ring(J) = ring(J) + ICOUNT(J,IAZ)
        SUM1 = SUM1 + ICOUNT(J,IAZ) * THSYM(J)
209     CONTINUE
        ring(J)=ring(J)/72.
        if (ring(j).le.0) print *,'ring(j)=',ring(j)
200     CONTINUE
c
        FACT = FI / SUM1 * 72.01
        PRINT '(A,F7.3)', ' Normalization factor= ', FACT
        DO 220 J = 1, JMAX
        DO 220 IAZ = 1, 72
        if (ring(j).le.0) icount(j,iaz)=0
        IF(ICOUNT(J,IAZ) .GT. TEXMAX) TEXMAX = ICOUNT(J,IAZ)
220     CONTINUE

C
        TSC = 9999. /TEXMAX/FACT
        IF(TSC .GT. 1) TSC = 1
        TFAC=TSC*FACT
c       PRINT *,'TEXMAX,TSC,FACT ',TEXMAX,TSC,FACT
c       PRINT *,'SUM1= ',SUM1
        DO 230 J = 1, JMAX
        DO 240 IAZ = 1, 72
        ICOUNT(J,IAZ) = ICOUNT(J,IAZ) * TFAC
        IF (ICOUNT(J,IAZ) .LT. 0)  ICOUNT(J,IAZ) = 0
 240    CONTINUE
        ring(J)=ring(J)*tfac
c
C       TO LEAVE RIM BLANK-REACTIVATE THESE NEXT 2 LINES AND 
C       DELETE JMAX=19 ABOVE
C       DO 230 J = JMAX + 1, 19
C       ICOUNT(J,IAZ) = 0
 230    CONTINUE
        I6 = 100 * TSC
        IF(IBGY.GT.0)IBGY=IBGY*TFAC
C
C       WRITE OUT THE POLEFIGURES
C
C       .....................................................................
C
C        routine for writing pole figure data to file
C
C       .....................................................................
C
        CNAME=MNAME//'.NPF'
        OPEN (UNIT=9,FILE=CNAME,STATUS='UNKNOWN',err=35)
        WRITE (9,1004) TITLE,TITLE1
        WRITE(9,1005)HKL,F1,F2,F3,F4,I1,I2,I3,I4,I5,I6,IBGY
1004    FORMAT(A26,4X,'DFB=NEUTRON TEXTURE',A26)
1005    FORMAT('(',A3,')',4F5.1,5I2,2I5)
        PRINT *, '      ...writing correct data file to ',   CNAME
        DO 300 J = 1, 19
        WRITE(9,1051)(ICOUNT(J,K),K=1,18)
        WRITE(9,1051)(ICOUNT(J,K),K=19,36)
        WRITE(9,1051)(ICOUNT(J,K),K=37,54)
        WRITE(9,1051)(ICOUNT(J,K),K=55,72)
1051    FORMAT(1X,18I4)
300     CONTINUE
        WRITE (9,9000)
        IF(N.EQ.NPF) GOTO 35
        GOTO 170
35      CLOSE (3)
        CLOSE (9)
        stop
        END
