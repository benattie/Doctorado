program ajuste

!use Math, ONLY : Lu_system

real(8), dimension(19,72,4) :: Val
real(8), dimension(19,72)   :: ro,d,Ch00opt,Chklopt,qopt
real(8), dimension(19,72)   :: coefR,coefRmax
real(8)                     :: lambda
real(8)                     :: theta111,theta200,theta220,theta311
real(8)                     :: C111,C200,C220,C311
real(8)                     :: h111,h200,h220,h311
real(8)                     :: N,Sx,Sy,Sxx,Syy,Sxy
real(8)                     :: m,h
real(8)                     :: maxmin
real(8)                     :: romin,dmin,coefRmin,qoptmin,Ch00optmin,Chkloptmin
real(8)                     :: f111,f200,f220,f311
real(8)                     :: Ch00,Chkl,q

character(LEN=78), dimension(2,4) :: prosa


lambda = 0.014267d0

theta111 = 3.922d0*3.141592/180.0
theta200 = 4.540d0*3.141592/180.0
theta220 = 6.408d0*3.141592/180.0
theta311 = 7.514d0*3.141592/180.0

C111 = 0.1d0
C200 = 0.3d0
C220 = 0.15d0
C311 = 0.206d0

h111 = 0.33333d0
h200 = 0.00000d0
h220 = 0.25000d0
h311 = 0.15702d0


open(unit=1,file='A70PB.rpf',status='old')

read(1,'(a)') prosa(1,1)
read(1,'(a)') prosa(2,1)
do i=1,19
  read(1,*) Val(i,1 :18,1)
  read(1,*) Val(i,19:36,1)
  read(1,*) Val(i,37:54,1)
  read(1,*) Val(i,55:72,1)
enddo
read(1,*)

read(1,'(a)') prosa(1,2)
read(1,'(a)') prosa(2,2)
do i=1,19
  read(1,*) Val(i,1 :18,2)
  read(1,*) Val(i,19:36,2)
  read(1,*) Val(i,37:54,2)
  read(1,*) Val(i,55:72,2)
enddo
read(1,*)

read(1,'(a)') prosa(1,3)
read(1,'(a)') prosa(2,3)
do i=1,19
  read(1,*) Val(i,1 :18,3)
  read(1,*) Val(i,19:36,3)
  read(1,*) Val(i,37:54,3)
  read(1,*) Val(i,55:72,3)
enddo
read(1,*)

read(1,'(a)') prosa(1,4)
read(1,'(a)') prosa(2,4)
do i=1,19
  read(1,*) Val(i,1 :18,4)
  read(1,*) Val(i,19:36,4)
  read(1,*) Val(i,37:54,4)
  read(1,*) Val(i,55:72,4)
enddo

close(1)

val = val*0.0001d0*3.141592/180.0


coefRmax = -1.d0

N = 4.d0

Ch00 = 0.2d0
IC : do 
  write(*,*) Ch00
  q = 1.5d0
  IQ: do

    f111 = 0.3**2 * 0.06472**2 * Ch00*(1.d0-q*H111) * 3.141592 / 2.d0
    f200 = 0.3**2 * 0.06472**2 * Ch00*(1.d0-q*H200) * 3.141592 / 2.d0
    f220 = 0.3**2 * 0.06472**2 * Ch00*(1.d0-q*H220) * 3.141592 / 2.d0
    f311 = 0.3**2 * 0.06472**2 * Ch00*(1.d0-q*H311) * 3.141592 / 2.d0


    do i=1,19
      do j=1,72

        Sx  = (f111**2*dsin(theta111)**2 + f200**2*dsin(theta200)**2 + &
	           f220**2*dsin(theta220)**2 + f311**2*dsin(theta311)**2)/lambda**2

	    Sy  = (val(i,j,1)*dcos(theta111) + val(i,j,2)*dcos(theta200) + &
	           val(i,j,3)*dcos(theta220) + val(i,j,4)*dcos(theta311))/lambda

        Sxx = (f111**4*dsin(theta111)**4 + f200**4*dsin(theta200)**4 + &
	           f220**4*dsin(theta220)**4 + f311**4*dsin(theta311)**4)/lambda**4

        Syy = (val(i,j,1)*dcos(theta111)*val(i,j,1)*dcos(theta111) + &
	           val(i,j,2)*dcos(theta200)*val(i,j,2)*dcos(theta200) + & 
	           val(i,j,3)*dcos(theta220)*val(i,j,3)*dcos(theta220) + &
		       val(i,j,4)*dcos(theta311)*val(i,j,4)*dcos(theta311))/lambda**2

        Sxy = (f111**2*dsin(theta111)**2*val(i,j,1)*dcos(theta111) + f200**2*dsin(theta200)**2*val(i,j,2)*dcos(theta200)+ & 
	           f220**2*dsin(theta220)**2*val(i,j,3)*dcos(theta220) + f311**2*dsin(theta311)**2*val(i,j,4)*dcos(theta311))/lambda**3

        m = (N*Sxy - Sx*Sy)/(N*Sxx - Sx*Sx)         ! m / coef1
        h = (Sxx*Sy - Sx*Sxy)/(N*Sxx - Sx*Sx)       ! h / coef2

        R = (N*Sxy - Sx*Sy)/dsqrt(N*Sxx - Sx*Sx)/dsqrt(N*Syy - Sy*Sy) ! coefR

        if(R > coefRmax(i,j)) then
	      coefRmax(i,j) = R
    	  ro(i,j) = m
	      d(i,j)  = h
	      Ch00opt(i,j) = Ch00
	      qopt(i,j)    = q
	    endif

      enddo
    enddo
 

    q = q + 0.01d0
	if(q > 3.d0) exit
  enddo IQ

  Ch00 = Ch00 + 0.01
  if(Ch00 > 0.5d0) exit
