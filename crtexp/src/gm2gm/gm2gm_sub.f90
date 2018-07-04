    subroutine xyintpo(flag0,im,jm,flag,nx,my,ain,aout,iwnd,xr,yr,first)
    implicit none
!
!   process the interpolation from gg(or ga, gx) to gg(or ga)
!   gg : the gaussion grid system
!   ga : the equal distant grid system
!   gx : the equal distant grid system, but the first point at half
!        a grid's distance
!
    integer :: i,j,ix,jy,im,jm,nx,my
    real    :: ain(im,jm),aout(nx,my),xr(nx),yr(my)
    character*2 flag0, flag
    integer iwnd
    logical first
!
!  working arrays
!
    real ::  weight0(jm),sinl0(jm),weight(my),sinl(my) &
            ,alat0(jm+2),alon0(im+1),alat(my),alon(nx)
    real :: aaa(im+1,jm+2),bbb(nx*my),wkx(nx*my),wky(nx*my)
    integer jend, mn, nxmy
    real :: pi, xx, yy, ps, pn 
!
    pi= 4.0*atan(1.0)

!-------------------------
    if( first ) then
!
!  gaussian quadrature weights and latitudes
!----
      if( flag0.eq.'gg' .or. flag0.eq.'GG' )then       !--- gg
!
      call gausl3 (jm,-1.,1.,weight0,sinl0)
      do j = 1, jm
       alat0(j+1) = asin(sinl0(j))
      end do
      alat0(1)    = -pi*0.5
      alat0(jm+2) = pi*0.5
      jend = jm+1
!
      elseif( flag0.eq.'ga' .or. flag0.eq.'GA' )then   !--- ga
!
      yy= pi/float(jm-1)
      do j = 1, jm
       alat0(j) = -0.5*pi+(j-1)*yy
      end do
      jend = jm-1
!
!  gx : equal distance, but the first point beginning at half delta
!
      elseif( flag0.eq.'gx' .or. flag0.eq.'GX' )then   !--- gx
      yy= pi/float(jm)
      do j = 1, jm 
       alat0(j+1) = -0.5*pi+0.5*yy+(j-1)*yy
      end do
      alat0(1)    = -pi*0.5
      alat0(jm+2) = pi*0.5
      jend = jm+1
!
      else
!
      print*, flag0,' No such grid system --- error '
      stop
!
      end if
!
      xx= (2.0*pi)/float(im)
      do i = 1, im
       alon0(i) = (i-1)*xx
      end do
      alon0(im+1) = pi*2.0
!----
      if( flag.eq.'gg' .or. flag.eq.'GG' )then
!
      call gausl3 (my,-1.,1.,weight,sinl)
!
      do j = 1, my
       alat(j) = asin(sinl(j))
      end do
!
      elseif( flag.eq.'ga' .or. flag.eq.'GA' )then   !--- else
!
      yy= pi/float(my-1)
      do j = 2, my-1
       alat(j) = -0.5*pi+(j-1)*yy
      end do
       alat(1)  = -0.5*pi+0.0001
       alat(my) =  0.5*pi-0.0001
!
      else
!
      print*, flag,' No such grid system for outfields'
      stop
!
      end if
!
      if( flag0.eq.'gx' .or. flag0.eq.'GX' )then
!
!  shift alon with half grid's distance
!
      xx= (2.0*pi)/float(nx)
      alon(1) = 2.0*pi-0.5*xx
      do i = 2, nx
       alon(i) = 0.5*xx+(i-1)*xx
      end do
!
      else
!
      xx= (2.0*pi)/float(nx)
      do i = 1, nx
       alon(i) = (i-1)*xx
      end do
!
      end if
!----
      do ix = 1, nx
      do i  = 1, im
      if( alon(ix).ge.alon0(i) .and. alon(ix).lt.alon0(i+1) )then
         xr(ix) = float(i) + (alon(ix)-alon0(i))/(alon0(i+1)-alon0(i))
      end if
      end do
      end do
!
      do jy = 1, my
      do j  = 1, jend
      if( alat(jy).ge.alat0(j) .and. alat(jy).lt.alat0(j+1) )then
         yr(jy) = float(j) + (alat(jy)-alat0(j))/(alat0(j+1)-alat0(j))
      end if
      end do
      end do
!
      end if
!------------------
!
!  check if the fields is of wind
!
!----
      if( flag0.eq.'gg' .or. flag0.eq.'GG' .or. flag0.eq.'gx'  &
          .or. flag0.eq.'GX')then
!
      do j = 1, jm
      do i = 1, im
       aaa(i,j+1) = ain(i,j)
      end do
      end do
!
      do j = 2, jm+1
       aaa(im+1,j) = aaa(1,j)
      end do
!
      if( iwnd .eq. 1 ) then
       do i = 1, im+1
        aaa(i,1) = 0.
        aaa(i,jm+2) = 0.
       end do
      else   ! ---- else
       ps= ain(1,1)
       pn= ain(1,jm)
       do i = 2, im
        ps= ps + ain(i,1)
        pn= pn + ain(i,jm)
       end do
        ps = ps/float(im)
        pn = pn/float(im)
       do i = 1, im+1
        aaa(i,1) = ps
        aaa(i,jm+2) = pn
       end do
      end if
!
      else   !--- else
!
      ps = ain(1,1)
      pn = ain(1,jm)
      do j = 1, jm
      do i = 1, im
       aaa(i,j) = ain(i,j)
      end do
      end do
!
      do j = 1, jm
       aaa(im+1,j) = aaa(1,j)
      end do
!
      end if
!----
!
      mn = 0
      do j = 1, my
      do i = 1, nx
       mn = mn+1
       wkx(mn) = xr(i)
       wky(mn) = yr(j)
      end do
      end do
!
      nxmy = nx*my
!
      if( flag0.eq.'gg' .or. flag0.eq.'GG' .or. flag0.eq.'gx'  &
             .or. flag0.eq.'GX' )then
       call bcubij(aaa,im+1,jm+2,bbb,nxmy,wkx,wky)
      else
       call bcubij(aaa,im+1,jm  ,bbb,nxmy,wkx,wky)
      end if
!
      mn = 0
      do j = 1, my
      do i = 1, nx
       mn = mn+1
       aout(i,j) = bbb(mn)
      end do
      end do
!
      if( flag.eq.'ga' .or. flag.eq.'GA' ) then
       if( iwnd .eq. 1 ) then
        do i = 1, nx
         aout(i,1) = 0.
         aout(i,my) = 0.
        end do
       else
        do i = 1, nx
         aout(i,1) = ps
         aout(i,my) = pn
        end do
       end if
      end if
!
      return
      end

      subroutine bcubij(f,ix,jy,dout,mn,xin,yin)
!         
!  parameter list   
!         
!  f,ix,jy,dout,mn,xin,yin - see below  
!               
      real :: f(ix,jy),dout(mn),xin(mn),yin(mn) 
