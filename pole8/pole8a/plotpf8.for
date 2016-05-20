c +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
c     program plotpf7       ---->       version 21/feb/05
c
c +++ reads file 'POLE8.OUT' created by POLE8.FOR and plots the pole
c +++ figure using the graphics routines of the PLOT88 software.
c
c +++ the following are the compilation and link commands in batch
c +++ file PLOT8877.BAT, for graphic library compatible with Lahey F77
c
c     F77L3 %1%2
c     386LINK %1 -SYMBOL - PACK -LIB F:\PLOT88\DRIVE88,F:\PLOT88\PLOT88
c
c +++ the following are the compilation and link commands in batch
c +++ file PLOT8890.BAT, for graphic library compatible with Lahey F90
c
c +++ lf90 %1.for -pack -symbol -libp c:\plot8890 -lib plot88,drive88,pl90
c +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      program plotpf

      parameter(npmax=100000)
      common/points/x(npmax),y(npmax),rad,ipfig

      character nfile*12,fileid*5,prosa*80,poles*16
      character*4  label(200)

      open(8,file='POLE8.OUT',status='old')
      read(8,'(a5)') fileid
      fileid=fileid   ! to fool the compiler
      nfile =nfile    ! to fool the compiler

c *** select the display hardware
      write(*,*) 'enter (1) if displaying on VGA screen'
      write(*,*) 'enter (2) if plotting on the HP-LJ3'
      write(*,*) 'enter (3) if displaying on EGA screen'
      write(*,*) 'enter (4) if plotting on the HP-LJ5'
      write(*,*) 'enter (5) if generating a B&W EPS file'
      write(*,*) 'enter (0) if generating a color EPS file'
      write(*,*)
      read(*,*) ndevice

      if (ndevice.eq.1) then
        ioport=91      !vga
        model =91      !vga
        ipen=1
        icol=15        ! office monitor
c       icol=0         ! home monitor
      elseif(ndevice.eq.2) then
        ioport=0
        model=62       ! 150 dpi --> HP LJ3
        ipen=3
        icol=0
      elseif(ndevice.eq.3) then
        ioport=97      !ega
        model =97      !ega
        ipen=1
        icol=15
      elseif(ndevice.eq.4) then
        ioport=0
        model =64      ! 300 dpi --> HP LJ5
        ipen=3
        icol=0
      elseif(ndevice.eq.5) then      ! B&W post script
        ioport=11
        model =111                   ! B&W Encapsulated Post Script
c       model =113                   ! B&W Post Script printer
        ipen=3
        icol=0
        open(90,file='POLE8.EPS')
      elseif(ndevice.eq.0) then      ! color post script
        ioport=11
        model =110                   ! color Encapsulated Post Script
c       model =112                   ! color Post Script printer
        ipen=3
        icol=0
        open(90,file='POLE8.EPS')
      endif

      call plots(0,ioport,model)
      call color (icol,ierr)   ! sets default color for this device
      call newpen(ipen)        ! sets the line width: ipen=1 to 3

      if(ndevice.eq.1 .or. ndevice.eq.3) iland=1
      if(ndevice.eq.0 .or. ndevice.eq.5) then
        iland=0
        write(*,*) 'open POLE8.EPS with GHOSTVIEW, click CONVERT, choose
     #  PDF & max resol'
      endif
      if(ndevice.eq.2 .or. ndevice.eq.4) then
        write(*,*) 'enter (0) for portrait (1) for landscape display'
        write(*,*)
        read(*,*) iland
      endif

c *** defines coordinates for labels
      if(iland.eq.1) then
        angle = 0.
        xprosa= 0.1
        yprosa= 7.5
        deltax= 0.0
        deltay=-0.16
      else if(iland.eq.0) then
        angle = 90.
        xprosa= 0.1
        yprosa= 0.1
        deltax= 0.16
        deltay= 0.0
      endif

c *** reads/writes info about texture files and PF parameters
      read(8,*) nprosa
      do n=1,nprosa
        xprosa=xprosa+deltax
        yprosa=yprosa+deltay
        read(8,'(a)') prosa
        call symbol(xprosa,yprosa,0.080,prosa,angle,80)
      enddo

      read(8,*) irepr
      read(8,*) rad
      read(8,*) isym
      read(8,*) ipfig
      read(8,*) ndifpoles,ndiftexts

      trad=rad/20.
      if(ipfig.gt.0) trad=rad/30.
      fontsz=1.7*trad

