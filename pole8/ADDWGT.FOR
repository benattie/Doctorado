      PROGRAM ADDWGT
      CHARACTER PROSA*80, NOMEN*1

      ONE=1.0

      OPEN(7,FILE='RT-TT-06.TXT',STATUS='OLD')
      OPEN(8,FILE='RT-TT-06.TEX',STATUS='NEW')
      READ(7,*)  PROSA
      WRITE(8,*) PROSA
      READ(7,*)  PROSA
      WRITE(8,*) PROSA
      READ(7,*)  PROSA
      WRITE(8,*) PROSA
      READ(7,*)  NOMEN,NGRAIN
      WRITE(8,*) NOMEN,NGRAIN
      DO IGR=1,NGRAIN
        READ(7,*) ANG1,ANG2,ANG3
        WRITE(8,'(3F10.2,3X,F7.1)') ANG1,ANG2,ANG3,ONE
      ENDDO
      STOP
      END
