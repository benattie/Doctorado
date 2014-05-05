        program sumapfs

        implicit none
        integer                          :: ier,npolesmax,nfigmax,int
        integer, dimension(5)            :: iw,jw,iper1,iper2,iper3,ngbg
        integer,dimension(5)             :: iwb,jwb,iper1b,iper2b, iper3b,ngbgb
        integer                          :: imax,imin,ifiles,ii,ip
        integer                          :: uin,match,k,ji,fi,np,jwe 
        integer                          :: jmax,i,j,iaz,jf
        integer, dimension(5)            :: iavg,iavgb 
        integer, dimension(19,72,5,100)  :: inten 
        integer, dimension(19,72,5)      :: intsuma, intsuman

        real(8),dimension(5)             :: dr,rm,daz,azm
        real(8),dimension(5)             :: drb,rmb,dazb,azmb 
        real(8)                          :: nr,mr,maz,error
        real(8)                          :: TSC,TEXMAX,FACT,TFAC
        real(8), dimension(5)            :: avg  
        real(8), dimension(20)           :: thsym
        real(8), dimension(19)           :: ring
        real(8)                          :: f1,sum1 
        logical                          :: compara
    
!# maximo de polos por figura =5, # maximo de figuras de polos =100  

       character(5), dimension(5)   :: hkl,seclab,label
       character(5),dimension(5)    :: hklb,seclabb,labelb
       character(8)                 :: name1,name2,file3,file4,cname
       character(18)                :: file1, file2
       character(78)                :: title1,titlesuma
    
       error=0.0000001
       compara=.false. 
     


      open(1,file='suma.out', status='unknown') 

      nfigmax=0
      npolesmax=0
      intsuma=0
      inten=0   
      uin=10

      write(*,*) 'Cuantos archivos quiere sumar?'
      read (*,(' (i3)' )) nfigmax
      write(*,*) 'Cuantas figuras de polos tiene cada uno?'
      read (*,(' (i1)' )) npolesmax
    
   
       do ii=1,nfigmax
        uin=uin+1
        write(*,*)' Enter the name of the + file --> '
        read (*,(' (a10)' )  ) file1
        open(unit=uin,file=file1,status='old',iostat=ier)
        if(ier /= 0) exit

        read(uin,('(a10)')) title1



       do ip = 1,npolesmax  
    
      
      read(uin,('(a5,4f5.1,5i2,2i5,2a5)')) hkl(ip),dr(ip),rm(ip),daz(ip),  &
                                       azm(ip),iw(ip),jw(ip),iper1(ip),iper2(ip),iper3(ip), &
                                    iavg(ip),ngbg(ip),seclab(ip),label(ip)


      match = 1

      if(compara.and.ii.gt.1) then
       if(hklb(ip).ne.hkl(ip)) match=0
       if(drb(ip).ne.dr(ip)) match=0
       if(rmb(ip).ne.rm(ip)) match=0
       if(dazb(ip).ne.daz(ip)) match=0
       if(azmb(ip).ne.azm(ip)) match=0
       if(iwb(ip).ne.iw(ip)) match=0
       if(jwb(ip).ne.jw(ip)) match=0
       if(iper1b(ip).ne.iper1(ip)) match=0
       if(iper2b(ip).ne.iper2(ip)) match=0
       if(iper3b(ip).ne.iper3(ip)) match=0
       if(ngbgb(ip).ne.ngbg(ip)) match=0
       if(seclabb(ip).ne.seclab(ip)) match=0
       if(labelb(ip).ne.label(ip)) match=0   
     else 
    endif    

    if(match.ne.1) then
       write(*,*) 'ATENCION! Hay diferencias en los parámetros de entrada'
    pause
    else
    endif

 

     hklb(ip)=hkl(ip)
     drb(ip)=dr(ip)
     rmb(ip)=rm(ip)
     dazb(ip)=daz(ip)
     azmb(ip)=azm(ip)
     iwb(ip)=iw(ip)
     jwb(ip)=jw(ip)
     iper1b(ip)=iper1(ip)
     iper2b(ip)=iper2(ip)
     iper3b(ip)=iper3(ip)
     ngbgb(ip)=ngbg(ip)
     seclabb(ip)=seclab(ip)
     labelb(ip)=label(ip)


      if (azm(ip).lt.1.) azm=360.
      nr=(rm(ip)/dr(ip)+iw(ip)+0.0001)
      mr=90./dr(ip)+iw(ip)+0.0001
      maz=(azm(ip)/daz(ip)+0.0001)
      np=maz/19+1
      int= (azm(ip)+.0001)/360
      jwe=jw(ip)*(1-int)     
      imax=-32000
      imin=32000

      if(iavg(ip).eq.0) iavg(ip)=100
      avg(ip)=float(iavg(ip))/100.+error
      
      do i=1,mr
        do k=1,np
        ji=(k-1)*18+1
        jf=ji+17
        if (k.eq.np) jf=jf+jwe
        read (uin,('(1x,19i4)')) (inten(i,j,ip,ii),j=ji,jf)

!        if(i.le.nr) then  !!# lee aun para angulos mayores de 80 en fig incompletas
    
           do  j=ji,jf
             intsuma(i,j,ip)=intsuma(i,j,ip)+inten(i,j,ip,ii)*avg(ip)
             imax=max0(imax,intsuma(i,j,ip))
             imin=min0(imin,intsuma(i,j,ip))
           enddo