c *** reads labels and coordinates of labels from fileid_LB.DAT
c     npoints=3*ndifpoles*ndiftexts
c     nfile=fileid//'_LB.DAT'
c     open(unit=2,file=nfile,status='old')
c       read(2,'(2f10.4,4x,a4)') (x(i),y(i),label(i),i=1,npoints)
c     close(unit=2)
c
c     call map_points(npoints,iland)
c
c *** writes the labels of the PF or IPF.
c     call plot(x(1),y(1),13)
c     do i=1,npoints
c       call symbol(x(i),y(i),fontsz,label(i),angle,4)
c     enddo

c *** reads labels and coordinates of labels from fileid_LB.DAT
c *** writes the labels of the PF or IPF.
      npoints=3*ndifpoles*ndiftexts
      nfile=fileid//'_LB.DAT'
      open(unit=2,file=nfile,status='old')
      do i=1,npoints
        ichar=i-(i/3)*3
        if(ichar.ne.0) read(2,'(2f10.4,4x,a2)') x(1),y(1),label(1)
        if(ichar.eq.0) read(2,'(2f10.4,4x,a4)') x(1),y(1),label(1)
        call map_points(npoints,iland)
        call plot(x(1),y(1),13)
        if(ichar.ne.0) icharx=2
        if(ichar.eq.0) icharx=4
        call symbol(x(1),y(1),fontsz,label(1),angle,icharx)
      enddo
      close(unit=2)

      do 100 npol=1,ndifpoles
      do 100 ntex=1,ndiftexts

        call color (icol,ierr)

c *************************************************************************
c *** reads points of circular section from POLE8.OUT
      read(8,'(a16)') poles      ! Miller indices of pole
      read(8,*) npoints
      read(8,*) (x(i),i=1,npoints)
      read(8,*) (y(i),i=1,npoints)

c *** reads points of circular section from fileid_CC.DAT
c     read(8,*) npoints
c     nfile=fileid//'_CC.DAT'
c     open(unit=2,file=nfile,status='old')
c       read(2,*) (x(i),y(i),i=1,npoints)
c     close(unit=2)

      call map_points(npoints,iland)

c *** plots the circular section and labels the axes.
      call plot(x(1),y(1),13)
      do i=1,npoints
        call plot(x(i),y(i),12)
      enddo

      xori=x(npoints)     ! not necessary if circles are read from CC.DAT
      yori=y(npoints)

c ************************************************************************
c *** if irepr=1 plots points at the poles position using subr 'symbol'.
c *** makes cross size proportional to the weight 'level(i)' of the point.

      if(irepr.eq.1) then

        if(iland.eq.1) then
          xlab=0.2
          ylab=5.0
        else if(iland.eq.0) then
          xlab=3.5-rad
          ylab=0.2
        endif

        read(8,'(a)') prosa      ! reads either 'levels' or 'weight npoles'
        call symbol(xlab,ylab,0.08,prosa,angle,80)

        do iterate=1,10

          read(8,*) leveli,npoints
          if(npoints.gt.npmax) then
            write(*,'('' npoints='',i5,'' EXCEEDS DIMENS npmax='',i5)')
     #                   npoints,npmax
            stop
          endif

          symbsize=iterate*rad/200.
          if(ndevice.le.1) call color(iterate,ierr)

          if(ntex.eq.1 .and. npol.eq.1) then
            xlab= xlab +(1-iland)*0.2
            ylab= ylab -   iland *0.2
            call symbol(xlab,ylab,symbsize,char(3),angle,-1)
            xnum= xlab+    iland *0.5
            ynum= ylab+ (1-iland)*0.5
            rrr=float(npoints)
            call number(xnum,ynum,0.08,rrr,angle,-1)
          endif

          if(npoints.gt.0) then

c *** reads coordinates of poles from POLE8.OUT
            read(8,*) (x(i),i=1,npoints)
            read(8,*) (y(i),i=1,npoints)

c *** reads coordinates of poles from fileid_Xn.DAT
c           nfile=fileid//'_X'//char(48+leveli)//'.DAT'
c           open(unit=2,file=nfile,status='old')
c             read(2,*) (x(i),y(i),i=1,npoints)
c           close(unit=2)

            call map_points(npoints,iland)

            do i=1,npoints
              call symbol(x(i),y(i),symbsize,char(3),angle,-1)
            enddo

          endif

        enddo      ! end of do iterate

      endif       ! end of if(irepr.eq.1)

c *************************************************************************
c *** if irepr=0 plots crosses and intensity levels.

      if(irepr.eq.0) then

        read(8,*) icross,npoints
        if(icross.eq.0 .and. npoints.ne.0) then

c *** reads coordinates of crosses from POLE8.OUT
          read(8,*) (x(i),i=1,npoints)
          read(8,*) (y(i),i=1,npoints)

