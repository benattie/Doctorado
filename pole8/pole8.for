      program pole
c
c ***********************************************************************
c ***   program pole8   ***   version 08/SEP/07   ***   Carlos Tome   ***
c ***********************************************************************
c *** This program makes pole figure representations starting from a  ***
c *** texture file containing a set of Euler angles with weights and  ***
c *** a list with the indices of poles to be plotted.                 ***
c ***                                                                 ***
c *** Creates an output file POLE8.OUT containing the information     ***
c *** about the pole figure for plotting with PLOTPF8.FOR.            ***
c *** Creates separate output files for plotting with any other       ***
c *** graphics software.                                              ***
c ***                                                                 ***
c *** It features the following options:                              ***
c ***     * handles Bunge, Kocks and Roe conventions.                 ***
c ***     * handles any crystal symmetry (cubic to triclinic)         ***
c ***     * handles several texture files simultaneously.             ***
c ***     * handles texture files with more than one texture in it.   ***
c ***     * can plot several poles for several textures in one run.   ***
c ***     * plots dots or intensity lines.                            ***
c ***     * plots equal area or stereographic representation.         ***
c ***     * (phi,theta) or (phi,cos(theta)) grid.                     ***
c ***     * optional symmetrization of the original set of poles.     ***
c ***     * for axial symmetrization outputs azimuthal intens profile ***
c ***     * 'gaussian' spreading of the poles.                        ***
c ***     * plots intensities in equal, geometric or arbitrarily      ***
c ***       spaced levels.                                            ***
c ***     * plots inverse pole figures for all symmetries.            ***
c ***********************************************************************
c ***     calls subroutines:   circles                                ***
c ***                          concatenate                            ***
c ***                          crystal_symmetry                       ***
c ***                          euler                                  ***
c ***                          isolev                                 ***
c ***                          linint                                 ***
c ***                          project                                ***
c ***                          special_cases (deactivated)            ***
c ***                          spread_poles                           ***
c ***                          texture                                ***
c ***********************************************************************
c ***     INPUT FILES:                                                ***
c ***        unit 1 (ur1):  POLE8.IN                                  ***
c ***        unit 2 (ur2):  texture file(s)                           ***
c ***        unit 3 (ur3):  POLE8.PRO                                 ***
c ***        unit 7 (ur4):  single crystal file 'filecrys'            ***
c ***********************************************************************
c ***     OUTPUT FILES:                                               ***
c ***        unit  4 (uw2): discriminated texture file(s)             ***
c ***        unit 10 (uw1): POLE8.OUT                                 ***
c ***     Level lines option:                                         ***
c ***        unit 11 :  circles coordinates (2 lines in sub circle)   ***
c ***        unit 12 :  crosses coordinates (2 lines in sub isolev)   ***
c ***        unit 13 :  maxima & their coordinates (1 line in isolev) ***
c ***        unit 14 :  labels & their coordinates (2 lines in circle)***
c ***        unit 18 :  PROFILE.OUT (only for axysymmetry option)     ***
c ***        unit 19 :  GRIDINT.OUT (intensity at grid positions)     ***
c ***        unit 21-36:   level lines coordinates                    ***
c ***     Dots option:                                                ***
c ***        unit 21-30:   crosses coordinates binned by weight       ***
c ***********************************************************************

      include 'POLE8.DIM'

      parameter (maxt= 6)      ! maximum number of textures to plot
      parameter (maxp= 6)      ! maximum number of poles to plot

      character*80 textfile(maxt),textfilex(maxt),filecrys,prosa
      dimension    ntfpf(maxt),ngrtf(maxt,maxt),miller(4,maxp)
      character    nfile*12,nomen*1
      character*10 time,date,zone
      integer      dt(8)
      integer*2    default
      dimension    q(3,24),rcomp(3),fcomp(3)
      dimension    fphi(0:75),fthe(20)
      dimension    xpx(npmax),ypx(npmax),npbin(10)

      prosa=prosa      ! JUST TO FOOL THE COMPILER
      dash ='     -    '

c *******************************************************************

      ur1=1
      ur2=2
      ur3=3
      ur4=7
      uw1=10
      uw2=4
      open(ur1,file='POLE8.IN',status='old')

c *** reads-in texture files & splits files that contain multiple textures
      read(ur1,'(a)') prosa
      read(ur1,*)     ntextfilesx

