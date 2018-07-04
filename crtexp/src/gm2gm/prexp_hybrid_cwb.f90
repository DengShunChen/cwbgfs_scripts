      subroutine prexp_hybrid_cwb (nxj,nx,lev,ptop,sigma,pt,pk,pk2,plt)
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
      dimension pt(nx),pk2(nx,lev),pk(nx,lev),sigma(lev+1,2),plt(nx,lev)
!
!sun  include '../include/paramt.h'  .. change im to nx
      dimension pl2(nx,2)
!
!  compute  pressure variables
!
      capa  = 1.0/3.5
      capap1= 1.0+capa
      opok  = 1.0/1000.0**capa
!
!ibm---beg
!     kbot= 1
!     k= 1
!     ptopk= ptop*opok*ptop**capa
!     do 80 i=1, nxj
!     pl2(i,kbot)= sig(2)*pt(i)+ptop
!     pk2(i,k)   = opok*pl2(i,kbot)**capa
!     pk(i,k)    = (pl2(i,kbot)*pk2(i,k)-ptopk)
!    1           / (capap1*(pl2(i,kbot)-ptop))
!     plt(i,k)   = 1000.0*pk(i,k)*pk(i,k)*pk(i,k)*sqrt(pk(i,k))
!  80 continue
!
!     do 90 k = 2, lev
!     ktop= kbot
!     kbot= 3 - ktop
!     do 90 i = 1, nxj
!     pl2(i,kbot)= sig(k+1)*pt(i)+ptop
!     pk2(i,k)   = opok*pl2(i,kbot)**capa
!     pk(i,k)    = (pl2(i,kbot)*pk2(i,k)-pl2(i,ktop)*pk2(i,k-1))
!    1           / (capap1*(pl2(i,kbot)-pl2(i,ktop)))
!     plt(i,k)   = 1000.0*pk(i,k)*pk(i,k)*pk(i,k)*sqrt(pk(i,k))
!  90 continue
!---
      ptopk= ptop*opok*ptop**capa

      do k=1,lev
      do i=1,nxj
      pk2(i,k)= sigma(k+1,1)*pt(i)+sigma(k+1,2)+ptop
!      pk2(i,k)= sig(k+1)*pt(i)+ptop
      enddo
      call vlog(pk2(1,k),pk2(1,k),nxj)
      enddo
!
      do k=1,lev
      do i=1,nxj
      pk2(i,k)=capa*pk2(i,k)
      enddo
      call vexp(pk2(1,k),pk2(1,k),nxj)
      enddo

      kbot= 1
      k= 1
      do 80 i=1, nxj
      pl2(i,kbot)= sigma(2,1)*pt(i)+sigma(2,2)+ptop
!      pl2(i,kbot)= sig(2)*pt(i)+ptop
      pk2(i,k)   = opok*pk2(i,k)
      pk(i,k)    = (pl2(i,kbot)*pk2(i,k)-ptopk)/ & 
                   (capap1*(pl2(i,kbot)-ptop))
      plt(i,k)   = 1000.0*pk(i,k)*pk(i,k)*pk(i,k)*sqrt(pk(i,k))
   80 continue
!
      do 90 k = 2, lev
      ktop= kbot
      kbot= 3 - ktop
      do 90 i = 1, nxj
      pl2(i,kbot)= sigma(k+1,1)*pt(i)+sigma(k+1,2)+ptop
!      pl2(i,kbot)= sig(k+1)*pt(i)+ptop
      pk2(i,k)   = opok*pk2(i,k)
      pk(i,k)    = (pl2(i,kbot)*pk2(i,k)-pl2(i,ktop)*pk2(i,k-1)) &
                / (capap1*(pl2(i,kbot)-pl2(i,ktop)))
      plt(i,k)   = 1000.0*pk(i,k)*pk(i,k)*pk(i,k)*sqrt(pk(i,k))
   90 continue
!ibm---end
!
      return
      end
