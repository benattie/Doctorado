program ajuste

!use Math, ONLY : Lu_system

integer :: coefRmaxI, coefRmaxJ
real(8), dimension(19,72,5) :: Val
real(8), dimension(19,72)   :: ro,d,Ch00opt,Chklopt,qopt,BETAopt
real(8), dimension(19,72)   :: coefR,coefRmax
real(8)                     :: lambda
real(8)                     :: theta111,theta200,theta220,theta311,theta222
real(8)                     :: h111,h200,h220,h311
real(8)                     :: N,Sx,Sy,Sxx,Syy,Sxy
real(8)                     :: m,h,R
real(8)                     :: maxmin
real(8)                     :: romin,dmin,coefRmin,qoptmin,Ch00optmin,Chkloptmin
real(8)                     :: f111,f200,f220,f311,b111,b200,b220,b311
real(8)                     :: Ch00,Chkl,q,BETA,W111,W200,W220,W311

character(LEN=78), dimension(2,5) :: prosa

lambda = 0.014267d0

theta111 = 3.9204d0*3.141592/360.0
theta200 = 4.5273d0*3.141592/360.0
theta220 = 6.4004d0*3.141592/360.0
theta311 = 7.5069d0*3.141592/360.0
theta222 = 7.8481d0*3.141592/360.0

h111 = 0.33333d0
h200 = 0.00000d0
h220 = 0.25000d0
h311 = 0.15702d0
h222 = 0.33333d0

open(unit=1,file='A70PBnati.tpf',status='old')


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
read(1,*)

read(1,'(a)') prosa(1,5)
read(1,'(a)') prosa(2,5)
do i=1,19
  read(1,*) Val(i,1 :18,5)
  read(1,*) Val(i,19:36,5)
  read(1,*) Val(i,37:54,5)
  read(1,*) Val(i,55:72,5)
enddo
close(1)

val = val*0.0001d0*3.141592/180.0

coefRmax = -1.d0

N = 5.d0

Ch00 = 0.2d0

!BETA = 0.001d0

W111 = 0.433d0
W200 = 1.d0
W220 = 0.7071d0
W311 = 0.4523d0
W222 = 0.433d0

!IB : do
!write(*,*) BETA
!IC : do 
  
  q = 1.5d0
 
  IQ: do
	f111 = 1.0**2 * 0.06472 * Ch00*(1.d0-q*H111) * 3.141592 * 2 * (dsin(theta111)**2) / lambda**2
    f200 = 1.0**2 * 0.06472 * Ch00*(1.d0-q*H200) * 3.141592 * 2 * (dsin(theta200)**2) / lambda**2
    f220 = 1.0**2 * 0.06472 * Ch00*(1.d0-q*H220) * 3.141592 * 2 * (dsin(theta220)**2) / lambda**2
    f311 = 1.0**2 * 0.06472 * Ch00*(1.d0-q*H311) * 3.141592 * 2 * (dsin(theta311)**2) / lambda**2
	f222 = 1.0**2 * 0.06472 * Ch00*(1.d0-q*H222) * 3.141592 * 2 * (dsin(theta222)**2) / lambda**2
		
     do i=1,19
      do j=1,72

!		b111 = (val(i,j,1)*dcos(theta111)/lambda)-W111*BETA
!		b200 = (val(i,j,2)*dcos(theta200)/lambda)-W200*BETA
!		b220 = (val(i,j,3)*dcos(theta220)/lambda)-W220*BETA
!		b311 = (val(i,j,4)*dcos(theta311)/lambda)-W311*BETA

		b111 = (val(i,j,1)*dcos(theta111)/lambda)
		b200 = (val(i,j,2)*dcos(theta200)/lambda)
		b220 = (val(i,j,3)*dcos(theta220)/lambda)
		b311 = (val(i,j,4)*dcos(theta311)/lambda)
		b222 = (val(i,j,5)*dcos(theta222)/lambda)


        Sx  = f111 + f200 + f220 + f311 + f222

	    Sy  = b111 + b200 + b220 + b311 + b222

        Sxx = f111**2 + f200**2 + f220**2 + f311**2 + f222**2

        Syy = b111**2 + b200**2 + b220**2 + b311**2 + b222**2

        Sxy = f111*b111 + f200*b200 + f220*b220 + f311*b311 + f222*b222

        m = (N*Sxy - Sx*Sy)/(N*Sxx - Sx*Sx)         ! m / coef1
        h = (Sxx*Sy - Sx*Sxy)/(N*Sxx - Sx*Sx)       ! h / coef2
        R = (N*Sxy - Sx*Sy)/dsqrt(N*Sxx - Sx*Sx)/dsqrt(N*Syy - Sy*Sy) ! coefR
		
  		if(R > coefRmax(i,j)) then
	      if (h > 0) then
		  coefRmax(i,j) = R
    	  ro(i,j) = m
	      d(i,j)  = h
	      qopt(i,j) = q
		  Ch00opt(i,j) = 0.3*(q - 1.5)/1.5 + 0.2
!		  BETAopt = BETA
!			write(*,*) BETA,q
		  endif
		endif
		
		R=0
		
      enddo
	enddo
 
	
    q = q + 0.01d0
	if(q > 3.d0) exit
  enddo IQ
	
!   BETA=BETA + 0.0001d0
!   if(BETA > 0.02d0) exit

!enddo IB
!  Ch00 = Ch00 + 0.02d0
!    if(Ch00 > 0.5d0) exit
!enddo IC

open(unit=11,file='A70PB_ro.rpf',status='unknown')
open(unit=12,file='A70PB_d.rpf',status='unknown')
open(unit=13,file='A70PB_R.rpf',status='unknown')
open(unit=14,file='A70PB_Ch00.rpf',status='unknown')
open(unit=15,file='A70PB_q.rpf',status='unknown')
!open(unit=20,file='A70PB_BETA.rpf',status='unknown')

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
!d = 1.d0/d
d = 0.9d0/d

maxmin = maxval(d)
write(*,*) maxmin
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

 write(*,*) d(1,1),maxmin

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
maxmin = maxval(Ch00opt)
maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

write(14,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
write(14,'(a)') prosa(2,1)

do i=1,19
  write(14,'(3(1x,18(i4)/),1x,18(i4))') int(Ch00opt(i,:)/maxmin*9999)
enddo


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



! BETA ----------------------------------------------------------

!maxmin = maxval(BETAopt)
!maxmin = 10**float(int(dlog(maxmin)/dlog(10.d0)+1.d0))

!write(20,'(a50," 9999=",e12.4)') prosa(1,1),maxmin
!write(20,'(a)') prosa(2,1)

!do i=1,19
!  write(20,'(3(1x,18(i4)/),1x,18(i4))') int(BETAopt(i,:)/maxmin*9999)
!enddo



close(11)
close(12)
close(13)
close(15)
!close(20)

end