enddo IC


open(unit=11,file='A70PB_ro.rpf',status='unknown')
open(unit=12,file='A70PB_d.rpf',status='unknown')
open(unit=13,file='A70PB_R.rpf',status='unknown')
!open(unit=14,file='A70PB_Ch00.rpf',status='unknown')
open(unit=15,file='A70PB_q.rpf',status='unknown')
open(unit=16,file='A70PB_Chkl111.rpf',status='unknown')
!open(unit=17,file='A70PB_Chkl200.rpf',status='unknown')
open(unit=18,file='A70PB_Chkl220.rpf',status='unknown')
open(unit=19,file='A70PB_Chkl311.rpf',status='unknown')

! Ro ----------------------------------------------------------
ro = ro*ro
maxmin = maxval(ro)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(11,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(11,'(a)') prosa(2,1)

do i=1,19
  write(11,'(3(1x,18(i4)/),1x,18(i4))') int(ro(i,:)/maxmin*9999)
enddo


! d ----------------------------------------------------------
d = 1.d0/d
where (d < 0.d0)
  d =0.d0
endwhere
maxmin = maxval(d)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(12,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(12,'(a)') prosa(2,1)

do i=1,19
  write(12,'(3(1x,18(i4)/),1x,18(i4))') int(d(i,:)/maxmin*9999)
enddo


! R ----------------------------------------------------------
write(13,'(a50," 9999=",e12.4)') prosa(1,1),1.0
write(13,'(a)') prosa(2,1)

do i=1,19
  write(13,'(3(1x,18(i4)/),1x,18(i4))') int(coefRmax(i,:)*9999)
enddo


! Ch00 ----------------------------------------------------------
!qoptmin = minval(Ch00opt)
!maxmin = maxval(Ch00opt)-Ch00optmin
!maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

!write(14,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
!write(14,'(a)') prosa(2,1)

!do i=1,19
!  write(14,'(3(1x,18(i4)/),1x,18(i4))') abs(int((Ch00opt(i,:)-Ch00optmin)/maxmin*9999))
!enddo


! q ----------------------------------------------------------
where (qopt < 0.d0)
  qopt =0.d0
endwhere
maxmin = maxval(qopt)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(15,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(15,'(a)') prosa(2,1)

do i=1,19
  write(15,'(3(1x,18(i4)/),1x,18(i4))') int(qopt(i,:)/maxmin*9999)
enddo

! Chklopt 111 -----------------------------------------------------
Chklopt = Ch00opt * (1.d0 - qopt*H111)
where (Chklopt < 0.d0)
  Chklopt =0.d0
endwhere
maxmin = maxval(Chklopt)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(16,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(16,'(a)') prosa(2,1)

do i=1,19
  write(16,'(3(1x,18(i4)/),1x,18(i4))') int(Chklopt(i,:)/maxmin*9999)
enddo

! Chklopt 220 -----------------------------------------------------
Chklopt = Ch00opt * (1.d0 - qopt*H220)
where (Chklopt < 0.d0)
  Chklopt =0.d0
endwhere
maxmin = maxval(Chklopt)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(18,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(18,'(a)') prosa(2,1)

do i=1,19
  write(18,'(3(1x,18(i4)/),1x,18(i4))') int(Chklopt(i,:)/maxmin*9999)
enddo

! Chklopt 311 -----------------------------------------------------
Chklopt = Ch00opt * (1.d0 - qopt*H311)
where (Chklopt < 0.d0)
  Chklopt =0.d0
endwhere
maxmin = maxval(Chklopt)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(19,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(19,'(a)') prosa(2,1)

do i=1,19
  write(19,'(3(1x,18(i4)/),1x,18(i4))') int(Chklopt(i,:)/maxmin*9999)
enddo

close(11)
close(12)
close(13)
close(15)
close(16)
close(18)
close(19)

end