c *** reads coordinates of crosses from fileid_XX.DAT
c         nfile=fileid//'_XX.DAT'
c         open(unit=2,file=nfile,status='old')
c         read(2,*) (x(i),y(i),i=1,npoints)
c         close(unit=2)

          call map_points(npoints,iland)

          symbsize=rad/200.
          do i=1,npoints
            call symbol(x(i),y(i),symbsize,char(3),0.,-1)
          enddo

        endif

c *** reads and prints fmax
        if (ndevice.le.1) call color(icol,ierr)
        plabel=1.2*rad
        if(isym.ge.3 .or. ipfig.gt.0) plabel=0.2*rad
        xprosa= xori +(1-iland)*plabel
        yprosa= yori -   iland *plabel
        read(8,'(a40)') prosa
        call symbol(xprosa,yprosa,fontsz,prosa,angle,40)

c *** plots a symbol at the location of the maximum.
        read(8,*) prosa
        read(8,*) x(1),y(1)     ! xmax,ymax

        call map_points(1,iland)

        do i=1,7
          charsize=rad/20.*(i/10.)
          call symbol(x(1),y(1),charsize,char(1),angle,-1)
        enddo

c *** reads and prints the levels to be represented.
        read(8,*) iwrite
        read(8,'(i3,a40)') levlines,prosa
        if(iland.eq.1) then
          xprosa=0.2
          yprosa=5.0
        else if(iland.eq.0) then
          xprosa=3.5-rad
          yprosa=0.2
        endif
          xpro=xprosa
          ypro=yprosa
        call symbol(xpro  ,ypro  ,0.08,prosa,angle,40)

        do l=1,levlines
          read(8,'(i3,a40)') leveli,prosa
          if (ndevice.le.1) call color(leveli,ierr)
          if(iland.eq.1) ypro  =yprosa-0.16 *leveli
          if(iland.eq.0) xpro  =xprosa+0.16 *leveli
          call symbol(xpro  ,ypro  ,0.08,prosa,angle,30)
        enddo

c *** reads coordinates of points in each level line.

        do iterate=1,1000

          read(8,*) leveli,npoints
          if(leveli.eq.999 .and. npoints.eq.999) go to 100
          read(8,*) (x(i),i=1,npoints)
          read(8,*) (y(i),i=1,npoints)

          call map_points(npoints,iland)

          iskip=0
          xold =x(1)
          yold =y(1)
          call plot (xold,yold,13)
          if (ndevice.le.1) call color(leveli,ierr)

          do i=1,npoints
            icount=icount+1
            seg=rad*sqrt((x(i)-xold)**2+(y(i)-yold)**2)
            if(iskip.eq.1 .or. seg.lt.rad/25 .or. iwrite.eq.0) then
              call plot (x(i),y(i),12)
            else
              xxx=(xold+x(i))/2.*rad
              yyy=(yold+y(i))/2.*rad
              hgt=rad/50.
              rrr=float(leveli)
              if (ndevice.le.1) call color(icol,ierr)
              call number(xxx,yyy,hgt,rrr,angle,-1)      ! writes level value
              call plot (x(i),y(i),13)
              if (ndevice.le.1) call color(leveli,ierr)
              iskip=1
            endif
            xold=x(i)
            yold=y(i)
          enddo

        enddo      ! end of do iterate

      endif      ! end of if(irepr.eq.0)
c *************************************************************************

  100 continue

  777 continue

      call plot(0.,0.,999)
      close(unit=8)

      stop
      end
c
c *************************************************************************
      subroutine map_points(npoints,iland)

c *** maps points in the frame of the PF or IPF to the coordinate system
c     defined by the printer.
c *** Shifts points by (xshift,yshift) to leave room for labels containing
c     information about the run and level lines
c *************************************************************************

      parameter(npmax=100000)
      common/points/x(npmax),y(npmax),rad,ipfig

c *** defines the shift with respect to page corner of PF/IPF coordinates
      if(iland.eq.1) then          ! landscape
        if(ipfig.eq.0) then
          xshift=3.5+rad
          yshift=6.5-rad
        else if(ipfig.gt.0) then
          xshift=3.5
          yshift=6.5-rad
        endif
      else if(iland.eq.0) then     ! portrait
        if(ipfig.eq.0) then
          xshift=3.5
          yshift=1.5+rad
        else if(ipfig.gt.0) then
          xshift=3.5
          yshift=1.5
        endif
      endif

      if(iland.eq.1) then
        do i=1,npoints
          x(i)=x(i)+xshift
          y(i)=y(i)+yshift
        enddo
      else if(iland.eq.0) then
        do i=1,npoints
          aux = x(i)
          x(i)=-y(i)+xshift
          y(i)= aux +yshift
        enddo
      endif

      return
      end
