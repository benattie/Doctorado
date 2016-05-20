program pp

character                          :: conv
character(LEN = 2)                 :: num
character(LEN = 5)                 :: name
character(LEN = 255), dimension(3) :: prosa
real(8), dimension(5000,4)         :: ang

open(unit=1,file='UVFC.TEX',status='old')
read(1,'(a)') prosa(1)
read(1,'(a)') prosa(2)
read(1,'(a)') prosa(3)
read(1,*) conv, ngr
do igr=1,ngr
  read(1,*) ang(igr,:)
enddo
close(1)

do i=1,73
  write(*,*) i
  write(num,'(i2)') i
  open(unit=1,file='grain.tex',status='unknown')
  write(1,'(a)') prosa(1)
  write(1,'(a)') prosa(2)
  write(1,'(a)') prosa(3)
  write(1,'(a2,i7)') conv,6
  do j=1,6
    write(1,'(3f10.3,3x,f10.6)') ang((j-1)*73+i,:)
  enddo
  close(1)

  open(unit=1,file='com.txt',status='unknown')
  write(1,'(a5)') 'grn'//num
  write(1,'(i5)') -1
  close(1)

  call system("pole8 < com.txt")
enddo

end