c *** auxiliar algorithm for controling # of columns
c     read(ur1,*)     ntextfilesx,ncmax    ! max # of columns (14/09/07)
c     if(ncmax.gt.6) then
c       write(*,*) ' --> maximum # of columns > 6 may cause trouble !!'
c       pause
c     endif

      read(ur1,'(a)') prosa
      ntextfiles=0
      do i=1,ntextfilesx
        ntfpf(i)=0
        read(ur1,'(a)') textfilex(i)
        open(ur2,file=textfilex(i),status='old')
        do multi=1,maxt     ! eventually may set lower limit to total textures
          read(ur2,'(a)',end=77) prosa
          read(ur2,'(a)') prosa
          read(ur2,'(a)') prosa
          read(ur2,*)     nomen,ngrain
          ntfpf(i)=ntfpf(i)+1
          ngrtf(i,ntfpf(i))=ngrain
          if(ngrain.gt.ngmax) then
            write(*,*)
            write(*,'('' WARNING !! THERE ARE'',I8,'' ORIENTATIONS IN'',
     #                '' TEXTURE FILE'')') NGRAIN
            write(*,'('' THE MAXIMUM DIMENSION NGMAX IS'',I8)') NGMAX
            write(*,'('' ---> INCREASE PARAMETER NGMAX IN POLE8.DIM'')')
            stop
          endif
          ntextfiles=ntextfiles+1
          if(ntextfiles.gt.maxt) then
            write(*,'('' TOTAL # OF TEXTURES CANNOT EXCEED maxt='',i5)')
     #                   maxt
            stop
          endif
          n10=ntextfiles/10
          n01=ntextfiles-n10*10
          textfile(ntextfiles)=
     #         'text_'//char(48+n10)//char(48+n01)//'.dat'
          open(uw2,file=textfile(ntextfiles),status='unknown')
            write(uw2,'(a1,i10)') nomen,ngrain
            do j=1,ngrain
              read(ur2,*)  ang1,ang2,ang3,wgtx
              write(uw2,*) ang1,ang2,ang3,wgtx
            enddo
          close(uw2)
        enddo
   77   continue
      enddo
      ndiftexts=ntextfiles

c ***********************************************************************
c *** Reads path & name of file with single crystal symmetry & parameters
c *** Calls CRYSTAL_SYMMETRY to read unit cell parameters and to generate
c *** unit cell vectors and symmetry operations associated with ICRYSYM.

      read(ur1,'(a)') prosa
      read(ur1,'(a)') filecrys
      open(unit=ur4,file=filecrys,status='old')
        call crystal_symmetry (1,ur4,icrysym,isn,rcomp,q,npol)
      close(unit=ur4)

c **********************************************************************
c     open output files for this run
c **********************************************************************

      open(uw1,file='POLE8.OUT',status='unknown')

      write(*,*) 'enter identification of output file (5 characters)'
      write(*,*)
      read (*,'(a5)')   outfileid
      write(uw1,'(a5)') outfileid
      nfile=outfileid//'_CC.DAT'
        open (unit=11,file=nfile,status='unknown')
      nfile=outfileid//'_XX.DAT'
        open (unit=12,file=nfile,status='unknown')
      nfile=outfileid//'_MX.DAT'
        open (unit=13,file=nfile,status='unknown')
      nfile=outfileid//'_LB.DAT'
        open (unit=14,file=nfile,status='unknown')

c **********************************************************************
c     default settings for representing PF's and IPF's
c **********************************************************************

        mgrid=36
        ngrid= 9
        spread=180.001/mgrid
        icros= 0
        idraw= 0
        ifull= 0
        igrid= 0
        iproj= 0
        irepr= 0
        isepa= 0
        ishft= 0
        ismth= 0
        isym = 0
        iwrite=0
        pfrot =0.

      write(*,*) 'enter: '
      write(*,*) '   1 if you want to choose the settings'
      write(*,*) '   0 if you want to use default settings'
      write(*,*) '  -1 to read settings from POLE8.PRO  ---> '
      read (*,*)  default

c **********************************************************************
      if (default.eq.-1) then
        open(ur3,file='POLE8.PRO',status='old')

c *** general parameters associated with dot & line PF's
        read(ur3,'(a)') prosa
        read(ur3,*)     ifull,iproj,irepr,isym
        read(ur3,'(a)') prosa
        read(ur3,*)     iper(1),iper(2),iper(3)
c *** parameters associated with grid & line
        read(ur3,'(a)') prosa
        read(ur3,*)     igrid,mgrid,ngrid
        pfrot=pfrot*pi/180.
c *** parameters associated with PF massaging
        read(ur3,'(a)') prosa
        read(ur3,*)     ishft,ismth,pfrot
c *** parameters associated with line representation (defined in ISOLEV)
        read(ur3,'(a)') prosa
        read(ur3,*)     icros,idraw,isepa,iwrite,spread,step
        read(ur3,'(a)') prosa
        read(ur3,*)     nlevels
          if(nlevels.gt.nlmax) then
            write(*,*) '*** nlevels EXCEEDS MAXIMUM DIMENSION nlmax'
            stop
          endif
        read(ur3,'(a)') prosa
        read(ur3,*)     (rlevel(l),l=1,nlevels)
        do l=1,nlevels
          level(l)=l
        enddo

        close(unit=ur3)
      endif

c ***********************************************************************
c *** reads 'ipfig' : 0 for pole fig plot, 1 for inverse pole fig plot

      read(ur1,'(a)') prosa
      read(ur1,*)     ipfig
c **********************************************************************
      if(default.ne.-1 .and. ipfig.eq.0) then
        write(*,*)
        write(*,*) 'enter indices of pole figure axes:'
        write(*,*) '   right,top,center                ---> '
        read (*,*)  iper(1),iper(2),iper(3)

        write(*,*) 'choose an option of symmetrization:'
        write(*,*) '   no symmetry  (0)'
        write(*,*) '   2-fold axis  (1)'
        write(*,*) '   x-mirror     (2)'
        write(*,*) '   y-mirror     (3)'
        write(*,*) '   x&y-mirror   (4)'
        write(*,*) '   axisymmetry (-1)                ---> '
        read(*,*) isym
        if(isym.gt.0) then
          write(*,*) 'enter (0) for a full circle representation'
          write(*,*) 'enter (1) for a reduced circular section   ---> '
          read (*,*)  ifull
        endif
      endif
c *********************************************************************
      if(default.eq.1) then
        write(*,*) 'choose equal area projection (0)'
        write(*,*) 'or stereographic projection  (1) ---> '
        read (*,*)  iproj

        write(*,*) 'choose level lines (0)'
        write(*,*) 'or dots representation (1)    ---> '
        read (*,*)  irepr
        if(irepr.eq.1 .and. isym.eq.-1) isym=0

        write(*,*) 'enter PF rotation in degrees  ---> '
        read (*,*)  pfrot
        pfrot=pfrot*pi/180.
      endif

      if(default.eq.1 .and. irepr.eq.0) then
        write(*,*) 'choose type of grid:'
        write(*,*) '  equispaced in phi , theta         (0)'
        write(*,*) '  or equispaced in phi , cos(theta) (1)  ---> '
        read (*,*)  igrid

        write(*,*) 'smooth polar sector of Pole Figure ?'
        write(*,*) 'enter (0) if not'
        write(*,*) 'enter 1<ismth<10 for weak/strong smoothing ---> '
        read (*,*)  ismth
      endif

      if(default.eq.1 .and. irepr.eq.0 .and. ipfig.le.0) then
        write(*,*) 'enter number of cells MGRID,NGRID (maximum 72x18)'
        write(*,*) 'in range: phi=[0,2*pi] & theta=[0,pi/2]    --->  '
        read(*,*) mgrid,ngrid

        if(isym.lt.4) meven=(mgrid/2)*2
        if(isym.eq.4) meven=(mgrid/4)*4
        if((mgrid/meven)*meven .ne. mgrid) then
          mgrid=(mgrid/meven)*meven
          write(*,'(''*** because of boundary condition requirements '',
     #              ''mgrid is updated to'',i3)') mgrid
        endif
        write(*,*)
        write(*,*) 'shift grid by deltaphi/2 (1) or not (0)?   ---> '
        read (*,*)  ishft
        if(ishft.eq.1) isym=0
      endif

c *******************************************************************
c *** For Inverse Pole Figures hard-wires some parameters.
c *** When plotting IPS's 'mgrid' has to be a multiple of 8, 12, 6, 4
c     or 2 for cubics, hexagonal, trigonal, orthorhombic or monoclinic.
c *** This gives IPF's spanning 45, 30, 60, 90 and 180 deg respectively.
c *** For simplicity mgrid=72 is hard-wired for all the cases.

      if(ipfig.gt.0) then
        mgrid=72
        ngrid=18
        iper(1)=1
        iper(2)=2
        iper(3)=3
      endif

c ***********************************************************************
c *** defines number of components in pole or inverse pole representation
c *** reads Miller indices of poles (or sample axes) to be plot

      nind=3
      if (icrysym.eq.2 .or. icrysym.eq.3) nind=4
      if (ipfig.gt.0) nind=3

      read(ur1,'(a)') prosa
      read(ur1,*)     ndifpoles
      if(ndifpoles.gt.maxp) then
        write(*,'('' TOTAL NUMBER OF POLES CANNOT EXCEED'',i4)') maxp
        write(*,'('' >  WILL PLOT ONLY THE FIRST'',i4,'' POLES'')') maxp
        ndifpoles=maxp
        pause
      endif
      read(ur1,'(a)') prosa
      do jpol=1,ndifpoles
        read(ur1,*) (miller(i,jpol),i=1,nind)
      enddo

c **********************************************************************
c *** defines the coordinates of the grid x=phi , y=cos(theta) , z=theta

      if(irepr.eq.0) then

        np2=ngrid+2
        mp2=mgrid+2
        deltx=2.*pi/mgrid
        hdeltx=deltx/2.*ishft
        do j=1,mp2
          x(j)=-pi+(j-1.5)*deltx-hdeltx
        enddo

c *** defines a grid with (mgrid*ngrid+1) equal-area spherical elements.
        if(igrid.eq.1) then
          delty=mgrid/(mgrid*ngrid+1.)
          cos1=ngrid*delty
          y(1)=0.9999      !set interp point as close to pole as possible
          z(1)=acos(cos1)
          do i=2,np2
            y(i)=cos1-(i-1.5)*delty
            z(i)=acos(cos1-(i-1)*delty)
          enddo
        endif

c *** defines a grid of mgrid*ngrid spherical elements spanning equal angles
c *** plus a polar cup spanning z(1) degrees.
        if(igrid.eq.0) then
          y(1)=0.9999         !set interp point as close to pole as possible
          z(1)=(pi/180.)*5    ! hardwires a 5 deg polar cap if igrid=0
          if(ipfig.gt.0) z(1)=pi/2./ngrid
          deltz=(pi/2.-z(1))/float(ngrid)
          do i=2,np2
            z(i)=z(1)+(i-1.)*deltz
            y(i)=(cos(z(i))+cos(z(i-1)))/2.
          enddo
        endif

c *** generates a 'cluster' of poles around each pole if spread>0
        if(default.eq.0) spread=180.001/mgrid
        if(default.eq.1) then
          spread=180.001/mgrid
          write(*,'('' suggested spread is'',f5.1,'' deg'')') spread
          write(*,*) 'enter (0) if you do not want to spread the poles'
          write(*,*) 'or enter spread around poles in degrees    ---> '
          read (*,*)  spread
        endif
        nps=1
        frac(1)=1.d0
        spreadr=spread*pi/180.d0
        if(spread.gt.0) call spread_poles(1,spreadr,nps,x1,y1)

      endif

c **********************************************************************
c *** Scales radious (in inches) of PF or IPF consistent with the number
c     of different poles and texture files.
c     For cubic IPF calculates extra factor to expand IPF to radious size.

      cubicfactor=1.
      if(icrysym.eq.1 .and. ipfig.gt.0) then
        xaux=0.
        yaux=cos(45./180.*pi)
        call project(xaux,yaux,1.d0,iproj)
        cubicfactor=1./xaux
      endif

      xframe=6.5      ! drawing area in inches
      yframe=6.5

c *** enforces more columns than rows
      ncols=max(ndifpoles,ndiftexts)
      nrows=min(ndifpoles,ndiftexts)

c *** enforces more rows than columns (26/mar/07)
c     nrows=max(ndifpoles,ndiftexts)
c     ncols=min(ndifpoles,ndiftexts)

c *** auxiliar algorithm for plotting in a 6x6 grid  (03/sep/2007)
c     if(ndiftexts.gt.6) then
c       ncols=6
c       nrows= ( (ndiftexts-1)/6 + 1) * ndifpoles
c       if(nrows.gt.6) then
c         write(*,*) 'STOPPING !! PLOT EXCEEDS THE 6X6 GRID'
c         stop
c       endif
c     endif

      if(ipfig.eq.0) then
        rad=1.d0
        xsepa=2.4*rad
        ysepa=2.7*rad
        if(ifull.eq.1) then
          if(isym.le.2) xsepa=1.4*rad
          if(isym.ge.3) ysepa=1.7*rad
          if(isym.eq.4) xsepa=1.4*rad
        endif
      else if(ipfig.gt.0) then
        rad=1.5
        xsepa=1.4*rad
        ysepa=1.7*rad
      endif

      xsize=ncols*xsepa
      ysize=nrows*ysepa
      scale=min(rad,xframe/xsize,yframe/ysize)
      rad  =scale*rad
      radx =rad*cubicfactor   ! accounts for IPFs of cubics
      xsepa=scale*xsepa
      ysepa=scale*ysepa

c **********************************************************************
c *** Write heading with information about this run in file POLE8.OUT

      call date_and_time (date,time,zone,dt)
      date=date
      time=time
      zone=zone
      nlines=7+ntextfilesx
      write(uw1,'(i4,''   next lines in POLE8.OUT is text'')') nlines
      write(uw1,'(i4,''/'',i2,''/'',i2,2x,i2,'':'',i2)')
     #                   dt(1),dt(2),dt(3),dt(5),dt(6)
      do i=1,ntextfilesx
        write(uw1,'(a40,9i5)') textfilex(i),(ngrtf(i,j),j=1,ntfpf(i))
      enddo

      if(icrysym.eq.1) write(uw1,'(''* CUBIC crystal'')')
      if(icrysym.eq.2) write(uw1,'(''* HEXAGONAL crystal'')')
      if(icrysym.eq.3) write(uw1,'(''* TRIGONAL crystal'')')
      if(icrysym.eq.4) write(uw1,'(''* TETRAGONAL crystal'')')
      if(icrysym.eq.5) write(uw1,'(''* ORTHOGONAL crystal'')')
      if(icrysym.eq.6) write(uw1,'(''* MONOCLINIC crystal'')')
      if(icrysym.eq.7) write(uw1,'(''* TRICLINIC crystal'')')

      if(ipfig.eq.0) then
        if(isym.eq.0)  write(uw1,*) '* PF not symmetrized'
        if(isym.eq.1)  write(uw1,*) '* two-fold PF symmetry'
        if(isym.eq.2)  write(uw1,*) '* x-mirror PF symmetry'
        if(isym.eq.3)  write(uw1,*) '* y-mirror PF symmetry'
        if(isym.eq.4)  write(uw1,*) '* orthogonal PF symmetry'
        if(isym.eq.-1) write(uw1,*) '* axial PF symmetry'
      else if(ipfig.gt.0) then
        write(uw1,*)               '* inverse pole figure'
      endif

      if(iproj.eq.0) write(uw1,*) '* equal area projectn'
      if(iproj.eq.1) write(uw1,*) '* stereograph projectn'

      if(irepr.eq.0) then
        if(igrid.eq.0) write(uw1,'(''*'',i3,''x'',i2,
     #                         '' [phi,th] grid'')') mgrid,ngrid
        if(igrid.eq.1) write(uw1,'(''*'',i3,''x'',i2,
     #                         '' [phi,cos(th)] grid'')') mgrid,ngrid
        write(uw1,'(''*'',f5.1,'' degrees spread'')') spread
        write(uw1,'(''* center smoothing='',i2)') ismth
        write(uw1,'(i2,'' (line representation)'')')  irepr
      else if(irepr.eq.1) then
        write(uw1,*)
        write(uw1,*)
        write(uw1,*)
        write(uw1,'(i2,'' (dot representation)'')')  irepr
      endif

      write(uw1,'(f6.2,'' (pole figure radious)'')') rad
      write(uw1,'(i2,'' (pole figure symmetrization)'')') isym*ifull
      if(ipfig.eq.0) write(uw1,'(i2,'' (direct pole figure)'')') ipfig
      if(ipfig.gt.0) write(uw1,'(i2,'' (invers pole figure)'')') ipfig
      write(uw1,*)
      write(uw1,'(2i5,''  npoles,ntextures'')') ndifpoles,ndiftexts

c **********************************************************************
c *** For direct pole figures uses the indices of the pole to be
c     represented, plus crystal symmetry operations, to calculate the
c     'npol' crystall. equiv. poles and unit normal vectors 'q(3,npol)'
c *** For inverse pole figures uses the indices of the sample axis
c     to be represented, plus crystal symmetry operations, to calculate
c     equivalent 'poles'
c **********************************************************************
c *** Reads texture in Bunge, Roe or Kocks convention.
c **********************************************************************
c *** For special applications reads a function associated with a grid.
c **********************************************************************

      nloops=0

      do 300 ndifpol=1,ndifpoles     ! LOOP OVER SEVERAL POLES

        do i=1,nind
          isn(i)=miller(i,ndifpol)
        enddo
        if(ipfig.eq.0) then
          call crystal_symmetry (2,ur1,icrysym,isn,rcomp,q,npol)
        else if(ipfig.gt.0) then
          if((isn(1)**2+isn(2)**2+isn(3)**2).ne.1) then
            write(*,*) ' can only plot IPF of sample axes !!'
            stop
          endif
          if(isn(1).eq.1) ipfig=1
          if(isn(2).eq.1) ipfig=2
          if(isn(3).eq.1) ipfig=3
        endif

c *** subroutine CIRCLES generates the points of the circular section,
c *** defines labels and label coordinates.

        call circles (xori,yori,1.d0,radx,icrysym,1)

      do 290 ndiftex=1,ndiftexts     ! LOOP OVER SEVERAL TEXTURES

ccc     pfrot=0.                             ! temporary special case
ccc     if(ndiftex.eq.1) pfrot=90.*pi/180.   ! temporary special case

        nloops=nloops+1
        if(nloops.ge.2) default=-1

        if(ipfig.ge.0) then
          open(ur2,file=textfile(ndiftex),status='old')
            call texture (ngrain)
          close(unit=ur2)
        endif

c *** defines the position of the (0,0) point of PF's and IPF's depending
c     on # of textures, # of PF's, and symmetrization option chosen.

        if(ndifpoles.ge.ndiftexts) then
          nxx=ndifpol
          nyy=ndiftex
        else if(ndifpoles.lt.ndiftexts) then
          nxx=ndiftex
          nyy=ndifpol
        endif

c *** auxiliar algorithm for forcing ncmax columns (ncmax.le.6) and
c *** plotting in a (ncmax x 6) grid     (03/sep/2007)
c       nxx= ndiftex-(ndiftex-1)/ncmax*ncmax
c       nxx= nloops -(nloops -1)/ncmax*ncmax
c       nyy= (nloops-1)/ncmax + 1

        xori= xsepa*(nxx-1)
        yori=-ysepa*(nyy-1)

c *** special cases need to be reprogrammed !!
c       if(ipfig.lt.0) then
c         call special_cases(np2,mbot,mtop,textfile)
c         default=0
c         go to 250
c       endif

c *** Write information about this loop in file POLE8.OUT
      if(ipfig.eq.0) write(uw1,'(4i3,''     poles'')')
     #                    (miller(i,ndifpol),i=1,nind)
      if(ipfig.gt.0) write(uw1,'(3i3,''     sample axis'')')
     #                    (miller(i,ndifpol),i=1,3)

c *** Subroutine CIRCLES writes the coordinates of the circular section
c *** into files 'POLE8.OUT' and 'FILEID_CC.DAT'.
c *** Writes the coordinates of the labels into 'FILEID_LB.DAT'.

      call circles (xori,yori,rad,radx,icrysym,2)

c **************************************************************************
c *** calculates coordinates of polar vectors: xp=phi,yp=cos(theta),zp=theta
c **************************************************************************

      np=1
      twgt=0.0
      npx=npol*ngrain
      if(isym.ge.1) npx=2*npx
      if(isym.eq.4) npx=2*npx
      if(npx .gt. npmax) then
        write(*,*) '**** DIMENSION npmax EXCEEDED'
        write(*,*) '**** INCREASE  npmax TO  ',npx,'  IN POLE8.DIM'
        stop
      endif

      do igrain=1,ngrain
        twgt=twgt+wgt(igrain)

c *** when plotting IPF's calculates the 'npoles' q for each orientation by
c *** applying the symmetry operations to sample axis 'ipfig' being plotted
c *** (given by the corresponding column of the grain's rotation matrix)

        if(ipfig.gt.0) then
          do i=1,3
            rcomp(i)=r(i,ipfig,igrain)
          enddo
          call crystal_symmetry (3,ur1,icrysym,isn,rcomp,q,npol)
        endif

        do k=1,npol

          if(ipfig.eq.0) then
            do j=1,3
            rcomp(j)=0.
              do i=1,3
                rcomp(j)=rcomp(j)+r(i,j,igrain)*q(i,k)
              enddo
            enddo
          else if(ipfig.gt.0) then
            do j=1,3
              rcomp(j)=q(j,k)
            enddo
          endif

c *** accounts for axes permutation in pole figure representation,
c *** including negative axis directions.
          fcomp(1)=isign(1,iper(1))*rcomp(abs(iper(1)))
          fcomp(2)=isign(1,iper(2))*rcomp(abs(iper(2)))
          fcomp(3)=isign(1,iper(3))*rcomp(abs(iper(3)))

          if(fcomp(3).lt.0.0) then
            fcomp(1)=-fcomp(1)
            fcomp(2)=-fcomp(2)
            fcomp(3)=-fcomp(3)
          endif

          seca=sqrt(fcomp(1)**2+fcomp(2)**2)
          if(seca.lt.1.e-03) then
            xp(np)=0.0 +pfrot
            yp(np)=cos(seca)
          else
            xp(np)=atan2(fcomp(2),fcomp(1)) +pfrot
            yp(np)=fcomp(3)
          endif
          wgtp(np)=wgt(igrain)
          np=np+1

        enddo      ! end of DO K=1,NPOL
      enddo      ! end of DO GRAIN=1,NGRAIN
      np=np-1

c *** symmetrizes the poles according to the value of 'isym'

c *** performs a center inversion.
      if(isym.eq.1) then
        do ip=1,np
          sign=1
          if(xp(ip).gt.0.0) sign=-1.
          xp(ip+np)=sign*(pi-abs(xp(ip)))
          yp(ip+np)= yp(ip)
          wgtp(ip+np)=wgtp(ip)
        enddo
        np=2*np
        twgt=2.*twgt
      endif

c *** performs an x-axis inversion.
      if(isym.eq.2 .or. isym.eq.4) then
        do ip=1,np
          if(xp(ip).ge.0.0) xp(ip+np)= pi-xp(ip)
          if(xp(ip).lt.0.0) xp(ip+np)=-pi-xp(ip)
          yp(ip+np)= yp(ip)
          wgtp(ip+np)=wgtp(ip)
        enddo
        np=2*np
        twgt=2.*twgt
      endif

c *** performs a y-axis inversion.
      if(isym.eq.3 .or. isym.eq.4) then
        do ip=1,np
          xp(ip+np)=-xp(ip)
          yp(ip+np)= yp(ip)
          wgtp(ip+np)=wgtp(ip)
        enddo
        np=2*np
        twgt=2.*twgt
      endif

c *********************************************************************
c     BLOCK FOR PROCESSING POINT POLE FIGURES (irepr=1)

      if(irepr.eq.1) then
c *********************************************************************

c *** keeps only the poles that are in the reduced symmetry region
c *** associated with isym=1,2,3,4.

        if(isym.ne.0 .and. ifull.gt.0) then

          if(isym.eq.1 .or. isym.eq.2) then
            xpbot=-pi/2.
            xptop= pi/2.
          else if (isym.eq.3) then
            xpbot= 0.
            xptop= pi
          else if (isym.eq.4) then
            xpbot= 0.
            xptop= pi/2.
          endif

          ipp=0
          do ip=1,np
            if(xp(ip).ge.xpbot .and. xp(ip).le.xptop) then
              ipp=ipp+1
              xp(ipp)=xp(ip)
              yp(ipp)=yp(ip)
              wgtp(ipp)=wgtp(ip)
            endif
          enddo
          np=ipp

        endif      ! end of if(isym.ne.0)

c ***************************************************************************
c *** projects each pole and stores the coordinates of the projection
c *** plus an integer proportional to the weight.

c *** for inverse pole figures keeps only points within the reduced region.
        if(ipfig.gt.0) then
          tiny=0.
          phibot=-tiny
          if(icrysym.eq.1) phitop=45.*pi/180. +tiny
          if(icrysym.eq.2) phitop=30.*pi/180. +tiny
          if(icrysym.eq.3) phitop=60.*pi/180. +tiny
          if(icrysym.eq.4) phitop=45.*pi/180. +tiny
          if(icrysym.eq.5) phitop=90.*pi/180. +tiny
          if(icrysym.eq.6) phitop=    pi      +tiny
          if(icrysym.eq.7) phitop= 2.*pi      +tiny
          npx=0

          do ip=1,np
            if(xp(ip).ge.phibot. and . xp(ip).le.phitop) then
              npx=npx+1
              xp(npx)=xp(ip)
              yp(npx)=yp(ip)
              wgtp(npx)=wgtp(ip)
            endif
          enddo
          np=npx
        endif

c *** eliminates crosses contained in 2nd and 3rd stereographic triangle.
        if(icrysym.eq.1 .and. ipfig.gt.0) then
          npx=0
          do ip=1,np
            thx=acos(yp(ip))
            pro=(-cos(xp(ip))*sin(thx)+cos(thx))/sqrt(2.)
            if(pro.ge.0) then
              npx=npx+1
              xp(npx)=xp(ip)
              yp(npx)=yp(ip)
              wgtp(npx)=wgtp(ip)
            endif
          enddo
          np=npx
        endif

c *** assigns poles to bins according to their weight
        wgtmax=0.
        do ip=1,np
          if(wgtp(ip).gt.wgtmax) wgtmax=wgtp(ip)
        enddo
        wgtmax=1.0001*wgtmax
        binsize=wgtmax/10.
        do ibin=1,10
          npbin(ibin)=0
        enddo
        do ip=1,np
          call project(xp(ip),yp(ip),1.d0,iproj)
          ibin=(wgtp(ip)/binsize)+1
          npbin(ibin)=npbin(ibin)+1
          intwgt(ip)=ibin
        enddo

c *** orders the poles sequentially by weight
        jp=1
        do ibin=1,10
          do ip=1,np
            if(intwgt(ip).eq.ibin) then
              xpx(jp) =xp(ip)
              ypx(jp) =yp(ip)
              jp=jp+1
            endif
          enddo
        enddo

        write(uw1,'('' weight  npoles'')')
        npacum=0
        do ibin=1,10
          write(uw1,'(i4,i6,''  wgt & npoles'')') ibin,npbin(ibin)
          if(npbin(ibin).gt.0) then

            write(uw1,'(8f10.4)')
     #           (xpx(ip)*radx+xori,ip=npacum+1,npacum+npbin(ibin))
            write(uw1,'(8f10.4)')
     #           (ypx(ip)*radx+yori,ip=npacum+1,npacum+npbin(ibin))

            nfile=outfileid//'_X'//char(48+ibin-1)//'.DAT'
            iunit=20+ibin
            open(unit=iunit,file=nfile,status='unknown')
            write(iunit,'(2f10.4)') (xpx(ip)*radx+xori,ypx(ip)*radx+yori
     #                              ,ip=npacum+1,npacum+npbin(ibin))
            write(iunit,'(2a10)') dash,dash

          endif
          npacum=npacum+npbin(ibin)
        enddo

c *********************************************************************
c     END OF BLOCK FOR PROCESSING POINT POLE FIGURES (irepr=1)

      endif      ! end of if(irepr.eq.1)
c *********************************************************************

c *********************************************************************
c     BLOCK FOR PROCESSING INTENSITY LINE POLE FIGURES (irepr=0)

      if(irepr.eq.0) then
c *********************************************************************

c *** accumulates poles in the elements of the grid.
c *** if spread>0 each pole is split into a 'cluster' of nps poles,
c *** preserving the total weight.

      do i=1,np2
      do j=1,mp2
        f(i,j)=0.
      enddo
      enddo
      do ip=1,np
        xps(1)=xp(ip)
        yps(1)=yp(ip)

        if(spread.gt.0.) call spread_poles(2,spreadr,nps,xp(ip),yp(ip))

        do ips=1,nps
          x1=xps(ips)
          y1=yps(ips)
          if(y1.lt.0.0) then
            x1=x1+pi
            y1=-y1
          endif
          z1=acos(y1)
          w1=wgtp(ip)*frac(ips)

          if(x1.lt.(-pi-hdeltx)) x1=x1+2.*pi
          if(x1.gt.( pi-hdeltx)) x1=x1-2.*pi
          jphi=int((x1+pi+hdeltx)/deltx+2.)
          if(igrid.eq.1) ithe=int((cos1-y1)/delty+2.)
          if(igrid.eq.0) ithe=int((z1-z(1))/deltz+2.)
          if(ithe.eq.0) ithe=1             ! fix potential polar cup effect
          f(ithe,jphi)=f(ithe,jphi)+w1
        enddo
      enddo

c *** activate next 6 lines for auxiliar check up of the spread option.
c      do n=1,nps
c        xp(n)=xps(n)
c        yp(n)=yps(n)
c      enddo
c      irepr=1
c      np=nps
c      go to 250

c *** calculates pole density from accumulated volume fraction in each element.
c *** pole density is normalized such as to be 1 for a random texture.
c *** imposes boundary conditions on the outer elements of the grid.

      mp1=mgrid+1
      np1=ngrid+1
      avf=npol*twgt/(2.*pi)

c *** assigns same density to first ring to smooth polar cup.
      fpole=0.0
      do j=2,mp1
        fpole=fpole+f(1,j)
      enddo
      fnorm=avf*(1.-cos(z(1)))*2.*pi
      fpole=fpole/fnorm
      do j=2,mp1
        f(1,j)=fpole
      enddo

c *** calculates intensities and normalizes (1 is random texture).
      do i=2,np1
        if(igrid.eq.1) fnorm=avf*delty*deltx
        if(igrid.eq.0) fnorm=avf*(cos(z(i-1))-cos(z(i)))*deltx
        do j=2,mp1
          f(i,j)=f(i,j)/fnorm
        enddo
      enddo

c *** this block enforces axisymmetry in pole figure.
      if(isym.eq.-1) then

        do i=1,np1
          fthe(i)=0.
          do j=2,mp1
            fthe(i)=fthe(i)+f(i,j)
          enddo
          fthe(i)=fthe(i)/mgrid    ! average intensity
        enddo
        fthe(np2)=fthe(np1)   ! equatorial boundary condition
        do i=1,np1
        do j=2,mp1
          f(i,j)=fthe(i)
        enddo
        enddo

c *** calculate axisymmetric profile of pole figure (OPTIONAL).
c     'fthe(i)' is intensity and 'fphi(i)' is volume fraction.
c *** Since f(i,j) is defined to be 1 for random texture, its integral over
c     Euler space gives 2*pi. As a consequence volume fractions follow from
c     integrating f(i,j) and dividing by 2*pi.

        if(ndiftex.eq.1 .and. ndifpol.eq.1)
     #        open(unit=18,file='profile.out',status='unknown')

        write(18,'(a)') textfile(ndiftex)
        write(18,'(''poles   '',4i3)') (miller(i,ndifpol),i=1,nind)
        write(18,
     #      '(''      ang       int     vdens     vfrac     vfacc'')')

        fphi(1)=(1.-cos(z(1)))*fthe(1)
        do i=2,np2
          fphi(i)=(cos(z(i-1))-cos(z(i)))*fthe(i)   ! volume fraction in ring
        enddo
        vfacc=fphi(1)
        do i=1,np1
          thetax=acos(y(i))
          write(18,'(f10.2,4f10.5)') thetax*180./pi,fthe(i),
     #                               fthe(i)*sin(thetax),fphi(i),vfacc
          vfacc=vfacc+fphi(i+1)
        enddo

      endif      ! end of isym=-1 condition

c *** impose boundary condition on equator elements (REQUIRED).
      mh  =mgrid/2
      mhp1=mh+1
      mhp2=mh+2
      do j=2,mhp1
        f(np2,j)=f(np1,j+mh)
      enddo
      do j=mhp2,mp1
        f(np2,j)=f(np1,j-mh)
      enddo

c *** impose boundary condition for 2*pi periodicity (REQUIRED).
      do i=1,np2
        f(i,1)=f(i,mp1)
        f(i,mp2)=f(i,2)
      enddo

c *** smooth PF by mixing the cell intensity with the intensity of the two
c     nearest neighbor cells using empirical coefficents: a0+2*a1+2*a2=1
c *** the amount of 'mix' is maximum at the pole and decays rapidly
c     towards the equator, with empirical factor 1< smthfr <0

      if(ismth.ne.0) then
        do ifilter=1,ismth      ! runs filter multiple times
          do i=2,np2
            thex=acos(y(i))*180./pi
            smthfr=2./(1.+exp(90.*(thex/90.)**4))
            do j=1,mp2
              fphi(j)=f(i,j)
            enddo
            fphi(0)=fphi(mp2-2)
            fphi(mp2+1)=fphi(3)
            a0= 0.30 + (1.-smthfr)* 0.70
            a1= 0.25 - (1.-smthfr)* 0.25
            a2= 0.10 - (1.-smthfr)* 0.10
            do j=2,mp1
              f(i,j)=a0*fphi(j)+a1*(fphi(j-1)+fphi(j+1))
     #                         +a2*(fphi(j-2)+fphi(j+2))
            enddo
            f(i,1)=f(i,mp1)
            f(i,mp2)=f(i,2)
          enddo
        enddo      ! end of multiple-filter loop
      endif

c *** smooth PF by mixing the cell intensity with the intensity of an
c *** axisymmetric 'belt'. The smoothing factor decays rapidly.
c
c     if(ismth.eq.1) then
c       do i=2,np2
c         thex=acos(y(i))*180./pi
c         smthfr=2./(1.+exp(90.*(thex/90.)**4))
c         fthe(i)=0
c         do j=2,mp1
c           fthe(i)=fthe(i)+f(i,j)
c         enddo
c         fthe(i)=fthe(i)/mgrid
c         do j=2,mp1
c           f(i,j)=(1-smthfr)*f(i,j)+smthfr*fthe(i)
c         enddo
c         f(i,1)=f(i,mp1)
c         f(i,mp2)=f(i,2)
c       enddo
c     endif
c
c *** writes table with grid coordinates (phi,th) and intensities (OPTIONAL).
c     write(19,*)
c     write(19,*) '   ang   phiave      ph1    ph2    ph3    ...'
c     write(19,'(18x,36f7.1)') (x(j)*180./pi,j=2,mgrid+1,2)
c     do i=1,np2
c       write(19,'(f6.2,3x,f6.2,3x,36f7.2)')
c    #            acos(y(i))*180./pi,fthe(i),(f(i,j),j=2,mgrid+1,2)
c     enddo

c *** writes table with: 'phi  cos(theta)  x  y  intensity' (OPTIONAL)
c     do i=1,np2
c       do j=1,mp2
c         ycart=y(i)
c         xcart=x(j)
c         call project(xcart,ycart,rad,iproj)
c         write(19,'(4f10.4,f10.2)') x(j),y(i),xcart,ycart,f(i,j)
c       enddo
c     enddo

c *** writes table with grid coordinates (phi,th) and intensities (OPTIONAL).

      if(ndiftex.eq.1 .and. ndifpol.eq.1)
     #        open(unit=19,file='gridint.out',status='unknown')

      write(19,'(a)') textfile(ndiftex)
      write(19,'(''poles   '',4i3)') (miller(i,ndifpol),i=1,nind)
      write(19,*) '      phi     theta      int'
      do i=1,np2
        do j=1,mp2
          write(19,'(3f10.3)') x(j)*180./pi,acos(y(i))*180./pi,f(i,j)
        enddo
      enddo

c ***************************************************************************
c *** special cases    --->   need to be reprogrammed !!!!
c     if (ipfig.lt.0) then
c       call isolev
c       go to 250
c     endif
c ***************************************************************************

c *** defines range of cells for plotting intensity lines.
c *** full interval runs from -180 < phi < 180.

      if(ipfig.eq.0) then
          ntop=np2
        if(isym.le.0 .or. ifull.eq.0) then
          mtop=mgrid+2
          mbot=1
        else if(isym.eq.1 .or. isym.eq.2) then
          mtop=3*mgrid/4+2
          mbot=mgrid/4+1
        else if(isym.eq.3) then
          mtop=mgrid+2
          mbot=mgrid/2+1
        else if(isym.eq.4) then
          mtop=3*mgrid/4+2
          mbot=mgrid/2+1
        endif
      endif

      if(ipfig.gt.0) then
          ntop=np2
        if(icrysym.eq.1) then
          mtop=5*mgrid/8+2
          mbot=4*mgrid/8+1
          ntop=13            ! quick fix to get maximum inside 1st triangle
        else if (icrysym.eq.2) then
          mtop=7*mgrid/12+2
          mbot=6*mgrid/12+1
        else if (icrysym.eq.3) then
          mtop=8*mgrid/12+2
          mbot=6*mgrid/12+1
        else if (icrysym.eq.4) then
          mtop=5*mgrid/8+2
          mbot=4*mgrid/8+1
        else if (icrysym.eq.5) then
          mtop=3*mgrid/4+2
          mbot=2*mgrid/4+1
        else if (icrysym.eq.6) then
          mtop=4*mgrid/4+2
          mbot=2*mgrid/4+1
        else if (icrysym.eq.7) then
          mtop=  mgrid+2
          mbot=  1
        endif
      endif

c *** generates the segments defining the iso-level lines and, optionally,
c     crosses at the points where the intensity is below the first level.
c *** writes coordinates of crosses in FILEID_XX.dat.
c *** writes coordinates of maximum in FILEID_MX.dat.
c *** writes coordinates of level lines in FILEID_nn.dat (1 file per level).
c *** writes coordinates of crosses, maximum and level lines (all) in POLE8.OUT

      call isolev (ntop,mbot,mtop,default,xori,yori,rad,radx,icrysym)

c ***************************************************************************
c     END OF BLOCK FOR PROCESSING INTENSITY LINES

      endif      ! end of if(irepr.eq.0)
c ***************************************************************************

  250 continue
  290 continue
  300 continue

c *** writes settings in a 'profile' file POLE8.PRO to use for repeat runs.

      close(unit=uw1)
      open(ur3,file='POLE8.PRO',status='unknown')

c *** general parameters associated with dot and line representation'
      write(ur3,*)        ' ifull iproj irepr  isym'
      write(ur3,'(10i6)')   ifull,iproj,irepr,isym
      write(ur3,*)        ' iper1 iper2 iper3'
      write(ur3,'(10i6)')   iper(1),iper(2),iper(3)
c *** parameters associated with grid (line representation)
      write(ur3,*)             ' igrid mgrid ngrid'
      write(ur3,'(3i6)')         igrid,mgrid,ngrid
c *** parameters associated with PF massaging (line representation)
      write(ur3,*)             ' ishft ismth  pfrot'
      write(ur3,'(2i6,f8.2)')    ishft,ismth,pfrot*180./pi
c *** intensity line related parameters set inside ISOLEV
      write(ur3,*)         ' icros idraw isepa iwrite spread    step'
      write(ur3,'(4i6,2f8.2)') icros,idraw,isepa,iwrite,spread,step
      write(ur3,*)        ' nlevels'
      write(ur3,'(i6)')     nlevels
      write(ur3,*)        ' rlevel(l)'
      write(ur3,'(8f9.2)') (rlevel(l),l=1,nlevels)

      close(unit=ur3)

      stop
      end
c
c ***************************************************************************
c     subroutine circles   --->   version 19/feb/05
c
c *** If IOPTION=1 generates the points of the circular sections that define
c *** the pole figure or the inverse pole figure assuming unit radious. It
c *** also defines coordinates of labels to be attached to the PF or IPF.

c *** If IOPTION=2, for each PF or IPF shifts coordinates by (xori,yori),
c *** scales by RAD, and writes them into 'FILEID_CC.DAT' & 'FILEID_LB.DAT'.
c ***************************************************************************

      subroutine circles (xori,yori,rad,radx,icrysym,ioption)

      include 'POLE8.DIM'

      dimension xc(1000),yc(1000)
      dimension label(6),xl(10),yl(10)
      save      np,nlabels,label,xl,yl,xc,yc

c ********************************************************************
      if(ioption.eq.1) then

      dang =pi/180.
      nlabels=3

c *** for a direct pole figure defines quarter, half or full circle
c *** depending on the symmetrization

      if(ipfig.le.0) then

        xl(1)=1.00
        yl(1)=0.05
        label(1)=iper(1)
        xl(2)=0.00
        yl(2)=1.05
        label(2)=iper(2)
        xl(3)=0.5
        yl(3)=1.1

        if(isym.le.0 .or. ifull.eq.0) then
          npoints=360.
          ang0=0.
        else if(isym.eq.1 .or. isym.eq.2) then
          npoints=180.
          ang0=-pi/2.
        else if(isym.eq.3) then
          npoints=180.
          ang0=0.
        else if(isym.eq.4) then
          npoints= 90.
          ang0=0.
        endif
        xc(1)=0.0
        yc(1)=1.04
        xc(2)=0.0
        yc(2)=0.0
        xc(3)=1.04
        yc(3)=0.0
        xc(4)=0.0
        yc(4)=0.0
        np=5
        do n=0,npoints
          ang= n*dang + ang0
          xc(np)=cos(ang)
          yc(np)=sin(ang)
          np=np+1
        enddo
        xc(np)=0.0
        yc(np)=0.0
      endif

c *** for an inverse pole figure defines circular section depending on
c *** the crystal symmetry

      if(ipfig.gt.0 .and . icrysym.ne.1) then
        if(icrysym.eq.2) npoints= 30
        if(icrysym.eq.3) npoints= 60
        if(icrysym.eq.4) npoints= 45
        if(icrysym.eq.5) npoints= 90
        if(icrysym.eq.6) npoints=180
        if(icrysym.eq.7) npoints=360
        ang=npoints/180.*pi
        xl(1)=1.05
        yl(1)=0.05
        label(1)=1120
        xl(2)=1.05*cos(ang)
        yl(2)=     sin(ang)
        label(2)=1010
        xl(3)=0.5
        yl(3)=1.1

        xc(1)=0.0
        yc(1)=0.0
        np=2
        do n=0,npoints
          ang= n*dang
          xc(np)=cos(ang)
          yc(np)=sin(ang)
          np=np+1
        enddo
        xc(np)=0.0
        yc(np)=0.0
      endif

c *********************************************************
      if(ipfig.gt.0 .and. icrysym.eq.1) then

        xl(1)=1.05
        yl(1)=0.05
        label(1)=110
        xl(2)=0.9
        yl(2)=0.9
        label(2)=111
        xl(3)=0.5
        yl(3)=1.1

c *** defines projection of [101] circle (1st stereogr triangle) for
c *** IPF of cubic materials

        npoints=45
        xc(1)=0.0
        yc(1)=0.0
        np=2
        delta=1./sqrt(3.)/npoints
        do n=0,npoints
          yaux=n*delta
          xaux=sqrt((1.-yaux**2)/2.)
          zaux=xaux
          t1=sqrt(1.-zaux)/sqrt(xaux**2+yaux**2)
          if(iproj.eq.0) then
            xc(np)=xaux*t1
            yc(np)=yaux*t1
          else if (iproj.eq.1) then
            t2=t1/sqrt(1.+zaux)
            xc(np)=xaux*t2
            yc(np)=yaux*t2
          endif
          np=np+1
        enddo
        xc(np)=0.0
        yc(np)=0.0

c *** defines projection of [011] circle (2nd stereographic triangle) for
c *** IPF of cubic materials
c
c       np=np+1
c       delta=(1.-1./sqrt(3.))/npoints
c       do n=0,npoints
c         xaux=n*delta + 1./sqrt(3.) - 1.e-6
c         yaux=sqrt((1.-xaux**2)/2.)
c         zaux=yaux
c         t1=sqrt(1.-zaux)/sqrt(xaux**2+yaux**2)
c         if(iproj.eq.0) then
c           xc(np)=xaux*t1
c           yc(np)=yaux*t1
c         else if (iproj.eq.1) then
c           t2=t1/sqrt(1.+zaux)
c           xc(np)=xaux*t2
c           yc(np)=yaux*t2
c         endif
c         np=np+1
c       enddo
c       xc(np)=0.0
c       yc(np)=0.0
c
c *** defines projection of [001] circle (3rd stereographic triangle) for
c *** IPF of cubic materials
c
c       np=np+1
c       dang=pi/180.
c       do n=0,npoints
c         ang= n*dang
c         xc(np)=cos(ang)
c         yc(np)=sin(ang)
c         np=np+1
c       enddo
c       xc(np)=0.0
c       yc(np)=0.0

      endif
c **************************************************************
      endif      ! end of ioption=1


c ********************************************************************
      if(ioption.eq.2) then
        write(uw1,'(i5,''   points in the circular section'')') np
        write(uw1,'(8f10.4)') (xc(i)*radx+xori,i=1,np)
        write(uw1,'(8f10.4)') (yc(i)*radx+yori,i=1,np)
        write(11,'(2f10.4)')   (xc(i)*radx+xori,yc(i)*radx+yori,i=1,np)
        write(11,'(2a10)')     dash,dash

        nind=3
        if(icrysym.eq.2 .or. icrysym.eq.3) nind=4
        do i=1,nlabels
          ichar=(i-(i/3)*3)
          if(ichar.ne.0) write(14,'(2f10.4,4x,i2)')
     #                         xl(i)*rad+xori,yl(i)*rad+yori,label(i)
          if(ichar.eq.0) write(14,'(2f10.4,4x,4i1)')
     #           xl(i)*rad+xori,yl(i)*rad+yori,(abs(isn(j)),j=1,nind)
        enddo
      endif
c ********************************************************************

      return
      end
C
C ***********************************************************************
C    SUBROUTINE CONCATENATE      VERSION 08/dec/03
C
C    BASED ON SUBROUTINE 'LINPLUS5' WHICH WAS AN IMPROVED VERSION OF
C    SUBROUTINE 'LINFULL' BY R. LEBENSOHN.
C
C    CONSTRUCTS INTENSITY LINES OUT OF THE SEGMENTS GENERATED BY POLE8.FOR
C
C    *  GIVEN AN INTENSITY LINE DEFINED BY A CHAIN OF CONCATENATED SEGMENTS,
C       BOTH EXTREMES OF THE CHAIN ARE LEFT OPEN AND SEGMENTS
C       ARE ATTACHED TO 'TOP' OR 'BOTTOM' END UNTIL THERE IS NO MATCH.
C    *  CREATES ONE OUTPUT FILE 'fileid_nn.DAT' FOR EACH INTENSITY LEVEL.
C       THIS FILE CONTAINS ALL LINES OF A GIVEN INTENSITY 'nn', SEPARATED
C       BY BLANK LINES. THIS FACILITATES PLOTTING WITH 'ORIGIN' OR 'GNUPLOT'.
C    *  POLE8 HANDLES FULL, HALF AND QUARTER CIRCLE POLE FIGURES.
C       CREATES A FILE 'fileid_CC.DAT' WITH THE POINTS OF THE FULL,
C       HALF OR QUARTER CIRCLE TO BE DRAWN.
C    *  POLE8 CREATES A FILE 'fileid_XX.DAT' WITH THE COORDINATES OF THE
C       POINTS WHERE THE INTENSITY IS BELOW THE LOWEST LEVEL LINE.
C    *  POLE8 CREATES A FILE 'fileid_MX.DAT' WITH THE COORDINATES OF THE
C       POINT WHERE THE INTENSITY IS MAXIMUM.
C
C    OUTPUT:
C           fileid_CC.DAT  --> CARTESIAN POINTS OF CIRCLE
C           fileid_XX.DAT  --> COORDINATES OF CROSSES FOR INTENSITY < minline
C           fileid_MX.DAT  --> COORDINATES OF MAXIMUM INTENSITY POINT
C           fileid_nn.DAT  --> ONE FILE FOR EACH INTENSITY LINE
C ************************************************************************

      SUBROUTINE CONCATENATE (xori,yori,rad,nseg,levbot,levtop)

      include 'POLE8.DIM'

      DIMENSION XL(-NSMAX:NSMAX),YL(-NSMAX:NSMAX)

      CHARACTER NFILE*12

      PI=PI
      ERR =0.00005

      SEGMAX=0.D0
      NSEGSHORT=0
      DO I=1,NSEG
        SEGLENGTH=DSQRT( (XI(I)-XF(I))**2+(YI(I)-YF(I))**2 )
        IF(SEGLENGTH.LT.ERR/2.) THEN
          NSEGSHORT=NSEGSHORT+1
          IF(SEGLENGTH.GT.SEGMAX) SEGMAX=SEGLENGTH
          SEGLEVEL(I)=999
        ENDIF
      ENDDO

C     IF(NSEGSHORT.NE.0) THEN
C       WRITE(*,'(I5,''  SEGMENTS SHORTER THAN'',F10.6)') NSEGSHORT,
C    #            ERR/2.
C       WRITE(*,'('' THE LONGEST IS '',F10.6)') SEGMAX
C       WRITE(*,'('' ALL WILL BE ELIMINATED '')')
C     ENDIF

C *** FINDS MAXIMUM INTENSITY LEVEL AND SHIFTS THE COMMA TO DEFINE
C *** 'LEVELID' USING THE FIRST THREE SIGNIFICANT DIGITS.
C *** ALGORITHM VALID FOR   10**(-5) < RLEVMAX < 10**(+4)

      RLEVELMAX=0.D0
      DO I=LEVBOT,LEVTOP
        IF(RLEVEL(I).GT.RLEVELMAX) RLEVELMAX=RLEVEL(I)
      ENDDO

      RLEVELMAX=99.  ! hard wired for plotting multiple poles not exceeding 99.

      DO I=-4,4
        IF(RLEVELMAX .LT. 10**I) THEN
          COEF= 10**(3-I)
          GO TO 10
        ENDIF
      ENDDO
   10 CONTINUE

C *** OPENS A FILE FOR EACH LEVEL. THE RENORMALIZED INTENSITY OF THE LEVEL
C *** (FIRST THREE NON-ZERO DIGITS) APPEARS IN THE NAME OF THE FILE.

      WRITE(*,'(''   ORDER   LEVEL LEVELID  RLEVEL(I)'')')
      DO I=LEVBOT,LEVTOP
        LEVELID=(RLEVEL(I)*COEF)
        WRITE(*,'(3I8,F10.3)') I,LEVEL(I),LEVELID,RLEVEL(I)

        NDIG1=(LEVELID/100)*100
        NDIG2= LEVELID-NDIG1
        NDIG2=(NDIG2/10)*10
        NDIG3= LEVELID-NDIG1-NDIG2
        NDIG1= NDIG1/100
        NDIG2= NDIG2/10
        NDIG3= NDIG3/1

        NFILE= OUTFILEID
     #         //CHAR(48+NDIG1)//CHAR(48+NDIG2)//CHAR(48+NDIG3)//'.DAT'
        NUNIT= 20+LEVEL(I)
        OPEN(NUNIT,FILE=NFILE,STATUS='NEW')

C       WRITE(*,'(I4,2X,A)') NUNIT,NFILE
C       WRITE(NUNIT,'(2A10)') '     X    ',
C    #        'LVL'//CHAR(48+NDIG1)//CHAR(48+NDIG2)//CHAR(48+NDIG3)
      ENDDO

C *** CONSTRUCTS EACH LINE BY PICKING A SEGMENT AND CHECKING THE OTHERS
C *** UNTIL IT FINDS THOSE THAT FIT EACH EXTREME. REDEFINES THE EXTREMES
C *** AND REPEATS THE PROCESS UNTIL THERE IS NO MATCH.
C *** THE LEVEL OF THE SEGMENTS THAT ARE USED IS REDEFINED SEGLEVEL(I)=999
C *** IN ORDER TO SKIP THEM IN THE NEXT ITERATIONS.

      DO 20 I=1,NSEG

C     PICKS THE FIRST UNUTILIZED SEGMENT AND STARTS A NEW CHAIN

      IF(SEGLEVEL(I).NE.999) THEN
        KBOT=0
        KTOP=1
        LEVELI=SEGLEVEL(I)
        XBOT=XI(I)
        YBOT=YI(I)
        XTOP=XF(I)
        YTOP=YF(I)
        XL(KBOT)=XBOT
        YL(KBOT)=YBOT
        XL(KTOP)=XTOP
        YL(KTOP)=YTOP
        SEGLEVEL(I)=999
      ELSE
        GO TO 20
      ENDIF

C     ATTACHES THE SEGMENTS AT BOTH ENDS OF THE CHAIN.
C     SKIPS A SEGMENT IF IT HAS BEEN USED ALREADY OR IF IT REPRESENTS
C     A DIFFERENT LEVEL.

100   DO 40 J=1,NSEG
      IF(SEGLEVEL(J).NE.LEVELI) GO TO 40
      IF(DABS(XI(J)-XTOP).LT.ERR .AND. DABS(YI(J)-YTOP).LT.ERR) THEN
        KTOP=KTOP+1
        XTOP=XF(J)
        YTOP=YF(J)
        XL(KTOP)=XTOP
        YL(KTOP)=YTOP
        SEGLEVEL(J)=999
        GO TO 100
      ELSEIF(DABS(XF(J)-XTOP).LT.ERR .AND. DABS(YF(J)-YTOP).LT.ERR) THEN
        KTOP=KTOP+1
        XTOP=XI(J)
        YTOP=YI(J)
        XL(KTOP)=XTOP
        YL(KTOP)=YTOP
        SEGLEVEL(J)=999
        GO TO 100
      ELSEIF(DABS(XI(J)-XBOT).LT.ERR .AND. DABS(YI(J)-YBOT).LT.ERR) THEN
        KBOT=KBOT-1
        XBOT=XF(J)
        YBOT=YF(J)
        XL(KBOT)=XBOT
        YL(KBOT)=YBOT
        SEGLEVEL(J)=999
        GO TO 100
      ELSEIF(DABS(XF(J)-XBOT).LT.ERR .AND. DABS(YF(J)-YBOT).LT.ERR) THEN
        KBOT=KBOT-1
        XBOT=XI(J)
        YBOT=YI(J)
        XL(KBOT)=XBOT
        YL(KBOT)=YBOT
        SEGLEVEL(J)=999
        GO TO 100
      ENDIF

   40 CONTINUE

C *** ADDS THE CHAIN OF ORDERED SEGMENTS TO THE FILE ASSOCIATED WITH
C *** LEVELI AND PUTS DASHES AT THE END TO SEPARATE THEM FROM THE ONES
C *** BELONGING TO A DIFFERENT ISOCLINE OF THE SAME VALUE.

      NUNIT=20+LEVELI
      WRITE(NUNIT,'(2F10.5)')
     #             (xl(j)*rad+xori,yl(j)*rad+yori,j=kbot,ktop)
      WRITE(NUNIT,'(2A10)') DASH,DASH

C *** WRITES THE CHAIN OF ORDERED SEGMENTS INTO 'POLE8.OUT'.

      NPOINTS=KTOP+1+ABS(KBOT)
      WRITE(uw1,'(2I10)') LEVELI,NPOINTS
      WRITE(uw1,'(8F10.4)') (xl(j)*rad+xori,j=kbot,ktop)
      WRITE(uw1,'(8F10.4)') (yl(j)*rad+yori,j=kbot,ktop)

   20 CONTINUE

      WRITE(uw1,'(''    999    999'')')     ! used to terminate data reading

      RETURN
      END
c
c ***********************************************************************
c     subroutine crystal_symmetry   --->   version 03/SEP/06
c
c *** If IOPTION=1:
c     Reads crystal symmetry 'icrysym' and unit cell parameters.
c     Generates vectors 'cvec(i,n)' of the unit cell.
c     Generates symmetry operators 'h(i,j,nsymop)' for cubic, hexagonal,
c     trigonal, orthorhombic or monoclinic crystals.
c *** If IOPTION=2:
c     Reads Miller indices of systems in 3 or 4-index notation 'isn(i)'
c     & 'isb(i)'. Calculates normal & burgers vectors 'sn(i)' & 'sb(i)'
c *** If IOPTION=3:
c     Reads Miller indices of diffraction planes 'isn(i)' and spherical
c     angles 'chi , eta'of diffraction direction.
c     Generates crystallographically equivalent orientations sneq(i,n) of
c     a sn(i) by applying all the symmetry operations to it.
c     Discards multiplicity and defines 'npol'
c *** Simmetry parameter ICRYSYM:
c        1: CUBIC
c        2: HEXAGONAL
c        3: TRIGONAL
c        4: TETRAGONAL
c        5: ORTHORHOMBIC
c        6: MONOCLINIC
c        7: TRICLINIC
c ***********************************************************************

      subroutine crystal_symmetry (ioption,ur1,icrysym,isn,sn,sneq,npol)

      dimension h(3,3,24),hx(3,3,6),itag(24)
      dimension isn(4),isnx(3),sn(3),sneq(3,24)
c     dimension isb(4),sb(3)
      dimension cdim(3),cang(3),cvec(3,3)
      integer ur1
      character crysym*5
      save h,nsymop,cvec
      data pi /3.1415926535898/

c ****************************************************************************

      if(ioption.eq.1) then

        read(ur1,*)
        read(ur1,'(a)') crysym
        icrysym=0
        if(crysym.eq.'cubic' .or. crysym.eq.'CUBIC') icrysym=1
        if(crysym.eq.'hexag' .or. crysym.eq.'HEXAG') icrysym=2
        if(crysym.eq.'trigo' .or. crysym.eq.'TRIGO') icrysym=3
        if(crysym.eq.'tetra' .or. crysym.eq.'TETRA') icrysym=4
        if(crysym.eq.'ortho' .or. crysym.eq.'ORTHO') icrysym=5
        if(crysym.eq.'monoc' .or. crysym.eq.'MONOC') icrysym=6
        if(crysym.eq.'tricl' .or. crysym.eq.'TRICL') icrysym=7
        if(icrysym.eq.0) then
          write(*,*) ' *** CANNOT RECOGNIZE THE CRYSTAL SYMMETRY'
          stop
        endif

        READ(UR1,*) (CDIM(i),i=1,3),(CANG(i),i=1,3)
        DO I=1,3
          CANG(I)=CANG(I)*PI/180.
        ENDDO
        CVEC(1,1)=1.
        CVEC(2,1)=0.
        CVEC(3,1)=0.
        CVEC(1,2)=COS(CANG(3))
        CVEC(2,2)=SIN(CANG(3))
        CVEC(3,2)=0.
        CVEC(1,3)=COS(CANG(2))
        CVEC(2,3)=(COS(CANG(1))-COS(CANG(2))*COS(CANG(3)))/SIN(CANG(3))
        CVEC(3,3)=SQRT(1.-CVEC(1,3)**2-CVEC(2,3)**2)
        DO J=1,3
        DO I=1,3
          CVEC(I,J)=CDIM(J)*CVEC(I,J)
        ENDDO
        ENDDO

c       write(*,'('' CVEC'',3f10.3)') ((CVEC(I,J),I=1,3),J=1,3)
c       pause 'inside crystal_symmetry'

        DO I=1,3
        DO J=1,3
          DO M=1,6
            HX(I,J,M)=0.d0
          ENDDO
          DO N=1,24
            H(I,J,N)=0.d0
          ENDDO
        ENDDO
        ENDDO

c *** identity operation ---> triclinic & all symmetries
      do i=1,3
        h(i,i,1)=1.d0
      enddo
      nsymop=1

c *** 180 deg rotation around (001) ---> orthorhombic, monoclinic
      if(icrysym.eq.5 .or. icrysym.eq.6) then
        h(1,1,2)= cos(pi)
        h(2,2,2)= cos(pi)
        h(3,3,2)= 1.d0
        h(1,2,2)=-sin(pi)
        h(2,1,2)= sin(pi)
        nsymop=2
      endif

c *** x-mirror & y-mirror ---> orthorhombic
      if(icrysym.eq.5) then
        h(1,1,3)=-1.d0
        h(2,2,3)= 1.d0
        h(3,3,3)= 1.d0

        h(1,1,4)= 1.d0
        h(2,2,4)=-1.d0
        h(3,3,4)= 1.d0
        nsymop=4
      endif

c *** cubic symmetry
      if(icrysym.eq.1) then

c *** rotations of (pi/3) & (2*pi/3) around <111>
        hx(1,3,1)= 1.d0
        hx(2,1,1)= 1.d0
        hx(3,2,1)= 1.d0

        hx(1,2,2)= 1.d0
        hx(2,3,2)= 1.d0
        hx(3,1,2)= 1.d0

        do m=1,2
          do n=1,nsymop
            mn=m*nsymop+n
            do i=1,3
            do j=1,3
            do k=1,3
              h(i,j,mn)=h(i,j,mn)+hx(i,k,m)*h(k,j,n)
            enddo
            enddo
            enddo
          enddo
        enddo
        nsymop=mn

c *** mirror across the plane (110)
        hx(1,2,3)= 1.d0
        hx(2,1,3)= 1.d0
        hx(3,3,3)= 1.d0

        do n=1,nsymop
          mn=nsymop+n
            do i=1,3
            do j=1,3
            do k=1,3
              h(i,j,mn)=h(i,j,mn)+hx(i,k,3)*h(k,j,n)
            enddo
            enddo
            enddo
        enddo
        nsymop=mn

c *** rotations of 90, 180, 270 around x3

        do m=1,3
          ang=pi/2.*float(m)
          hx(1,1,m)= cos(ang)
          hx(2,2,m)= cos(ang)
          hx(3,3,m)= 1.0
          hx(1,2,m)=-sin(ang)
          hx(2,1,m)= sin(ang)
          hx(1,3,m)= 0.0
          hx(3,1,m)= 0.0
          hx(2,3,m)= 0.0
          hx(3,2,m)= 0.0
        enddo

        do m=1,3
          do n=1,nsymop
            mn=m*nsymop+n
              do i=1,3
              do j=1,3
              do k=1,3
                h(i,j,mn)=h(i,j,mn)+hx(i,k,m)*h(k,j,n)
              enddo
              enddo
              enddo
          enddo
        enddo
        nsymop=mn

      endif                    !end of condition for icrysym=1

c *** hexagonal, trigonal and tetragonal symmetry

      if(icrysym.ge.2 .and. icrysym.le.4) then
        if(icrysym.eq.2) nrot=6
        if(icrysym.eq.3) nrot=3
        if(icrysym.eq.4) nrot=4

c *** mirror plane at 30 deg or 60 deg or 45 deg with respect to x1
        ang=pi/float(nrot)
        h(1,1,2)= cos(ang)**2-sin(ang)**2
        h(2,2,2)=-h(1,1,2)
        h(3,3,2)= 1.d0
        h(1,2,2)= 2.*cos(ang)*sin(ang)
        h(2,1,2)= h(1,2,2)
        nsymop=2

c *** rotations of 2*pi/6 around axis <001> for hexagonals.
c *** rotations of 2*pi/3 around axis <001> for trigonals.
c *** rotations of 2*pi/8 around axis <001> for trigonals.
        do nr=1,nrot-1
          ang=nr*2.*pi/nrot
          hx(1,1,nr)= cos(ang)
          hx(2,2,nr)= cos(ang)
          hx(3,3,nr)= 1.d0
          hx(1,2,nr)=-sin(ang)
          hx(2,1,nr)= sin(ang)
        enddo

        do m=1,nrot-1
          do n=1,nsymop
            mn=m*nsymop+n
            do i=1,3
            do j=1,3
            do k=1,3
              h(i,j,mn)=h(i,j,mn)+hx(i,k,m)*h(k,j,n)
            enddo
            enddo
            enddo
          enddo
        enddo
        nsymop=mn

      endif               !end of condition for icrysym= 2,3,4

c     write(10,*)
c     write(10,'(''  # of symmetry operations='',i4)') nsymop
c     write(10,'(''  symmetry matrices'')')
c     write(10,'(i3,9f7.3)') (n,((h(i,j,n),j=1,3),i=1,3),n=1,nsymop)

      endif               !end of condition for ioption=1

c **************************************************************************
c   Reads Miller-Bravais indices for cubic (1), tetragonal (4), ortho-
c   rhombic (5), monoclinic (6) & triclinic (7) systems in 3-index notation.
c   For hexagonal (2) & trigonal (3) systems reads 4-index notation.
c   Converts indices of plane normal and slip direction into normalized
c   vectors sn(i) and sb(i), respectively.
c **************************************************************************

      if (ioption.eq.2) then

        nind=3
        do i=1,nind
          isnx(i)=isn(i)
        enddo
        if(icrysym.eq.2 .or. icrysym.eq.3) then
          nind=4
          isnx(3)=isn(4)
        endif

c *** this block specific for EPSC3
c       if (ioption.eq.2) then
c         read(ur1,*) (isn(i),i=1,nind),(isb(i),i=1,nind)
c       else if (ioption.eq.3) then
c         read(ur1,*) (isn(i),i=1,nind),chi,eta
c         eta=eta*pi/180.
c         chi=chi*pi/180.
c         sb(1)=cos(eta)*sin(chi)
c         sb(2)=sin(eta)*sin(chi)
c         sb(3)=         cos(chi)
c       endif

        sn(1)= isnx(1)/cvec(1,1)
        sn(2)=(isnx(2)-cvec(1,2)*sn(1))/cvec(2,2)
        sn(3)=(isnx(3)-cvec(1,3)*sn(1)-cvec(2,3)*sn(2))/cvec(3,3)
        snnor=sqrt(sn(1)**2+sn(2)**2+sn(3)**2)
        do j=1,3
          sn(j)=sn(j)/snnor
          if(abs(sn(j)).lt.1.e-03) sn(j)=0.
        enddo

c *** this block specific for EPSC3

c         IF (ICRYSYM.EQ.2 .OR. ICRYSYM.EQ.3) THEN
c           ISB(1)=ISB(1)-ISB(3)
c           ISB(2)=ISB(2)-ISB(3)
c           ISB(3)=ISB(4)
c         ENDIF
c         do i=1,3
c           sb(i)=isb(1)*cvec(i,1)+isb(2)*cvec(i,2)+isb(3)*cvec(i,3)
c         enddo
c         sbnor=sqrt(sb(1)**2+sb(2)**2+sb(3)**2)
c         do j=1,3
c           sb(j)=sb(j)/sbnor
c           if(abs(sb(j)).lt.1.e-03) sb(j)=0.
c         enddo
c
c         prod=sn(1)*sb(1)+sn(2)*sb(2)+sn(3)*sb(3)
c         IF(PROD.GE.1.E-3) THEN
c           WRITE(*,'('' SYSTEM IS NOT ORTHOGONAL !!'')')
c           WRITE(*,'('' ISN='',3I7)') (ISN(J),J=1,3)
c           WRITE(*,'('' ISB='',3I7)') (ISB(J),J=1,3)
c           WRITE(*,'(''   N='',3F7.3)') (SN(J),J=1,3)
c           WRITE(*,'(''   B='',3F7.3)') (SB(J),J=1,3)
c           STOP
c         ENDIF

      endif      ! end of if(ioption.eq.2)

c **************************************************************************
c *** generates all symmetry related vectors sneq(i,n) with z>0.
c *** eliminates redundant poles: coincidents and opposites
c **************************************************************************

      if(ioption.eq.2. or. ioption.eq.3) then

        do n=1,nsymop
          itag(n)=0
          do i=1,3
          sneq(i,n)=0.d0
            do j=1,3
              sneq(i,n)=sneq(i,n)+h(i,j,n)*sn(j)
            enddo
          enddo
        enddo

        if(ioption.eq.2) then
        if(icrysym.ne.7) then      ! nsymop=1 for trigonal
          do m=1,nsymop-1
            if(itag(m).eq.0) then
              do n=m+1,nsymop
                sndif=abs(sneq(1,m)-sneq(1,n))+abs(sneq(2,m)-sneq(2,n))
     #               +abs(sneq(3,m)-sneq(3,n))
                if(sndif .le. 0.0001) itag(n)=1
                sndif=abs(sneq(1,m)+sneq(1,n))+abs(sneq(2,m)+sneq(2,n))
     #               +abs(sneq(3,m)+sneq(3,n))
                if(sndif .le. 0.0001) itag(n)=1
              enddo
            endif
          enddo
        endif
        endif

        npol=0
        do n=1,nsymop
          if(itag(n).eq.0) then
            npol=npol+1
            isign=1
            if(sneq(3,n).lt.0.) isign=-1
            sneq(1,npol)=isign*sneq(1,n)
            sneq(2,npol)=isign*sneq(2,n)
            sneq(3,npol)=isign*sneq(3,n)
          endif
        enddo

      endif            !end of if(ioption=3)
c **************************************************************************

      return
      end
c
c *************************************************************************
      subroutine euler(iopt,ph,th,om,a)

      implicit real*8 (a-h,o-z)
      dimension a(3,3)
      data pi /3.1415926535898/
c
c     CALCULATE THE EULER ANGLES ASSOCIATED WITH THE TRANSFORMATION
c     MATRIX A(I,J) IF IOPT=1 AND VICEVERSA IF IOPT=2
c     A(i,j) TRANSFORMS FROM SYSTEM sa TO SYSTEM ca.
c     ph,th,om ARE THE EULER ANGLES OF ca REFERRED TO sa.
c
      if(iopt.eq.1) then
        th=dacos(a(3,3))
        if(dabs(a(3,3)).ge.0.9999) then
          om=0.d0
          ph=datan2(a(1,2),a(1,1))
        else
          sth=dsin(th)
          om =datan2(a(1,3)/sth,a(2,3)/sth)
          ph =datan2(a(3,1)/sth,-a(3,2)/sth)
        endif
        th=th*180.d0/pi
        ph=ph*180.d0/pi
        om=om*180.d0/pi
      else if(iopt.eq.2) then
        sph=dsin(ph*pi/180.d0)
        cph=dcos(ph*pi/180.d0)
        sth=dsin(th*pi/180.d0)
        cth=dcos(th*pi/180.d0)
        som=dsin(om*pi/180.d0)
        com=dcos(om*pi/180.d0)
        a(1,1)= com*cph-sph*som*cth
        a(2,1)=-som*cph-sph*com*cth
        a(3,1)= sph*sth
        a(1,2)= com*sph+cph*som*cth
        a(2,2)=-sph*som+cph*com*cth
        a(3,2)=-sth*cph
        a(1,3)= sth*som
        a(2,3)= com*sth
        a(3,3)= cth
      endif

      return
      end
c
c ************************************************************************
c
c     subroutine isolev      --->      version 08/dec/03
c
c *** calculates contour lines (f=integer*step) of a positive function
c *** f(i,j) defined at the coordinate points x(j) , y(i) of a
c *** rectangular grid with 1<i<ngrid and mbot<j<mtop.
c *** the points along the rim of the rectangular grid serve as boundary
c *** condition, and level lines extend half-way between these points and
c *** the ones of the closest inner ring.
c ************************************************************************

      subroutine isolev (ngrid,mbot,mtop,default,xori,yori,rad,radx,
     #                   icrysym)

      include 'POLE8.DIM'

      dimension xx(3),yy(3),ff(3),is(2),js(2),v12(3),v13(3)
      integer*2 default

      dimension id(9),jd(9),kc(9)
      data id/-1,-1,0,1,1,1,0,-1,-1/,jd/0,-1,-1,-1,0,1,1,1,0/
      data kc/1,2,3,2,3,1,3,1,2/


c *** looks for maximum & minimum value of f assuming that the rim
c *** elements of the grid are used as boundary conditions for interpolating.
c *** only at the north pole accounts explicitly for the boundary.
c *** prompts to enter the incremental step for the intensity lines.

      fmax=f(1,2)
      fmin=f(1,2)
      do i=1,ngrid-1
      do j=mbot+1,mtop-1
        if(fmax.le.f(i,j)) then      ! .LE. required when fmax=f(1,2)
          fmax=f(i,j)
          xmax=x(j)
          ymax=y(i)
          ifmax=i
          jfmax=j
        endif
        if(fmin.ge.f(i,j)) then      ! .GE. required when fmin=f(1,2)
          fmin=f(i,j)
        endif
      enddo
      enddo

      if(ifmax.eq.1) write(*,'('' MAXIMUM COINCIDES WITH NORTH POLE'')')
c
c *** the following procedure detects whether the maximum falls on the
c *** lines that define the grid instead of on the center of an element.

      if(ifmax.ne.1) then
        toler=1.d-3*dabs(fmax)
        if (dabs(f(ifmax-1,jfmax)-f(ifmax,jfmax)).le.toler) then
          ymax=0.5d0*(y(ifmax-1)+y(ifmax))
        elseif(dabs(f(ifmax+1,jfmax)-f(ifmax,jfmax)).le.toler) then
          ymax=0.5d0*(y(ifmax+1)+y(ifmax))
        endif
        if (dabs(f(ifmax,jfmax-1)-f(ifmax,jfmax)).le.toler) then
          xmax=0.5d0*(x(jfmax-1)+x(jfmax))
        elseif(dabs(f(ifmax,jfmax+1)-f(ifmax,jfmax)).le.toler) then
          xmax=0.5d0*(x(jfmax+1)+x(jfmax))
        endif
      endif

      phimax=xmax*180./pi
      themax=acos(ymax)*180./pi
      write(*,*)
      write(*,'('' fmax='',f7.2,''   at phi='',f7.2,''  theta='',f7.2)')
     #             fmax,phimax,themax

c *** gives the option of using linear or exponential scale, and
c     defines the values of the levels

      if(default.ge.0) then
        if(default.eq.0) then
          step=0.5
        else if(default.eq.1) then
          print *
          print *, 'enter 0 for power of 2 spaced lines '
          print *, 'enter 1 for equally spaced lines ---> '
          read(*,*) isepa
          print *
          print *, 'enter contour lines STEP as a positive number'
          if(isepa.eq.0) print *, ' level(l)= 2**(STEP*(l-2))  ---> '
          if(isepa.eq.1) print *, ' level(l)= l*STEP           ---> '
          read(*,*) step
        endif

        nlevels=nlmax
        do l=1,nlevels
          level (l)= l
          if(isepa.eq.0) rlevel(l)= 2.**(step*(l-2))
          if(isepa.eq.1) rlevel(l)= l*step
        enddo
      endif

      if(default.eq.1) then
        write(*,*)
        write(*,*) ' the following levels (up to fmax) will be plot'
        write(*,'(8f7.2)') (rlevel(l),l=1,nlevels)

        write(*,*)
        write(*,*) ' enter 1 if you want to eliminate some'
        write(*,*) ' enter 0 if you want to draw all them ---> '
        read (*,*)   idraw

        if(idraw.eq.1) then
          write(*,*) ' insert a 0 below the levels to eliminate'
          write(*,*) ' insert a 1 below the levels to keep'
          do line=1,nlevels,8
            write(*,'(8f7.2)') (rlevel(l),l=line,line+7)
            write(*,*)
            read(*,*)           (level(l),l=line,line+7)
          enddo
          nlevels=0
          do l=1,nlmax
            if(level(l).eq.1) then
              nlevels=nlevels+1
              rlevel(nlevels)=rlevel(l)
              level (nlevels)=nlevels
            endif
          enddo
        endif

        write(*,*)
        write(*,*) ' enter 0 for not labeling level values in plot'
        write(*,*) ' enter 1 for labeling levels (messier plot) ---> '
        read(*,*) iwrite

        write(*,*) 'enter 0 to plot crosses below lower line'
        write(*,*) 'enter 1 for not plotting crosses            ---> '
        read(*,*) icros
      endif

c *** increases slightly the values of f that coincide with contour
c     lines in order to avoid interpolation complications

      tiny=1.e-04
      do i=1,ngrid
        do j=mbot,mtop
          do l=1,nlevels
            toler=f(i,j)-rlevel(l)
            if(toler.gt.0. .and. toler.lt.tiny) f(i,j)=f(i,j)+tiny
            if(toler.lt.0. .and.-toler.lt.tiny) f(i,j)=f(i,j)-tiny
          enddo
        enddo
      enddo

      levbot= 0
      levtop= 0
      do l=1,nlevels
        if(rlevel(l).le.fmax) levtop=levtop+1
        if(rlevel(l).ge.fmin .and. levbot.eq.0) levbot=l
      enddo

      if(levtop.eq.nlmax) then
        write(*,*)
        write(*,'(''**** NUMBER OF LEVELS   nlevels='',i3,
     #            ''  MAY NOT BE SUFFICIENT'')') nlevels
        write(*,'('' --> INCREASE PARAMETER nlmax IN POLE8.DIM OR ''
     #                   ,''INCREASE LEVEL SEPARATION step     '')')
        pause
      endif

**************************************************************************

c *** calculates the coordinates of the level lines associated with f(i,j).
c *** will plot crosses for f(i,j) < firstlevel

      nil=0
      nsegms=0
      do 110 i=2,ngrid-1
      do 110 j=mbot+1,mtop-1
        ff(1)=f(i,j)
        xx(1)=x(j)
        yy(1)=y(i)

      if(ff(1).lt.rlevel(levbot)) then
        nil=nil+1
        xnil(nil)=xx(1)
        ynil(nil)=yy(1)
      endif

c *** averages the coordinates and the function for the intermediate ***
c *** point between the center of element (i,j) and each one of the  ***
c *** 4 diagonal neighbouring elements                               ***
      do 105 l=2,8,2
      il=i+id(l)
      jl=j+jd(l)
      is(1)=i+id(l-1)
      js(1)=j+jd(l-1)
      is(2)=i+id(l+1)
      js(2)=j+jd(l+1)
      ff(2)=(f(i,j)+f(il,jl)+f(is(1),js(1))+f(is(2),js(2)))/4.
      xx(2)=(x(j)+x(jl)+x(js(1))+x(js(2)))/4.
      yy(2)=(y(i)+y(il)+y(is(1))+y(is(2)))/4.
      if(i.gt.2) go to 27
      if(l.ne.2.and.l.ne.8) go to 27
      ff(2)=f(1,j)
      yy(2)=y(1)
   27 continue

c      if(ff(2).lt.rlevel(levbot)) then
c        nil=nil+1
c        xnil(nil)=xx(2)
c        ynil(nil)=yy(2)
c      endif
c
c *** averages the coordinates and the function for the vertices of ****
c *** the triangles that lie at each side of the diagonal           ****
      do 100 ls=1,2
      ff(3)=(f(i,j)+f(is(ls),js(ls)))/2.
      xx(3)=(x(j)+x(js(ls)))/2.
      yy(3)=(y(i)+y(is(ls)))/2.
      if(i.gt.2) go to 37
      if(l.ne.2.and.l.ne.8) go to 37
      if(js(ls).ne.j) go to 37
      ff(3)=f(1,j)
      yy(3)=y(1)
   37 continue

c      if(ff(3).lt.rlevel(levbot)) then
c        nil=nil+1
c        xnil(nil)=xx(3)
c        ynil(nil)=yy(3)
c      endif

c *** evaluates contour lines between each pair of sides defining the **
c *** triangle. Pairs are taken cyclically using the array kc(k).     **
      do k=1,3
        f1 =ff(kc(k))
        x1 =xx(kc(k))
        y1 =yy(kc(k))
        f2 =ff(kc(k+3))
        x2 =xx(kc(k+3))
        y2 =yy(kc(k+3))
        f3 =ff(kc(k+6))
        x3 =xx(kc(k+6))
        y3 =yy(kc(k+6))
        iskip=1
        if(f1.lt.f2 .and. f1.lt.f3) then
          ftop=min(f2,f3)
          fbot=f1
          iskip=0
        else if(f1.gt.f2 .and. f1.gt.f3) then
          ftop=f1
          fbot=max(f2,f3)
          iskip=0
        endif
        if(iskip.eq.0) then
          isoc=1
          do while(isoc.le.nlevels .and. rlevel(isoc).le.ftop)
            if(rlevel(isoc).ge.fbot) then
              fk=rlevel(isoc)
              call linint(x1,y1,f1,x2,y2,f2,x12,y12,fk)
              call linint(x1,y1,f1,x3,y3,f3,x13,y13,fk)
              nsegms=nsegms+1
              xi(nsegms)=x12
              yi(nsegms)=y12
              xf(nsegms)=x13
              yf(nsegms)=y13
              seglevel(nsegms)=level(isoc)
            endif
            isoc=isoc+1
          enddo
          if(nsegms.gt.nsmax) then
            write(*,*) '*** DIMENSION nsmax EXCEEDED'
            write(*,*) '*** INCREASE  nsmax TO  ',nsegms,' IN POLE8.DIM'
            stop
          endif
        endif
      enddo      ! end of do k=1,3
  100 continue
  105 continue
  110 continue

c **************************************************************************
c *** For cubic inverse pole figures keeps only the segments and crosses
c *** within the first stereographic triangle.
c *** Segments that cross the stereographic circle are interpolated.
c *** Scales the first stereogr. triangle to a unit radious for cubic ipf's.

      if(icrysym.eq.1 .and. ipfig.gt.0) then
        if(nil.ne.0 .and. icros.eq.0) then
          nilx=0
          do i=1,nil
            thx=acos(ynil(i))
            pro=(-cos(xnil(i))*sin(thx)+cos(thx))/sqrt(2.)
            if(pro.ge.0) then
              nilx=nilx+1
              xnil(nilx)=xnil(i)
              ynil(nilx)=ynil(i)
            endif
          enddo
          nil=nilx
        endif

        nsegmx=0
        do i=1,nsegms
          x12=xi(i)
          y12=yi(i)
          x13=xf(i)
          y13=yf(i)

          th12=acos(y12)
          th13=acos(y13)
          v12(1)=cos(x12)*sin(th12)
          v12(2)=sin(x12)*sin(th12)
          v12(3)=         cos(th12)
          pro12 =sqrt(0.5)*(-v12(1)+v12(3))
          v13(1)=cos(x13)*sin(th13)
          v13(2)=sin(x13)*sin(th13)
          v13(3)=         cos(th13)
          pro13 =sqrt(0.5)*(-v13(1)+v13(3))

          if(pro12.ge.0 .or. pro13.ge.0) then
            if(pro12.ge.0 .and. pro13.le.0) then
              finter=abs(pro12)/(abs(pro12)+abs(pro13))
              do n=1,3
                v13(n)=v12(n)+(v13(n)-v12(n))*finter
              enddo
              x13=atan2(v13(2),v13(1))
              y13=v13(3)
            endif
            if(pro12.le.0 .and. pro13.ge.0) then
              finter=abs(pro13)/(abs(pro12)+abs(pro13))
              do n=1,3
                v12(n)=v13(n)+(v12(n)-v13(n))*finter
              enddo
              x12=atan2(v12(2),v12(1))
              y12=v12(3)
            endif
            nsegmx=nsegmx+1
            xi(nsegmx)=x12
            yi(nsegmx)=y12
            xf(nsegmx)=x13
            yf(nsegmx)=y13
            seglevel(nsegmx)=seglevel(i)
          endif
        enddo
        nsegms=nsegmx
      endif

c **************************************************************************
c *** projects coordinates of segments & crosses (phi,cos(theta)) as (x,y)

      call project(xmax,ymax,1.d0,iproj)
      do i=1,nsegms
        call project(xi(i),yi(i),1.d0,iproj)
        call project(xf(i),yf(i),1.d0,iproj)
      enddo
      if(nil.ne.0 .and. icros.eq.0) then
        do i=1,nil
          call project(xnil(i),ynil(i),1.d0,iproj)
        enddo
      endif

c *** writes coordinates (x,y) of crosses in POLE8.OUT and NFILE_XX.DAT
      write(uw1,'(2i5,''   crosses'')') icros,nil
      if(nil.ne.0 .and. icros.eq.0) then
        write(uw1,'(8f10.4)') (xnil(i)*radx+xori,i=1,nil)
        write(uw1,'(8f10.4)') (ynil(i)*radx+yori,i=1,nil)

        write(12,'(2f10.4)') (xnil(i)*radx+xori,ynil(i)*radx+yori,
     #                       i=1,nil)
        write(12,'(2a10)')    dash,dash
      endif

c *** writes maximum in POLE8.OUT
      write(uw1,'('' max='',f6.2)') fmax  !read as character inside PLOTPF8
      write(uw1,*) '  xmax   ymax'
      write(uw1,'(2f7.3)') xmax*rad+xori,ymax*rad+yori  !read as real ins PLOTPF8

c *** writes maximum and its position in NFILE_MX.DAT
      write(13,'(3f7.3)') xmax*rad+xori,ymax*rad+yori,fmax

c *** writes values of levels kept in POLE8.OUT
      write(uw1,'(i3,''  iwrite'')') iwrite
      write(uw1,'(i3,''  levels'')') levtop-levbot+1
      do l=levbot,levtop
        write(uw1,'(i3,f8.2)') level(l),rlevel(l)
      enddo

c *** concatenates the segments that belong to each of the level lines.
c *** writes the coordinates of the lines in 'POLE8.OUT'
c *** writes FILEID_nn.DAT with the coordinates of each intensity level.

      call concatenate (xori,yori,radx,nsegms,levbot,levtop)

      return
      end
c
c **************************************************************************
c
      subroutine linint(x1,y1,f1,x2,y2,f2,x,y,f)
c *** interpolates linearly between f1 & f2 for a given value f

      implicit real*8 (a-h,o-z)

      x=(x2-x1)*(f-f1)/(f2-f1)+x1
      y=(y2-y1)*(f-f1)/(f2-f1)+y1
      return
      end

c ***************************************************************************
      subroutine project (x,y,rad,iproj)

      implicit real*8 (a-h,o-z)

c *** gives cartesian coordinates of the projection of a point defined
c *** by the polar coordinates x=phi,y=cos(theta).
c *** iproj=0 stands for equal area and iproj=1 for stereographic proj.

      t1=    sqrt(abs(1.-y))
      t2= t1/sqrt(abs(1.+y))
      cx= cos(x)
      sx= sin(x)
      if (iproj.eq.0) then
        x  = cx*t1*rad
        y  = sx*t1*rad
      else if (iproj.eq.1) then
        x  = cx*t2*rad
        y  = sx*t2*rad
      endif

      return
      end
c
c *******************************************************************
      subroutine special_cases(np2,mbot,mtop,textfile)

      include 'POLE8.DIM'

      character*80 prosa,textfile

      prosa=prosa
c *******************************************************************
c *** if ipfig=-1 reads a table with grid coordinates (phi,cos(th)) defining
c *** the direct. of elastic wave propagation, and the associated wave speed.
c
      if(ipfig .eq. -1) then
        write(uw1,*) '  2  lines in POLE8.OUT is text'
        write(uw1,'(a)') textfile
        write(uw1,*) '  this is a wave speed pole figure file'
c
        read(1,*) idum
        do i=1,idum
          read(1,'(a80)') prosa
        enddo
        read(1,*)  mp2,np2
        read(1,*) (y(i),i=1,np2)
        read(1,*) (x(j),(f(i,j),i=1,np2),j=1,mp2)
c *** normalization to 1000 gives problem when opening plotting files
        do i=1,np2
          do j=1,mp2
            f(i,j)=f(i,j)*0.999
          enddo
        enddo

        mgrid=mp2-2
        ngrid=np2-2
        isym =0
        ipfig=0
      endif
c
c *************************************************************************
c *** if ipfig=-2 reads a table of pole intensities defined every 5 degrees
c *** in phi (0-355) and theta (0-90).
c *** defines extra 'outer' values for boundary conditions.
c
      if(ipfig .eq. -2) then
        ipopla=1
        write(uw1,*) '  2  lines in POLE8.OUT is text'
        write(uw1,'(a)') textfile
        if(ipopla.eq.1) write(uw1,*) '  this is a popLA *.epf file'
        if(ipopla.eq.0) write(uw1,*) '  this is a CRL.pf file'
c
        idum=3
        do i=1,idum
          read(1,'(a80)') prosa
        enddo
        if(ipopla.eq.1) then
          deltang =pi/180.d0*5.d0
          angshift=0.d0
          mgrid=72
          ngrid=18
        else
          deltang =pi/180.d0*5.d0
          angshift=pi/180.d0*2.5d0
          mgrid=18
          ngrid=18
        endif
        mp1=mgrid+1
        np1=ngrid+1
        mp2=mgrid+2
        np2=ngrid+2

        if(ipopla.eq.0) read(1,*)             ((f(i,j),j=2,mp1),i=1,np1)
        if(ipopla.eq.1) read(1,'(1x,18f4.0)') ((f(i,j),j=2,mp1),i=1,np1)

        y(1)=1.d0
        do i=2,np2
          y(i)=dcos(-angshift+(i-1)*deltang)
        enddo
        if(ipopla.eq.1) then
          y(np1)=dcos(pi/180.d0*89.d0)
          y(np2)=dcos(pi/180.d0*91.d0)
        endif
        do j=1,mp2
          x(j)=(j-1)*deltang-angshift
          f(np2,j)=f(np1,j)
        enddo
        if(ipopla.eq.0) then
          do i=1,np2
            f(i,1)  =f(i,2)
            f(i,mp2)=f(i,mp1)
          enddo
        else
          do i=1,np2
            f(i,1)  =f(i,mp1)
            f(i,mp2)=f(i,2)
            do j=1,mp2
              f(i,j)=f(i,j)/100.d0
            enddo
          enddo
        endif

        mtop=mp2
        mbot=1
        isym=0
        iper(1)=1
        iper(2)=2
        iper(3)=3
      endif
c
c *************************************************************************
c *** if ipfig=-3 reads a table of strains defined every 15 degrees
c *** in phi (0-90) and theta (0-90).
c *** defines extra 'outer' values for boundary conditions.
c
      if(ipfig .eq. -3) then
        mgrid=7
        ngrid=7
        deltang=pi/180.d0*15.d0
        mp1=mgrid+1
        np1=ngrid+1
        mp2=mgrid+2
        np2=ngrid+2

        read(1,'(a80)') prosa
        read(1,*) (xdum,(f(i,j),i=2,np1),j=2,mp1)
        xdum=xdum
c *** rescale strains, search for minimum and shift to positive values
        fmin=f(2,2)*1.d+4
        do i=2,np1
        do j=2,mp1
          f(i,j)=f(i,j)*1.d+4
          if(f(i,j).lt.fmin) fmin=f(i,j)
        enddo
        enddo

        write(uw1,*) '  4  lines in POLE8.OUT is text'
        write(uw1,'(a)') textfile
        write(uw1,*) '  this is an EPSC (ijk) strains file'
        write(uw1,'(''  the minimum strain is'',f10.2,'' E-04'')') fmin
        write(uw1,'(''  lines are shifted up by 10.E-04'')')

        if(fmin.lt.0.d0) then
          do i=2,np1
          do j=2,mp1
c            f(i,j)=f(i,j)+dabs(fmin)
            f(i,j)=f(i,j)+10.d0
          enddo
          enddo
        endif

        do i=2,np1
          y(i)=dcos((i-2)*deltang)
        enddo
        y(1)  =1.d0
        y(2)  =dcos(pi/180.d0* 1.d0)
        y(np1)=dcos(pi/180.d0*89.d0)
        y(np2)=dcos(pi/180.d0*91.d0)
        do j=2,mp1
          x(j)=(j-2)*deltang
          f(1,j)  =f(2,j)
          f(np2,j)=f(np1,j)
        enddo
        x(1)=pi/180.d0*(-1.)
        x(2)=pi/180.d0*( 1.)
        x(mp1)=pi/180.d0*(89.)
        x(mp2)=pi/180.d0*(91.)
        do i=1,np2
          f(i,1)  =f(i,2)
          f(i,mp2)=f(i,mp1)
        enddo

        isym=4
        ifull=1
        mtop=mp2
        mbot=1
        iper(1)=2
        iper(2)=1
        iper(3)=3
      endif

      return
      end
c
c ***************************************************************************

      subroutine spread_poles (ioption,spred,nps,x1,y1)

      include 'POLE8.DIM'

      dimension h(3,3)

c **************************************************************************
c *** generates a set of nps unitary vectors spread around (0,0,1) and
c *** gives a weight frac(i) to each one.
c *** Both the vectors vs(i) and their relative weights (frac) depend on the
c *** model proposed for doing the spread and can be modified by the user.

      IF(IOPTION.EQ.1) THEN
      npart=4
      dalf=spred/npart
      nps=1
      vs(1,1)=0.0
      vs(2,1)=0.0
      vs(3,1)=1.0
      frac(1)=1./npart
      tfrac=frac(1)
      do n=2,npart+1
        alf=dalf*(n-1.0)
        mpart=5*n
        do m=1,mpart
          nps=nps+1
          bet=2.*pi*(m-0.5)/mpart
          vs(1,nps)=sin(alf)*cos(bet)
          vs(2,nps)=sin(alf)*sin(bet)
          vs(3,nps)=cos(alf)
          frac(nps)=1./(mpart*npart)
          tfrac=tfrac+frac(nps)
        enddo
      enddo
      do n=1,nps
        frac(n)=frac(n)/tfrac
      enddo
ccc      print *, 'vs(i,n) and frac(n) for nps = ',nps
ccc      print * , 'tfrac = ',tfrac
ccc      write(*,'(3f10.4,5x,f10.4)') ((vs(i,n),i=1,3),frac(n),n=1,nps)
ccc      write(*,'(10f8.4)') (frac(n),n=1,nps)

      ELSE IF (IOPTION.EQ.2) THEN

c *** calculates coordinates of spread vectors vs in sample axes.
c *** calculates their polar coordinates xps=phi and yps=cos(theta).
      ct=y1
      st=sqrt(1.-ct*ct)
      cp=cos(x1)
      sp=sin(x1)

      h(1,1)=cp*ct
      h(1,2)=-sp
      h(1,3)=cp*st
      h(2,1)=sp*ct
      h(2,2)=cp
      h(2,3)=sp*st
      h(3,1)=-st
      h(3,2)=0.
      h(3,3)=ct

      do n=1,nps
        v1=h(1,1)*vs(1,n)+h(1,2)*vs(2,n)+h(1,3)*vs(3,n)
        v2=h(2,1)*vs(1,n)+h(2,2)*vs(2,n)+h(2,3)*vs(3,n)
        v3=h(3,1)*vs(1,n)+h(3,2)*vs(2,n)+h(3,3)*vs(3,n)
        seca=v1*v1+v2*v2
        if(seca.lt.1.e-06) then
          xps(n)=0.0
        else
          xps(n)=atan2(v2,v1)
        endif
        yps(n)=v3
      enddo

      ENDIF

      return
      end
C
C++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C     SUBROUTINE TEXTURE  --->  VERSION OF 26/aug/05
C
C *** READS EULER ANGLES OF CRYSTAL WITH RESPECT TO SAMPLE AXES.
C *** OPTIONAL: MAKES STATISTICS TO REDEFINE THE TOTAL NUMBER OF GRAINS
C *** AND RENORMALIZES WEIGHTS.
C+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      SUBROUTINE TEXTURE (NGRAIN)

      include 'POLE8.DIM'

      DIMENSION PFRAC(10),NFRAC(10),AUX(3,3)
      CHARACTER NOMEN*1,PROSA*80

      IPRINT=0

      PROSA=PROSA      ! TO FOOL THE COMPILER
      PI=PI            ! TO FOOL THE COMPILER

      READ(ur2,*) NOMEN,NGRAIN
      IF(NGRAIN.GT.NGMAX) THEN
        WRITE(*,*)
        WRITE(*,'('' WARNING !! THERE ARE'',I8,'' ORIENTATIONS IN'',
     #            '' TEXTURE FILE'')') NGRAIN
        WRITE(*,'('' THE MAXIMUM DIMENSION NGMAX IS'',I8)') NGMAX
        WRITE(*,'('' ---> INCREASE PARAMETER NGMAX IN POLE8.DIM'')')
        STOP
      ENDIF
      IF(NOMEN.EQ.'B' .OR. NOMEN.EQ.'b')      THEN
        WRITE(*,11)
      ELSE IF(NOMEN.EQ.'K' .OR. NOMEN.EQ.'k') THEN
        WRITE(*,12)
      ELSE IF(NOMEN.EQ.'R' .OR. NOMEN.EQ.'r') THEN
        WRITE(*,13)
      ELSE
        WRITE(*,14)
        STOP
      ENDIF

   11 FORMAT(/,' READS EULER ANGLES IN BUNGE CONVENTION ACCORDING',
     #         ' TO THE SEQUENCE (phi1,PHI,phi2)')
   12 FORMAT(/,' READS EULER ANGLES IN KOCKS CONVENTION ACCORDING',
     #         ' TO THE SEQUENCE (PSI,THETA,phi)')
   13 FORMAT(/,' READS EULER ANGLES IN ROE CONVENTION ACCORDING',
     #         ' TO THE SEQUENCE (PSI,THETA,phi)')
   14 FORMAT(/,' STOPS EXECUTION BECAUSE EULER ANGLE CONVENTION DOES',
     #         ' NOT AGREE WITH ANY OF THE STANDARD ONES')

      DO N=1,NGRAIN
        READ(ur2,*) ANG1,ANG2,ANG3,WGT(N)
        IF(NOMEN.EQ.'B' .OR. NOMEN.EQ.'b') THEN
          PHI(N)= ANG1
          THE(N)= ANG2
          OME(N)= ANG3
        ELSE IF(NOMEN.EQ.'K' .OR. NOMEN.EQ.'k') THEN
          PHI(N)= ANG1-90.D0
          THE(N)=-ANG2
          OME(N)=-ANG3-90.D0
        ELSE IF(NOMEN.EQ.'R' .OR. NOMEN.EQ.'r') THEN
          PHI(N)= ANG1+90.D0
          THE(N)= ANG2
          OME(N)= ANG3-90.D0
        ENDIF
      ENDDO

      WRITE(*,*) 'TOTAL NUMBER OF ORIENTATIONS READ IS ',NGRAIN
      WGTMAX=0.D0
      TOTWGT=0.D0
      DO N=1,NGRAIN
        IF(WGT(N).GT.WGTMAX) WGTMAX=WGT(N)
        TOTWGT=TOTWGT+WGT(N)
      ENDDO
      WGTMAX=1.0001*WGTMAX/TOTWGT

c     write(*,'('' --> total volume fraction = '',F10.6)') TOTWGT
c     pause

      DO N=1,10
        NFRAC(N)=0
        PFRAC(N)=0.D0
      ENDDO
      DO N=1,NGRAIN
        WGT(N)=WGT(N)/TOTWGT
        ISLOT=10.*WGT(N)/WGTMAX + 1
        NFRAC(ISLOT)=NFRAC(ISLOT)+1
        PFRAC(ISLOT)=PFRAC(ISLOT)+WGT(N)
      ENDDO

      NACUM=0
      WACUM=0.D0
      DO N=1,10
        NACUM=NACUM+NFRAC(N)
        WACUM=WACUM+PFRAC(N)*100.D0
        SLOT =WGTMAX/10.D0*N
        IF(IPRINT.EQ.1) WRITE(*,'('' WEIGHTS UP TO'',F8.5,
     #   '' ACCOUNT FOR'',I5,'' GRAINS AND'',F7.2,
     #   '' % OF THE TOTAL VOLUME'')') SLOT,NACUM,WACUM
      ENDDO

C *** CALCULATES ROTATION MATRICES FOR EACH GRAIN.
C *** R(I,J,NGR) TRANSFORMS FROM SPECIMEN TO CRYSTAL AXES.
C *** THE ROWS OF 'R' ARE THE COORDINATES OF CRYSTAL AXES IN SAMPLE AXES.

      K=0
      TOTWGT=0.D0
      WGTMIN=0.
      DO KX=1,NGRAIN
        IF(WGT(KX).GE.WGTMIN) THEN
          K=K+1
          PHI(K)=PHI(KX)
          THE(K)=THE(KX)
          OME(K)=OME(KX)
          WGT(K)=WGT(KX)
          TOTWGT=TOTWGT+WGT(K)
          CALL EULER(2,PHI(K),THE(K),OME(K),AUX)
          DO I=1,3
          DO J=1,3
            R(I,J,K)=AUX(I,J)
          ENDDO
          ENDDO
        ENDIF
      ENDDO

      NGRAIN=K
      DO N=1,NGRAIN
        WGT(N)=WGT(N)/TOTWGT
      ENDDO

      RETURN
      END