!         
!
!  working array
      real,dimension(ix,jy) ::  fxx,fyy,tp3
      real,dimension(mn,4) ::   pix,pjy,tp1,tp2   
      dimension ipt(mn) 
!         
!          a bicubic spline interpolator to interpolate from a grid   
!          with constant grid spacing to a grid with constant or      
!          variable grid spacing. all grids are assumed to have point 
!          (1,1) in the lower left corner with i increasing to the right        
!          and j increasing upward.     
!         
!          arguments:         
!         
!          f(ix,jy): fwa of data array to be interpolated from (given 
!                    by user) 
!         
!          ix: first (i) dimension of f (given by user)     
!         
!          jy: second (j) dimension of f (given by user)    
!         
!          dout(mn): fwa of array of interpolated values (given on    
!                     output) 
!         
!         
!         mn: number of points (dimension) of output grid   
!         
!          xin(mn): x-coordinates of points in dout relative to the   
!                   x-coordinates of f. a "1" refers to the leftmost  
!                   boundary of f (given by user) 
!         
!          yin(mn): y-coordinates of points in dout relative to the   
!                   y-corrdinates of f. a "1" refers to the bottom    
!                   row of f (given by user)      
!         
!   scratch work arrays
!
!          pix(mn,4): array to hold coefficients for interpolation in 
!                     x-direction     
!         
!          pjy(mn,4): array to hold coefficients for interpolation in 
!                     y-direction 
!         
!          tp1(mn,4): work space        
!         
!          tp2(mn,4): work space        
!         
!          tp3(ix,jy): work space       
!         
!          fxx(ix,jy): array to hold cubic spline values (computed    
!                      internally)      
!         
!          fyy(ix,jy): array to hold cubic spline values (computed    
!                      internally)      
!         
!          ipt(mn): array that holds 2-d coordinate, relative to f grid,
!                   of each point in dout 
!         
!          compute ipt,jpt,pix and pjy  
!         
      call stupij(xin,yin,mn,ix,pix,pjy,ipt)
!         
      ijm2=ix*jy-2  
      ixjym2=ix*(jy-2)
!         
!          interpolate in x-direction   
!         
!          compute fyy        
!         
      do 100 i=1,ixjym2       
      fyy(i,2)=(f(i,1)-2.0*f(i,2)+f(i,3))         
  100 continue      
      call trdih(ix,jy-2,fyy(1,2))     
!         
      do 105 i=1,ix
      fyy(i,1)= 0.0
      fyy(i,jy)= 0.0
  105 continue
!         
!          compute fxxyy      
!         
      do 130 i=1,ijm2         
      fxx(i+1,1)= fyy(i,1)+(fyy(i+2,1)-2.0*fyy(i+1,1))      
  130 continue      
!         
      do 205 j=1,jy 
      fxx(1,j)= fyy(ix,j)-2.0*fyy(1,j)+fyy(2,j)   
      fxx(ix,j)= fyy(ix-1,j)-2.0*fyy(ix,j)+fyy(1,j)         
  205 continue      
!
      call tpose(fxx,ix,jy,tp3)        
      call trdiph(jy,ix,tp3)      
      call tpose(tp3,jy,ix,fxx)        
!         
!          fxx holds fxxyy and fyy holds fyy      
!         
      call gathij(1,mn,ix,jy,ipt,fxx,fyy,tp2)    
!
      do 550 i=1,mn 
      tp2(i,1)= pix(i,1)*tp2(i,1)    
      tp2(i,2)= pix(i,2)*tp2(i,2)    
      tp2(i,3)= pix(i,3)*tp2(i,3)    
      tp2(i,4)= pix(i,4)*tp2(i,4)    
      tp1(i,1)=tp2(i,1)+tp2(i,2)+tp2(i,3)+tp2(i,4)
  550 continue      
!
      call gathij(0,mn,ix,jy,ipt,fxx,fyy,tp2)    
!
      do 555 i=1,mn 
      tp2(i,1)= pix(i,1)*tp2(i,1)    
      tp2(i,2)= pix(i,2)*tp2(i,2)    
      tp2(i,3)= pix(i,3)*tp2(i,3)    
      tp2(i,4)= pix(i,4)*tp2(i,4)    
      tp1(i,2)=tp2(i,1)+tp2(i,2)+tp2(i,3)+tp2(i,4)
  555 continue      
!         
!          compute fxx        
!         
      do 170 i=1,ijm2         
      fxx(i+1,1)= f(i,1)+f(i+2,1)-2.0*f(i+1,1)  
  170 continue      
!
      do 155 j=1,jy 
      fxx(1,j)= f(ix,j)-2.0*f(1,j)+f(2,j)         
      fxx(ix,j)= f(ix-1,j)-2.0*f(ix,j)+f(1,j)     
  155 continue      
!
      call tpose(fxx,ix,jy,tp3)        
      call trdiph(jy,ix,tp3)
      call tpose(tp3,jy,ix,fxx)        
!         
      call gathij(1,mn,ix,jy,ipt,fxx,f,tp2)      
!
      do 560 i=1,mn 
      tp2(i,1)= pix(i,1)*tp2(i,1)    
      tp2(i,2)= pix(i,2)*tp2(i,2)    
      tp2(i,3)= pix(i,3)*tp2(i,3)    
      tp2(i,4)= pix(i,4)*tp2(i,4)    
      tp1(i,3)=tp2(i,1)+tp2(i,2)+tp2(i,3)+tp2(i,4)
  560 continue      
!
      call gathij(0,mn,ix,jy,ipt,fxx,f,tp2)      
!
      do 570 i=1,mn 
      tp2(i,1)= pix(i,1)*tp2(i,1)    
      tp2(i,2)= pix(i,2)*tp2(i,2)    
      tp2(i,3)= pix(i,3)*tp2(i,3)    
      tp2(i,4)= pix(i,4)*tp2(i,4)    
      tp1(i,4)=tp2(i,1)+tp2(i,2)+tp2(i,3)+tp2(i,4)
!         
!          interpolate in y-direction   
!
      tp1(i,1)= tp1(i,1)*pjy(i,1)    
      tp1(i,2)= tp1(i,2)*pjy(i,2)    
      tp1(i,3)= tp1(i,3)*pjy(i,3)    
      tp1(i,4)= tp1(i,4)*pjy(i,4)    
      dout(i)=tp1(i,1)+tp1(i,2)+tp1(i,3)+tp1(i,4) 
  570 continue      
      return        
      end
      subroutine stupij(xin,yin,mn,ix,pix,pjy,ijpt)         
!         
      dimension xin(mn),yin(mn),pix(mn,4),pjy(mn,4)         
      dimension ijpt(mn)         
!         
      do 20 i=1,mn  
      ipt= int(xin(i))
      jpt= int(yin(i))
      pix(i,3)= xin(i)-float(ipt)         
      pjy(i,3)= yin(i)-float(jpt)         
      pix(i,4)= 1.0-pix(i,3)  
      pjy(i,4)= 1.0-pjy(i,3)  
      ijpt(i)= ipt+ix*jpt
   20 continue      
