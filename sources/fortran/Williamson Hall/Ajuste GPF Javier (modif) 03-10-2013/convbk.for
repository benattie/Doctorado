        program conv
c     goes from Kocks to Bunge (option 1) or from Bunge to Kocks(option 2)
      character*8 name
      character*20 axes
        open(unit=1,file='tin.wts',status='old')
        open(unit=11,file='tout.wts',status='unknown')
          write(*,*) 'reads Kocks and goes to Bunge (1)'
          write(*,*) 'reads Bunge and goes to Kocks (2)' 
          read(*,*) option
          write(*,*) 'number of grains?'
          read(*,*) ngrain
!           option=1
!           ngrain=2000
           if (option.eq.1) then
        read(1,'(a8)') name
        read(1,'(a20)')  axes
        read(1,*)  
        read(1,*)
        write(11,'(a8)') name
        write(11,'(a20)') axes
        write(11,*)'texture' 
        write(11,'(a2,1x,i6)')'B', ngrain
         do i=1,ngrain
          read(1,*) phk,thetk,omk,wgts
          phb=(phk+90.)
          thetb=thetk
          omb=-(omk-90.)  
          if (phb.lt.-1.*180.) then
              absphb=abs(phb)
              phb=phb+(int(absphb/360.)+1)*360.
          endif
c
          if (thetb.lt.0) then
          absthetb=abs(thetb) 
          thetb=thetb+(int(absthetb/180.)+1)*180.
          endif 
c
          if (omb.lt.0) then
          absomb=abs(omb)
          omb=omb+(int(absomb/360.)+1)*360. 
          endif 
c
          write(11,('(4(2x,f7.3,2x))'))phb,thetb,omb,wgts
        enddo
         else  !if option  equal 2
        read(1,'(a8)') name
        read(1,'(a20)')  axes
        read(1,*)  
        read(1,*)
        write(11,'(a8)') name
        write(11,'(a20)') axes
        write(11,*)'texture' 
        write(11,'(a2,1x,i6)')'K', ngrain

         do i=1,ngrain
          read(1,*) phb,thetb,omb,wgts
          phk=(phb-90.)
          thetk=thetb
          omk=90.-omb  
          if (phk.lt.-90.) then
              absphb=abs(phb)
              phb=phb+(int(absphb/360.)+1)*360.
          endif
c
          if (thetk.lt.0) then
          absthetk=abs(thetk) 
          thetb=thetb+(int(absthetb/180.)+1)*180.
          endif 
c
          if (omk.gt.180.) then
          absomb=abs(omb)
          omb=omb-(int(absomb/180.)+1)*180. 
          endif 
c
          write(11,('(4(2x,f7.3,2x))'))phk,thetk,omk,wgts
        enddo

         endif 
       stop
       end