!         endif
        enddo
      enddo
      
      imax=max0(imax,abs(imin))
      avg(ip)=1.
      if(imax.gt.9999) avg(ip)=9999./imax
      iavg(ip)=100*avg(ip)

      read (uin,*)

  if(ip.lt.npolesmax)  read (uin,*)

      enddo ! ipolo

       compara=.true.

      enddo !ii

    write(1,('(a5)')) 'suma'
    do ip=1,npolesmax
      
      write(1,('(a5,4f5.1,5i2,2i5,2a5)'))hkl(ip),dr(ip),rm(ip),daz(ip),azm(ip),iw(ip),jw(ip),iper1(ip), &
                                         iper2(ip), iper3(ip),iavg(ip),ngbg(ip), &
                                         seclab(ip),label(ip)
      write(*,*)'mr',mr,'np',np
      do  i=1,mr
      do  k=1,np
      ji=(k-1)*18+1
      jf=ji+17
      if (k.eq.np) jf=jf+jwe
      do  j=ji,jf
      intsuma(i,j,ip)=intsuma(i,j,ip)*avg(ip)
!      if(i.gt.nr) intsuma(i,j,ip)=0
!      ÿ# No escribe ceros para angulos mayores
!       # a 80 grados en el caso de figuras incompletas 

      enddo
      write (1,('(1x,19i4)')) (intsuma(i,j,ip),j=ji,jf)
      enddo 
      enddo    
      write(1,*)
   enddo
      close(1)  

!c 92   format(1x,'********'//)
!c 94   format(1x,'********'//)
!c
!c
!c
!c         routine normalize(...,...)
!c
!c
!        write(*,*)'cname=',cname

        OPEN (UNIT=9,FILE='suma.nor',STATUS='UNKNOWN',err=35)
      write(9,('(a11)')) 'normalizado'
      do ip=1,npolesmax
     write(9,('(a5,4f5.1,5i2,2i5,2a5)'))hkl(ip),dr(ip),rm(ip),daz(ip),azm(ip),iw(ip),jw(ip),  &
                                        iper1(ip),iper2(ip),iper3(ip),iavg(ip),ngbg(ip), &
                                         seclab(ip),label(ip)
       
!c
!C       ....................................................................
!C       Set up normalization weights
!C
        DO J=2,18
          THSYM(J)=-DCOS(3.1415926d0*(2*J-1)*2.5/180.)+ &
                    DCOS(3.1415926d0*(2*J-3)*2.5/180.)
        ENDDO        

        THSYM(1)=0.00095178
        THSYM(19)=0.0436194

!C       ....................................................................
!C
!C        routine for normalizing data (100 = 1 m.r.d.)
!C
!C       ....................................................................
        SUM1 = 0
        FI = 100
        JMAX=19
!C      THIS WILL NORMALIZE MEASURED DATA AS LOS ALAMOS FORMAT
!C
        DO J = 1, 19
        ring(J)=0.
          DO IAZ = 1, 72
           ring(J) = ring(J) + intsuma(J,IAZ,ip)
           SUM1 = SUM1 + intsuma(J,IAZ,ip) * THSYM(J)
          ENDDO
        write(*,*)'sum1',sum1
        ring(J)=ring(J)/72.
        if (ring(j).le.0) print *,'ring(j)=',ring(j)
        ENDDO
!c
        FACT = FI / SUM1 * 72.01
        PRINT '(A,F7.3)', ' Normalization factor= ', FACT
        DO J = 1, JMAX
        DO IAZ = 1, 72
         if (ring(j).le.0) intsuma(j,iaz,ip)=0
         IF(intsuma(J,IAZ,ip) .GT. TEXMAX) TEXMAX = intsuma(J,IAZ,ip)
        ENDDO
        ENDDO
!c
        write(*,*) 'texmax=', texmax,'fact=', fact
!C
        TSC = 9999. /TEXMAX/FACT
        IF(TSC .GT. 1) TSC = 1
        TFAC=TSC*FACT
!c       PRINT *,'TEXMAX,TSC,FACT ',TEXMAX,TSC,FACT
!c       PRINT *,'SUM1= ',SUM1
        DO J = 1, JMAX
        DO IAZ = 1, 72
        intsuma(J,IAZ,ip) = intsuma(J,IAZ,ip) * TFAC
        IF (intsuma(J,IAZ,ip) .LT. 0)  intsuma(J,IAZ,ip) = 0
        ENDDO
        ring(J)=ring(J)*tfac
!c
!C       TO LEAVE RIM BLANK-REACTIVATE THESE NEXT 2 LINES AND 
!C       DELETE JMAX=19 ABOVE
!C       DO J = JMAX + 1, 19
!C       ICOUNT(J,IAZ) = 0
!         ENDDO
         ENDDO
!c        I6 = 100 * TSC
!c        IF(IBGY.GT.0)IBGY=IBGY*TFAC
!C
!C       WRITE OUT THE POLEFIGURES
!C
!C       .....................................................................
!C
!C        routine for writing pole figure data to file
!C
!C       .....................................................................
!C
        PRINT *, '      ...writing correct data file '
        DO J = 1, 19
        WRITE(9,('(1X,18I4)'))(intsuma(J,K,ip),K=1,18)
        WRITE(9,('(1X,18I4)'))(intsuma(J,K,ip),K=19,36)
        WRITE(9,('(1X,18I4)'))(intsuma(J,K,ip),K=37,54)
        WRITE(9,('(1X,18I4)'))(intsuma(J,K,ip),K=55,72)

        ENDDO
        WRITE (9,*)
!ccc        IF(N.EQ.ipolesmax) GOTO 35
!ccc        GOTO 170


         enddo !ip

35      CLOSE (3)
        close(4)
        CLOSE (9)
        stop
        END