!         
      do 30 i=1,mn*2
      pix(i,1)= pix(i,3)*(pix(i,3)*pix(i,3)-1.0)   
      pjy(i,1)= pjy(i,3)*(pjy(i,3)*pjy(i,3)-1.0)   
   30 continue      
      return        
      end 
      subroutine trdih (m,n,y)
!         
!  vectorized tri-diagonal gaussian elimintaion solver      
!         
      dimension y(m,n),c(5000) 
!         
! gaussian elimination        
!         
      c(1) = 0.25          
!
      do 201 i=1,m  
      y(i,1)= y(i,1)*c(1)  
  201 continue      
!
      do 103 j=2,n-1 
      c(j)= 1.0/(4.0-c(j-1))
!DIR$ IVDEP
!ocl  novrec
      do 103 i=1,m  
      y(i,j)= (y(i,j)-y(i,j-1))*c(j) 
  103 continue      
!
!DIR$ IVDEP
!ocl  novrec
      do 202 i=1,m  
      y(i,n)=(y(i,n)-y(i,n-1))/(4.0-c(n-1))     
  202 continue      
!         
! backwards substitution      
!         
      do 104 k=n-1,1,-1        
!DIR$ IVDEP
!ocl  novrec
      do 104 i=1,m  
      y(i,k)= y(i,k)-c(k)*y(i,k+1)
  104 continue      
      return        
      end 
      subroutine tpose(x,im,jm,y)       
      dimension x(im,jm),y(jm,im)       
      do 1 i=1,im   
      do 1 j=1,jm   
    1 y(j,i)= x(i,j)
      return        
      end 
      subroutine trdiph (m,n,y)         
!         
!  vectorized periodic gaussian elimination solver
!         
      dimension y(m,n),work(10000) 
!         
! gaussian elimination        
!         
      nt2= 2*n      
      work(n+1)= 0.25         
      v = 1.0       
      work(1) = work(n+1)     
      work(nt2+1) = work(n+1) 
      bn = -v*work(nt2+1)+4.0
      do 101 j=2,n-2
         ne = j+n   
         work(ne) = 1.0/(4.0-work(j-1))
         work(j) = work(ne)   
         nu = j+nt2 
         work(nu) = -work(nu-1)*work(ne)
         v = -v*work(j-1)     
         bn = bn-v*work(nu)   
  101 continue      
!
      v = 1.0-v*work(n-2)     
      ne = nt2      
      work(ne-1) = 1.0/(4.0-work(n-2)) 
      nu = nt2+n    
      work(n-1) = (1.0-work(nu-2))*work(ne-1)      
      work(ne) = 1.0/(bn-v*work(n-1))    
!
      v= 1.0        
!DIR$ IVDEP
!ocl  novrec
      do 201 i=1,m  
      y(i,1)= y(i,1)*work(n+1)
      work(i+3*n)=y(i,n)-v*y(i,1)       
  201 continue      
!
      do 103 j=2,n-2
      v= -v*work(j-1)         
         ne = j+n   
!DIR$ IVDEP
!ocl  novrec
      do 113 i=1,m  
      y(i,j)= (y(i,j)-y(i,j-1))*work(ne)
      work(i+3*n)= work(i+3*n)-v*y(i,j) 
  113 continue      
  103 continue      
      v = 1.0-v*work(n-2)     
      ne = nt2      
!DIR$ IVDEP
!ocl  novrec
      do 203 i=1,m  
      y(i,n-1)=(y(i,n-1)-y(i,n-2))*work(ne-1)       
      work(i+3*n)= work(i+3*n)-v*y(i,n-1)
!         
! backwards substitution      
!         
      y(i,n)= work(i+3*n)*work(ne)      
      y(i,n-1)= y(i,n-1)-work(n-1)*y(i,n)  
  203 continue      
!
      do 104 k=n-2,1,-1
	 nu = k+nt2 
!DIR$ IVDEP
!ocl  novrec
      do 104 i=1,m  
      y(i,k)= y(i,k)-work(k)*y(i,k+1)-work(nu)*y(i,n)       
  104 continue      
      return        
      end 
      subroutine gathij(kp,mn,ix,jy,ijpt,fxx,f,tp2)
!
      dimension fxx(ix*jy),f(ix*jy),tp2(mn,4)
      dimension ijpt(mn)
!
      if(kp.eq.0) then
!
!  lower left corner of interpolation square
!
      do 10 i=1,mn
      inx= ijpt(i)-ix
      tp2(i,2)= fxx(inx)
      tp2(i,4)= f  (inx)
   10 continue
!
      else
!
!  upper left corner of interpolation square
!
      do 20 i=1,mn
      tp2(i,2)= fxx(ijpt(i))
      tp2(i,4)= f  (ijpt(i))
   20 continue
      endif
!
      if(kp.eq.0) then
!  lower right corner of interpolation square
      i1= 1-ix
      else
!  upper right corner of interpolation square
      i1= 1
      endif
!
      do 30 i=1,mn
      inx= ijpt(i)+i1
      if(mod(inx,ix).eq.1) inx= inx-ix
      tp2(i,1)= fxx(inx)
      tp2(i,3)= f  (inx)
   30 continue
!
      return
      end
      subroutine dmsread(nx,my,lrec,lenc,kflag,ifile,z,istat)
!
!  subroutine to read data in pressure level fields
!
! **** input ****
!
!  lrec: field identifaction label
!  lenc: no. of data values in a 2-d lrec field
!  ifile: path/file name containing initial fields
!
! **** output ****
!
!  z: array containing gaussian grid 2-d field
!  istat: status code. .ne. zero means bad read
!
      dimension z(nx,my)
      character lrec*26,ifile*48,kflag*1
!
! working array
!
!      dimension y(lenc)
      character key*34,crmk*88
!
      write(key,1000)lrec,kflag,lenc
 1000 format(a26,a1,i7.7)
!
      call dmsget(ifile,key//char(0),z,istat)
!
      if(istat.ne.0) then
      write(crmk,100) key
  100 format('#######  record ',a34,' missing  ######')
      print*, crmk
      call dmsexit(-1)
      else
      print *,'dms key=',key,' found'
      endif
!
!      do 1 i=1,lenc
!        z(i,1)=y(i)
! 1    continue
!
      return
      end
      subroutine dmswrit(nx,my,lrec,lenc,kflag,ifile,z,istat)
!
!  subroutine to read data in pressure level fields
!
! **** input ****
!
!  lrec: field identifaction label
!  lenc: no. of data values in a 2-d lrec field
!  ifile: path/file name containing initial fields
!
! **** output ****
!
!  z: array containing gaussian grid 2-d field
!  istat: status code. .ne. zero means bad read
!
      dimension z(nx,my)
      character lrec*26,ifile*48,kflag*1
!
! working array
!
!      dimension y(lenc)
      character key*34
!
      write(key,1000)lrec,kflag,lenc
 1000 format(a26,a1,i7.7)
!
!      do 1 i=1,lenc
!        y(i)=z(i,1)
! 1    continue
!
      call dmsput(ifile,key//char(0),z,istat)
!
      if(istat.ne.0)then
        print *,'dmsput key=',key,' error'
        call dmsexit(-1)
      else
        print *,'dmsput key=',key,' ok'
      endif
!
      return
      end

      subroutine syslbl (clrec,idtg,itau,ciflap,cirec)
!
      character*4 ciflap
      character*6 clrec
      character*26 cirec
      integer*8 idtg
!
      write(cirec,1) clrec,itau,ciflap,idtg
 1    format(a6,i4.4,a4,i12.12)
      return
      end

      subroutine gausl3 (n,xa,xb,wt,ab)
!
! weights and abscissas for nth order gaussian quadrature on (xa,xb).
! input arguments
!
! n  -the order desired
! xa -the left endpoint of the interval of integration
! xb -the right endpoint of the interval of integration
! output arguments
! ab -the n calculated abscissas
! wt -the n calculated weights
!
      implicit double precision (a-h,o-z)
!
!fj
!ccc  include '../include/rank.h'
!fj
      real  ab(n) ,wt(n),xa,xb
!
! machine dependent constants---
!  tol - convergence criterion for double precision iteration
!  pi  - given to 15 significant digits
!  c1  -  1/8                     these are coefficients in mcmahon"s
!  c2  -  -31/(2*3*8**2)          expansions of the kth zero of the
!  c3  -  3779/(2*3*5*8**3)       bessel function j0(x) (cf. abramowitz,
!  c4  -  -6277237/(3*5*7*8**5)   handbook of mathematical functions).
!  u   -  (1-(2/pi)**2)/4
!
      data tol/1.d-14/,pi/3.14159265358979/,u/.148678816357662/
      data c1,c2,c3,c4/.125,-.080729166666667,.246028645833333, &
                     -1.82443876720609 /
!
! maximum number of iterations before giving up on convergence
!
      data maxit /5/
!
! arithmetic statement function for converting integer to double
!
      dbli(i) = dble(float(i))
!
      ddif = .5d0*(dble(xb)-dble(xa))
      dsum = .5d0*(dble(xb)+dble(xa))
      if (n .gt. 1) go to 101
      ab(1) = 0.
      wt(1) = 2.*ddif
      go to 107
  101 continue
      nnp1 = n*(n+1)
      cond = 1./sqrt((.5+float(n))**2+u)
      lim = n/2
!
      do 105 k=1,lim
         b = (float(k)-.25)*pi
         bisq = 1./(b*b)
!
! rootbf approximates the kth zero of the bessel function j0(x)
!
         rootbf = b*(1.+bisq*(c1+bisq*(c2+bisq*(c3+bisq*c4))))
!
!      initial guess for kth root of legendre poly p-sub-n(x)
!
         dzero = cos(rootbf*cond)
         do 103 i=1,maxit
!
            dpm2 = 1.d0
            dpm1 = dzero
!
!       recursion relation for legendre polynomials
!
            do 102 nn=2,n
                dp = (dbli(2*nn-1)*dzero*dpm1-dbli(nn-1)*dpm2)/dbli(nn)
                dpm2 = dpm1
                dpm1 = dp
  102       continue
            dtmp = 1.d0/(1.d0-dzero*dzero)
            dppr = dbli(n)*(dpm2-dzero*dp)*dtmp
            dp2pri = (2.d0*dzero*dppr-dbli(nnp1)*dp)*dtmp
            drat = dp/dppr
!
!       cubically-convergent iterative improvement of root
!
            dzeri = dzero-drat*(1.d0+drat*dp2pri/(2.d0*dppr))
            ddum= dabs(dzeri-dzero)
         if (ddum .le. tol) go to 104
            dzero = dzeri
  103    continue
!fj
!ccc     if(myrank .eq. 0) print 504
!fj
  504    format(1x,' in gausl3, convergence failed')
  104    continue
         ddifx = ddif*dzero
         ab(k) = dsum-ddifx
         wt(k) = 2.d0*(1.d0-dzero*dzero)/(dbli(n)*dpm2)**2*ddif
         i = n-k+1
         ab(i) = dsum+ddifx
         wt(i) = wt(k)
  105 continue
!
      if (mod(n,2) .eq. 0) go to 107
      ab(lim+1) = dsum
      nm1 = n-1
      dprod = n
      do 106 k=1,nm1,2
         dprod = dbli(nm1-k)*dprod/dbli(n-k)
  106 continue
      wt(lim+1) = 2.d0/dprod**2*ddif
  107 return
      end
      subroutine vterpj (nx,lmaxp,lev,yr,f,yout,dout,tensy)
!
!          a bicubic spline interpolator to interpolate from a grid
!          with constant i (first dimension) grid spacing and variable
!          j (second dimension) grid spacing t0 a grid with
!          variable grid spacing. all grids are assumed to have point
!          (i,1) in the lower left corner with i increasing to the right
!          and j increasing upward.
!
! **** input ****
!
!  nx: no. of points in e-w direction of input arrays
!  lmaxp: no. of levels in input arrays
!  lev: no. of levels in output arrays
!  yr: independent interpolation variable for input grid
!  f: dependent variable for input grid
!  yout: independent interpolation variable for output grid
!  tensy: cubic spline tension factor.
!
! **** output ****
!
!  dout: dependent variable on output grid
!
      dimension f(nx,lmaxp),dout(nx*lev),yr(nx,lmaxp) &
             , yout(nx*lev),tensy(lmaxp)
!
      dimension fxx(nx,lmaxp),fyy(nx,lmaxp),pjy(nx*lev*4) &
             , tp1(nx*lev*4),ipt(nx*lev)
!
!          compute ipt and pjy
!
      jym2  = lmaxp-2
      nxjym2= nx*jym2
      mn    = nx*lev
!
      call setupv (yr,yout,mn,nx,lmaxp,pjy,ipt,tp1)
!
!          compute fyy
!
      ll= nxjym2+nx
      do 110 i=1,ll
      fxx(i,2)= yr(i,2)-yr(i,1)
  110 continue
!
!CWB2015
!ocl serial
      do 210 i=1,nxjym2
      fyy(i,2)= (fxx(i,3)*(f(i,1)-f(i,2))+fxx(i,2)*(f(i,3) &
               -f(i,2)))/(fxx(i,3)*fxx(i,3)*fxx(i,2))
      fxx(i,2)= fxx(i,2)/fxx(i,3)
  210 continue
!
      call trdivv (nx,jym2,fxx(1,2),fyy(1,2))
!
      do 100 i=1,nx
      fyy(i,1)= 0.0
      fyy(i,lmaxp)= 0.0
  100 continue
!
!  apply tension
!
      do 5 k=1,lmaxp
      do 5 i=1,nx
      fyy(i,k)= fyy(i,k)*tensy(k)
    5 continue
!
      call gathv (mn,nx,lmaxp,ipt,fyy,f,tp1)
!
      i1= mn
      i2= mn*2
      i3= mn*3
      do 130 i=1,mn
      dout(i)= tp1(i)*pjy(i)+tp1(i+i1)*pjy(i+i1)+tp1(i+i2)*pjy(i+i2) &
            + tp1(i+i3)*pjy(i+i3)
  130 continue
      return
      end

      subroutine prexp ( nx,lev,ptop,sig,pt,pk,pk2,plt )
      implicit none
!
!  subroutine to compute p to the kapa on odd and even levels
!
! *** input ****
!
!  nx: e-w dimension no.
!  lev: number of vertical levels
!  sig: sigma levels
!  pt: terrain pressure
!
! *** output ***
!
!  pk: odd (full) level p**capa
!  pk2: even( half) level p**capa
!
! **************************************************
!
!
      real ptop,capa,capap1,opok,ptopk
      integer i,k,nx,lev,kbot,ktop
      real pt(nx),pk2(nx,lev),pk(nx,lev),sig(lev+1),plt(nx,lev)
!
!sun  include '../include/paramt.h'  .. change im to nx
      real pl2(nx,2)
!
!  compute  pressure variables
!
      capa  = 1.0/3.5
      capap1= 1.0+capa
      opok  = 1.0/1000.0**capa
!
      kbot= 1
      k= 1
      ptopk= ptop*opok*ptop**capa
      do 80 i=1, nx
      pl2(i,kbot)= sig(2)*pt(i)+ptop
      pk2(i,1)   = opok*pl2(i,kbot)**capa
      pk(i,k)    = (pl2(i,kbot)*pk2(i,k)-ptopk) &
                / (capap1*(pl2(i,kbot)-ptop))
      plt(i,k)   = 1000.0*pk(i,k)*pk(i,k)*pk(i,k)*sqrt(pk(i,k))
   80 continue
!
      do 90 k = 2, lev
      ktop= kbot
      kbot= 3 - ktop
      do 90 i = 1, nx
      pl2(i,kbot)= sig(k+1)*pt(i)+ptop
      pk2(i,k)   = opok*pl2(i,kbot)**capa
      pk(i,k)    = (pl2(i,kbot)*pk2(i,k)-pl2(i,ktop)*pk2(i,k-1)) &
                / (capap1*(pl2(i,kbot)-pl2(i,ktop)))
      plt(i,k)   = 1000.0*pk(i,k)*pk(i,k)*pk(i,k)*sqrt(pk(i,k))
   90 continue
!
      return
      end
      subroutine setupv (yr,yin,mn,nx,lmaxp,pjy,ipt,tp1)
!
!  setup routine for bicubv parameters.  see bicubv prolog for
!  parameter descriptions
!
      dimension yin(mn),yr(nx,lmaxp),pjy(mn,4),tp1(mn,4)
      dimension ipt(mn)
!
      n= mn/nx
!
!  check out of bounds to ensure interpolation
!
      eps = 1.0e-5
      do 100 i = 1, mn
      ix = i - ((i-1)/nx)*nx
      if ( yin(i).le.yr(ix,1) )      yin(i) = yr(ix,1) + eps
      if ( yin(i).ge.yr(ix,lmaxp) )  yin(i) = yr(ix,lmaxp) - eps
  100 continue
!
      do 10 i=1,nx
      k=1
      do 5 j=1,n
      ii= nx*(j-1)
    6 k= k+1
      if(yin(i+ii).gt.yr(i,k)) go to 6
      ipt(i+ii)= i+nx*(k-1)
      tp1(i+ii,1)= yin(i+ii)-yr(i,k-1)
      tp1(i+ii,2)= yr(i,k)-yr(i,k-1)
      k= k-1
    5 continue
   10 continue
!
      do 90 i=1,mn
      pjy(i,3)= tp1(i,1)/tp1(i,2)
      pjy(i,4)= 1.0-pjy(i,3)
      pjy(i,1)= pjy(i,3)*pjy(i,3)-1.0
      pjy(i,2)= pjy(i,4)*pjy(i,4)-1.0
      pjy(i,1)= pjy(i,1)*tp1(i,1)*tp1(i,2)
      tp1(i,1)= tp1(i,2)-tp1(i,1)
      pjy(i,2)= pjy(i,2)*tp1(i,1)*tp1(i,2)
   90 continue
!
      return
      end

      subroutine trdivv (m,n,a,y)
!sun  subroutine trdivv (m,n,a,c,y)
!
!  tri-diagonal gaussian elimination subroutine call by bicubv
!
      dimension  a(m,n), y(m,n)
      dimension  c(m,n-1)
!
      nm = n-1
      do 201 i=1,m
      c(i,1)= 0.5/(1.0+a(i,1))
      y(i,1) = y(i,1)*c(i,1)
  201 continue
!
! gaussian elimination
!
      do 101 j=2,nm
!dir$ ivdep
      do 101 i=1,m
      c(i,j)= 1.0/(2.0+a(i,j)*(2.0-c(i,j-1)))
      y(i,j) = (y(i,j)-a(i,j)*y(i,j-1))*c(i,j)
  101 continue
!
      do 202 i=1,m
      y(i,n)= (y(i,n)-a(i,n)*y(i,nm))/(2.0+a(i,n)*(2.0-c(i,nm)))
  202 continue
!
! backwards substitution
!
      do 104 k=nm,1,-1
!dir$ ivdep
      do 104 i=1,m
      y(i,k)= y(i,k)-c(i,k)*y(i,k+1)
  104 continue
      return
      end

      subroutine gathv (mn,nx,lev,ipt,fyy,f,tp1)
!
!  sorting routine to find coefficients for cubic splines for each
!  interpolation grid element.  see bicubv for parameter descriptions
!
      dimension fyy(nx*lev),f(nx*lev),tp1(mn,4)
      dimension ipt(mn)
!
      do 20 i=1,mn
      tp1(i,1)= fyy(ipt(i))
      tp1(i,3)= f  (ipt(i))
      inx= ipt(i)-nx
      tp1(i,2)= fyy(inx)
      tp1(i,4)= f  (inx)
   20 continue
!
      return
      end
      subroutine phi2pt(nx,my,lmax,zz,anlslp,t1000,puvphi,sgeo,pt)
!
      dimension sgeo(nx,my),pt(nx,my),zz(nx,my,lmax)
      dimension fld1(nx,lmax+2,my),fld2(nx,lmax+2,my),t1000(nx,my) &
             , anlslp(nx,my),presp(nx,lmax+2,my) &
             , pdiff(nx,my),hld1(nx,my),hld2(nx,my) &
             , tens(lmax+2)
      dimension phistd(lmax),puvphi(lmax)
!
      data cp/1004.24/, grav/9.80616/
!
      capa= 1.0/3.5
      rgas= capa*cp
!
      lmaxp1= lmax + 1
      lmaxp2= lmax + 2
      do 20 k = 1, lmaxp2
      tens(k) = 1.0
  20  continue
      tens(lmaxp2) = 0.0
      tens(1) = 0.0
!
      call geostd ( lmax,puvphi,phistd )
!
!  read geopotential height
!
      do 60 k=1,lmax
      pstdt= log(puvphi(k))
      do 50 j=1,my
      do 50 i=1,nx
      presp(i,k+1,j)= pstdt
      fld2(i,k+1,j)= -grav*zz(i,j,k)
      fld1(i,k+1,j)= -grav*phistd(k)-fld2(i,k+1,j)
  50  continue
  60  continue
!
!  initialization of terrain pressure
!
!  define bottom & top boundary condition for pt interpolation
!
      l1= 1
      alaps= 6.5e-4
      eps = 0.001
      call ttstd ( 1, 1.0, tp00 )
      call ttstd ( 1, puvphi(1), tp01 )
!
      do 130 j=1,my
      do 132 i=1,nx
      hld1(i,j)= anlslp(i,j)
      pt(i,j)  = 0.1
!
! dealing with inconsistency between anlslp and 1000hPa height
! 2009/12/10
      if( fld2(i,lmaxp1,j).gt.0 .and. anlslp(i,j).ge.1000.)then
        pxx = log(hld1(i,j))
        pt(i,j) = fld2(i,lmaxp1,j) &
               +rgas*t1000(i,j)*(pxx-presp(i,lmaxp1,j))
      endif
!
      if(sgeo(i,j).le.-1.0) then
        px= sgeo(i,j)/(rgas*(t1000(i,j)-alaps*0.5*sgeo(i,j)))
        hld1(i,j)= hld1(i,j)*(1.0-px)
        pt(i,j)  =-sgeo(i,j) + 0.1
      endif
  132 continue
      call geostd (nx,hld1(1,j),hld2(1,j))
!
      do 133 i=1,nx
      hld1(i,j) = log(hld1(i,j))
!cc   if ( hld1(i,j) .le. (presp(i,lmaxp1,j)+eps) )  then
      if ( hld1(i,j) .le. presp(i,lmaxp1,j) )  then
        presp(i,lmaxp2,j)= 2.0*presp(i,lmaxp1,j) - presp(i,lmax,j)
        fld2(i,lmaxp2,j) = 2.0*fld2(i,lmaxp1,j) - fld2(i,lmax,j)
        fld1(i,lmaxp2,j) = fld1(i,lmaxp1,j)
      else
        presp(i,lmaxp2,j)= hld1(i,j)
        fld2(i,lmaxp2,j) = pt(i,j)
        fld1(i,lmaxp2,j) =-fld2(i,lmaxp2,j)-grav*hld2(i,j)
      endif
      presp(i,1,j)= log(1.0)
      fld2(i,1,j) = fld2(i,2,j) - rgas*tp00*(presp(i,2,j)-presp(i,1,j))
      fld1(i,1,j) = fld1(i,2,j)
!
      pdiff(i,j)  = -sgeo(i,j)
      if ((sgeo(i,j).le.0.0).and.(sgeo(i,j).ge.(-1.0+eps))) &
       pdiff(i,j)= 0.0
!
  133 continue
!
!  interpolate to get terrain pressure
!  interpolation is of log p - cubic as function of geopotential
!  output is log p in array pt
!
      call vterpj( nx,lmaxp2,l1,fld2(1,1,j),presp(1,1,j),pdiff(1,j) &
                , pt(1,j),tens)
!
      do 135 i=1,nx
      pt(i,j)= exp(pt(i,j))
  135 continue
  130 continue
!
      return
      end
      subroutine geostd (m,pin,phiin)
!
!  table lookup for standard atmosphere geopotentials as a function
!  of pressure.  table has resolution of 10mbs below 100mb, 1mb
!  from 100mbs to 1 mb.  interpolation is linear in log p.
!
!
!  *********************************************************************
!
!
      dimension pin(m),phiin(m)
      dimension phi(230)
!
!     dimension phi(230),phi1(55),phi2(60),phi3(55),phi4(60)
!     equivalence (phi(116),phi3)
!     equivalence (phi(171),phi4)
!
!     equivalence (phi,phi1)
!     equivalence (phi(56),phi2)
!
!     data  phi1/
      data (phi(i),i=1,55) / &
       31055. ,26481. ,23849. ,22000. ,20576. &
      ,19420. ,18442. ,17595. ,16848. ,16180. &
      ,15576. ,15024. ,14516. ,14046. ,13608. &
      ,13199. ,12815. ,12452. ,12110. ,11784. &
      ,11475. ,11180. ,10898. ,10626. ,10363. &
      ,10109. , 9862. , 9623. , 9390. , 9164. &
      , 8944. , 8730. , 8521. , 8317. , 8117. &
      , 7923. , 7733. , 7546. , 7364. , 7185. &
      , 7011. , 6839. , 6671. , 6506. , 6344. &
      , 6185. , 6028. , 5874. , 5723. , 5574. &
      , 5428. , 5284. , 5143. , 5003. , 4865./
!     data  phi2/
      data (phi(i),i=56,115) / &
        4730. , 4596. , 4465. , 4335. , 4206. &
      , 4080. , 3955. , 3832. , 3711. , 3591. &
      , 3472. , 3355. , 3240. , 3125. , 3012. &
      , 2901. , 2790. , 2681. , 2573. , 2466. &
      , 2361. , 2256. , 2153. , 2050. , 1949. &
      , 1849. , 1750. , 1651. , 1554. , 1457. &
      , 1362. , 1267. , 1174. , 1081. ,  988. &
      ,  897. ,  807. ,  717. ,  629. ,  540. &
      ,  453. ,  367. ,  281. ,  195. ,  111. &
      ,   27. ,  -55. , -137. , -219. , -301. &
      , -381. , -461. , -540. , -619. , -698. &
      , -775. , -852. , -928. ,-1004. ,-1080./
!     data  phi3/
      data (phi(i),i=116,170) / &
       47832. ,42451. ,39436. ,37360. ,35786. &
      ,34520. ,33462. ,32554. ,31760. ,31055. &
      ,30421. ,29843. ,29313. ,28824. ,28369. &
      ,27944. ,27546. ,27171. ,26817. ,26481. &
      ,26163. ,25860. ,25571. ,25294. ,25028. &
      ,24775. ,24530. ,24295. ,24068. ,23849. &
      ,23637. ,23433. ,23235. ,23043. ,22856. &
      ,22675. ,22500. ,22329. ,22162. ,22000. &
      ,21842. ,21688. ,21538. ,21391. ,21247. &
      ,21107. ,20970. ,20836. ,20705. ,20576. &
      ,20451. ,20327. ,20206. ,20088. ,19971./
!     data  phi4/
      data (phi(i),i=171,230) / &
       19857. ,19745. ,19634. ,19526. ,19420. &
      ,19315. ,19211. ,19110. ,19010. ,18912. &
      ,18815. ,18720. ,18626. ,18533. ,18442. &
      ,18352. ,18263. ,18176. ,18090. ,18004. &
      ,17920. ,17837. ,17756. ,17675. ,17595. &
      ,17516. ,17439. ,17362. ,17286. ,17211. &
      ,17136. ,17063. ,16991. ,16919. ,16848. &
      ,16778. ,16709. ,16640. ,16572. ,16505. &
      ,16439. ,16373. ,16308. ,16244. ,16180. &
      ,16117. ,16054. ,15993. ,15931. ,15871. &
      ,15810. ,15751. ,15692. ,15634. ,15576. &
      ,15518. ,15461. ,15405. ,15349. ,15294./
!
      do 3 i=1,m
      phix= pin(i)*0.1
      if(pin(i).lt.100.0) phix= max(1.000001,pin(i))
!
      ii= int(phix)
      pw2= phix/float(ii)
      phix= 1.0+1.0/float(ii)
      if(pin(i).lt.100.0) ii= ii+115
!
!      print*,'phi(ii)=',phi(ii)
!      print*,'phi(1+ii)=',phi(1+ii)
!      print*,'log(pw2)=',log(pw2)
!      print*,'log(phix)=',log(phix)
!      print*,'phi(ii),phi(1+ii),phi(ii),log(pw2),log(phix)=',ii,phi(ii)
!     +      ,phi(1+ii),phi(ii),log(pw2),log(phix)
      phiin(i)= phi(ii)+(phi(1+ii)-phi(ii))*log(pw2)/log(phix)
    3 continue
      return
      end
      subroutine ttstd (m,pin,ttin)
!
!  table lookup for standard atmosphere temperature as a function
!  of pressure.  table has resolution of 10 mbs below 100mb, 1mb
!  from 100 to 1 mb. interpolation is linear in log p.
!
!
! *****************************************************************
!
      dimension pin(m),ttin(m)
      dimension tt(220),tt3(70),tt4(40)
      equivalence (tt(111),tt3)
      equivalence (tt(181),tt4)
      dimension tt1(70),tt2(40)
      equivalence (tt,tt1)
      equivalence (tt(71),tt2)
!
      data tt1/ &
       227.7088 ,223.1353 ,220.5026 ,218.6536 ,217.2301 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,217.3175 ,219.0844 ,220.7927 &
      ,222.4464 ,224.0495 ,225.6052 ,227.1165 ,228.5862 &
      ,230.0167 ,231.4104 ,232.7692 ,234.0951 ,235.3898 &
      ,236.6548 ,237.8917 ,239.1019 ,240.2865 ,241.4467 &
      ,242.5838 ,243.6985 ,244.7920 ,245.8651 ,246.9186 &
      ,247.9533 ,248.9700 ,249.9693 ,250.9519 ,251.9184 &
      ,252.8693 ,253.8053 ,254.7268 ,255.6343 ,256.5284 &
      ,257.4093 ,258.2776 ,259.1337 ,259.9779 ,260.8106 &
      ,261.6321 ,262.4428 ,263.2430 ,264.0329 ,264.8129 &
      ,265.5833 ,266.3442 ,267.0961 ,267.8390 ,268.5733/
      data tt2/ &
       269.2991 ,270.0166 ,270.7262 ,271.4279 ,272.1220 &
      ,272.8087 ,273.4880 ,274.1603 ,274.8256 ,275.4841 &
      ,276.1360 ,276.7814 ,277.4205 ,278.0533 ,278.6801 &
      ,279.3010 ,279.9160 ,280.5253 ,281.1291 ,281.7274 &
      ,282.3203 ,282.9080 ,283.4905 ,284.0679 ,284.6405 &
      ,285.2081 ,285.7710 ,286.3292 ,286.8828 ,287.4319 &
      ,287.9766 ,288.5170 ,289.0530 ,289.5849 ,290.1126 &
      ,290.6363 ,291.1560 ,291.6718 ,292.1837 ,292.6918/
      data tt3/ &
       272.0700 ,258.3600 ,249.7100 ,243.3700 ,238.6400 & 
      ,235.7700 ,233.3300 ,231.2300 ,229.3700 ,227.7100 &
      ,227.0744 ,226.4968 ,225.9667 ,225.4771 ,225.0222 &
      ,224.5975 ,224.1993 ,223.8245 ,223.4705 ,223.1353 &
      ,222.8168 ,222.5136 ,222.2243 ,221.9476 ,221.6826 &
      ,221.4282 ,221.1837 ,220.9484 ,220.7216 ,220.5026 &
      ,220.2911 ,220.0865 ,219.8883 ,219.6963 ,219.5099 &
      ,219.3290 ,219.1532 ,218.9822 ,218.8157 ,218.6536 &
      ,218.4956 ,218.3416 ,218.1912 ,218.0444 ,217.9011 &
      ,217.7609 ,217.6239 ,217.4898 ,217.3586 ,217.2301 &
      ,217.1042 ,216.9808 ,216.8599 ,216.7413 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500/
      data tt4/ &
       216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500 &
      ,216.6500 ,216.6500 ,216.6500 ,216.6500 ,216.6500/
!
!
      do 3 i=1,m
      ttx= pin(i)*0.1
      if(pin(i).lt.100.0) ttx= max(1.0000001,pin(i))
!
      ii= int(ttx)
      pw2= ttx/float(ii)
      ttx= 1.0+1.0/float(ii)
      if(pin(i).lt.100.0) ii= ii+110
    3 ttin(i)= tt(ii)+(tt(ii+1)-tt(ii))*log(pw2)/log(ttx)
      return
      end
	subroutine qsatq (imjm,tqs,pqs,qss)
!
!  vectorized saturation specific humidity subroutine
!  algorithm is table-lookup.
!
!  formal parameters:
!
! **** input ****
!
!  tqs:  input temperatures
!  pqs:  input pressures
!  imjm:  number of elements in input arrays
!
! **** output ****
!
!  qss:  output saturation specific humidity
!
      dimension tqs(imjm),pqs(imjm),qss(imjm)
      dimension vpsat(191)
!
!
! est1 are the saturated vapor pressure over ice for the temperatures
!      -90.0 to -40.0 degrees c in one degree increments.
! est3 are the saturated vapor pressures over water for the temperatures
!      0 to 100 degrees c in one degree increments.
! est2 are the saturated vapor pressures over water and ice for the
!      temperatures -39 to -1 degeegs c linearly interpolated assuming
!      total ice at -40.0 degrees and total water at 0 degrees.
!
! the saturated values are obtained from the smithsonian meteorological
! tables, sixth revised edition (1971) page 350 using the goff-gratch
! formulation for saturated vapor pressure.
!
      data vpsat/ &
         9.67165e-05,  1.15983e-04,  1.38819e-04,  1.65835e-04, &
         1.97736e-04,  2.35339e-04,  2.79584e-04,  3.31553e-04, &
         3.92489e-04,  4.63820e-04,  5.47177e-04,  6.44430e-04, &
         7.57710e-04,  8.89450e-04,  1.04242e-03,  1.21975e-03, &
         1.42503e-03,  1.66230e-03,  1.93614e-03,  2.25172e-03, &
         2.61488e-03,  3.03222e-03,  3.51113e-03,  4.05995e-03, &
         4.68804e-03,  5.40589e-03,  6.22523e-03,  7.15922e-03, &
         8.22253e-03,  9.43153e-03,  1.08045e-02,  1.23617e-02, &
         1.41258e-02,  1.61219e-02,  1.83779e-02,  2.09244e-02, &
         2.37959e-02,  2.70300e-02,  3.06684e-02,  3.47573e-02, &
         3.93475e-02,  4.44947e-02,  5.02607e-02,  5.67130e-02, &
         6.39258e-02,  7.19807e-02,  8.09670e-02,  9.09823e-02, &
         1.02134e-01,  1.14538e-01,  1.28323e-01,               &
!
                       1.45280e-01,  1.64189e-01,  1.85241e-01, &
         2.08643e-01,  2.34615e-01,  2.63398e-01,  2.95248e-01, &
         3.30441e-01,  3.69270e-01,  4.12053e-01,  4.59124e-01, &
         5.10843e-01,  5.67591e-01,  6.29773e-01,  6.97819e-01, &
         7.72185e-01,  8.53352e-01,  9.41827e-01,  1.03814e+00, &
         1.14287e+00,  1.25659e+00,  1.37992e+00,  1.51352e+00, &
         1.65806e+00,  1.81424e+00,  1.98279e+00,  2.16447e+00, &
         2.36006e+00,  2.57039e+00,  2.79628e+00,  3.03858e+00, &
         3.29819e+00,  3.57599e+00,  3.87289e+00,  4.18982e+00, &
         4.52773e+00,  4.88753e+00,  5.27019e+00,  5.67664e+00, & 
!
         6.10780e+00,  6.56617e+00,  7.05475e+00,  7.57526e+00, &
         8.12946e+00,  8.71922e+00,  9.34647e+00,  1.00132e+01, &
         1.07216e+01,  1.14739e+01,  1.22723e+01,  1.31192e+01, &
         1.40172e+01,  1.49688e+01,  1.59767e+01,  1.70438e+01, &
         1.81729e+01,  1.93672e+01,  2.06298e+01,  2.19639e+01, &
         2.33729e+01,  2.48605e+01,  2.64302e+01,  2.80858e+01, &
         2.98314e+01,  3.16708e+01,  3.36085e+01,  3.56487e+01, &
         3.77959e+01,  4.00548e+01,  4.24303e+01,  4.49274e+01, &
         4.75511e+01,  5.03069e+01,  5.32001e+01,  5.62365e+01, &
         5.94220e+01,  6.27625e+01,  6.62643e+01,  6.99337e+01, &
!
         7.37774e+01,  7.78022e+01,  8.20150e+01,  8.64231e+01, &
         9.10338e+01,  9.58548e+01,  1.00894e+02,  1.06159e+02, &
         1.11659e+02,  1.17401e+02,  1.23395e+02,  1.29650e+02, &
         1.36174e+02,  1.42978e+02,  1.50070e+02,  1.57461e+02, &
         1.65161e+02,  1.73180e+02,  1.81529e+02,  1.90218e+02, &
         1.99260e+02,  2.08665e+02,  2.18446e+02,  2.28613e+02, &
         2.39180e+02,  2.50159e+02,  2.61562e+02,  2.73404e+02, &
         2.85696e+02,  2.98453e+02,  3.11689e+02,  3.25418e+02, &
         3.39655e+02,  3.54414e+02,  3.69711e+02,  3.85560e+02, &
         4.01979e+02,  4.18982e+02,  4.36586e+02,  4.54808e+02, &
!
         4.73665e+02,  4.93175e+02,  5.13354e+02,  5.34221e+02, &
         5.55795e+02,  5.78093e+02,  6.01135e+02,  6.24940e+02, &
         6.49527e+02,  6.74918e+02,  7.01131e+02,  7.28188e+02, &
         7.56110e+02,  7.84918e+02,  8.14633e+02,  8.45278e+02, &
         8.76876e+02,  9.09448e+02,  9.43018e+02,  9.77609e+02, &
         1.01325e+03/
!
      tem = 1.0/1.622
      do 100 i=1,imjm
      t1 = max(1.00001, min(190.999, tqs(i)-182.16))
      ic = int(t1)
      qqq = min(tem*pqs(i), vpsat(ic)+(vpsat(1+ic)-vpsat(ic)) &
                                    *(t1-float(ic)))
      qss(i) = 0.622*qqq/(pqs(i)-qqq)
  100 continue
      return
      end

      subroutine dmsreadi(nx,my,lrec,lenc,kflag,ifile,z,istat)
!
!  subroutine to read data in pressure level fields
!
! **** input ****
!
!  lrec: field identifaction label
!  lenc: no. of data values in a 2-d lrec field
!  ifile: path/file name containing initial fields
!
! **** output ****
!
!  z: array containing gaussian grid 2-d field
!  istat: status code. .ne. zero means bad read
!
      integer z(nx,my)
      character lrec*26,ifile*48,kflag*1
!
      character key*34,crmk*88
!
      write(key,1000)lrec,kflag,lenc
 1000 format(a26,a1,i7.7)
!
      call dmsget(ifile,key//char(0),z,istat)
!
      if(istat.ne.0) then
!
      write(crmk,100) key
  100 format('#######  record ',a34,' missing  ######')
      print*, crmk
      call dmsexit(-1)
      else
      print *,'dms key=',key,' found'
      endif
!
      return
      end

      subroutine dmswriti(nx,my,lrec,lenc,kflag,ifile,z,istat)
!
!  subroutine to read data in pressure level fields
!
! **** input ****
!
!  lrec: field identifaction label
!  lenc: no. of data values in a 2-d lrec field
!  ifile: path/file name containing initial fields
!
! **** output ****
!
!  z: array containing gaussian grid 2-d field
!  istat: status code. .ne. zero means bad read
!
      integer z(nx,my)
      character lrec*26,ifile*48,kflag*1
!
! working array
!
!      dimension y(lenc)
      character key*34
!
      write(key,1000)lrec,kflag,lenc
 1000 format(a26,a1,i7.7)
!
!      do 1 i=1,lenc
!        y(i)=z(i,1)
! 1    continue
!
      call dmsput(ifile,key//char(0),z,istat)
!
      if(istat.ne.0)then
        print *,'dmsput key=',key,' error'
        call dmsexit(-1)
      else
        print *,'dmsput key=',key,' ok'
      endif
!
      return
      end
